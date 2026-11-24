import { describe, expect, it, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import '@/i18n';
import AdminAudit from './AdminAudit';
import { useAdminPlatformStore } from '@/store/adminPlatformStore';

describe('AdminAudit Page', () => {
  beforeEach(() => {
    localStorage.clear();
    useAdminPlatformStore.getState().resetToDefaults();
  });

  it('renders audit log overview and metrics', () => {
    render(<AdminAudit />);

    expect(screen.getByText('Bitácora de Auditoría del Sistema')).toBeInTheDocument();
    expect(screen.getByText('Eventos Registrados')).toBeInTheDocument();
    expect(screen.getByText('Banco de Preguntas')).toBeInTheDocument();
    expect(screen.getByText('Publicación de Banco Metodológico')).toBeInTheDocument();
    expect(screen.getByText('Ascenso a Plan Pro')).toBeInTheDocument();
  });

  it('filters audit logs by search query', () => {
    render(<AdminAudit />);

    const searchInput = screen.getByPlaceholderText(/Buscar por usuario actor/i);
    fireEvent.change(searchInput, { target: { value: 'matias.lopez' } });

    expect(screen.getByText('matias.lopez@tryaigap.com')).toBeInTheDocument();
    expect(screen.queryByText('fabrizio.martinez@tryaigap.com')).not.toBeInTheDocument();
  });

  it('provides export button for audit log', () => {
    render(<AdminAudit />);

    const exportBtn = screen.getByRole('button', { name: /Exportar Bitácora \(JSON\)/i });
    expect(exportBtn).toBeInTheDocument();
  });
});
