import { create } from 'zustand';
import {
  fetchAdminOrganizations,
  fetchAdminUsers,
  updateAdminOrganizationPlan,
  updateAdminOrganizationStatus,
  updateAdminUserRole,
  updateAdminUserStatus,
} from '@/api';
import { hasSession } from '@/api/client';
import type { AdminOrganization as ApiAdminOrganization, AdminUser as ApiAdminUser, Role } from '@/api/types';

export type PlanType = 'free' | 'pro';
export type OrgStatus = 'active' | 'suspended';
export type UserStatus = 'active' | 'inactive';

export interface AdminOrganization {
  id: string;
  name: string;
  slug: string;
  plan: PlanType;
  sector: string;
  size: string;
  memberCount: number;
  maxMembers: number;
  progress: number; // 0 - 100
  maturityScore?: number; // 1.0 - 5.0
  consultantId?: string;
  consultantName?: string;
  status: OrgStatus;
  createdAt: string;
  planExpiresAt?: string;
}

export interface AdminUser {
  id: string;
  email: string;
  fullName: string;
  role: Role;
  organizationId: string;
  organizationName: string;
  status: UserStatus;
  lastActiveAt: string;
  createdAt: string;
}

const STORAGE_KEY = 'tryaigap.admin.organizations_v1';

const INITIAL_ORGANIZATIONS: AdminOrganization[] = [
  {
    id: 'org-acme-1',
    name: 'Acme Retail Sudamérica',
    slug: 'acme-retail',
    plan: 'pro',
    sector: 'Retail y Consumo Masivo',
    size: '201-1000 colaboradores',
    memberCount: 38,
    maxMembers: 50,
    progress: 88,
    maturityScore: 3.8,
    consultantId: 'c-1',
    consultantName: 'Dra. Elena Ruiz (Sénior AI)',
    status: 'active',
    createdAt: '2026-03-15T10:00:00Z',
    planExpiresAt: '2027-03-15T10:00:00Z',
  },
  {
    id: 'org-tech-2',
    name: 'TechInnovate Solutions',
    slug: 'techinnovate',
    plan: 'pro',
    sector: 'Software & Cloud Services',
    size: '51-200 colaboradores',
    memberCount: 22,
    maxMembers: 25,
    progress: 95,
    maturityScore: 4.4,
    consultantId: 'c-2',
    consultantName: 'Carlos M. Soto (Arquitecto MLOps)',
    status: 'active',
    createdAt: '2026-04-02T14:30:00Z',
    planExpiresAt: '2027-04-02T14:30:00Z',
  },
  {
    id: 'org-log-3',
    name: 'Logística Andina Express',
    slug: 'logistica-andina',
    plan: 'free',
    sector: 'Transporte y Distribución',
    size: '51-200 colaboradores',
    memberCount: 5,
    maxMembers: 5,
    progress: 42,
    maturityScore: 2.3,
    status: 'active',
    createdAt: '2026-06-10T09:15:00Z',
  },
  {
    id: 'org-bio-4',
    name: 'BioSalud Laboratorios',
    slug: 'biosalud',
    plan: 'pro',
    sector: 'Salud & Biotecnología',
    size: '201-1000 colaboradores',
    memberCount: 44,
    maxMembers: 50,
    progress: 76,
    maturityScore: 3.5,
    consultantId: 'c-1',
    consultantName: 'Dra. Elena Ruiz (Sénior AI)',
    status: 'active',
    createdAt: '2026-05-18T16:00:00Z',
    planExpiresAt: '2027-05-18T16:00:00Z',
  },
  {
    id: 'org-min-5',
    name: 'Minera del Norte S.A.',
    slug: 'minera-norte',
    plan: 'free',
    sector: 'Minería & Recursos Naturales',
    size: '1000+ colaboradores',
    memberCount: 4,
    maxMembers: 5,
    progress: 25,
    maturityScore: 1.9,
    status: 'active',
    createdAt: '2026-07-22T11:45:00Z',
  },
  {
    id: 'org-fin-6',
    name: 'FinGroup Corporate Banking',
    slug: 'fingroup',
    plan: 'pro',
    sector: 'Banca y Servicios Financieros',
    size: '1000+ colaboradores',
    memberCount: 65,
    maxMembers: 100,
    progress: 100,
    maturityScore: 4.7,
    consultantId: 'c-3',
    consultantName: 'Martín Morales (Especialista Fintech)',
    status: 'active',
    createdAt: '2026-02-01T08:00:00Z',
    planExpiresAt: '2027-02-01T08:00:00Z',
  },
  {
    id: 'org-edu-7',
    name: 'EducaDigital Iberoamérica',
    slug: 'educadigital',
    plan: 'free',
    sector: 'Educación & EdTech',
    size: '1-50 colaboradores',
    memberCount: 3,
    maxMembers: 5,
    progress: 60,
    maturityScore: 3.1,
    status: 'active',
    createdAt: '2026-08-05T13:20:00Z',
  },
];

