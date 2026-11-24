import { useState, useMemo, useEffect } from 'react';
import {
  HelpCircle,
  Search,
  CheckCircle2,
  FileJson,
  RotateCcw,
  Pencil,
  Copy,
  Check,
  Download,
  Globe2,
} from 'lucide-react';
import { useQuestionBankStore, type BankQuestion, type MultilingualText, type QuestionStatus } from '@/store/questionBankStore';
import { QuestionEditDialog } from '@/components/admin/QuestionEditDialog';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Switch } from '@/components/ui/switch';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

const MODULES = [
  { key: 'all', label: 'Todos los Módulos', count: 132 },
  { key: 'maturity', label: 'Madurez Digital (M1)', count: 20 },
  { key: 'ventas', label: 'Ventas (M2)', count: 16 },
  { key: 'marketing', label: 'Marketing (M3)', count: 16 },
  { key: 'servicio', label: 'Servicio al Cliente (M4)', count: 16 },
  { key: 'finanzas', label: 'Finanzas (M5)', count: 16 },
  { key: 'rrhh', label: 'Gestión RRHH (M6)', count: 16 },
  { key: 'operaciones', label: 'Operaciones (M7)', count: 16 },
  { key: 'legal', label: 'Legal & Compliance', count: 16 },
] as const;

