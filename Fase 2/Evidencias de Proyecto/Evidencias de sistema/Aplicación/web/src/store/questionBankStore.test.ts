import { describe, expect, it, beforeEach } from 'vitest';
import { useQuestionBankStore } from './questionBankStore';

describe('questionBankStore', () => {
  beforeEach(() => {
    localStorage.clear();
    useQuestionBankStore.getState().resetToDefaults();
  });

  it('initializes exactly 132 questions across maturity and 7 functional areas', () => {
    const questions = useQuestionBankStore.getState().questions;
    expect(questions.length).toBe(132);

    const maturityQs = questions.filter((q) => q.moduleKey === 'maturity');
    expect(maturityQs.length).toBe(20);

    const areas = ['ventas', 'marketing', 'servicio', 'finanzas', 'rrhh', 'operaciones', 'legal'];
    for (const area of areas) {
      const areaQs = questions.filter((q) => q.moduleKey === area);
      expect(areaQs.length).toBe(16);
    }
  });

  it('all questions default to published status with multilingual translations', () => {
    const questions = useQuestionBankStore.getState().questions;
    const published = useQuestionBankStore.getState().getPublishedQuestions();
    expect(published.length).toBe(132);

    for (const q of questions) {
      expect(q.status).toBe('published');
      expect(q.text.es.length).toBeGreaterThan(0);
      expect(q.text.en.length).toBeGreaterThan(0);
      expect(q.text.de.length).toBeGreaterThan(0);
      expect(q.text.pt.length).toBeGreaterThan(0);
    }
  });

  it('toggles question status between published and draft', () => {
    const firstId = useQuestionBankStore.getState().questions[0].id;
    useQuestionBankStore.getState().toggleStatus(firstId);

    let updated = useQuestionBankStore.getState().questions.find((q) => q.id === firstId);
    expect(updated?.status).toBe('draft');

    useQuestionBankStore.getState().toggleStatus(firstId);
    updated = useQuestionBankStore.getState().questions.find((q) => q.id === firstId);
    expect(updated?.status).toBe('published');
  });

  it('updates question text across languages and persists', () => {
    const firstId = useQuestionBankStore.getState().questions[0].id;
    const customText = {
      es: 'Texto modificado en español',
      en: 'Modified text in English',
      de: 'Geänderter Text auf Deutsch',
      pt: 'Texto modificado em português',
    };

    useQuestionBankStore.getState().updateQuestion(firstId, customText, 'draft');

    const updated = useQuestionBankStore.getState().questions.find((q) => q.id === firstId);
    expect(updated?.text).toEqual(customText);
    expect(updated?.status).toBe('draft');
    expect(updated?.updatedAt).toBeDefined();
  });

  it('sets all questions in a module to a target status', () => {
    useQuestionBankStore.getState().setModuleStatus('ventas', 'draft');
    const ventasQs = useQuestionBankStore.getState().questions.filter((q) => q.moduleKey === 'ventas');
    expect(ventasQs.every((q) => q.status === 'draft')).toBe(true);

    useQuestionBankStore.getState().publishAll();
    const allPublished = useQuestionBankStore.getState().questions.every((q) => q.status === 'published');
    expect(allPublished).toBe(true);
  });
});
