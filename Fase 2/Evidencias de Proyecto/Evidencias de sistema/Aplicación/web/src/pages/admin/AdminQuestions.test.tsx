import { describe, expect, it, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import '@/i18n';
import AdminQuestions from './AdminQuestions';
import { useQuestionBankStore } from '@/store/questionBankStore';

describe('AdminQuestions Page', () => {
  beforeEach(() => {
    localStorage.clear();
    useQuestionBankStore.getState().resetToDefaults();
  });

  it('renders question bank overview with 132 questions', () => {
    render(<AdminQuestions />);

    expect(screen.getByText('Banco de 132 Preguntas Metodológicas')).toBeInTheDocument();
    expect(screen.getByText('Catálogo Total')).toBeInTheDocument();
    expect(screen.getAllByText('132').length).toBeGreaterThan(0);
    expect(screen.getByText('Maturity (20) + 7 Áreas (112)')).toBeInTheDocument();
  });

  it('filters questions by search input', () => {
    render(<AdminQuestions />);

    const searchInput = screen.getByPlaceholderText(/Buscar por pregunta/i);
    fireEvent.change(searchInput, { target: { value: 'inventario' } });

    expect(screen.getByText(/¿Tienes inventario actualizado/i)).toBeInTheDocument();
  });

  it('opens multilingual editor modal when clicking edit', () => {
    render(<AdminQuestions />);

    const editButtons = screen.getAllByRole('button', { name: /Editar/i });
    expect(editButtons.length).toBeGreaterThan(0);

    fireEvent.click(editButtons[0]);

    expect(screen.getByText('Editor Multilingüe de Pregunta')).toBeInTheDocument();
    expect(screen.getByText(/Idiomas Disponibles/i)).toBeInTheDocument();
  });

  it('opens API contract export dialog when clicking mobile contract button', () => {
    render(<AdminQuestions />);

    const exportBtn = screen.getByRole('button', { name: /Contrato API Móvil/i });
    fireEvent.click(exportBtn);

    expect(screen.getByText('Contrato de API: Preguntas Publicadas')).toBeInTheDocument();
    expect(screen.getAllByText(/GET \/api\/v1\/questions\/published/i).length).toBeGreaterThan(0);
  });
});
