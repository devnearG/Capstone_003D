"""add Supabase auth user mapping

Revision ID: 8d5c6f2a1b40
Revises: 7e2c4a1f9b30
"""
from alembic import op
import sqlalchemy as sa


revision = "8d5c6f2a1b40"
down_revision = "7e2c4a1f9b30"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("supabase_user_id", sa.Uuid(), nullable=True))
    op.create_index(
        "ix_users_supabase_user_id",
        "users",
        ["supabase_user_id"],
        unique=True,
    )


def downgrade() -> None:
    op.drop_index("ix_users_supabase_user_id", table_name="users")
    op.drop_column("users", "supabase_user_id")
