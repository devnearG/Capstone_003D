import { useState, useMemo, useEffect } from 'react';
import {
  Search,
  ShieldCheck,
  Briefcase,
  UserRound,
  RotateCcw,
  Lock,
  UserCheck,
  UserX,
} from 'lucide-react';
import {
  useAdminOrganizationsStore,
  type AdminUser,
} from '@/store/adminOrganizationsStore';
import type { Role } from '@/api/types';
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
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { toast } from 'sonner';

export default function AdminUsers() {
  const {
    users,
    load,
    changeUserRole,
    toggleUserStatus,
    resetToDefaults,
  } = useAdminOrganizationsStore();

  useEffect(() => {
    load().catch(() => {
      toast.error('No se pudieron cargar los usuarios.');
    });
  }, [load]);

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRole, setSelectedRole] = useState<string>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');

  // Modal para confirmación de cambio de rol
  const [roleChangeUser, setRoleChangeUser] = useState<AdminUser | null>(null);
  const [targetRole, setTargetRole] = useState<Role | null>(null);
  const [roleDialogOpen, setRoleDialogOpen] = useState(false);

  // Métricas
  const totalUsers = users.length;
  const clientsCount = users.filter((u) => u.role === 'client').length;
  const consultantsCount = users.filter((u) => u.role === 'consultant').length;
  const adminsCount = users.filter((u) => u.role === 'admin').length;

  // Filtrado reactivo
  const filteredUsers = useMemo(() => {
    return users.filter((u) => {
      if (selectedRole !== 'all' && u.role !== selectedRole) return false;
      if (selectedStatus !== 'all' && u.status !== selectedStatus) return false;

      if (searchQuery.trim()) {
        const q = searchQuery.trim().toLowerCase();
        const matchesName = u.fullName.toLowerCase().includes(q);
        const matchesEmail = u.email.toLowerCase().includes(q);
        const matchesOrg = u.organizationName.toLowerCase().includes(q);
        if (!matchesName && !matchesEmail && !matchesOrg) {
          return false;
        }
      }

      return true;
    });
  }, [users, selectedRole, selectedStatus, searchQuery]);

  const handleInitiateRoleChange = (user: AdminUser, newRole: Role) => {
    if (user.role === newRole) return;
    setRoleChangeUser(user);
    setTargetRole(newRole);
    setRoleDialogOpen(true);
  };

  const handleConfirmRoleChange = async () => {
    if (roleChangeUser && targetRole) {
      try {
        await changeUserRole(roleChangeUser.id, targetRole);
      } catch {
        toast.error('No se pudo cambiar el rol del usuario.');
        return;
      }
      setRoleDialogOpen(false);
      setRoleChangeUser(null);
      setTargetRole(null);
    }
  };

  const handleToggleUserStatus = async (userId: string) => {
    try {
      await toggleUserStatus(userId);
    } catch {
      toast.error('No se pudo actualizar el estado del usuario.');
    }
  };

  const getRoleBadge = (role: Role) => {
    switch (role) {
      case 'admin':
        return (
          <Badge variant="outline" className="text-[10px] border-primary/40 text-primary bg-primary/5 font-semibold gap-1">
            <ShieldCheck className="h-3 w-3" />
            Administrador
          </Badge>
        );
      case 'consultant':
        return (
          <Badge variant="secondary" className="text-[10px] text-amber-500 font-semibold gap-1">
            <Briefcase className="h-3 w-3" />
            Consultor
          </Badge>
        );
      case 'client':
      default:
        return (
          <Badge variant="outline" className="text-[10px] text-muted-foreground gap-1">
            <UserRound className="h-3 w-3" />
            Cliente
          </Badge>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/40 pb-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="outline" className="border-primary/40 bg-primary/10 text-primary text-[10px] font-bold">
              ADM-08
            </Badge>
            <Badge variant="secondary" className="text-[10px]">
              Directorio de Accesos y Roles
            </Badge>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            Gestión de Usuarios y Roles
          </h1>
          <p className="mt-1 text-sm text-muted-foreground max-w-3xl">
            Control de identidades, asignación de roles (client, consultant, admin) y revocación de accesos en la plataforma TryAIGap.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            size="sm"
            variant="ghost"
            onClick={resetToDefaults}
            title="Restablecer usuarios originales"
            className="text-xs text-muted-foreground hover:text-foreground h-9 w-9 p-0"
          >
            <RotateCcw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Métricas de Usuarios */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Total Usuarios</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">{totalUsers}</span>
            <span className="text-xs text-muted-foreground">cuentas</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Directorio global</p>
        </div>

        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Clientes Corporativos</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-foreground">{clientsCount}</span>
            <span className="text-xs text-muted-foreground">líderes</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Evaluadores de área</p>
        </div>

        <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-4">
          <span className="text-[11px] font-medium text-amber-500">Consultores Acreditados</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-amber-500">{consultantsCount}</span>
            <span className="text-xs text-muted-foreground">sénior</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Revisión cualitativa M7</p>
        </div>

        <div className="rounded-xl border border-primary/20 bg-primary/5 p-4">
          <span className="text-[11px] font-medium text-primary">Administradores</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-primary">{adminsCount}</span>
            <span className="text-xs text-muted-foreground">super-users</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Gestión de plataforma</p>
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
                placeholder="Buscar por nombre, email o empresa..."
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
              <Select value={selectedRole} onValueChange={setSelectedRole}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Rol" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos los Roles</SelectItem>
                  <SelectItem value="client" className="text-xs">Clientes ({clientsCount})</SelectItem>
                  <SelectItem value="consultant" className="text-xs">Consultores ({consultantsCount})</SelectItem>
                  <SelectItem value="admin" className="text-xs">Administradores ({adminsCount})</SelectItem>
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
                  <SelectItem value="active" className="text-xs">Activos</SelectItem>
                  <SelectItem value="inactive" className="text-xs">Inactivos</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="flex items-center justify-between text-xs text-muted-foreground pt-1">
            <span>
              Mostrando <strong>{filteredUsers.length}</strong> de {totalUsers} usuarios
            </span>
            {(selectedRole !== 'all' || selectedStatus !== 'all' || searchQuery) && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setSelectedRole('all');
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

      {/* Tabla de Usuarios */}
      <Card className="border-border/60 bg-card/60 shadow-xs overflow-hidden">
        <Table>
          <TableHeader className="bg-muted/40">
            <TableRow>
              <TableHead className="text-xs font-bold text-foreground">Usuario</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Organización</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Rol Asignado</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Última Actividad</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Estado</TableHead>
              <TableHead className="text-xs font-bold text-foreground text-right">Acciones</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center py-8 text-xs text-muted-foreground">
                  No se encontraron usuarios con los criterios seleccionados.
                </TableCell>
              </TableRow>
            ) : (
              filteredUsers.map((u) => {
                const initials = u.fullName.slice(0, 2).toUpperCase();
                return (
                  <TableRow key={u.id} className="hover:bg-muted/30">
                    <TableCell>
                      <div className="flex items-center gap-2.5">
                        <Avatar className="h-8 w-8">
                          <AvatarFallback className="brand-gradient text-[11px] font-bold text-white">
                            {initials}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="font-semibold text-xs text-foreground leading-tight">{u.fullName}</p>
                          <p className="text-[11px] text-muted-foreground font-mono">{u.email}</p>
                        </div>
                      </div>
                    </TableCell>

                    <TableCell>
                      <span className="text-xs font-medium text-foreground">{u.organizationName}</span>
                    </TableCell>

                    <TableCell>
                      <div className="flex items-center gap-2">
                        {getRoleBadge(u.role)}
                        <Select
                          value={u.role}
                          onValueChange={(val) => handleInitiateRoleChange(u, val as Role)}
                        >
                          <SelectTrigger className="h-6 w-20 text-[10px] px-1.5 py-0 border-border/60">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="client" className="text-xs">Cliente</SelectItem>
                            <SelectItem value="consultant" className="text-xs">Consultor</SelectItem>
                            <SelectItem value="admin" className="text-xs">Admin</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    </TableCell>

                    <TableCell>
                      <span className="text-xs text-muted-foreground">{u.lastActiveAt}</span>
                    </TableCell>

                    <TableCell>
                      {u.status === 'active' ? (
                        <Badge variant="outline" className="text-[10px] text-emerald-500 border-emerald-500/30 bg-emerald-500/5">
                          Activo
                        </Badge>
                      ) : (
                        <Badge variant="secondary" className="text-[10px] text-muted-foreground">
                          Inactivo
                        </Badge>
                      )}
                    </TableCell>

                    <TableCell className="text-right">
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => handleToggleUserStatus(u.id)}
                        className="h-7 text-[11px] text-muted-foreground hover:text-foreground"
                      >
                        {u.status === 'active' ? (
                          <span className="flex items-center gap-1 text-destructive">
                            <UserX className="h-3 w-3" />
                            Suspender
                          </span>
                        ) : (
                          <span className="flex items-center gap-1 text-emerald-500">
                            <UserCheck className="h-3 w-3" />
                            Reactivar
                          </span>
                        )}
                      </Button>
                    </TableCell>
                  </TableRow>
                );
              })
            )}
          </TableBody>
        </Table>
      </Card>

      {/* Modal de Confirmación de Cambio de Rol */}
      <Dialog open={roleDialogOpen} onOpenChange={setRoleDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <div className="flex items-center gap-2 mb-1">
              <Badge variant="outline" className="border-primary/40 text-primary text-[10px]">
                ADM-08 · Permisos RBAC
              </Badge>
            </div>
            <DialogTitle className="text-lg font-bold">
              Confirmar Cambio de Rol de Usuario
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Usuario: <strong className="text-foreground">{roleChangeUser?.fullName}</strong> ({roleChangeUser?.email})
            </DialogDescription>
          </DialogHeader>

          <div className="py-3 space-y-3">
            <div className="rounded-xl border border-border/60 bg-muted/30 p-4 space-y-2 text-xs">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Rol Actual:</span>
                <span className="font-bold capitalize">{roleChangeUser?.role}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Nuevo Rol:</span>
                <strong className="text-primary uppercase">{targetRole}</strong>
              </div>
            </div>

            {targetRole === 'admin' && (
              <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-3 text-xs text-amber-500 flex items-start gap-2">
                <Lock className="h-4 w-4 shrink-0 mt-0.5" />
                <span>
                  <strong>Atención:</strong> Asignar rol de Administrador otorgará acceso total a la gestión del banco de preguntas, organizaciones, finanzas y auditoría.
                </span>
              </div>
            )}
          </div>

          <DialogFooter className="flex items-center justify-between sm:justify-between pt-2">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setRoleDialogOpen(false)}
              className="text-xs text-muted-foreground"
            >
              Cancelar
            </Button>

            <Button
              type="button"
              size="sm"
              onClick={handleConfirmRoleChange}
              className="brand-gradient text-white text-xs shadow-xs"
            >
              Confirmar Cambio
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
