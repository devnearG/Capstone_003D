"""Administrator-only question, plan, assignment, audit and payment endpoints."""
import uuid
from typing import Optional

from fastapi import APIRouter, Depends, File, UploadFile
from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentUser, get_db, require_admin
from app.core.errors import APIError
from app.core.security import now_utc
from app.integrations.storage import upload_bytes
from app.models import (
    Assessment, ConsultantAssignment, Organization, Payment, Question, QuestionTranslation, User, AuditLog
)
from app.schemas.admin import (
    AdminConsultantOut, AdminOrganizationOut, AdminUserOut, AssignmentCreate, AssignmentOut,
    AuditLogOut, PaymentAdminOut, OrganizationStatusUpdate, PlanUpdate, UserRoleUpdate, UserStatusUpdate,
    QuestionAdminOut, QuestionCreate, QuestionUpdate, ReconcilePayment, ManualPaymentCreate,
)
from app.services import audit_service
from app.services.consultant_service import _assessment_maturity, _assessment_progress

router = APIRouter(prefix="/admin", tags=["admin"])


async def _question_out(db: AsyncSession, question: Question) -> QuestionAdminOut:
    translations = (
        await db.execute(
            select(QuestionTranslation).where(QuestionTranslation.question_id == question.id)
        )
    ).scalars().all()
    return QuestionAdminOut(
        id=question.id, module=question.module, area_key=question.area_key,
        block_id=question.block_id, code=question.code, position=question.position,
        dimension=question.dimension, vector_type=question.vector_type,
        weight=question.weight, readiness=question.readiness, status=question.status,
        translations=[{
            "locale": t.locale, "text": t.text, "block_title": t.block_title
        } for t in translations],
    )


