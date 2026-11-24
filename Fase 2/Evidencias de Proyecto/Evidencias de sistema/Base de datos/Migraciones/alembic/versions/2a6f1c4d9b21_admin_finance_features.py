"""admin, consultant assignments, audit logs and payment reconciliation

Revision ID: 2a6f1c4d9b21
Revises: 011e579eda6c
"""
from alembic import op
import sqlalchemy as sa


revision = "2a6f1c4d9b21"
down_revision = "011e579eda6c"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("questions", sa.Column("vector_type", sa.String(length=30), nullable=True))
    op.add_column("questions", sa.Column("weight", sa.SmallInteger(), nullable=True))
    op.add_column("questions", sa.Column("readiness", sa.SmallInteger(), nullable=True))
    op.add_column("invitations", sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("payments", sa.Column("proof_storage_key", sa.Text(), nullable=True))
    op.add_column("payments", sa.Column("proof_filename", sa.String(length=255), nullable=True))
    op.add_column("payments", sa.Column(
        "reconciliation_status", sa.String(length=12), nullable=False, server_default="pending"
    ))
    op.add_column("payments", sa.Column("reconciled_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("payments", sa.Column("reconciled_by", sa.Uuid(), nullable=True))
    op.create_foreign_key(
        "fk_payments_reconciled_by", "payments", "users", ["reconciled_by"], ["id"], ondelete="SET NULL"
    )
    op.create_table(
        "consultant_assignments",
        sa.Column("organization_id", sa.Uuid(), nullable=False),
        sa.Column("consultant_id", sa.Uuid(), nullable=False),
        sa.Column("assigned_by", sa.Uuid(), nullable=True),
        sa.Column("status", sa.String(length=12), nullable=False),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.CheckConstraint("status in ('active','revoked')", name="ck_assignment_status"),
        sa.ForeignKeyConstraint(["organization_id"], ["organizations.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["consultant_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["assigned_by"], ["users.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("organization_id", "consultant_id", name="uq_consultant_assignment"),
    )
    op.create_table(
        "audit_logs",
        sa.Column("actor_id", sa.Uuid(), nullable=True),
        sa.Column("action", sa.String(length=80), nullable=False),
        sa.Column("resource_type", sa.String(length=80), nullable=True),
        sa.Column("resource_id", sa.String(length=80), nullable=True),
        sa.Column("details", sa.JSON(), nullable=False),
        sa.Column("ip_address", sa.String(length=45), nullable=True),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["actor_id"], ["users.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
    )


def downgrade() -> None:
    op.drop_table("audit_logs")
    op.drop_table("consultant_assignments")
    op.drop_constraint("fk_payments_reconciled_by", "payments", type_="foreignkey")
    for column in ("reconciled_by", "reconciled_at", "reconciliation_status", "proof_filename", "proof_storage_key"):
        op.drop_column("payments", column)
    op.drop_column("invitations", "expires_at")
    for column in ("readiness", "weight", "vector_type"):
        op.drop_column("questions", column)
