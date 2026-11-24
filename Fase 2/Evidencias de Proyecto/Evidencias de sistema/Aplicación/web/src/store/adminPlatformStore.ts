import { create } from 'zustand';
import {
  createAdminAssignment,
  createAdminManualPayment,
  fetchAdminConsultants,
  fetchAdminAuditLogs,
  fetchAdminPayments,
  reconcileAdminPayment,
  revokeAdminAssignment,
} from '@/api';
import { hasSession } from '@/api/client';

export interface ConsultantProfile {
  id: string;
  name: string;
  email: string;
  avatarUrl?: string;
  specialty: string;
  seniority: 'Senior Specialist' | 'Lead Partner' | 'Principal Consultant';
  assignedOrgIds: string[];
  assignedOrgNames: string[];
  completedReviews: number;
  activeReviews: number;
  rating: number; // 1.0 - 5.0
  status: 'available' | 'busy' | 'offline';
}

export type PaymentMethod = 'stripe' | 'wire_transfer' | 'purchase_order';
export type PaymentStatus = 'paid' | 'pending_reconciliation' | 'failed' | 'refunded';

export interface AdminPaymentTransaction {
  id: string;
  invoiceNumber: string;
  organizationId: string;
  organizationName: string;
  amount: number; // in USD
  currency: string;
  method: PaymentMethod;
  status: PaymentStatus;
  plan: 'pro_annual' | 'pro_monthly' | 'custom_enterprise';
  referenceCode?: string;
  voucherUrl?: string;
  createdAt: string;
  reconciledAt?: string;
  reconciledBy?: string;
}

export type AuditActionType =
  | 'question_published'
  | 'question_drafted'
  | 'question_updated'
  | 'plan_upgraded'
  | 'plan_downgraded'
  | 'role_changed'
  | 'user_suspended'
  | 'user_activated'
  | 'consultant_assigned'
  | 'payment_reconciled'
  | 'payment_created';

export interface AuditLogEntry {
  id: string;
  timestamp: string;
  actorEmail: string;
  actorRole: string;
  action: AuditActionType;
  actionLabel: string;
  targetId: string;
  targetName: string;
  details: string;
  ipAddress: string;
}

const STORAGE_KEY = 'tryaigap.admin.platform_store_v1';

const INITIAL_CONSULTANTS: ConsultantProfile[] = [
  {
    id: 'c-1',
    name: 'Dra. Elena Ruiz',
    email: 'elena.ruiz@tryaigap.com',
    specialty: 'Estrategia de IA & Transformación Digital',
    seniority: 'Lead Partner',
    assignedOrgIds: ['org-acme-1', 'org-bio-4'],
    assignedOrgNames: ['Acme Retail Sudamérica', 'BioSalud Laboratorios'],
    completedReviews: 24,
    activeReviews: 2,
    rating: 4.9,
    status: 'available',
  },
  {
    id: 'c-2',
    name: 'Carlos M. Soto',
    email: 'carlos.soto@tryaigap.com',
    specialty: 'Arquitectura Cloud & MLOps Productivo',
    seniority: 'Principal Consultant',
    assignedOrgIds: ['org-tech-2'],
    assignedOrgNames: ['TechInnovate Solutions'],
    completedReviews: 18,
    activeReviews: 1,
    rating: 4.8,
    status: 'available',
  },
  {
    id: 'c-3',
    name: 'Martín Morales',
    email: 'martin.morales@tryaigap.com',
    specialty: 'Gobernanza Financiera & Riesgo de Modelos',
    seniority: 'Senior Specialist',
    assignedOrgIds: ['org-fin-6'],
    assignedOrgNames: ['FinGroup Corporate Banking'],
    completedReviews: 15,
    activeReviews: 1,
    rating: 4.95,
    status: 'busy',
  },
  {
    id: 'c-4',
    name: 'Valentina Lagos',
    email: 'valentina.lagos@tryaigap.com',
    specialty: 'Optimización de Procesos & Logística Inteligente',
    seniority: 'Senior Specialist',
    assignedOrgIds: [],
    assignedOrgNames: [],
    completedReviews: 10,
    activeReviews: 0,
    rating: 4.75,
    status: 'available',
  },
];