const INITIAL_USERS: AdminUser[] = [
  {
    id: 'u-1',
    email: 'admin@tryaigap.com',
    fullName: 'Fabrizio Martínez',
    role: 'admin',
    organizationId: 'org-tech-2',
    organizationName: 'TechInnovate Solutions',
    status: 'active',
    lastActiveAt: 'Hace 5 minutos',
    createdAt: '2026-01-10T12:00:00Z',
  },
  {
    id: 'u-2',
    email: 'elena.ruiz@tryaigap.com',
    fullName: 'Dra. Elena Ruiz',
    role: 'consultant',
    organizationId: 'org-acme-1',
    organizationName: 'Acme Retail Sudamérica',
    status: 'active',
    lastActiveAt: 'Hace 1 hora',
    createdAt: '2026-02-14T09:00:00Z',
  },
  {
    id: 'u-3',
    email: 'carlos.soto@tryaigap.com',
    fullName: 'Carlos M. Soto',
    role: 'consultant',
    organizationId: 'org-tech-2',
    organizationName: 'TechInnovate Solutions',
    status: 'active',
    lastActiveAt: 'Hace 3 horas',
    createdAt: '2026-02-20T10:30:00Z',
  },
  {
    id: 'u-4',
    email: 'jorge.valdes@acmeretail.com',
    fullName: 'Jorge Valdés (CTO)',
    role: 'client',
    organizationId: 'org-acme-1',
    organizationName: 'Acme Retail Sudamérica',
    status: 'active',
    lastActiveAt: 'Ayer',
    createdAt: '2026-03-16T11:00:00Z',
  },
  {
    id: 'u-5',
    email: 'marcela.silva@techinnovate.io',
    fullName: 'Marcela Silva (VP Data)',
    role: 'client',
    organizationId: 'org-tech-2',
    organizationName: 'TechInnovate Solutions',
    status: 'active',
    lastActiveAt: 'Hace 2 horas',
    createdAt: '2026-04-03T15:00:00Z',
  },
  {
    id: 'u-6',
    email: 'rodrigo.munoz@logisticaandina.cl',
    fullName: 'Rodrigo Muñoz (Gerente Ops)',
    role: 'client',
    organizationId: 'org-log-3',
    organizationName: 'Logística Andina Express',
    status: 'active',
    lastActiveAt: 'Hace 3 días',
    createdAt: '2026-06-11T10:00:00Z',
  },
  {
    id: 'u-7',
    email: 'patricia.ibanez@fingroup.com',
    fullName: 'Patricia Ibáñez (Chief Risk Officer)',
    role: 'client',
    organizationId: 'org-fin-6',
    organizationName: 'FinGroup Corporate Banking',
    status: 'active',
    lastActiveAt: 'Hace 20 minutos',
    createdAt: '2026-02-02T14:00:00Z',
  },
  {
    id: 'u-8',
    email: 'matias.gonzalez@tryaigap.com',
    fullName: 'Matías González',
    role: 'admin',
    organizationId: 'org-tech-2',
    organizationName: 'TechInnovate Solutions',
    status: 'active',
    lastActiveAt: 'Hace 30 minutos',
    createdAt: '2026-01-10T12:00:00Z',
  },
  {
    id: 'u-9',
    email: 'matias.lopez@tryaigap.com',
    fullName: 'Matías López',
    role: 'admin',
    organizationId: 'org-tech-2',
    organizationName: 'TechInnovate Solutions',
    status: 'active',
    lastActiveAt: 'Hace 10 minutos',
    createdAt: '2026-01-10T12:00:00Z',
  },
];

interface SavedState {
  organizations: AdminOrganization[];
  users: AdminUser[];
}

// Demo fixtures are dev-only: in production the API is the single source of
// truth, so stores start empty rather than showing fabricated orgs/users.
const IS_PROD = import.meta.env.PROD;

function defaultState(): SavedState {
  return IS_PROD
    ? { organizations: [], users: [] }
    : { organizations: INITIAL_ORGANIZATIONS, users: INITIAL_USERS };
}

function loadInitialState(): SavedState {
  if (IS_PROD) return defaultState();
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw) as SavedState;
      if (Array.isArray(parsed.organizations) && Array.isArray(parsed.users)) {
        return parsed;
      }
    }
  } catch {
    // Si falla, utiliza los valores por defecto
  }

  return defaultState();
}

function persistState(state: SavedState) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // LocalStorage restringido o lleno
  }
}

