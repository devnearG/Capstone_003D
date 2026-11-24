"""Administrative API contracts."""
import uuid
from datetime import datetime
from typing import Dict, List, Optional

from pydantic import BaseModel, ConfigDict, Field


class TranslationIn(BaseModel):
    locale: str = Field(min_length=2, max_length=2)
    text: str = Field(min_length=1)
    block_title: Optional[str] = None


class QuestionCreate(BaseModel):
    module: str
    area_key: Optional[str] = None
    block_id: str
    code: str
    position: int = 0
    dimension: Optional[str] = None
    vector_type: Optional[str] = None
    weight: Optional[int] = None
    readiness: Optional[int] = None
    status: str = Field(default="published", pattern="^(published|draft)$")
    translations: List[TranslationIn] = Field(default_factory=list)


class QuestionUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    module: Optional[str] = None
    area_key: Optional[str] = None
    block_id: Optional[str] = None
    code: Optional[str] = None
    position: Optional[int] = None
    dimension: Optional[str] = None
    vector_type: Optional[str] = None
    weight: Optional[int] = None
    readiness: Optional[int] = None
    status: Optional[str] = Field(default=None, pattern="^(published|draft)$")
    translations: Optional[List[TranslationIn]] = None


class QuestionAdminOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    module: str
    area_key: Optional[str]
    block_id: str
    code: str
    position: int
    dimension: Optional[str]
    vector_type: Optional[str]
    weight: Optional[int]
    readiness: Optional[int]
    status: str
    translations: List[TranslationIn]


class PlanUpdate(BaseModel):
    plan: str = Field(pattern="^(free|pro)$")


class OrganizationStatusUpdate(BaseModel):
    status: str = Field(pattern="^(active|suspended)$")


class UserRoleUpdate(BaseModel):
    role: str = Field(pattern="^(client|consultant|admin)$")


class UserStatusUpdate(BaseModel):
    status: str = Field(pattern="^(active|disabled)$")


class AssignmentCreate(BaseModel):
    organization_id: uuid.UUID
    consultant_id: uuid.UUID


class AssignmentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    organization_id: uuid.UUID
    consultant_id: uuid.UUID
    status: str


class AdminOrganizationOut(BaseModel):
    id: uuid.UUID
    name: str
    sector: Optional[str] = None
    size: Optional[str] = None
    plan: str
    status: str
    created_at: datetime
    member_count: int
    max_members: int
    progress: int = 0
    maturity_score: Optional[float] = None
    consultant_id: Optional[uuid.UUID] = None
    consultant_name: Optional[str] = None


class AdminUserOut(BaseModel):
    id: uuid.UUID
    email: str
    full_name: Optional[str] = None
    role: str
    organization_id: Optional[uuid.UUID] = None
    organization_name: Optional[str] = None
    status: str
    created_at: datetime
    last_active_at: datetime


class AdminConsultantOut(BaseModel):
    id: uuid.UUID
    email: str
    full_name: Optional[str] = None
    assigned_org_ids: List[uuid.UUID]
    assigned_org_names: List[str]
    completed_reviews: int = 0
    active_reviews: int
    rating: float = 0
    status: str


class AuditLogOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    actor_id: Optional[uuid.UUID]
    actor_email: Optional[str] = None
    action: str
    resource_type: Optional[str]
    resource_id: Optional[str]
    details: Dict
    ip_address: Optional[str]
    created_at: datetime


class ReconcilePayment(BaseModel):
    status: str = Field(pattern="^(reconciled|rejected)$")


class ManualPaymentCreate(BaseModel):
    organization_id: uuid.UUID
    amount: float = Field(gt=0)
    currency: str = Field(min_length=3, max_length=3)
    provider: str = Field(default="manual", min_length=1, max_length=20)
    provider_ref: Optional[str] = None


class PaymentAdminOut(BaseModel):
    payment_id: uuid.UUID
    organization_id: uuid.UUID
    organization_name: Optional[str] = None
    amount: float
    currency: str
    provider: str
    provider_ref: Optional[str] = None
    status: str
    reconciliation_status: str
    proof_filename: Optional[str]
    created_at: datetime
    reconciled_at: Optional[datetime] = None
