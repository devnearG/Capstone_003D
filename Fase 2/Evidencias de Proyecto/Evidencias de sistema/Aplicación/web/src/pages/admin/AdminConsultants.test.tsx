import { describe, expect, it, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import '@/i18n';
import AdminConsultants from './AdminConsultants';
import { useAdminPlatformStore } from '@/store/adminPlatformStore';

describe('AdminConsultants Page', () => {
  beforeEach(() => {
    localStorage.clear();
    useAdminPlatformStore.getState().resetToDefaults();
  });

  it('renders consultants overview, ratings and active reviews', () => {
    render(<AdminConsultants />);

    expect(screen.getByText('Consultores y Asignaciones')).toBeInTheDocument();
    expect(screen.getByText('Consultores Acreditados')).toBeInTheDocument();
    expect(screen.getByText('Revisiones Activas (M7)')).toBeInTheDocument();
    expect(screen.getByText('Dra. Elena Ruiz')).toBeInTheDocument();
    expect(screen.getByText('Carlos M. Soto')).toBeInTheDocument();
  });

  it('filters consultants by search input', () => {
    render(<AdminConsultants />);

    const searchInput = screen.getByPlaceholderText(/Buscar por nombre, especialidad/i);
    fireEvent.change(searchInput, { target: { value: 'MLOps' } });

    expect(screen.getByText('Carlos M. Soto')).toBeInTheDocument();
    expect(screen.queryByText('Dra. Elena Ruiz')).not.toBeInTheDocument();
  });

  it('opens assignment modal when clicking assign pro button', () => {
    render(<AdminConsultants />);

    const assignButtons = screen.getAllByRole('button', { name: /Asignar Pro/i });
    expect(assignButtons.length).toBeGreaterThan(0);

    fireEvent.click(assignButtons[0]);

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText(/Asignar Empresa Pro a Consultor/i)).toBeInTheDocument();
  });
});
