import { useState, useMemo, useEffect } from 'react';
import {
  Search,
  Star,
  Plus,
  X,
  CheckCircle2,
  Building2,
  RotateCcw,
} from 'lucide-react';
import {
  useAdminPlatformStore,
  type ConsultantProfile,
} from '@/store/adminPlatformStore';
import { useAdminOrganizationsStore } from '@/store/adminOrganizationsStore';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
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
import { toast } from 'sonner';

export default function AdminConsultants() {
  const {
    consultants,
    loadConsultants,
    assignConsultantToOrg,
    removeConsultantFromOrg,
    resetToDefaults,
  } = useAdminPlatformStore();

  const { organizations, load: loadOrganizations, updateOrganization } = useAdminOrganizationsStore();

  useEffect(() => {
    Promise.all([loadConsultants(), loadOrganizations()]).catch(() => {
      toast.error('No se pudieron cargar los consultores.');
    });
  }, [loadConsultants, loadOrganizations]);

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSeniority, setSelectedSeniority] = useState<string>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');

  // Modal para asignación
  const [assignDialogOpen, setAssignDialogOpen] = useState(false);
  const [targetConsultant, setTargetConsultant] = useState<ConsultantProfile | null>(null);
  const [selectedOrgId, setSelectedOrgId] = useState<string>('');

  // Organizaciones elegibles para consultoría (Plan Pro)
  const proOrganizations = useMemo(() => {
    return organizations.filter((org) => org.plan === 'pro');
  }, [organizations]);

  // Métricas
  const totalConsultants = consultants.length;
  const activeReviewsCount = consultants.reduce((acc, c) => acc + c.activeReviews, 0);
  const completedReviewsCount = consultants.reduce((acc, c) => acc + c.completedReviews, 0);
  const avgRating = (
    consultants.reduce((acc, c) => acc + c.rating, 0) / (consultants.length || 1)
  ).toFixed(2);

  // Filtrado reactivo
  const filteredConsultants = useMemo(() => {
    return consultants.filter((c) => {
      if (selectedSeniority !== 'all' && c.seniority !== selectedSeniority) return false;
      if (selectedStatus !== 'all' && c.status !== selectedStatus) return false;

      if (searchQuery.trim()) {
        const q = searchQuery.trim().toLowerCase();
        const matchesName = c.name.toLowerCase().includes(q);
        const matchesSpecialty = c.specialty.toLowerCase().includes(q);
        const matchesEmail = c.email.toLowerCase().includes(q);
        const matchesOrg = c.assignedOrgNames.some((org) => org.toLowerCase().includes(q));

        if (!matchesName && !matchesSpecialty && !matchesEmail && !matchesOrg) {
          return false;
        }
      }

      return true;
    });
  }, [consultants, selectedSeniority, selectedStatus, searchQuery]);

  const handleOpenAssignModal = (consultant: ConsultantProfile) => {
    setTargetConsultant(consultant);
    setSelectedOrgId('');
    setAssignDialogOpen(true);
  };

  const handleConfirmAssignment = async () => {
    if (!targetConsultant || !selectedOrgId) return;

    const org = organizations.find((o) => o.id === selectedOrgId);
    if (!org) return;

    // Asignar en store de consultores
    try {
      await assignConsultantToOrg(targetConsultant.id, org.id, org.name);
    } catch {
      toast.error('No se pudo asignar el consultor.');
      return;
    }

    // Actualizar nombre de consultor en store de organizaciones
    updateOrganization(org.id, {
      consultantId: targetConsultant.id,
      consultantName: `${targetConsultant.name} (${targetConsultant.seniority})`,
    });

    setAssignDialogOpen(false);
    setTargetConsultant(null);
    setSelectedOrgId('');
  };

  const handleRemoveAssignment = async (consultantId: string, orgId: string) => {
    try {
      await removeConsultantFromOrg(consultantId, orgId);
    } catch {
      toast.error('No se pudo revocar la asignación.');
      return;
    }

    // Limpiar consultor de la organización
    updateOrganization(orgId, {
      consultantId: undefined,
      consultantName: undefined,
    });
  };

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/40 pb-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="outline" className="border-primary/40 bg-primary/10 text-primary text-[10px] font-bold">
              ADM-11
            </Badge>
            <Badge variant="secondary" className="text-[10px]">
              Supervisión Metodológica M7
            </Badge>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            Consultores y Asignaciones
          </h1>
          <p className="mt-1 text-sm text-muted-foreground max-w-3xl">
            Gestión del equipo de consultores sénior acreditados, balance de carga operativa y emparejamiento con organizaciones Pro.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            size="sm"
            variant="ghost"
            onClick={resetToDefaults}
            title="Restablecer consultores originales"
            className="text-xs text-muted-foreground hover:text-foreground h-9 w-9 p-0"
          >
            <RotateCcw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Métricas Globales */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Consultores Acreditados</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">{totalConsultants}</span>
            <span className="text-xs text-muted-foreground">especialistas</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">TryAIGap Enterprise Team</p>
        </div>

        <div className="rounded-xl border border-primary/20 bg-primary/5 p-4">
          <span className="text-[11px] font-medium text-primary">Revisiones Activas (M7)</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-primary">{activeReviewsCount}</span>
            <span className="text-xs text-muted-foreground">en proceso</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Clientes Pro en evaluación</p>
        </div>

        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4">
          <span className="text-[11px] font-medium text-emerald-500">Revisiones Completadas</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-emerald-500">{completedReviewsCount}</span>
            <span className="text-xs text-muted-foreground">dictámenes</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Reportes PDF ejecutivos</p>
        </div>

        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Satisfacción Promedio</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-amber-500 flex items-center gap-1">
              <Star className="h-5 w-5 fill-amber-500 text-amber-500" />
              {avgRating}
            </span>
            <span className="text-xs text-muted-foreground">/ 5.0</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Evaluación post-diagnóstico</p>
        </div>
      </div>

      {/* Barra de Filtros */}
      <Card className="border-border/60 bg-card/50 shadow-xs">
        <CardContent className="p-4 space-y-3">
          <div className="flex flex-col md:flex-row items-stretch md:items-center gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar por nombre, especialidad o empresa asignada..."
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

            <div className="w-full md:w-52">
              <Select value={selectedSeniority} onValueChange={setSelectedSeniority}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Seniority" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos los Rangos</SelectItem>
                  <SelectItem value="Lead Partner" className="text-xs">Lead Partner</SelectItem>
                  <SelectItem value="Principal Consultant" className="text-xs">Principal Consultant</SelectItem>
                  <SelectItem value="Senior Specialist" className="text-xs">Senior Specialist</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="w-full md:w-40">
              <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Disponibilidad" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todas</SelectItem>
                  <SelectItem value="available" className="text-xs">Disponible</SelectItem>
                  <SelectItem value="busy" className="text-xs">Ocupado</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Tarjetas de Consultores */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {filteredConsultants.map((c) => {
          const initials = c.name.slice(0, 2).toUpperCase();
          return (
            <Card
              key={c.id}
              className="border-border/60 bg-card/60 hover:border-primary/40 transition-all flex flex-col justify-between"
            >
              <CardContent className="p-5 space-y-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <Avatar className="h-11 w-11">
                      <AvatarFallback className="brand-gradient text-xs font-bold text-white">
                        {initials}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <h3 className="font-bold text-sm text-foreground flex items-center gap-1.5">
                        {c.name}
                        {c.status === 'available' ? (
                          <span className="h-2 w-2 rounded-full bg-emerald-500 inline-block" title="Disponible" />
                        ) : (
                          <span className="h-2 w-2 rounded-full bg-amber-500 inline-block" title="Carga Completa" />
                        )}
                      </h3>
                      <p className="text-xs text-muted-foreground">{c.email}</p>
                      <Badge variant="outline" className="mt-1 text-[10px] text-primary border-primary/30">
                        {c.seniority}
                      </Badge>
                    </div>
                  </div>

                  <div className="text-right">
                    <div className="flex items-center justify-end gap-1 text-xs font-bold text-amber-500">
                      <Star className="h-3.5 w-3.5 fill-amber-500 text-amber-500" />
                      <span>{c.rating}</span>
                    </div>
                    <span className="text-[10px] text-muted-foreground font-mono">
                      {c.completedReviews} dictámenes
                    </span>
                  </div>
                </div>

                <div className="text-xs text-muted-foreground bg-muted/30 rounded-lg p-2.5">
                  <strong className="text-foreground">Especialidad:</strong> {c.specialty}
                </div>

                {/* Empresas Pro Asignadas */}
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-semibold text-foreground flex items-center gap-1.5">
                      <Building2 className="h-3.5 w-3.5 text-primary" />
                      Clientes Asignados ({c.assignedOrgNames.length}):
                    </span>
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => handleOpenAssignModal(c)}
                      className="h-6 px-2 text-[11px] text-primary hover:bg-primary/10 gap-1"
                    >
                      <Plus className="h-3 w-3" />
                      Asignar Pro
                    </Button>
                  </div>

                  {c.assignedOrgNames.length === 0 ? (
                    <p className="text-[11px] text-muted-foreground italic pl-5">
                      Sin clientes asignados actualmente.
                    </p>
                  ) : (
                    <div className="flex flex-wrap gap-1.5 pt-1">
                      {c.assignedOrgNames.map((orgName, idx) => {
                        const orgId = c.assignedOrgIds[idx];
                        return (
                          <span
                            key={idx}
                            className="inline-flex items-center gap-1 rounded-md border border-border/80 bg-muted/60 px-2 py-1 text-[11px] font-medium text-foreground"
                          >
                            <span>{orgName}</span>
                            <button
                              onClick={() => handleRemoveAssignment(c.id, orgId)}
                              className="text-muted-foreground hover:text-destructive cursor-pointer ml-0.5"
                              title="Desvincular cliente"
                            >
                              <X className="h-3 w-3" />
                            </button>
                          </span>
                        );
                      })}
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Modal de Asignación de Consultor */}
      <Dialog open={assignDialogOpen} onOpenChange={setAssignDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <div className="flex items-center gap-2 mb-1">
              <Badge variant="outline" className="border-primary/40 text-primary text-[10px]">
                ADM-11 · Supervisión M7
              </Badge>
            </div>
            <DialogTitle className="text-lg font-bold">
              Asignar Empresa Pro a Consultor
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Consultor: <strong className="text-foreground">{targetConsultant?.name}</strong> ({targetConsultant?.specialty})
            </DialogDescription>
          </DialogHeader>

          <div className="py-3 space-y-3">
            <label className="text-xs font-semibold text-foreground">
              Selecciona una Organización Pro:
            </label>
            <Select value={selectedOrgId} onValueChange={setSelectedOrgId}>
              <SelectTrigger className="text-xs h-9">
                <SelectValue placeholder="Seleccionar empresa Pro..." />
              </SelectTrigger>
              <SelectContent>
                {proOrganizations.map((org) => (
                  <SelectItem key={org.id} value={org.id} className="text-xs">
                    {org.name} · {org.sector}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <div className="rounded-xl border border-primary/20 bg-primary/5 p-3 text-xs text-muted-foreground space-y-1">
              <div className="flex items-center gap-1.5 font-bold text-primary">
                <CheckCircle2 className="h-3.5 w-3.5" />
                <span>Alcance de la Asignación:</span>
              </div>
              <p className="text-[11px]">
                El consultor seleccionado supervisará el cuestionario M1 a M6 y redactará las recomendaciones ejecutivas en el entregable cualitativo M7.
              </p>
            </div>
          </div>

          <DialogFooter className="flex items-center justify-between sm:justify-between pt-2">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setAssignDialogOpen(false)}
              className="text-xs text-muted-foreground"
            >
              Cancelar
            </Button>

            <Button
              type="button"
              size="sm"
              disabled={!selectedOrgId}
              onClick={handleConfirmAssignment}
              className="brand-gradient text-white text-xs shadow-xs"
            >
              Confirmar Asignación
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
