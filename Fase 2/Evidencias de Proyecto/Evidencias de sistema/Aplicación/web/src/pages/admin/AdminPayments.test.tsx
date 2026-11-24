import { describe, expect, it, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import '@/i18n';
import AdminPayments from './AdminPayments';
import { useAdminPlatformStore } from '@/store/adminPlatformStore';

describe('AdminPayments Page', () => {
  beforeEach(() => {
    localStorage.clear();
    useAdminPlatformStore.getState().resetToDefaults();
  });

  it('renders payments overview with revenue and metrics', () => {
    render(<AdminPayments />);

    expect(screen.getByText('Control de Pagos y Facturación B2B')).toBeInTheDocument();
    expect(screen.getByText('Ingresos Reconciliados')).toBeInTheDocument();
    expect(screen.getByText('Pendientes Conciliación')).toBeInTheDocument();
    expect(screen.getByText('INV-2026-0045')).toBeInTheDocument();
    expect(screen.getByText('TechInnovate Solutions')).toBeInTheDocument();
  });

  it('filters payments by search input', () => {
    render(<AdminPayments />);

    const searchInput = screen.getByPlaceholderText(/Buscar por factura/i);
    fireEvent.change(searchInput, { target: { value: 'INV-2026-0048' } });

    expect(screen.getByText('Logística Andina Express')).toBeInTheDocument();
    expect(screen.queryByText('TechInnovate Solutions')).not.toBeInTheDocument();
  });

  it('opens reconciliation modal when clicking reconcile button', () => {
    render(<AdminPayments />);

    const reconcileBtn = screen.getByRole('button', { name: /Conciliar/i });
    expect(reconcileBtn).toBeInTheDocument();

    fireEvent.click(reconcileBtn);

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText('Conciliar Transferencia Bancaria')).toBeInTheDocument();
  });

  it('opens manual payment registration dialog', () => {
    render(<AdminPayments />);

    const registerBtn = screen.getByRole('button', { name: /Registrar Pago Manual/i });
    fireEvent.click(registerBtn);

    expect(screen.getByText('Registrar Orden de Pago Manual')).toBeInTheDocument();
  });
});
