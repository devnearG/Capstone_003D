import { describe, expect, it, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import '@/i18n';
import AdminUsers from './AdminUsers';
import { useAdminOrganizationsStore } from '@/store/adminOrganizationsStore';

describe('AdminUsers Page', () => {
  beforeEach(() => {
    localStorage.clear();
    useAdminOrganizationsStore.getState().resetToDefaults();
  });

  it('renders users management overview and metrics', () => {
    render(<AdminUsers />);

    expect(screen.getByText('Gestión de Usuarios y Roles')).toBeInTheDocument();
    expect(screen.getByText('Total Usuarios')).toBeInTheDocument();
    expect(screen.getByText('Clientes Corporativos')).toBeInTheDocument();
    expect(screen.getByText('Consultores Acreditados')).toBeInTheDocument();
    expect(screen.getByText('Fabrizio Martínez')).toBeInTheDocument();
  });

  it('filters users by search input', () => {
    render(<AdminUsers />);

    const searchInput = screen.getByPlaceholderText(/Buscar por nombre, email o empresa/i);
    fireEvent.change(searchInput, { target: { value: 'Elena' } });

    expect(screen.getByText('Dra. Elena Ruiz')).toBeInTheDocument();
    expect(screen.queryByText('Jorge Valdés (CTO)')).not.toBeInTheDocument();
  });

  it('toggles user status when clicking suspend button', async () => {
    render(<AdminUsers />);

    const suspendButtons = screen.getAllByRole('button', { name: /Suspender/i });
    expect(suspendButtons.length).toBeGreaterThan(0);

    fireEvent.click(suspendButtons[0]);

    expect((await screen.findAllByRole('button', { name: /Reactivar/i })).length).toBeGreaterThan(0);
  });
});
