import { afterEach, describe, expect, it, beforeEach, vi } from 'vitest';
import * as api from '@/api';
import { useAdminOrganizationsStore } from './adminOrganizationsStore';

describe('adminOrganizationsStore', () => {
  beforeEach(() => {
    localStorage.clear();
    useAdminOrganizationsStore.getState().resetToDefaults();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('loads initial organizations and users', () => {
    const { organizations, users } = useAdminOrganizationsStore.getState();
    expect(organizations.length).toBeGreaterThan(0);
    expect(users.length).toBeGreaterThan(0);

    const proOrgs = organizations.filter((o) => o.plan === 'pro');
    const freeOrgs = organizations.filter((o) => o.plan === 'free');
    expect(proOrgs.length).toBeGreaterThan(0);
    expect(freeOrgs.length).toBeGreaterThan(0);
  });

  it('toggles organization plan between free and pro', async () => {
    const firstOrg = useAdminOrganizationsStore.getState().organizations[0];
    const initialPlan = firstOrg.plan;

    await useAdminOrganizationsStore.getState().toggleOrganizationPlan(firstOrg.id);

    let updated = useAdminOrganizationsStore.getState().organizations.find((o) => o.id === firstOrg.id);
    expect(updated?.plan).toBe(initialPlan === 'pro' ? 'free' : 'pro');

    await useAdminOrganizationsStore.getState().toggleOrganizationPlan(firstOrg.id);
    updated = useAdminOrganizationsStore.getState().organizations.find((o) => o.id === firstOrg.id);
    expect(updated?.plan).toBe(initialPlan);
  });

  it('changes user role and persists update', async () => {
    const clientUser = useAdminOrganizationsStore.getState().users.find((u) => u.role === 'client');
    expect(clientUser).toBeDefined();

    if (clientUser) {
      await useAdminOrganizationsStore.getState().changeUserRole(clientUser.id, 'consultant');
      const updated = useAdminOrganizationsStore.getState().users.find((u) => u.id === clientUser.id);
      expect(updated?.role).toBe('consultant');
    }
  });

  it('toggles user status between active and inactive', async () => {
    const firstUser = useAdminOrganizationsStore.getState().users[0];
    expect(firstUser.status).toBe('active');

    await useAdminOrganizationsStore.getState().toggleUserStatus(firstUser.id);
    let updated = useAdminOrganizationsStore.getState().users.find((u) => u.id === firstUser.id);
    expect(updated?.status).toBe('inactive');

    await useAdminOrganizationsStore.getState().toggleUserStatus(firstUser.id);
    updated = useAdminOrganizationsStore.getState().users.find((u) => u.id === firstUser.id);
    expect(updated?.status).toBe('active');
  });

  it('updates organization status only after the API confirms it', async () => {
    localStorage.setItem('tryaigap.access_token', 'admin-token');
    const organization = useAdminOrganizationsStore.getState().organizations[0];
    const updateStatus = vi.spyOn(api, 'updateAdminOrganizationStatus').mockResolvedValue({
      organization_id: organization.id,
      status: 'suspended',
    });

    await useAdminOrganizationsStore.getState().toggleOrganizationStatus(organization.id);

    expect(updateStatus).toHaveBeenCalledWith(organization.id, 'suspended');
    expect(useAdminOrganizationsStore.getState().organizations[0].status).toBe('suspended');
  });

  it('does not mutate organization status when the API fails', async () => {
    localStorage.setItem('tryaigap.access_token', 'admin-token');
    const organization = useAdminOrganizationsStore.getState().organizations[0];
    vi.spyOn(api, 'updateAdminOrganizationStatus').mockRejectedValue(new Error('API unavailable'));

    await expect(
      useAdminOrganizationsStore.getState().toggleOrganizationStatus(organization.id),
    ).rejects.toThrow('API unavailable');
    expect(useAdminOrganizationsStore.getState().organizations[0].status).toBe(organization.status);
  });
});