const INITIAL_PAYMENTS: AdminPaymentTransaction[] = [
  {
    id: 'tx-1001',
    invoiceNumber: 'INV-2026-0045',
    organizationId: 'org-tech-2',
    organizationName: 'TechInnovate Solutions',
    amount: 2400,
    currency: 'USD',
    method: 'stripe',
    status: 'paid',
    plan: 'pro_annual',
    referenceCode: 'ch_3N8vG2K1098XyZ',
    createdAt: '2026-04-02T14:35:00Z',
    reconciledAt: '2026-04-02T14:35:05Z',
    reconciledBy: 'Stripe Webhook (Auto)',
  },
  {
    id: 'tx-1002',
    invoiceNumber: 'INV-2026-0046',
    organizationId: 'org-acme-1',
    organizationName: 'Acme Retail Sudamérica',
    amount: 4800,
    currency: 'USD',
    method: 'wire_transfer',
    status: 'paid',
    plan: 'pro_annual',
    referenceCode: 'TRANSF-SANTANDER-99812',
    createdAt: '2026-03-15T10:15:00Z',
    reconciledAt: '2026-03-15T11:00:00Z',
    reconciledBy: 'admin@tryaigap.com',
  },
  {
    id: 'tx-1003',
    invoiceNumber: 'INV-2026-0047',
    organizationId: 'org-bio-4',
    organizationName: 'BioSalud Laboratorios',
    amount: 3200,
    currency: 'USD',
    method: 'purchase_order',
    status: 'paid',
    plan: 'pro_annual',
    referenceCode: 'OC-BIOSALUD-2026-88',
    createdAt: '2026-05-18T16:10:00Z',
    reconciledAt: '2026-05-19T09:30:00Z',
    reconciledBy: 'admin@tryaigap.com',
  },
  {
    id: 'tx-1004',
    invoiceNumber: 'INV-2026-0048',
    organizationId: 'org-log-3',
    organizationName: 'Logística Andina Express',
    amount: 2400,
    currency: 'USD',
    method: 'wire_transfer',
    status: 'pending_reconciliation',
    plan: 'pro_annual',
    referenceCode: 'COMPR-BANCOESTADO-5512',
    voucherUrl: 'https://storage.tryaigap.com/vouchers/voucher-log-3.pdf',
    createdAt: '2026-10-24T15:20:00Z',
  },
  {
    id: 'tx-1005',
    invoiceNumber: 'INV-2026-0049',
    organizationId: 'org-fin-6',
    organizationName: 'FinGroup Corporate Banking',
    amount: 6000,
    currency: 'USD',
    method: 'purchase_order',
    status: 'paid',
    plan: 'custom_enterprise',
    referenceCode: 'PO-FINGROUP-00129',
    createdAt: '2026-02-01T08:15:00Z',
    reconciledAt: '2026-02-01T09:00:00Z',
    reconciledBy: 'admin@tryaigap.com',
  },
];

const INITIAL_AUDIT_LOGS: AuditLogEntry[] = [
  {
    id: 'log-1',
    timestamp: '2026-10-24T17:45:00Z',
    actorEmail: 'fabrizio.martinez@tryaigap.com',
    actorRole: 'admin',
    action: 'question_published',
    actionLabel: 'Publicación de Banco Metodológico',
    targetId: 'qbank-all',
    targetName: 'Banco de 132 Preguntas',
    details: 'Verificación de paridad multilingüe completada en ES, EN, DE, PT.',
    ipAddress: '190.161.44.12',
  },
  {
    id: 'log-2',
    timestamp: '2026-10-24T16:20:00Z',
    actorEmail: 'matias.lopez@tryaigap.com',
    actorRole: 'admin',
    action: 'plan_upgraded',
    actionLabel: 'Ascenso a Plan Pro',
    targetId: 'org-acme-1',
    targetName: 'Acme Retail Sudamérica',
    details: 'Activación de acceso completo a 7 módulos y ampliación a 50 miembros.',
    ipAddress: '190.45.122.9',
  },
  {
    id: 'log-3',
    timestamp: '2026-10-24T15:40:00Z',
    actorEmail: 'admin@tryaigap.com',
    actorRole: 'admin',
    action: 'consultant_assigned',
    actionLabel: 'Asignación de Consultor',
    targetId: 'c-1',
    targetName: 'Dra. Elena Ruiz ➔ Acme Retail',
    details: 'Vinculación de consultor líder para revisión cualitativa en M7.',
    ipAddress: '201.214.88.54',
  },
  {
    id: 'log-4',
    timestamp: '2026-10-24T14:10:00Z',
    actorEmail: 'admin@tryaigap.com',
    actorRole: 'admin',
    action: 'role_changed',
    actionLabel: 'Modificación de Rol RBAC',
    targetId: 'u-3',
    targetName: 'Carlos M. Soto',
    details: 'Elevación de privilegios de usuario a rol Consultant.',
    ipAddress: '201.214.88.54',
  },
];

