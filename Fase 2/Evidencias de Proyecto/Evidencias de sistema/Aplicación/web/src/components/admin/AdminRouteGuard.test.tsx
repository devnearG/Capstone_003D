import { describe, expect, it, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router';
import '@/i18n';
import { AdminRouteGuard } from './AdminRouteGuard';
import { useAuthStore } from '@/store/authStore';
import type { MeResponse } from '@/api/types';

function setUser(role: MeResponse['role'] | null, status: 'authenticated' | 'unauthenticated' | 'hydrating' = 'authenticated') {
  useAuthStore.setState({
    user: role
      ? { id: 'u-admin-1', email: 'admin@tryaigap.com', role, locale: 'es', organization_id: 'org-1' }
      : null,
    status,
  });
}

function renderAdminGuard() {
  return render(
    <MemoryRouter initialEntries={['/admin/dashboard']}>
      <Routes>
        <Route
          path="/admin/dashboard"
          element={
            <AdminRouteGuard>
              <p>admin-console-content</p>
            </AdminRouteGuard>
          }
        />
        <Route path="/login" element={<p>login-redirect</p>} />
        <Route path="/dashboard" element={<p>dashboard-view</p>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('AdminRouteGuard', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('renders content when user is admin', () => {
    setUser('admin');
    renderAdminGuard();
    expect(screen.getByText('admin-console-content')).toBeInTheDocument();
  });

  it('shows restricted access warning when user is client', () => {
    setUser('client');
    renderAdminGuard();
    expect(screen.queryByText('admin-console-content')).not.toBeInTheDocument();
    expect(screen.getByText(/Acceso Restringido|Restricted Access|admin\.guard\.title/i)).toBeInTheDocument();
  });

  it('shows restricted access warning when user is consultant', () => {
    setUser('consultant');
    renderAdminGuard();
    expect(screen.queryByText('admin-console-content')).not.toBeInTheDocument();
    expect(screen.getByText(/Acceso Restringido|Restricted Access|admin\.guard\.title/i)).toBeInTheDocument();
  });

  it('redirects to /login when user is unauthenticated', () => {
    setUser(null, 'unauthenticated');
    renderAdminGuard();
    expect(screen.queryByText('admin-console-content')).not.toBeInTheDocument();
    expect(screen.getByText('login-redirect')).toBeInTheDocument();
  });
});
