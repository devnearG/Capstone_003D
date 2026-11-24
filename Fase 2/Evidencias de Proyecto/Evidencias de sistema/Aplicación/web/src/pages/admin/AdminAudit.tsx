import { useState, useMemo, useEffect } from 'react';
import {
  Search,
  Download,
  RotateCcw,
  Lock,
  Zap,
  Briefcase,
  DollarSign,
  HelpCircle,
} from 'lucide-react';
import {
  useAdminPlatformStore,
  type AuditActionType,
} from '@/store/adminPlatformStore';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { toast } from 'sonner';

const isQuestionAction = (action: string) =>
  action.startsWith('question_') || action.startsWith('question.');
const isPlanAction = (action: string) =>
  action.startsWith('plan_') || action.startsWith('organization.plan');
const isConsultantAction = (action: string) =>
  action === 'consultant_assigned' || action.startsWith('consultant.');
const isPaymentAction = (action: string) =>
  action.startsWith('payment_') || action.startsWith('payment.');

export default function AdminAudit() {
  const { auditLogs, loadAuditLogs, resetToDefaults } = useAdminPlatformStore();

  useEffect(() => {
    loadAuditLogs().catch(() => {
      toast.error('No se pudo cargar la bitácora de auditoría.');
    });
  }, [loadAuditLogs]);

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedAction, setSelectedAction] = useState<string>('all');

  // Métricas
  const totalLogs = auditLogs.length;
  const questionLogsCount = auditLogs.filter((l) => isQuestionAction(l.action)).length;
  const planLogsCount = auditLogs.filter((l) => isPlanAction(l.action)).length;
  const securityLogsCount = auditLogs.filter(
    (l) => l.action === 'role_changed' || l.action.startsWith('user_'),
  ).length;

  // Filtrado reactivo
  const filteredLogs = useMemo(() => {
    return auditLogs.filter((log) => {
      if (selectedAction !== 'all') {
        if (selectedAction === 'questions' && !isQuestionAction(log.action)) return false;
        if (selectedAction === 'plans' && !isPlanAction(log.action)) return false;
        if (selectedAction === 'roles' && log.action !== 'role_changed') return false;
        if (selectedAction === 'consultants' && !isConsultantAction(log.action)) return false;
        if (selectedAction === 'payments' && !isPaymentAction(log.action)) return false;
      }

      if (searchQuery.trim()) {
        const q = searchQuery.trim().toLowerCase();
        const matchesActor = log.actorEmail.toLowerCase().includes(q);
        const matchesLabel = log.actionLabel.toLowerCase().includes(q);
        const matchesTarget = log.targetName.toLowerCase().includes(q);
        const matchesDetails = log.details.toLowerCase().includes(q);
        const matchesIp = log.ipAddress.toLowerCase().includes(q);

        if (!matchesActor && !matchesLabel && !matchesTarget && !matchesDetails && !matchesIp) {
          return false;
        }
      }

      return true;
    });
  }, [auditLogs, selectedAction, searchQuery]);

  const handleExportAuditJson = () => {
    const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(filteredLogs, null, 2));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('href', dataStr);
    downloadAnchor.setAttribute('download', `tryaigap_audit_log_${new Date().toISOString().slice(0, 10)}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
  };

  const getActionBadge = (action: AuditActionType, label: string) => {
    if (isQuestionAction(action)) {
      return (
        <Badge variant="outline" className="border-cyan-500/40 text-cyan-500 bg-cyan-500/5 text-[10px] gap-1 font-semibold">
          <HelpCircle className="h-3 w-3" />
          {label}
        </Badge>
      );
    }
    if (isPlanAction(action)) {
      return (
        <Badge variant="default" className="bg-emerald-600 hover:bg-emerald-600 text-[10px] gap-1 font-semibold">
          <Zap className="h-3 w-3" />
          {label}
        </Badge>
      );
    }
    if (action === 'role_changed' || action.startsWith('user_')) {
      return (
        <Badge variant="outline" className="border-amber-500/40 text-amber-500 bg-amber-500/5 text-[10px] gap-1 font-semibold">
          <Lock className="h-3 w-3" />
          {label}
        </Badge>
      );
    }
    if (isConsultantAction(action)) {
      return (
        <Badge variant="secondary" className="text-primary text-[10px] gap-1 font-semibold">
          <Briefcase className="h-3 w-3" />
          {label}
        </Badge>
      );
    }
    return (
      <Badge variant="outline" className="border-emerald-500/40 text-emerald-500 text-[10px] gap-1 font-semibold">
        <DollarSign className="h-3 w-3" />
        {label}
      </Badge>
    );
  };

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/40 pb-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="outline" className="border-primary/40 bg-primary/10 text-primary text-[10px] font-bold">
              ADM-17 a ADM-21
            </Badge>
            <Badge variant="secondary" className="text-[10px]">
              Trazabilidad Inmutable
            </Badge>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            Bitácora de Auditoría del Sistema
          </h1>
          <p className="mt-1 text-sm text-muted-foreground max-w-3xl">
            Registro cronológico inmutable de eventos críticos: cambios de planes, publicaciones de preguntas, asignaciones y elevaciones de rol.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            size="sm"
            variant="outline"
            onClick={handleExportAuditJson}
            className="gap-1.5 text-xs border-border/60 hover:bg-muted"
          >
            <Download className="h-3.5 w-3.5" />
            <span>Exportar Bitácora (JSON)</span>
          </Button>

          <Button
            size="sm"
            variant="ghost"
            onClick={resetToDefaults}
            title="Restablecer bitácora original"
            className="text-xs text-muted-foreground hover:text-foreground h-9 w-9 p-0"
          >
            <RotateCcw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Métricas de Auditoría */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Eventos Registrados</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">{totalLogs}</span>
            <span className="text-xs text-muted-foreground">entradas</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Log inmutable de plataforma</p>
        </div>

        <div className="rounded-xl border border-cyan-500/30 bg-cyan-500/5 p-4">
          <span className="text-[11px] font-medium text-cyan-500">Banco de Preguntas</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-cyan-500">{questionLogsCount}</span>
            <span className="text-xs text-muted-foreground">acciones</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Publicaciones y ediciones</p>
        </div>

        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4">
          <span className="text-[11px] font-medium text-emerald-500">Conmutación de Planes</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-emerald-500">{planLogsCount}</span>
            <span className="text-xs text-muted-foreground">cambios</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Ascensos Pro y Free</p>
        </div>

        <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-4">
          <span className="text-[11px] font-medium text-amber-500">Seguridad & RBAC</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-amber-500">{securityLogsCount}</span>
            <span className="text-xs text-muted-foreground">auditorías</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Roles y suspensiones</p>
        </div>
      </div>

      {/* Filtros */}
      <Card className="border-border/60 bg-card/50 shadow-xs">
        <CardContent className="p-4 space-y-3">
          <div className="flex flex-col md:flex-row items-stretch md:items-center gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar por usuario actor, acción, objetivo o IP..."
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

            <div className="w-full md:w-56">
              <Select value={selectedAction} onValueChange={setSelectedAction}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Tipo de Acción" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todas las Acciones</SelectItem>
                  <SelectItem value="questions" className="text-xs">Banco de Preguntas</SelectItem>
                  <SelectItem value="plans" className="text-xs">Planes y Suscripciones</SelectItem>
                  <SelectItem value="roles" className="text-xs">Seguridad y Roles RBAC</SelectItem>
                  <SelectItem value="consultants" className="text-xs">Asignación de Consultores</SelectItem>
                  <SelectItem value="payments" className="text-xs">Conciliación de Pagos</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Tabla de Auditoría */}
      <Card className="border-border/60 bg-card/60 shadow-xs overflow-hidden">
        <Table>
          <TableHeader className="bg-muted/40">
            <TableRow>
              <TableHead className="text-xs font-bold text-foreground">Fecha / Hora</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Actor</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Acción</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Objetivo</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Detalles del Evento</TableHead>
              <TableHead className="text-xs font-bold text-foreground text-right">Dirección IP</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredLogs.map((log) => (
              <TableRow key={log.id} className="hover:bg-muted/30">
                <TableCell className="w-36">
                  <span className="font-mono text-[11px] text-muted-foreground block">
                    {new Date(log.timestamp).toLocaleDateString()}
                  </span>
                  <span className="font-mono text-[10px] text-foreground font-semibold">
                    {new Date(log.timestamp).toLocaleTimeString()}
                  </span>
                </TableCell>

                <TableCell>
                  <div className="flex items-center gap-1.5">
                    <span className="font-mono text-xs text-foreground font-medium">{log.actorEmail}</span>
                    <Badge variant="outline" className="text-[9px] uppercase px-1 py-0 text-muted-foreground">
                      {log.actorRole}
                    </Badge>
                  </div>
                </TableCell>

                <TableCell>
                  {getActionBadge(log.action, log.actionLabel)}
                </TableCell>

                <TableCell>
                  <span className="font-semibold text-xs text-foreground">{log.targetName}</span>
                </TableCell>

                <TableCell className="max-w-md">
                  <p className="text-xs text-muted-foreground leading-relaxed line-clamp-2">
                    {log.details}
                  </p>
                </TableCell>

                <TableCell className="text-right">
                  <span className="font-mono text-[11px] text-muted-foreground">
                    {log.ipAddress}
                  </span>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}
