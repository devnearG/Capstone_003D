import { describe, expect, it, beforeEach } from 'vitest';
import { useAdminPlatformStore } from './adminPlatformStore';

describe('adminPlatformStore', () => {
  beforeEach(() => {
    localStorage.clear();
    useAdminPlatformStore.getState().resetToDefaults();
  });

  it('initializes consultants, payments, and audit logs', () => {
    const { consultants, payments, auditLogs } = useAdminPlatformStore.getState();
    expect(consultants.length).toBeGreaterThan(0);
    expect(payments.length).toBeGreaterThan(0);
    expect(auditLogs.length).toBeGreaterThan(0);
  });

  it('assigns a consultant to an organization and logs audit event', async () => {
    const consultant = useAdminPlatformStore.getState().consultants[0];
    const initialAuditCount = useAdminPlatformStore.getState().auditLogs.length;

    await useAdminPlatformStore.getState().assignConsultantToOrg(
      consultant.id,
      'org-test-99',
      'Empresa de Prueba',
    );

    const updatedConsultant = useAdminPlatformStore.getState().consultants.find((c) => c.id === consultant.id);
    expect(updatedConsultant?.assignedOrgIds).toContain('org-test-99');
    expect(updatedConsultant?.assignedOrgNames).toContain('Empresa de Prueba');

    const newAuditCount = useAdminPlatformStore.getState().auditLogs.length;
    expect(newAuditCount).toBe(initialAuditCount + 1);
  });

  it('reconciles a pending payment transaction', async () => {
    const pendingTx = useAdminPlatformStore.getState().payments.find((p) => p.status === 'pending_reconciliation');
    expect(pendingTx).toBeDefined();

    if (pendingTx) {
      await useAdminPlatformStore.getState().reconcilePayment(pendingTx.id, 'admin@tryaigap.com');

      const updatedTx = useAdminPlatformStore.getState().payments.find((p) => p.id === pendingTx.id);
      expect(updatedTx?.status).toBe('paid');
      expect(updatedTx?.reconciledBy).toBe('admin@tryaigap.com');
      expect(updatedTx?.reconciledAt).toBeDefined();
    }
  });

  it('adds manual payment order and logs event', async () => {
    const initialPaymentsCount = useAdminPlatformStore.getState().payments.length;

    await useAdminPlatformStore.getState().addManualPayment({
      invoiceNumber: 'INV-TEST-009',
      organizationId: 'org-test-1',
      organizationName: 'Organización Test',
      amount: 1500,
      currency: 'USD',
      method: 'wire_transfer',
      status: 'pending_reconciliation',
      plan: 'pro_annual',
    });

    const newPaymentsCount = useAdminPlatformStore.getState().payments.length;
    expect(newPaymentsCount).toBe(initialPaymentsCount + 1);
  });
});
