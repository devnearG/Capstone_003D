"""persist organization status"""

from alembic import op
import sqlalchemy as sa


revision = "7e2c4a1f9b30"
down_revision = "4c1d8f6e2a31"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "organizations",
        sa.Column("status", sa.String(length=12), nullable=False, server_default="active"),
    )
    op.create_check_constraint(
        "ck_org_status", "organizations", "status in ('active','suspended')"
    )


def downgrade() -> None:
    op.drop_constraint("ck_org_status", "organizations", type_="check")
    op.drop_column("organizations", "status")