export default function AdminQuestions() {
  const {
    questions,
    updateQuestion,
    toggleStatus,
    publishAll,
    resetToDefaults,
    load,
  } = useQuestionBankStore();

  useEffect(() => {
    load().catch(() => {
      toast.error('No se pudo cargar el banco de preguntas.');
    });
  }, [load]);

  // Estados de filtrado y búsqueda
  const [selectedModule, setSelectedModule] = useState<string>('all');
  const [selectedBlock, setSelectedBlock] = useState<string>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [previewLang, setPreviewLang] = useState<'es' | 'en' | 'de' | 'pt'>('es');

  // Estados de diálogos
  const [editingQuestion, setEditingQuestion] = useState<BankQuestion | null>(null);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [exportDialogOpen, setExportDialogOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  // Métricas
  const totalQuestions = questions.length;
  const publishedCount = questions.filter((q) => q.status === 'published').length;
  const draftCount = totalQuestions - publishedCount;

  // Filtrado reactivo de preguntas
  const filteredQuestions = useMemo(() => {
    return questions.filter((q) => {
      // Filtro de Módulo
      if (selectedModule !== 'all' && q.moduleKey !== selectedModule) return false;

      // Filtro de Bloque
      if (selectedBlock !== 'all' && q.blockId !== selectedBlock) return false;

      // Filtro de Estado
      if (selectedStatus !== 'all' && q.status !== selectedStatus) return false;

      // Filtro de Búsqueda
      if (searchQuery.trim()) {
        const query = searchQuery.trim().toLowerCase();
        const matchesCode = q.code.toLowerCase().includes(query);
        const matchesId = q.id.toLowerCase().includes(query);
        const matchesTextEs = q.text.es.toLowerCase().includes(query);
        const matchesTextEn = q.text.en.toLowerCase().includes(query);
        const matchesTextDe = q.text.de.toLowerCase().includes(query);
        const matchesTextPt = q.text.pt.toLowerCase().includes(query);
        const matchesModule = q.moduleLabel.toLowerCase().includes(query);
        const matchesBlock = q.blockTitle.toLowerCase().includes(query);

        if (
          !matchesCode &&
          !matchesId &&
          !matchesTextEs &&
          !matchesTextEn &&
          !matchesTextDe &&
          !matchesTextPt &&
          !matchesModule &&
          !matchesBlock
        ) {
          return false;
        }
      }

      return true;
    });
  }, [questions, selectedModule, selectedBlock, selectedStatus, searchQuery]);

  // Agrupación por Bloque para visualización jerárquica
  const groupedByBlock = useMemo(() => {
    const groups: Record<string, { blockTitle: string; moduleLabel: string; items: BankQuestion[] }> = {};
    for (const q of filteredQuestions) {
      const groupKey = `${q.moduleKey}-${q.blockId}`;
      if (!groups[groupKey]) {
        groups[groupKey] = {
          blockTitle: q.blockTitle,
          moduleLabel: q.moduleLabel,
          items: [],
        };
      }
      groups[groupKey].items.push(q);
    }
    return groups;
  }, [filteredQuestions]);

  const handleEditClick = (q: BankQuestion) => {
    setEditingQuestion(q);
    setEditDialogOpen(true);
  };

  const handleSaveQuestion = (id: string, text: MultilingualText, status: QuestionStatus) => {
    updateQuestion(id, text, status).catch(() => {
      toast.error('No se pudo guardar la pregunta.');
    });
  };

  // Contrato API JSON para el equipo móvil de Andrew
  const exportJsonPayload = useMemo(() => {
    const published = questions.filter((q) => q.status === 'published');
    return {
      schemaVersion: '2.0.0',
      contract: 'GET /api/v1/questions/published',
      generatedAt: new Date().toISOString(),
      totalPublished: published.length,
      locale: previewLang,
      questions: published.map((q) => ({
        id: q.id,
        code: q.code,
        module: q.moduleKey,
        moduleLabel: q.moduleLabel,
        blockId: q.blockId,
        blockTitle: q.blockTitle,
        dim: q.dim ?? null,
        text: q.text[previewLang],
        status: q.status,
      })),
    };
  }, [questions, previewLang]);

  const handleCopyJson = () => {
    navigator.clipboard.writeText(JSON.stringify(exportJsonPayload, null, 2));
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadJson = () => {
    const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(exportJsonPayload, null, 2));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('href', dataStr);
    downloadAnchor.setAttribute('download', `tryaigap_questions_${previewLang}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
  };

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/40 pb-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="outline" className="border-primary/40 bg-primary/10 text-primary text-[10px] font-bold">
              ADM-03 a ADM-07
            </Badge>
            <Badge variant="secondary" className="text-[10px]">
              Banco Dinámico de Preguntas
            </Badge>
            <Badge variant="outline" className="text-[10px] border-emerald-500/40 text-emerald-500 bg-emerald-500/5">
              4 Idiomas Activos
            </Badge>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            Banco de 132 Preguntas Metodológicas
          </h1>
          <p className="mt-1 text-sm text-muted-foreground max-w-3xl">
            Supervisión, edición en vivo en 4 idiomas (ES, EN, DE, PT) y control de publicación para el motor de diagnóstico web y la App Móvil.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <Button
            size="sm"
            variant="outline"
            onClick={() => setExportDialogOpen(true)}
            className="gap-2 text-xs border-border/60 hover:bg-muted"
          >
            <FileJson className="h-4 w-4 text-primary" />
            <span>Contrato API Móvil</span>
          </Button>

          {draftCount > 0 && (
            <Button
              size="sm"
              variant="default"
              onClick={publishAll}
              className="gap-1.5 text-xs brand-gradient text-white shadow-xs"
            >
              <CheckCircle2 className="h-3.5 w-3.5" />
              <span>Publicar Todo ({draftCount})</span>
            </Button>
          )}

          <Button
            size="sm"
            variant="ghost"
            onClick={resetToDefaults}
            title="Restablecer valores predeterminados"
            className="text-xs text-muted-foreground hover:text-foreground h-9 w-9 p-0"
          >
            <RotateCcw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Tarjetas de Métricas de Publicación */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Catálogo Total</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">{totalQuestions}</span>
            <span className="text-xs text-muted-foreground">preguntas</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Maturity (20) + 7 Áreas (112)</p>
        </div>

        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4">
          <span className="text-[11px] font-medium text-emerald-500">Publicadas Activas</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-emerald-500">{publishedCount}</span>
            <Badge variant="outline" className="border-emerald-500/30 text-emerald-500 text-[10px]">
              {Math.round((publishedCount / totalQuestions) * 100)}%
            </Badge>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Disponibles para evaluación</p>
        </div>

        <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-4">
          <span className="text-[11px] font-medium text-amber-500">En Borrador</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-amber-500">{draftCount}</span>
            <span className="text-xs text-muted-foreground">ocultas</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Pendientes de publicación</p>
        </div>

        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Cobertura Idiomas</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">4 / 4</span>
            <span className="text-xs text-emerald-500 font-medium">100%</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">ES · EN · DE · PT</p>
        </div>
      </div>

      {/* Barra de Filtros y Búsqueda */}
      <Card className="border-border/60 bg-card/50 shadow-xs">
        <CardContent className="p-4 space-y-3">
          <div className="flex flex-col md:flex-row items-stretch md:items-center gap-3">
            {/* Buscador */}
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar por pregunta, ID (ej. A1, B3), módulo o palabra clave..."
                className="pl-9 h-9 text-xs bg-background/80"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery('')}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground text-xs"
                >
                  ✕
                </button>
              )}
            </div>

            {/* Selector de Módulo */}
            <div className="w-full md:w-56">
              <Select value={selectedModule} onValueChange={setSelectedModule}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Módulo" />
                </SelectTrigger>
                <SelectContent>
                  {MODULES.map((m) => (
                    <SelectItem key={m.key} value={m.key} className="text-xs">
                      {m.label} ({m.count})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Selector de Bloque */}
            <div className="w-full md:w-40">
              <Select value={selectedBlock} onValueChange={setSelectedBlock}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Bloque" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos los Bloques</SelectItem>
                  <SelectItem value="A" className="text-xs">Bloque A</SelectItem>
                  <SelectItem value="B" className="text-xs">Bloque B</SelectItem>
                  <SelectItem value="C" className="text-xs">Bloque C</SelectItem>
                  <SelectItem value="D" className="text-xs">Bloque D</SelectItem>
                  <SelectItem value="E" className="text-xs">Bloque E</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Selector de Estado */}
            <div className="w-full md:w-36">
              <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Estado" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos ({totalQuestions})</SelectItem>
                  <SelectItem value="published" className="text-xs">Publicados ({publishedCount})</SelectItem>
                  <SelectItem value="draft" className="text-xs">Borradores ({draftCount})</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Idioma de Previsualización */}
            <div className="flex items-center gap-1.5 border border-border/60 rounded-lg p-1 bg-muted/40">
              <span className="text-[10px] font-semibold text-muted-foreground px-1 uppercase">Ver:</span>
              {(['es', 'en', 'de', 'pt'] as const).map((lang) => (
                <button
                  key={lang}
                  onClick={() => setPreviewLang(lang)}
                  className={cn(
                    'px-2 py-0.5 rounded text-[10px] font-bold uppercase transition-colors cursor-pointer',
                    previewLang === lang
                      ? 'bg-primary text-primary-foreground shadow-2xs'
                      : 'text-muted-foreground hover:text-foreground',
                  )}
                >
                  {lang}
                </button>
              ))}
            </div>
          </div>

          <div className="flex items-center justify-between text-xs text-muted-foreground pt-1">
            <span>
              Mostrando <strong>{filteredQuestions.length}</strong> de {totalQuestions} preguntas
            </span>
            {(selectedModule !== 'all' || selectedBlock !== 'all' || selectedStatus !== 'all' || searchQuery) && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setSelectedModule('all');
                  setSelectedBlock('all');
                  setSelectedStatus('all');
                  setSearchQuery('');
                }}
                className="h-6 px-2 text-[11px] text-primary hover:bg-primary/10"
              >
                Limpiar filtros
              </Button>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Listado Jerárquico de Preguntas por Bloque */}
      {filteredQuestions.length === 0 ? (
        <Card className="border-border/60 bg-card/40 p-12 text-center">
          <HelpCircle className="mx-auto h-10 w-10 text-muted-foreground/60 mb-3" />
          <h3 className="text-sm font-bold text-foreground">No se encontraron preguntas</h3>
          <p className="mt-1 text-xs text-muted-foreground max-w-sm mx-auto">
            Ninguna pregunta coincide con los filtros o el término de búsqueda actual. Intenta limpiar los filtros.
          </p>
        </Card>
      ) : (
        <div className="space-y-6">
          {Object.entries(groupedByBlock).map(([groupKey, group]) => (
            <div key={groupKey} className="space-y-3">
              <div className="flex items-center justify-between px-1">
                <div className="flex items-center gap-2">
                  <span className="h-2 w-2 rounded-full brand-gradient inline-block" />
                  <h2 className="text-sm font-bold text-foreground">
                    {group.blockTitle}
                  </h2>
                  <Badge variant="outline" className="text-[10px] border-border/70 text-muted-foreground">
                    {group.moduleLabel}
                  </Badge>
                </div>
                <span className="text-[11px] text-muted-foreground font-mono">
                  {group.items.length} {group.items.length === 1 ? 'pregunta' : 'preguntas'}
                </span>
              </div>

              <div className="grid grid-cols-1 gap-2.5">
                {group.items.map((q) => (
                  <div
                    key={q.id}
                    className={cn(
                      'group relative flex flex-col md:flex-row md:items-center justify-between gap-3 rounded-xl border p-3.5 transition-all duration-150',
                      q.status === 'published'
                        ? 'border-border/60 bg-card/60 hover:border-primary/40'
                        : 'border-amber-500/30 bg-amber-500/5 hover:border-amber-500/50',
                    )}
                  >
                    <div className="flex items-start gap-3 flex-1 min-w-0">
                      <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-xs font-mono font-bold text-primary mt-0.5">
                        {q.code}
                      </span>
                      <div className="space-y-1 min-w-0 flex-1">
                        <p className="text-xs font-medium text-foreground leading-relaxed">
                          {q.text[previewLang]}
                        </p>
                        <div className="flex flex-wrap items-center gap-2 text-[10px] text-muted-foreground">
                          <span className="font-mono">{q.id}</span>
                          {q.dim && (
                            <>
                              <span>·</span>
                              <span className="text-primary font-medium">{q.dim}</span>
                            </>
                          )}
                          <span>·</span>
                          <span className="flex items-center gap-1">
                            <Globe2 className="h-3 w-3 text-emerald-500" />
                            4 idiomas
                          </span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center justify-between md:justify-end gap-3 shrink-0 pt-2 md:pt-0 border-t md:border-t-0 border-border/40">
                      <div className="flex items-center gap-2">
                        <span className="text-[11px] text-muted-foreground">
                          {q.status === 'published' ? (
                            <span className="text-emerald-500 font-medium">Publicado</span>
                          ) : (
                            <span className="text-amber-500 font-medium">Borrador</span>
                          )}
                        </span>
                        <Switch
                          checked={q.status === 'published'}
                          onCheckedChange={() => toggleStatus(q.id)}
                          aria-label={`Cambiar estado de ${q.code}`}
                        />
                      </div>

                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleEditClick(q)}
                        className="gap-1.5 h-8 text-xs border-border/70 hover:bg-primary/10 hover:text-primary"
                      >
                        <Pencil className="h-3.5 w-3.5" />
                        <span>Editar</span>
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal de Edición Multilingüe */}
      <QuestionEditDialog
        key={editingQuestion?.id ?? 'closed'}
        question={editingQuestion}
        open={editDialogOpen}
        onOpenChange={setEditDialogOpen}
        onSave={handleSaveQuestion}
      />

      {/* Modal de Exportación de Contrato API (Para Andrew / Móvil) */}
      <Dialog open={exportDialogOpen} onOpenChange={setExportDialogOpen}>
        <DialogContent className="max-w-2xl sm:max-w-3xl">
          <DialogHeader>
            <div className="flex items-center gap-2 mb-1">
              <Badge variant="outline" className="text-[10px] border-primary/40 text-primary font-mono">
                GET /api/v1/questions/published
              </Badge>
              <Badge variant="secondary" className="text-[10px]">
                Contrato Móvil
              </Badge>
            </div>
            <DialogTitle className="text-lg font-bold">
              Contrato de API: Preguntas Publicadas
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Este payload representa el esquema exacto que consumirá la App Móvil de Andrew ({publishedCount} preguntas en {previewLang.toUpperCase()}).
            </DialogDescription>
          </DialogHeader>

          <div className="relative mt-2">
            <pre className="max-h-96 overflow-y-auto rounded-xl border border-border/60 bg-muted/40 p-4 text-[11px] font-mono text-foreground leading-relaxed">
              {JSON.stringify(exportJsonPayload, null, 2)}
            </pre>
          </div>

          <DialogFooter className="flex items-center justify-between sm:justify-between pt-3">
            <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
              <span>Idioma exportado:</span>
              <strong className="text-foreground uppercase">{previewLang}</strong>
            </div>

            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={handleCopyJson}
                className="gap-1.5 text-xs"
              >
                {copied ? <Check className="h-3.5 w-3.5 text-emerald-500" /> : <Copy className="h-3.5 w-3.5" />}
                <span>{copied ? 'Copiado al Portapapeles' : 'Copiar JSON'}</span>
              </Button>

              <Button
                size="sm"
                onClick={handleDownloadJson}
                className="gap-1.5 text-xs brand-gradient text-white shadow-xs"
              >
                <Download className="h-3.5 w-3.5" />
                <span>Descargar JSON</span>
              </Button>
            </div>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