interface PlatformState {
  consultants: ConsultantProfile[];
  payments: AdminPaymentTransaction[];
  auditLogs: AuditLogEntry[];
}

// Demo fixtures are dev-only: in production the API is the single source of
// truth, so stores start empty rather than showing fabricated records.
const IS_PROD = import.meta.env.PROD;

function defaultState(): PlatformState {
  return IS_PROD
    ? { consultants: [], payments: [], auditLogs: [] }
    : {
        consultants: INITIAL_CONSULTANTS,
        payments: INITIAL_PAYMENTS,
        auditLogs: INITIAL_AUDIT_LOGS,
      };
}

function loadInitialState(): PlatformState {
  if (IS_PROD) return defaultState();
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw) as PlatformState;
      if (
        Array.isArray(parsed.consultants) &&
        Array.isArray(parsed.payments) &&
        Array.isArray(parsed.auditLogs)
      ) {
        return parsed;
      }
    }
  } catch {
    // En caso de fallo de lectura, utiliza estado por defecto
  }

  return defaultState();
}

function persistState(state: PlatformState) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // LocalStorage lleno o restringido
  }
}

function formatAuditAction(action: string): string {
  const labels: Record<string, string> = {
    'question.created': 'Creación de Pregunta',
    'question.updated': 'Actualización de Pregunta',
    'question.bulk_published': 'Publicación Masiva de Preguntas',
    'organization.plan_updated': 'Actualización de Plan',
    'consultant.assignment_updated': 'Asignación de Consultor',
    'consultant.assignment_revoked': 'Revocación de Consultor',
    'payment.created': 'Creación de Pago',
    'payment.proof_uploaded': 'Carga de Comprobante',
    'payment.reconciled': 'Conciliación de Pago',
  };
  return labels[action] ?? action;
}

interface AdminPlatformActions {
  assignConsultantToOrg: (consultantId: string, orgId: string, orgName: string) => Promise<void>;
  removeConsultantFromOrg: (consultantId: string, orgId: string, assignmentId?: string) => Promise<void>;
  loadConsultants: () => Promise<void>;
  loadPayments: () => Promise<void>;
  loadAuditLogs: () => Promise<void>;
  reconcilePayment: (paymentId: string, reconciledBy: string) => Promise<void>;
  addManualPayment: (payment: Omit<AdminPaymentTransaction, 'id' | 'createdAt'>) => Promise<void>;
  logAuditEvent: (entry: Omit<AuditLogEntry, 'id' | 'timestamp'>) => void;
  resetToDefaults: () => void;
}

function mapApiPayment(payment: Awaited<ReturnType<typeof fetchAdminPayments>>[number]): AdminPaymentTransaction {
  return {
    id: payment.payment_id,
    invoiceNumber: payment.provider_ref ?? payment.payment_id.slice(0, 8),
    organizationId: payment.organization_id,
    organizationName: payment.organization_name ?? payment.organization_id,
    amount: payment.amount,
    currency: payment.currency,
    method: payment.provider === 'stripe' ? 'stripe' : 'wire_transfer',
    status: payment.reconciliation_status === 'reconciled' || payment.status === 'succeeded'
      ? 'paid'
      : payment.status === 'failed' || payment.reconciliation_status === 'rejected'
        ? 'failed'
        : 'pending_reconciliation',
    plan: 'pro_annual',
    referenceCode: payment.provider_ref ?? undefined,
    voucherUrl: payment.proof_filename ?? undefined,
    createdAt: payment.created_at,
    reconciledAt: payment.reconciled_at ?? undefined,
  };
}

