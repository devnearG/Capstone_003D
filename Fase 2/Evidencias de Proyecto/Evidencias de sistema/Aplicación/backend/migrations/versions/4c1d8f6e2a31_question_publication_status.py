"""add publication status to questions

Revision ID: 4c1d8f6e2a31
Revises: 2a6f1c4d9b21
"""
from alembic import op
import sqlalchemy as sa


revision = "4c1d8f6e2a31"
down_revision = "2a6f1c4d9b21"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "questions",
        sa.Column("status", sa.String(length=12), nullable=False, server_default="published"),
    )
    op.create_check_constraint(
        "ck_question_status", "questions", "status in ('published','draft')"
    )


def downgrade() -> None:
    op.drop_constraint("ck_question_status", "questions", type_="check")
    op.drop_column("questions", "status")