@router.get("/organizations", response_model=list[AdminOrganizationOut])
async def list_admin_organizations(
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    organizations = (
        await db.execute(select(Organization).order_by(Organization.created_at.desc()))
    ).scalars().all()
    result = []
    for organization in organizations:
        member_count = await db.scalar(
            select(func.count(User.id)).where(User.organization_id == organization.id)
        )
        assignment = await db.execute(
            select(ConsultantAssignment, User.full_name)
            .join(User, ConsultantAssignment.consultant_id == User.id)
            .where(
                ConsultantAssignment.organization_id == organization.id,
                ConsultantAssignment.status == "active",
            )
            .limit(1)
        )
        assignment_row = assignment.first()
        assessment = (
            await db.execute(
                select(Assessment)
                .where(Assessment.organization_id == organization.id)
                .order_by(Assessment.created_at.desc())
                .limit(1)
            )
        ).scalar_one_or_none()
        progress = await _assessment_progress(db, assessment.id) if assessment else 0
        maturity_score = await _assessment_maturity(db, assessment.id) if assessment else None
        result.append(AdminOrganizationOut(
            id=organization.id,
            name=organization.name,
            sector=organization.sector,
            size=organization.size,
            plan=organization.plan,
            status=organization.status,
            created_at=organization.created_at,
            member_count=member_count or 0,
            max_members=50 if organization.plan == "pro" else 5,
            progress=progress,
            maturity_score=maturity_score,
            consultant_id=assignment_row[0].consultant_id if assignment_row else None,
            consultant_name=assignment_row[1] if assignment_row else None,
        ))
    return result


@router.get("/users", response_model=list[AdminUserOut])
async def list_admin_users(
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    rows = (
        await db.execute(
            select(User, Organization.name)
            .outerjoin(Organization, User.organization_id == Organization.id)
            .order_by(User.created_at.desc())
        )
    ).all()
    return [
        _admin_user_schema(user, organization_name)
        for user, organization_name in rows
    ]


def _admin_user_schema(user: User, organization_name: Optional[str]) -> AdminUserOut:
    return AdminUserOut(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        role=user.role,
        organization_id=user.organization_id,
        organization_name=organization_name,
        status="inactive" if user.status == "disabled" else user.status,
        created_at=user.created_at,
        last_active_at=user.updated_at,
    )


async def _admin_user_out(db: AsyncSession, user: User) -> AdminUserOut:
    organization_name = None
    if user.organization_id:
        organization_name = await db.scalar(
            select(Organization.name).where(Organization.id == user.organization_id)
        )
    return _admin_user_schema(user, organization_name)


@router.get("/consultants", response_model=list[AdminConsultantOut])
async def list_admin_consultants(
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    consultants = (
        await db.execute(select(User).where(User.role == "consultant").order_by(User.created_at))
    ).scalars().all()
    result = []
    for consultant in consultants:
        assignments = (
            await db.execute(
                select(ConsultantAssignment.organization_id, Organization.name)
                .join(Organization, ConsultantAssignment.organization_id == Organization.id)
                .where(
                    ConsultantAssignment.consultant_id == consultant.id,
                    ConsultantAssignment.status == "active",
                )
            )
        ).all()
        result.append(AdminConsultantOut(
            id=consultant.id,
            email=consultant.email,
            full_name=consultant.full_name,
            assigned_org_ids=[row[0] for row in assignments],
            assigned_org_names=[row[1] for row in assignments],
            active_reviews=len(assignments),
            status="offline" if consultant.status != "active" else "available",
        ))
    return result


@router.get("/questions", response_model=list[QuestionAdminOut])
async def list_questions(
    current: CurrentUser = Depends(require_admin), db: AsyncSession = Depends(get_db)
):
    questions = (await db.execute(select(Question).order_by(Question.module, Question.position))).scalars().all()
    return [await _question_out(db, q) for q in questions]


@router.post("/questions", response_model=QuestionAdminOut, status_code=201)
async def create_question(
    payload: QuestionCreate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    question = Question(**payload.model_dump(exclude={"translations"}))
    db.add(question)
    await db.flush()
    for translation in payload.translations:
        db.add(QuestionTranslation(question_id=question.id, **translation.model_dump()))
    await audit_service.record(db, "question.created", current.id, "question", question.id)
    return await _question_out(db, question)


@router.patch("/questions/{question_id}", response_model=QuestionAdminOut)
async def update_question(
    question_id: uuid.UUID,
    payload: QuestionUpdate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    question = await db.get(Question, question_id)
    if question is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Pregunta no encontrada.")
    data = payload.model_dump(exclude_unset=True, exclude={"translations"})
    for field, value in data.items():
        setattr(question, field, value)
    if payload.translations is not None:
        old = (await db.execute(
            select(QuestionTranslation).where(QuestionTranslation.question_id == question.id)
        )).scalars().all()
        for translation in old:
            await db.delete(translation)
        for translation in payload.translations:
            db.add(QuestionTranslation(question_id=question.id, **translation.model_dump()))
    await db.flush()
    await audit_service.record(db, "question.updated", current.id, "question", question.id)
    return await _question_out(db, question)


@router.post("/questions/publish-all", response_model=dict)
async def publish_all_questions(
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    questions = (await db.execute(select(Question).where(Question.status == "draft"))).scalars().all()
    for question in questions:
        question.status = "published"
    await db.flush()
    await audit_service.record(
        db, "question.bulk_published", current.id, "question-bank", None,
        {"published": len(questions)},
    )
    return {"published": len(questions)}


@router.patch("/organizations/{organization_id}/plan", response_model=dict)
async def update_plan(
    organization_id: uuid.UUID,
    payload: PlanUpdate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    org = await db.get(Organization, organization_id)
    if org is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Organización no encontrada.")
    org.plan = payload.plan
    await audit_service.record(
        db, "organization.plan_updated", current.id, "organization", organization_id,
        {"plan": payload.plan},
    )
    return {"organization_id": organization_id, "plan": payload.plan}


@router.patch("/organizations/{organization_id}/status", response_model=dict)
async def update_organization_status(
    organization_id: uuid.UUID,
    payload: OrganizationStatusUpdate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    organization = await db.get(Organization, organization_id)
    if organization is None:
        raise APIError(404, "ORGANIZATION_NOT_FOUND", "Organización no encontrada.")
    organization.status = payload.status
    await audit_service.record(
        db, "organization.status_updated", current.id, "organization", organization_id,
        {"status": payload.status},
    )
    await db.commit()
    return {"organization_id": organization_id, "status": organization.status}


@router.patch("/users/{user_id}/role", response_model=AdminUserOut)
async def update_user_role(
    user_id: uuid.UUID,
    payload: UserRoleUpdate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if user is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Usuario no encontrado.")
    user.role = payload.role
    await audit_service.record(
        db, "user.role_updated", current.id, "user", user_id, {"role": payload.role}
    )
    await db.refresh(user)
    return await _admin_user_out(db, user)


@router.patch("/users/{user_id}/status", response_model=AdminUserOut)
async def update_user_status(
    user_id: uuid.UUID,
    payload: UserStatusUpdate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if user is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Usuario no encontrado.")
    user.status = payload.status
    await audit_service.record(
        db, "user.status_updated", current.id, "user", user_id, {"status": payload.status}
    )
    await db.refresh(user)
    return await _admin_user_out(db, user)


@router.post("/consultant-assignments", response_model=AssignmentOut, status_code=201)
async def assign_consultant(
    payload: AssignmentCreate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    if await db.get(Organization, payload.organization_id) is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Organización no encontrada.")
    consultant = await db.get(User, payload.consultant_id)
    if consultant is None or consultant.role != "consultant":
        raise APIError(422, "CONSULTANT_REQUIRED", "El usuario debe tener rol consultor.")
    assignment = (await db.execute(select(ConsultantAssignment).where(
        ConsultantAssignment.organization_id == payload.organization_id,
        ConsultantAssignment.consultant_id == payload.consultant_id,
    ))).scalar_one_or_none()
    if assignment is None:
        assignment = ConsultantAssignment(**payload.model_dump(), assigned_by=current.id)
        db.add(assignment)
    else:
        assignment.status = "active"
        assignment.assigned_by = current.id
    await db.flush()
    await audit_service.record(db, "consultant.assignment_updated", current.id, "organization", payload.organization_id)
    return AssignmentOut.model_validate(assignment)


@router.delete("/consultant-assignments/{assignment_id}", status_code=204)
async def revoke_consultant(
    assignment_id: uuid.UUID,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    assignment = await db.get(ConsultantAssignment, assignment_id)
    if assignment is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Asignación no encontrada.")
    assignment.status = "revoked"
    await audit_service.record(db, "consultant.assignment_revoked", current.id, "assignment", assignment_id)


@router.get("/audit", response_model=list[AuditLogOut])
async def list_audit_logs(
    current: CurrentUser = Depends(require_admin), db: AsyncSession = Depends(get_db)
):
    rows = (
        await db.execute(
            select(AuditLog, User.email)
            .outerjoin(User, AuditLog.actor_id == User.id)
            .order_by(AuditLog.created_at.desc())
            .limit(200)
        )
    ).all()
    result = []
    for row, actor_email in rows:
        audit_log = AuditLogOut.model_validate(row)
        audit_log.actor_email = actor_email
        result.append(audit_log)
    return result


@router.get("/payments", response_model=list[PaymentAdminOut])
async def list_payments(
    current: CurrentUser = Depends(require_admin), db: AsyncSession = Depends(get_db)
):
    rows = (await db.execute(select(Payment).order_by(Payment.created_at.desc()).limit(200))).scalars().all()
    result = []
    for payment in rows:
        organization = await db.get(Organization, payment.organization_id)
        result.append(PaymentAdminOut(
            payment_id=payment.id, organization_id=payment.organization_id,
            organization_name=organization.name if organization else None,
            amount=float(payment.amount), currency=payment.currency,
            provider=payment.provider, provider_ref=payment.provider_ref,
            status=payment.status, reconciliation_status=payment.reconciliation_status,
            proof_filename=payment.proof_filename, created_at=payment.created_at,
            reconciled_at=payment.reconciled_at,
        ))
    return result


@router.post("/payments", response_model=PaymentAdminOut, status_code=201)
async def create_manual_payment(
    payload: ManualPaymentCreate,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    organization = await db.get(Organization, payload.organization_id)
    if organization is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Organización no encontrada.")
    payment = Payment(
        organization_id=payload.organization_id,
        amount=payload.amount,
        currency=payload.currency.upper(),
        provider=payload.provider,
        provider_ref=payload.provider_ref,
        status="pending",
        reconciliation_status="pending",
    )
    db.add(payment)
    await db.flush()
    await audit_service.record(
        db, "payment.created", current.id, "payment", payment.id,
        {"organization_id": str(payload.organization_id), "amount": payload.amount},
    )
    return PaymentAdminOut(
        payment_id=payment.id, organization_id=payment.organization_id,
        organization_name=organization.name, amount=float(payment.amount),
        currency=payment.currency, provider=payment.provider,
        provider_ref=payment.provider_ref, status=payment.status,
        reconciliation_status=payment.reconciliation_status,
        proof_filename=payment.proof_filename, created_at=payment.created_at,
    )


@router.post("/payments/{payment_id}/proof", response_model=PaymentAdminOut)
async def upload_payment_proof(
    payment_id: uuid.UUID,
    file: UploadFile = File(...),
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    payment = await db.get(Payment, payment_id)
    if payment is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Pago no encontrado.")
    data = await file.read()
    if len(data) > 10 * 1024 * 1024:
        raise APIError(413, "FILE_TOO_LARGE", "El comprobante supera 10 MB.")
    payment.proof_storage_key = await upload_bytes(data, file.filename or "proof", file.content_type or "application/octet-stream")
    payment.proof_filename = file.filename
    payment.reconciliation_status = "pending"
    await audit_service.record(db, "payment.proof_uploaded", current.id, "payment", payment_id)
    return PaymentAdminOut(
        payment_id=payment.id, organization_id=payment.organization_id, amount=float(payment.amount),
        currency=payment.currency, provider=payment.provider, provider_ref=payment.provider_ref,
        status=payment.status, reconciliation_status=payment.reconciliation_status,
        proof_filename=payment.proof_filename, created_at=payment.created_at,
    )


@router.patch("/payments/{payment_id}/reconcile", response_model=PaymentAdminOut)
async def reconcile_payment(
    payment_id: uuid.UUID,
    payload: ReconcilePayment,
    current: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    payment = await db.get(Payment, payment_id)
    if payment is None:
        raise APIError(404, "RESOURCE_NOT_FOUND", "Pago no encontrado.")
    payment.reconciliation_status = payload.status
    payment.reconciled_at = now_utc()
    payment.reconciled_by = current.id
    if payload.status == "reconciled":
        payment.status = "succeeded"
        organization = await db.get(Organization, payment.organization_id)
        if organization is not None:
            organization.plan = "pro"
            await db.execute(
                update(Assessment)
                .where(
                    Assessment.organization_id == organization.id,
                    Assessment.plan == "free",
                )
                .values(plan="pro")
            )
    await audit_service.record(
        db, "payment.reconciled", current.id, "payment", payment_id, {"status": payload.status}
    )
    return PaymentAdminOut(
        payment_id=payment.id, organization_id=payment.organization_id, amount=float(payment.amount),
        currency=payment.currency, provider=payment.provider, provider_ref=payment.provider_ref,
        status=payment.status, reconciliation_status=payment.reconciliation_status,
        proof_filename=payment.proof_filename, created_at=payment.created_at,
        reconciled_at=payment.reconciled_at,
    )
