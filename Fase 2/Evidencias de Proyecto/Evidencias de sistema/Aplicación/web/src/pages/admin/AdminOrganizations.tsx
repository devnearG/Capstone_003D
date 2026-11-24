import { useState, useMemo, useEffect } from 'react';
import {
  Search,
  Sparkles,
  Users,
  Briefcase,
  CheckCircle2,
  AlertTriangle,
  RotateCcw,
  Zap,
} from 'lucide-react';
import {
  useAdminOrganizationsStore,
  type AdminOrganization,
} from '@/store/adminOrganizationsStore';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
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
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { toast } from 'sonner';

export default function AdminOrganizations() {
  const {
    organizations,
    load,
    toggleOrganizationPlan,
    toggleOrganizationStatus,
    resetToDefaults,
  } = useAdminOrganizationsStore();

  useEffect(() => {
    load().catch(() => {
      toast.error('No se pudieron cargar las organizaciones.');
    });
  }, [load]);

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedPlan, setSelectedPlan] = useState<string>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');

  // Modal para cambio de plan
  const [planSwitchOrg, setPlanSwitchOrg] = useState<AdminOrganization | null>(null);
  const [planSwitchOpen, setPlanSwitchOpen] = useState(false);

  // Métricas
  const totalOrgs = organizations.length;
  const proOrgsCount = organizations.filter((o) => o.plan === 'pro').length;
  const freeOrgsCount = organizations.filter((o) => o.plan === 'free').length;
  const avgMaturity = (
    organizations.reduce((acc, o) => acc + (o.maturityScore ?? 0), 0) /
    (organizations.filter((o) => o.maturityScore).length || 1)
  ).toFixed(1);

  // Filtrado reactivo
  const filteredOrgs = useMemo(() => {
    return organizations.filter((org) => {
      if (selectedPlan !== 'all' && org.plan !== selectedPlan) return false;
      if (selectedStatus !== 'all' && org.status !== selectedStatus) return false;

      if (searchQuery.trim()) {
        const q = searchQuery.trim().toLowerCase();
        const matchesName = org.name.toLowerCase().includes(q);
        const matchesSector = org.sector.toLowerCase().includes(q);
        const matchesSlug = org.slug.toLowerCase().includes(q);
        const matchesConsultant = org.consultantName?.toLowerCase().includes(q) ?? false;
        if (!matchesName && !matchesSector && !matchesSlug && !matchesConsultant) {
          return false;
        }
      }

      return true;
    });
  }, [organizations, selectedPlan, selectedStatus, searchQuery]);

  const handleOpenPlanSwitch = (org: AdminOrganization) => {
    setPlanSwitchOrg(org);
    setPlanSwitchOpen(true);
  };

  const handleConfirmPlanSwitch = async () => {
    if (planSwitchOrg) {
      try {
        await toggleOrganizationPlan(planSwitchOrg.id);
      } catch {
        toast.error('No se pudo actualizar el plan.');
        return;
      }
      setPlanSwitchOpen(false);
      setPlanSwitchOrg(null);
    }
  };

  const handleToggleOrganizationStatus = async (orgId: string) => {
    try {
      await toggleOrganizationStatus(orgId);
    } catch {
      toast.error('No se pudo actualizar el estado de la organización.');
    }
  };

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/40 pb-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="outline" className="border-primary/40 bg-primary/10 text-primary text-[10px] font-bold">
              ADM-08 a ADM-10
            </Badge>
            <Badge variant="secondary" className="text-[10px]">
              Gestión de Empresas & Planes
            </Badge>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            Organizaciones y Planes Empresariales
          </h1>
          <p className="mt-1 text-sm text-muted-foreground max-w-3xl">
            Supervisión global de empresas clientes, cuotas de miembros por área funcional y switch interactivo entre planes Freemium y Pro Enterprise.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            size="sm"
            variant="ghost"
            onClick={resetToDefaults}
            title="Restablecer organizaciones originales"
            className="text-xs text-muted-foreground hover:text-foreground h-9 w-9 p-0"
          >
            <RotateCcw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Métricas Globales */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Total Empresas</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">{totalOrgs}</span>
            <span className="text-xs text-muted-foreground">registradas</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Clientes corporativos</p>
        </div>

        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4">
          <span className="text-[11px] font-medium text-emerald-500">Plan Pro Enterprise</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-emerald-500">{proOrgsCount}</span>
            <Badge variant="outline" className="border-emerald-500/30 text-emerald-500 text-[10px]">
              {Math.round((proOrgsCount / totalOrgs) * 100)}%
            </Badge>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Acceso 7 módulos M1–M7</p>
        </div>

        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Plan Freemium</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">{freeOrgsCount}</span>
            <span className="text-xs text-muted-foreground">empresas</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Diagnóstico básico M1</p>
        </div>

        <div className="rounded-xl border border-primary/20 bg-primary/5 p-4">
          <span className="text-[11px] font-medium text-primary">Madurez Promedio</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-primary">{avgMaturity}</span>
            <span className="text-xs text-muted-foreground">/ 5.0</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Índice global de adopción</p>
        </div>
      </div>

      {/* Barra de Búsqueda y Filtros */}
      <Card className="border-border/60 bg-card/50 shadow-xs">
        <CardContent className="p-4 space-y-3">
          <div className="flex flex-col md:flex-row items-stretch md:items-center gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar por nombre de empresa, sector o consultor asignado..."
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

            <div className="w-full md:w-44">
              <Select value={selectedPlan} onValueChange={setSelectedPlan}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Plan" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos los Planes</SelectItem>
                  <SelectItem value="pro" className="text-xs">Pro Enterprise ({proOrgsCount})</SelectItem>
                  <SelectItem value="free" className="text-xs">Freemium ({freeOrgsCount})</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="w-full md:w-40">
              <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Estado" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos los Estados</SelectItem>
                  <SelectItem value="active" className="text-xs">Activas</SelectItem>
                  <SelectItem value="suspended" className="text-xs">Suspendidas</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="flex items-center justify-between text-xs text-muted-foreground pt-1">
            <span>
              Mostrando <strong>{filteredOrgs.length}</strong> de {totalOrgs} organizaciones
            </span>
            {(selectedPlan !== 'all' || selectedStatus !== 'all' || searchQuery) && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setSelectedPlan('all');
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

      {/* Tabla de Organizaciones */}
      <Card className="border-border/60 bg-card/60 shadow-xs overflow-hidden">
        <Table>
          <TableHeader className="bg-muted/40">
            <TableRow>
              <TableHead className="text-xs font-bold text-foreground">Empresa</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Plan Actual</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Progreso Diagnóstico</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Miembros</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Consultor Asignado</TableHead>
              <TableHead className="text-xs font-bold text-foreground text-right">Acciones</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredOrgs.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center py-8 text-xs text-muted-foreground">
                  No se encontraron empresas con los criterios seleccionados.
                </TableCell>
              </TableRow>
            ) : (
              filteredOrgs.map((org) => {
                const isPro = org.plan === 'pro';
                return (
                  <TableRow key={org.id} className="hover:bg-muted/30">
                    <TableCell>
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-xs text-foreground">{org.name}</span>
                          {org.status === 'suspended' && (
                            <Badge variant="destructive" className="text-[9px] px-1.5 py-0">
                              Suspendida
                            </Badge>
                          )}
                        </div>
                        <p className="text-[11px] text-muted-foreground mt-0.5">
                          {org.sector} · {org.size}
                        </p>
                      </div>
                    </TableCell>

                    <TableCell>
                      {isPro ? (
                        <Badge variant="default" className="gap-1 text-[10px] font-bold bg-emerald-600 hover:bg-emerald-600">
                          <Sparkles className="h-3 w-3" />
                          Pro Enterprise
                        </Badge>
                      ) : (
                        <Badge variant="secondary" className="text-[10px] font-medium">
                          Freemium
                        </Badge>
                      )}
                    </TableCell>

                    <TableCell className="w-48">
                      <div className="space-y-1">
                        <div className="flex items-center justify-between text-[11px]">
                          <span className="text-muted-foreground font-mono">{org.progress}%</span>
                          {org.maturityScore && (
                            <span className="font-semibold text-primary">
                              ★ {org.maturityScore}
                            </span>
                          )}
                        </div>
                        <Progress value={org.progress} className="h-1.5" />
                      </div>
                    </TableCell>

                    <TableCell>
                      <div className="flex items-center gap-1.5 text-xs">
                        <Users className="h-3.5 w-3.5 text-muted-foreground" />
                        <span className="font-mono">
                          {org.memberCount} / {org.maxMembers}
                        </span>
                      </div>
                    </TableCell>

                    <TableCell>
                      <div className="text-xs">
                        {org.consultantName ? (
                          <div className="flex items-center gap-1.5 text-foreground">
                            <Briefcase className="h-3.5 w-3.5 text-primary shrink-0" />
                            <span className="truncate max-w-[180px]">{org.consultantName}</span>
                          </div>
                        ) : (
                          <span className="text-[11px] text-muted-foreground italic">
                            Sin consultor asignado
                          </span>
                        )}
                      </div>
                    </TableCell>

                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          size="sm"
                          variant={isPro ? 'outline' : 'default'}
                          onClick={() => handleOpenPlanSwitch(org)}
                          className={isPro ? 'h-7 text-xs' : 'h-7 text-xs brand-gradient text-white shadow-2xs'}
                        >
                          <Zap className="h-3 w-3 mr-1" />
                          {isPro ? 'Bajar a Free' : 'Subir a Pro'}
                        </Button>

                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleToggleOrganizationStatus(org.id)}
                          className="h-7 text-[11px] text-muted-foreground hover:text-destructive"
                        >
                          {org.status === 'active' ? 'Suspender' : 'Reactivar'}
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                );
              })
            )}
          </TableBody>
        </Table>
      </Card>

      {/* Modal de Confirmación de Cambio de Plan (ADM-10) */}
      <Dialog open={planSwitchOpen} onOpenChange={setPlanSwitchOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <div className="flex items-center gap-2 mb-1">
              <Badge variant="outline" className="border-primary/40 text-primary text-[10px]">
                ADM-10 · Conmutación de Plan
              </Badge>
            </div>
            <DialogTitle className="text-lg font-bold">
              {planSwitchOrg?.plan === 'pro'
                ? 'Degradar Organización a Plan Freemium'
                : 'Actualizar Organización a Pro Enterprise'}
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Empresa: <strong className="text-foreground">{planSwitchOrg?.name}</strong>
            </DialogDescription>
          </DialogHeader>

          <div className="py-3 space-y-3">
            {planSwitchOrg?.plan === 'free' ? (
              <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4 space-y-2">
                <div className="flex items-center gap-2 text-emerald-500 font-bold text-xs">
                  <CheckCircle2 className="h-4 w-4" />
                  <span>Beneficios activados inmediatamente:</span>
                </div>
                <ul className="text-xs text-muted-foreground space-y-1.5 list-disc pl-5">
                  <li>Desbloqueo de los <strong>7 módulos funcionales</strong> (M1 a M7).</li>
                  <li>Ampliación de cuota de líderes de área de <strong>5 a 50 miembros</strong>.</li>
                  <li>Generación y descarga ilimitada del <strong>Reporte Ejecutivo en PDF</strong>.</li>
                  <li>Asignación de consultor sénior para revisión cualitativa en M7.</li>
                </ul>
              </div>
            ) : (
              <div className="rounded-xl border border-destructive/30 bg-destructive/5 p-4 space-y-2">
                <div className="flex items-center gap-2 text-destructive font-bold text-xs">
                  <AlertTriangle className="h-4 w-4" />
                  <span>Impacto de degradar a Freemium:</span>
                </div>
                <ul className="text-xs text-muted-foreground space-y-1.5 list-disc pl-5">
                  <li>Se restringe el acceso solo al <strong>Diagnóstico de Madurez (M1)</strong>.</li>
                  <li>El límite de colaboradores se reduce a <strong>5 miembros</strong>.</li>
                  <li>Se bloquea la descarga de reportes PDF de áreas funcionales.</li>
                </ul>
              </div>
            )}
          </div>

          <DialogFooter className="flex items-center justify-between sm:justify-between pt-2">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setPlanSwitchOpen(false)}
              className="text-xs text-muted-foreground"
            >
              Cancelar
            </Button>

            <Button
              type="button"
              size="sm"
              onClick={handleConfirmPlanSwitch}
              className={
                planSwitchOrg?.plan === 'free'
                  ? 'brand-gradient text-white text-xs shadow-xs'
                  : 'bg-destructive text-destructive-foreground text-xs hover:bg-destructive/90'
              }
            >
              {planSwitchOrg?.plan === 'free' ? 'Confirmar Activación Pro' : 'Confirmar Degradación'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