interface AdminOrganizationsState {
  organizations: AdminOrganization[];
  users: AdminUser[];
  load: () => Promise<void>;
  toggleOrganizationPlan: (orgId: string) => Promise<void>;
  updateOrganization: (orgId: string, updates: Partial<AdminOrganization>) => void;
  toggleOrganizationStatus: (orgId: string) => Promise<void>;
  changeUserRole: (userId: string, newRole: Role) => Promise<void>;
  toggleUserStatus: (userId: string) => Promise<void>;
  resetToDefaults: () => void;
}

export const useAdminOrganizationsStore = create<AdminOrganizationsState>((set, get) => ({
  ...loadInitialState(),

  async load() {
    if (!await hasSession()) return;
    const [apiOrganizations, apiUsers] = await Promise.all([
      fetchAdminOrganizations(),
      fetchAdminUsers(),
    ]);
    const organizations: AdminOrganization[] = apiOrganizations.map((organization: ApiAdminOrganization) => ({
      id: organization.id,
      name: organization.name,
      slug: organization.name.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
      plan: organization.plan,
      sector: organization.sector ?? 'Sin sector',
      size: organization.size ?? 'Sin tamaño',
      memberCount: organization.member_count,
      maxMembers: organization.max_members,
      progress: organization.progress,
      maturityScore: organization.maturity_score ?? undefined,
      consultantId: organization.consultant_id ?? undefined,
      consultantName: organization.consultant_name ?? undefined,
      status: organization.status === 'suspended' ? 'suspended' : 'active',
      createdAt: organization.created_at,
    }));
    const users: AdminUser[] = apiUsers.map((user: ApiAdminUser) => ({
      id: user.id,
      email: user.email,
      fullName: user.full_name ?? user.email,
      role: user.role,
      organizationId: user.organization_id ?? '',
      organizationName: user.organization_name ?? 'Sin organización',
      status: user.status === 'inactive' ? 'inactive' : 'active',
      lastActiveAt: user.last_active_at,
      createdAt: user.created_at,
    }));
    set({ organizations, users });
  },

  toggleOrganizationPlan: async (orgId) => {
    const { organizations, users } = get();
    const organization = organizations.find((org) => org.id === orgId);
    if (!organization) return;
    const nextPlan: PlanType = organization.plan === 'pro' ? 'free' : 'pro';
    if (await hasSession()) {
      await updateAdminOrganizationPlan(orgId, nextPlan);
    }
    const nextOrgs = organizations.map((org) => {
      if (org.id === orgId) {
        return {
          ...org,
          plan: nextPlan,
          maxMembers: nextPlan === 'pro' ? 50 : 5,
          planExpiresAt:
            nextPlan === 'pro'
              ? new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString()
              : undefined,
        };
      }
      return org;
    });

    persistState({ organizations: nextOrgs, users });
    set({ organizations: nextOrgs });
  },

  updateOrganization: (orgId, updates) => {
    const { organizations, users } = get();
    const nextOrgs = organizations.map((org) =>
      org.id === orgId ? { ...org, ...updates } : org,
    );
    persistState({ organizations: nextOrgs, users });
    set({ organizations: nextOrgs });
  },

  toggleOrganizationStatus: async (orgId) => {
    const { organizations, users } = get();
    const organization = organizations.find((org) => org.id === orgId);
    if (!organization) return;
    const nextStatus: OrgStatus = organization.status === 'active' ? 'suspended' : 'active';
    if (await hasSession()) {
      await updateAdminOrganizationStatus(orgId, nextStatus);
    }
    const nextOrgs = organizations.map((org) => {
      if (org.id === orgId) {
        return {
          ...org,
          status: nextStatus,
        };
      }
      return org;
    });
    persistState({ organizations: nextOrgs, users });
    set({ organizations: nextOrgs });
  },

  changeUserRole: async (userId, newRole) => {
    const { organizations, users } = get();
    if (await hasSession()) {
      await updateAdminUserRole(userId, newRole);
    }
    const nextUsers = users.map((u) => (u.id === userId ? { ...u, role: newRole } : u));
    persistState({ organizations, users: nextUsers });
    set({ users: nextUsers });
  },

  toggleUserStatus: async (userId) => {
    const { organizations, users } = get();
    const user = users.find((item) => item.id === userId);
    if (!user) return;
    const nextStatus: UserStatus = user.status === 'active' ? 'inactive' : 'active';
    if (await hasSession()) {
      await updateAdminUserStatus(userId, nextStatus === 'inactive' ? 'disabled' : 'active');
    }
    const nextUsers = users.map((u) => {
      if (u.id === userId) {
        return {
          ...u,
          status: nextStatus,
        };
      }
      return u;
    });
    persistState({ organizations, users: nextUsers });
    set({ users: nextUsers });
  },

  resetToDefaults: () => {
    localStorage.removeItem(STORAGE_KEY);
    set(defaultState());
  },
}));
