import { describe, expect, it, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import '@/i18n';
import AdminOrganizations from './AdminOrganizations';
import { useAdminOrganizationsStore } from '@/store/adminOrganizationsStore';

describe('AdminOrganizations Page', () => {
  beforeEach(() => {
    localStorage.clear();
    useAdminOrganizationsStore.getState().resetToDefaults();
  });

  it('renders organizations management overview and metrics', () => {
    render(<AdminOrganizations />);

    expect(screen.getByText('Organizaciones y Planes Empresariales')).toBeInTheDocument();
    expect(screen.getByText('Total Empresas')).toBeInTheDocument();
    expect(screen.getByText('Plan Pro Enterprise')).toBeInTheDocument();
    expect(screen.getByText('Plan Freemium')).toBeInTheDocument();
    expect(screen.getByText('Acme Retail Sudamérica')).toBeInTheDocument();
  });

  it('filters organizations by search input', () => {
    render(<AdminOrganizations />);

    const searchInput = screen.getByPlaceholderText(/Buscar por nombre de empresa/i);
    fireEvent.change(searchInput, { target: { value: 'TechInnovate' } });

    expect(screen.getByText('TechInnovate Solutions')).toBeInTheDocument();
    expect(screen.queryByText('Logística Andina Express')).not.toBeInTheDocument();
  });

  it('opens confirmation modal when clicking plan switch button', () => {
    render(<AdminOrganizations />);

    const switchButtons = screen.getAllByRole('button', { name: /Subir a Pro|Bajar a Free/i });
    expect(switchButtons.length).toBeGreaterThan(0);

    fireEvent.click(switchButtons[0]);

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText(/ADM-10 · Conmutación de Plan/i)).toBeInTheDocument();
  });
});
