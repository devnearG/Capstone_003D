import { create } from 'zustand';
import esQBank from '@/i18n/locales/qbank.es.json';
import enQBank from '@/i18n/locales/qbank.en.json';
import deQBank from '@/i18n/locales/qbank.de.json';
import ptQBank from '@/i18n/locales/qbank.pt.json';
import { fetchAdminQuestions, publishAdminQuestions, updateAdminQuestion } from '@/api';
import { hasSession } from '@/api/client';
import type { AdminQuestion } from '@/api/types';

export type QuestionStatus = 'published' | 'draft';

export interface MultilingualText {
  es: string;
  en: string;
  de: string;
  pt: string;
}

export interface BankQuestion {
  id: string; // e.g. "maturity-A-A1" or "ventas-B-B2"
  moduleKey: string; // "maturity", "ventas", "marketing", etc.
  moduleLabel: string;
  blockId: string; // "A", "B", "C", "D", "E"
  blockTitle: string;
  code: string; // "A1", "A2", etc.
  dim?: string;
  text: MultilingualText;
  status: QuestionStatus;
  updatedAt?: string;
}

const STORAGE_KEY = 'tryaigap.admin.qbank_overrides';

const MODULE_LABELS: Record<string, string> = {
  maturity: 'Diagnóstico de Madurez',
  ventas: 'Ventas y Comercial',
  marketing: 'Marketing Digital',
  servicio: 'Atención y Servicio al Cliente',
  finanzas: 'Finanzas y Contabilidad',
  rrhh: 'Gestión del Talento y RRHH',
  operaciones: 'Operaciones y Logística',
  legal: 'Legal, Riesgo y Compliance',
};

function buildInitialQuestions(): BankQuestion[] {
  const list: BankQuestion[] = [];

  // 1. Maturity Questions (20 questions)
  esQBank.maturity.blocks.forEach((blockEs, blockIdx) => {
    const blockEn = enQBank.maturity.blocks[blockIdx];
    const blockDe = deQBank.maturity.blocks[blockIdx];
    const blockPt = ptQBank.maturity.blocks[blockIdx];

    blockEs.questions.forEach((qEs, qIdx) => {
      const qEn = blockEn?.questions[qIdx];
      const qDe = blockDe?.questions[qIdx];
      const qPt = blockPt?.questions[qIdx];

      list.push({
        id: `maturity-${blockEs.id}-${qEs.id}`,
        moduleKey: 'maturity',
        moduleLabel: MODULE_LABELS.maturity,
        blockId: blockEs.id,
        blockTitle: blockEs.title,
        dim: blockEs.dim,
        code: qEs.id,
        text: {
          es: qEs.text,
          en: qEn?.text ?? qEs.text,
          de: qDe?.text ?? qEs.text,
          pt: qPt?.text ?? qEs.text,
        },
        status: 'published',
      });
    });
  });

  // 2. Functional Area Questions (7 areas * 16 questions = 112 questions)
  const areaKeys = Object.keys(esQBank.areas) as Array<keyof typeof esQBank.areas>;
  areaKeys.forEach((areaKey) => {
    const blocksEs = esQBank.areas[areaKey];
    const blocksEn = (enQBank.areas as unknown as Record<string, typeof blocksEs>)[areaKey];
    const blocksDe = (deQBank.areas as unknown as Record<string, typeof blocksEs>)[areaKey];
    const blocksPt = (ptQBank.areas as unknown as Record<string, typeof blocksEs>)[areaKey];

    blocksEs.forEach((blockEs, blockIdx) => {
      const blockEn = blocksEn?.[blockIdx];
      const blockDe = blocksDe?.[blockIdx];
      const blockPt = blocksPt?.[blockIdx];

      blockEs.questions.forEach((qEs, qIdx) => {
        const qEn = blockEn?.questions[qIdx];
        const qDe = blockDe?.questions[qIdx];
        const qPt = blockPt?.questions[qIdx];

        list.push({
          id: `${areaKey}-${blockEs.id}-${qEs.id}`,
          moduleKey: areaKey,
          moduleLabel: MODULE_LABELS[areaKey] ?? areaKey,
          blockId: blockEs.id,
          blockTitle: blockEs.title,
          code: qEs.id,
          text: {
            es: qEs.text,
            en: qEn?.text ?? qEs.text,
            de: qDe?.text ?? qEs.text,
            pt: qPt?.text ?? qEs.text,
          },
          status: 'published',
        });
      });
    });
  });

  // Cargar overrides guardados en localStorage si existen
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      const overrides: Record<string, Partial<BankQuestion>> = JSON.parse(saved);
      return list.map((q) => {
        if (overrides[q.id]) {
          return {
            ...q,
            ...overrides[q.id],
            text: {
              ...q.text,
              ...(overrides[q.id].text ?? {}),
            },
          };
        }
        return q;
      });
    }
  } catch {
    // Si falla el parseo, retorna el listado base
  }

  return list;
}