export const useAdminPlatformStore = create<PlatformState & AdminPlatformActions>((set, get) => ({
  ...loadInitialState(),

  async loadPayments() {
    if (!await hasSession()) return;
    const payments = await fetchAdminPayments();
    set((state) => ({ ...state, payments: payments.map(mapApiPayment) }));
  },

  async loadAuditLogs() {
    if (!await hasSession()) return;
    const logs = await fetchAdminAuditLogs();
    set((state) => ({
      ...state,
      auditLogs: logs.map((log) => ({
        id: log.id,
        timestamp: log.created_at,
        actorEmail: log.actor_email ?? log.actor_id ?? 'Sistema',
        actorRole: 'admin',
        action: log.action as AuditActionType,
        actionLabel: formatAuditAction(log.action),
        targetId: log.resource_id ?? '',
        targetName: log.resource_type
          ? `${log.resource_type}${log.resource_id ? ` (${log.resource_id})` : ''}`
          : log.resource_id ?? 'Sistema',
        details: Object.keys(log.details).length > 0
          ? JSON.stringify(log.details)
          : log.action,
        ipAddress: log.ip_address ?? 'No disponible',
      })),
    }));
  },

  async loadConsultants() {
    if (!await hasSession()) return;
    const consultants = await fetchAdminConsultants();
    set((state) => ({
      ...state,
      consultants: consultants.map((consultant) => ({
        id: consultant.id,
        name: consultant.full_name ?? consultant.email,
        email: consultant.email,
        specialty: 'Consultoría de transformación con IA',
        seniority: 'Senior Specialist',
        assignedOrgIds: consultant.assigned_org_ids,
        assignedOrgNames: consultant.assigned_org_names,
        completedReviews: consultant.completed_reviews,
        activeReviews: consultant.active_reviews,
        rating: consultant.rating,
        status: consultant.status,
      })),
    }));
  },

  assignConsultantToOrg: async (consultantId, orgId, orgName) => {
    if (await hasSession()) {
      await createAdminAssignment({
        organization_id: orgId,
        consultant_id: consultantId,
      });
    }
    const { consultants, payments, auditLogs } = get();

    // 1. Remover de cualquier consultor previo para evitar duplicidad
    const updatedConsultants = consultants.map((c) => {
      const isTarget = c.id === consultantId;
      const filteredOrgIds = c.assignedOrgIds.filter((id) => id !== orgId);
      const filteredOrgNames = c.assignedOrgNames.filter((name) => name !== orgName);

      if (isTarget) {
        return {
          ...c,
          assignedOrgIds: [...filteredOrgIds, orgId],
          assignedOrgNames: [...filteredOrgNames, orgName],
          activeReviews: filteredOrgIds.length + 1,
        };
      }

      return {
        ...c,
        assignedOrgIds: filteredOrgIds,
        assignedOrgNames: filteredOrgNames,
        activeReviews: filteredOrgIds.length,
      };
    });

    const targetConsultant = consultants.find((c) => c.id === consultantId);

    const newAuditLog: AuditLogEntry = {
      id: `log-${Date.now()}`,
      timestamp: new Date().toISOString(),
      actorEmail: 'admin@tryaigap.com',
      actorRole: 'admin',
      action: 'consultant_assigned',
      actionLabel: 'Asignación de Consultor',
      targetId: consultantId,
      targetName: `${targetConsultant?.name ?? 'Consultor'} ➔ ${orgName}`,
      details: `Asignación de consultor para supervisión de evaluación M7.`,
      ipAddress: '127.0.0.1 (Local Admin Session)',
    };

    const nextState = {
      consultants: updatedConsultants,
      payments,
      auditLogs: [newAuditLog, ...auditLogs],
    };

    persistState(nextState);
    set(nextState);
  },

  removeConsultantFromOrg: async (consultantId, orgId, assignmentId) => {
    if (await hasSession() && assignmentId) {
      await revokeAdminAssignment(assignmentId);
    }
    const { consultants, payments, auditLogs } = get();

    const updatedConsultants = consultants.map((c) => {
      if (c.id === consultantId) {
        const idx = c.assignedOrgIds.indexOf(orgId);
        const filteredOrgIds = c.assignedOrgIds.filter((id) => id !== orgId);
        const filteredOrgNames = c.assignedOrgNames.filter((_, i) => i !== idx);
        return {
          ...c,
          assignedOrgIds: filteredOrgIds,
          assignedOrgNames: filteredOrgNames,
          activeReviews: Math.max(0, filteredOrgIds.length),
        };
      }
      return c;
    });

    const nextState = {
      consultants: updatedConsultants,
      payments,
      auditLogs,
    };

    persistState(nextState);
    set(nextState);
  },

  reconcilePayment: async (paymentId, reconciledBy) => {
    const { consultants, payments, auditLogs } = get();

    if (await hasSession()) {
      const reconciledPayment = await reconcileAdminPayment(paymentId, 'reconciled');
      set((state) => ({
        ...state,
        payments: state.payments.map((payment) =>
          payment.id === paymentId ? mapApiPayment(reconciledPayment) : payment,
        ),
      }));
      return;
    }

    let reconciledTx: AdminPaymentTransaction | undefined;

    const updatedPayments = payments.map((tx) => {
      if (tx.id === paymentId) {
        reconciledTx = {
          ...tx,
          status: 'paid' as PaymentStatus,
          reconciledAt: new Date().toISOString(),
          reconciledBy,
        };
        return reconciledTx;
      }
      return tx;
    });

    const newAuditLog: AuditLogEntry = {
      id: `log-${Date.now()}`,
      timestamp: new Date().toISOString(),
      actorEmail: reconciledBy,
      actorRole: 'admin',
      action: 'payment_reconciled',
      actionLabel: 'Conciliación de Pago B2B',
      targetId: paymentId,
      targetName: reconciledTx ? `${reconciledTx.invoiceNumber} (${reconciledTx.organizationName})` : paymentId,
      details: `Pago de $${reconciledTx?.amount ?? 0} USD aprobado y conciliado manualmente.`,
      ipAddress: '127.0.0.1 (Local Admin Session)',
    };

    const nextState = {
      consultants,
      payments: updatedPayments,
      auditLogs: [newAuditLog, ...auditLogs],
    };

    persistState(nextState);
    set(nextState);
  },

  addManualPayment: async (paymentData) => {
    const { consultants, payments, auditLogs } = get();

    if (await hasSession()) {
      const created = await createAdminManualPayment({
        organization_id: paymentData.organizationId,
        amount: paymentData.amount,
        currency: paymentData.currency,
        provider: paymentData.method,
        provider_ref: paymentData.referenceCode,
      });
      set((state) => ({
        ...state,
        payments: [mapApiPayment(created), ...state.payments],
      }));
      return;
    }

    const newTx: AdminPaymentTransaction = {
      ...paymentData,
      id: `tx-${Date.now()}`,
      createdAt: new Date().toISOString(),
    };

    const newAuditLog: AuditLogEntry = {
      id: `log-${Date.now()}`,
      timestamp: new Date().toISOString(),
      actorEmail: 'admin@tryaigap.com',
      actorRole: 'admin',
      action: 'payment_created',
      actionLabel: 'Registro de Orden de Pago',
      targetId: newTx.id,
      targetName: `${newTx.invoiceNumber} (${newTx.organizationName})`,
      details: `Registro de factura/transferencia manual por $${newTx.amount} USD.`,
      ipAddress: '127.0.0.1 (Local Admin Session)',
    };

    const nextState = {
      consultants,
      payments: [newTx, ...payments],
      auditLogs: [newAuditLog, ...auditLogs],
    };

    persistState(nextState);
    set(nextState);
  },

  logAuditEvent: (entry) => {
    const { consultants, payments, auditLogs } = get();

    const newEntry: AuditLogEntry = {
      ...entry,
      id: `log-${Date.now()}`,
      timestamp: new Date().toISOString(),
    };

    const nextState = {
      consultants,
      payments,
      auditLogs: [newEntry, ...auditLogs],
    };

    persistState(nextState);
    set(nextState);
  },

  resetToDefaults: () => {
    localStorage.removeItem(STORAGE_KEY);
    set(defaultState());
  },
}));
