import { useState } from 'react';
import { Globe2, CheckCircle2, Sparkles, Save, X } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Textarea } from '@/components/ui/textarea';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import type { BankQuestion, MultilingualText, QuestionStatus } from '@/store/questionBankStore';

interface QuestionEditDialogProps {
  question: BankQuestion | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSave: (id: string, text: MultilingualText, status: QuestionStatus) => void;
}

const LANGUAGES = [
  { code: 'es', label: 'Español', flag: '🇪🇸' },
  { code: 'en', label: 'English', flag: '🇬🇧' },
  { code: 'de', label: 'Deutsch', flag: '🇩🇪' },
  { code: 'pt', label: 'Português', flag: '🇵🇹' },
] as const;

export function QuestionEditDialog({
  question,
  open,
  onOpenChange,
  onSave,
}: QuestionEditDialogProps) {
  const [activeLang, setActiveLang] = useState<'es' | 'en' | 'de' | 'pt'>('es');
  const [formData, setFormData] = useState<MultilingualText>(() => ({
    es: '',
    en: '',
    de: '',
    pt: '',
    ...question?.text,
  }));
  const [status, setStatus] = useState<QuestionStatus>(() => question?.status ?? 'published');
  const [error, setError] = useState<string | null>(null);

  if (!question) return null;

  const handleTextChange = (lang: 'es' | 'en' | 'de' | 'pt', val: string) => {
    setFormData((prev) => ({ ...prev, [lang]: val }));
    if (error && val.trim().length > 0) {
      setError(null);
    }
  };

  const handleSave = () => {
    // Validar que al menos la versión en español no esté vacía
    if (!formData.es.trim()) {
      setError('La pregunta en español es obligatoria y no puede quedar vacía.');
      setActiveLang('es');
      return;
    }

    onSave(question.id, formData, status);
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl sm:max-w-3xl overflow-hidden p-0 gap-0">
        <DialogHeader className="p-6 pb-4 border-b border-border/40 bg-card/60">
          <div className="flex items-center justify-between gap-3 mb-1">
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="font-mono text-xs font-bold border-primary/40 text-primary bg-primary/5">
                {question.code}
              </Badge>
              <Badge variant="secondary" className="text-[11px]">
                {question.moduleLabel}
              </Badge>
              {question.dim && (
                <Badge variant="outline" className="text-[11px] text-muted-foreground">
                  {question.dim}
                </Badge>
              )}
            </div>

            <div className="flex items-center gap-2">
              <span className="text-xs font-medium text-muted-foreground">
                {status === 'published' ? 'Publicado' : 'Borrador'}
              </span>
              <Switch
                checked={status === 'published'}
                onCheckedChange={(checked) => setStatus(checked ? 'published' : 'draft')}
                aria-label="Estado de publicación"
              />
            </div>
          </div>

          <DialogTitle className="text-lg font-bold">
            Editor Multilingüe de Pregunta
          </DialogTitle>
          <DialogDescription className="text-xs text-muted-foreground">
            {question.blockTitle} · ID interno: <code className="font-mono">{question.id}</code>
          </DialogDescription>
        </DialogHeader>

        <div className="p-6 space-y-5">
          {/* Tabs de Idiomas */}
          <Tabs
            value={activeLang}
            onValueChange={(val) => setActiveLang(val as 'es' | 'en' | 'de' | 'pt')}
            className="w-full"
          >
            <div className="flex items-center justify-between gap-2 mb-3">
              <Label className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                <Globe2 className="h-3.5 w-3.5 text-primary" />
                Idiomas Disponibles (4)
              </Label>
              <span className="text-[11px] text-muted-foreground">
                Editando: <strong className="text-foreground capitalize">{activeLang}</strong>
              </span>
            </div>

            <TabsList className="grid grid-cols-4 w-full h-10 p-1 bg-muted/60">
              {LANGUAGES.map((lang) => {
                const hasContent = formData[lang.code].trim().length > 0;
                return (
                  <TabsTrigger
                    key={lang.code}
                    value={lang.code}
                    className="flex items-center gap-1.5 text-xs font-medium cursor-pointer"
                  >
                    <span>{lang.flag}</span>
                    <span className="hidden sm:inline">{lang.label}</span>
                    <span className="sm:hidden uppercase">{lang.code}</span>
                    {hasContent ? (
                      <CheckCircle2 className="h-3 w-3 text-emerald-500 ml-0.5" />
                    ) : (
                      <span className="h-1.5 w-1.5 rounded-full bg-amber-500 ml-0.5" />
                    )}
                  </TabsTrigger>
                );
              })}
            </TabsList>

            {LANGUAGES.map((lang) => (
              <TabsContent key={lang.code} value={lang.code} className="mt-4 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-muted-foreground">
                    Formulación de la pregunta ({lang.label}):
                  </span>
                  <span className="text-[10px] font-mono text-muted-foreground">
                    {formData[lang.code].length} caracteres
                  </span>
                </div>
                <Textarea
                  value={formData[lang.code]}
                  onChange={(e) => handleTextChange(lang.code, e.target.value)}
                  placeholder={`Redacta la pregunta en ${lang.label}...`}
                  rows={4}
                  className="resize-none text-sm font-medium leading-relaxed bg-background/80 focus-visible:ring-primary/30"
                />
              </TabsContent>
            ))}
          </Tabs>

          {error && (
            <p className="text-xs font-semibold text-destructive flex items-center gap-1.5">
              <X className="h-4 w-4" />
              {error}
            </p>
          )}

          {/* Vista Previa para el Cliente */}
          <div className="rounded-xl border border-border/60 bg-muted/30 p-4 space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold text-muted-foreground uppercase tracking-wider flex items-center gap-1.5">
                <Sparkles className="h-3.5 w-3.5 text-primary" />
                Previsualización en Cuestionario ({activeLang.toUpperCase()})
              </span>
              <Badge variant={status === 'published' ? 'default' : 'secondary'} className="text-[10px] capitalize">
                {status === 'published' ? 'Visible en Evaluación' : 'Oculta (Borrador)'}
              </Badge>
            </div>
            <div className="rounded-lg border border-border/40 bg-card p-3 shadow-xs">
              <div className="flex items-start gap-2.5">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-md bg-primary/10 text-[11px] font-mono font-bold text-primary">
                  {question.code}
                </span>
                <p className="text-xs font-medium text-foreground leading-relaxed">
                  {formData[activeLang] || <em className="text-muted-foreground">Sin traducción para este idioma</em>}
                </p>
              </div>
            </div>
          </div>
        </div>

        <DialogFooter className="p-4 border-t border-border/40 bg-muted/20 flex items-center justify-between sm:justify-between">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => onOpenChange(false)}
            className="text-xs text-muted-foreground"
          >
            Cancelar
          </Button>

          <Button
            type="button"
            size="sm"
            onClick={handleSave}
            className="gap-2 brand-gradient text-white shadow-xs text-xs"
          >
            <Save className="h-3.5 w-3.5" />
            Guardar Cambios
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