function persistOverrides(questions: BankQuestion[]) {
  try {
    const base = buildInitialDefaultMap();
    const overrides: Record<string, Partial<BankQuestion>> = {};
    for (const q of questions) {
      const def = base[q.id];
      if (!def) continue;
      const isModified =
        q.status !== def.status ||
        q.text.es !== def.text.es ||
        q.text.en !== def.text.en ||
        q.text.de !== def.text.de ||
        q.text.pt !== def.text.pt;

      if (isModified) {
        overrides[q.id] = {
          status: q.status,
          text: q.text,
          updatedAt: q.updatedAt,
        };
      }
    }
    localStorage.setItem(STORAGE_KEY, JSON.stringify(overrides));
  } catch {
    // LocalStorage lleno o restringido
  }
}

function buildInitialDefaultMap(): Record<string, BankQuestion> {
  const map: Record<string, BankQuestion> = {};
  // Crea el mapeo limpio sin leer localStorage
  const saved = localStorage.getItem(STORAGE_KEY);
  localStorage.removeItem(STORAGE_KEY);
  const defs = buildInitialQuestions();
  if (saved) localStorage.setItem(STORAGE_KEY, saved);
  for (const q of defs) {
    map[q.id] = q;
  }
  return map;
}

interface QuestionBankState {
  questions: BankQuestion[];
  loading: boolean;
  load: () => Promise<void>;
  updateQuestion: (id: string, text: MultilingualText, status?: QuestionStatus) => Promise<void>;
  toggleStatus: (id: string) => Promise<void>;
  setModuleStatus: (moduleKey: string, status: QuestionStatus) => void;
  publishAll: () => Promise<void>;
  resetToDefaults: () => Promise<void>;
  getPublishedQuestions: () => BankQuestion[];
}

function toBankQuestion(question: AdminQuestion): BankQuestion {
  const text = { es: '', en: '', de: '', pt: '' } as MultilingualText;
  let blockTitle = question.block_id;
  for (const translation of question.translations) {
    if (translation.locale in text) {
      text[translation.locale] = translation.text;
    }
    if (translation.locale === 'es' || (!blockTitle && translation.block_title)) {
      blockTitle = translation.block_title || blockTitle;
    }
  }
  const moduleKey = question.area_key || question.module;
  return {
    id: question.id,
    moduleKey,
    moduleLabel: MODULE_LABELS[moduleKey] ?? moduleKey,
    blockId: question.block_id,
    blockTitle,
    code: question.code,
    dim: question.dimension ?? undefined,
    text,
    status: question.status,
  };
}

function toTranslations(text: MultilingualText, blockTitle: string) {
  return (Object.keys(text) as Array<keyof MultilingualText>).map((locale) => ({
    locale,
    text: text[locale],
    block_title: blockTitle,
  }));
}

export const useQuestionBankStore = create<QuestionBankState>((set, get) => ({
  questions: buildInitialQuestions(),
  loading: false,

  async load() {
    set({ loading: true });
    try {
      const questions = await fetchAdminQuestions();
      set({ questions: questions.map(toBankQuestion), loading: false });
    } catch (error) {
      set({ loading: false });
      throw error;
    }
  },

  async updateQuestion(id, text, status) {
    const current = get().questions.find((question) => question.id === id);
    if (!current) return;
    const nextStatus = status ?? current.status;
    set((state) => {
      const next = state.questions.map((question) =>
        question.id === id
          ? { ...question, text, status: nextStatus, updatedAt: new Date().toISOString() }
          : question,
      );
      persistOverrides(next);
      return { questions: next };
    });
    if (!await hasSession()) return;
    const updated = await updateAdminQuestion(id, {
      status: nextStatus,
      translations: toTranslations(text, current.blockTitle),
    });
    set((state) => ({
      questions: state.questions.map((question) =>
        question.id === id ? toBankQuestion(updated) : question,
      ),
    }));
  },

  async toggleStatus(id) {
    const question = get().questions.find((item) => item.id === id);
    if (!question) return;
    await get().updateQuestion(id, question.text, question.status === 'published' ? 'draft' : 'published');
  },

  setModuleStatus: (moduleKey, status) => {
    set((state) => {
      const next = state.questions.map((q) => {
        if (q.moduleKey === moduleKey) {
          return {
            ...q,
            status,
            updatedAt: new Date().toISOString(),
          };
        }
        return q;
      });
      persistOverrides(next);
      return { questions: next };
    });
  },

  async publishAll() {
    set((state) => {
      const next = state.questions.map((question) => ({
        ...question,
        status: 'published' as QuestionStatus,
        updatedAt: new Date().toISOString(),
      }));
      persistOverrides(next);
      return { questions: next };
    });
    if (!await hasSession()) return;
    await publishAdminQuestions();
  },

  async resetToDefaults() {
    try {
      await get().load();
    } catch {
      set({ questions: buildInitialQuestions() });
    }
  },

  getPublishedQuestions: () => {
    return get().questions.filter((q) => q.status === 'published');
  },
}));
