import { useState, useMemo, useEffect } from 'react';
import {
  Search,
  CheckCircle2,
  Plus,
  RotateCcw,
  Zap,
} from 'lucide-react';
import {
  useAdminPlatformStore,
  type AdminPaymentTransaction,
  type PaymentMethod,
} from '@/store/adminPlatformStore';
import { useAdminOrganizationsStore } from '@/store/adminOrganizationsStore';
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

export default function AdminPayments() {
  const {
    payments,
    reconcilePayment,
    addManualPayment,
    resetToDefaults,
    loadPayments,
  } = useAdminPlatformStore();

  useEffect(() => {
    loadPayments().catch(() => toast.error('No se pudieron cargar los pagos.'));
  }, [loadPayments]);

  const { organizations, toggleOrganizationPlan } = useAdminOrganizationsStore();

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedMethod, setSelectedMethod] = useState<string>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');

  // Modal para conciliar pago
  const [reconcileTx, setReconcileTx] = useState<AdminPaymentTransaction | null>(null);
  const [reconcileOpen, setReconcileOpen] = useState(false);

  // Modal para registrar nuevo pago manual
  const [manualPaymentOpen, setManualPaymentOpen] = useState(false);
  const [newInvoice, setNewInvoice] = useState('');
  const [newOrgId, setNewOrgId] = useState('');
  const [newAmount, setNewAmount] = useState('2400');
  const [newMethod, setNewMethod] = useState<PaymentMethod>('wire_transfer');
  const [newReference, setNewReference] = useState('');

  // Métricas
  const totalRevenue = payments
    .filter((p) => p.status === 'paid')
    .reduce((acc, p) => acc + p.amount, 0);

  const pendingCount = payments.filter((p) => p.status === 'pending_reconciliation').length;
  const paidCount = payments.filter((p) => p.status === 'paid').length;
  const avgTicket = paidCount > 0 ? Math.round(totalRevenue / paidCount) : 0;

  // Filtrado reactivo
  const filteredPayments = useMemo(() => {
    return payments.filter((tx) => {
      if (selectedMethod !== 'all' && tx.method !== selectedMethod) return false;
      if (selectedStatus !== 'all' && tx.status !== selectedStatus) return false;

      if (searchQuery.trim()) {
        const q = searchQuery.trim().toLowerCase();
        const matchesInvoice = tx.invoiceNumber.toLowerCase().includes(q);
        const matchesOrg = tx.organizationName.toLowerCase().includes(q);
        const matchesRef = tx.referenceCode?.toLowerCase().includes(q) ?? false;
        if (!matchesInvoice && !matchesOrg && !matchesRef) {
          return false;
        }
      }

      return true;
    });
  }, [payments, selectedMethod, selectedStatus, searchQuery]);

  const handleOpenReconcile = (tx: AdminPaymentTransaction) => {
    setReconcileTx(tx);
    setReconcileOpen(true);
  };

  const handleConfirmReconcile = () => {
    if (!reconcileTx) return;

    reconcilePayment(reconcileTx.id, 'admin@tryaigap.com').catch(() => {
      toast.error('No se pudo conciliar el pago.');
    });

    // Si la organización era Free, elevarla automáticamente a Pro
    const org = organizations.find((o) => o.id === reconcileTx.organizationId);
    if (org && org.plan === 'free') {
      toggleOrganizationPlan(org.id);
    }

    setReconcileOpen(false);
    setReconcileTx(null);
  };

  const handleCreateManualPayment = () => {
    const org = organizations.find((o) => o.id === newOrgId);
    if (!org) return;

    addManualPayment({
      invoiceNumber: newInvoice.trim() || `INV-2026-${Math.floor(1000 + Math.random() * 9000)}`,
      organizationId: org.id,
      organizationName: org.name,
      amount: parseFloat(newAmount) || 2400,
      currency: 'USD',
      method: newMethod,
      status: 'pending_reconciliation',
      plan: 'pro_annual',
      referenceCode: newReference.trim() || 'MANUAL-ENTRY',
    }).catch(() => toast.error('No se pudo registrar el pago.'));

    setManualPaymentOpen(false);
    setNewInvoice('');
    setNewOrgId('');
    setNewAmount('2400');
    setNewReference('');
  };

  const getMethodBadge = (method: PaymentMethod) => {
    switch (method) {
      case 'stripe':
        return (
          <Badge variant="outline" className="text-[10px] border-emerald-500/40 text-emerald-500 bg-emerald-500/5">
            Stripe Gateway
          </Badge>
        );
      case 'wire_transfer':
        return (
          <Badge variant="secondary" className="text-[10px] text-primary">
            Transferencia Bancaria
          </Badge>
        );
      case 'purchase_order':
        return (
          <Badge variant="outline" className="text-[10px] text-amber-500 border-amber-500/40 bg-amber-500/5">
            Orden de Compra B2B
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
              ADM-12 a ADM-16
            </Badge>
            <Badge variant="secondary" className="text-[10px]">
              Finanzas & Pagos Corporativos
            </Badge>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            Control de Pagos y Facturación B2B
          </h1>
          <p className="mt-1 text-sm text-muted-foreground max-w-3xl">
            Supervisión de pagos por pasarela Stripe, registro de transferencias bancarias manuales y conciliación para activación de licencias Pro.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            size="sm"
            onClick={() => setManualPaymentOpen(true)}
            className="gap-1.5 brand-gradient text-white text-xs shadow-xs"
          >
            <Plus className="h-4 w-4" />
            <span>Registrar Pago Manual</span>
          </Button>

          <Button
            size="sm"
            variant="ghost"
            onClick={resetToDefaults}
            title="Restablecer transacciones originales"
            className="text-xs text-muted-foreground hover:text-foreground h-9 w-9 p-0"
          >
            <RotateCcw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Métricas Financieras */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4">
          <span className="text-[11px] font-medium text-emerald-500">Ingresos Reconciliados</span>
          <div className="mt-1 flex items-baseline gap-1">
            <span className="text-2xl font-bold tracking-tight text-emerald-500">
              ${totalRevenue.toLocaleString()}
            </span>
            <span className="text-xs text-muted-foreground">USD</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">{paidCount} transacciones liquidadas</p>
        </div>

        <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-4">
          <span className="text-[11px] font-medium text-amber-500">Pendientes Conciliación</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight text-amber-500">{pendingCount}</span>
            <Badge variant="outline" className="border-amber-500/40 text-amber-500 text-[10px]">
              Requiere revisión
            </Badge>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Transferencias por validar</p>
        </div>

        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Ticket Promedio Pro</span>
          <div className="mt-1 flex items-baseline gap-1">
            <span className="text-2xl font-bold tracking-tight">
              ${avgTicket.toLocaleString()}
            </span>
            <span className="text-xs text-muted-foreground">USD / año</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Licencia anual empresarial</p>
        </div>

        <div className="rounded-xl border border-border/60 bg-card/60 p-4">
          <span className="text-[11px] font-medium text-muted-foreground">Métodos Admitidos</span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="text-2xl font-bold tracking-tight">3</span>
            <span className="text-xs text-emerald-500 font-medium">100% operativos</span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground">Stripe · Wire · Purchase Order</p>
        </div>
      </div>

      {/* Filtros y Búsqueda */}
      <Card className="border-border/60 bg-card/50 shadow-xs">
        <CardContent className="p-4 space-y-3">
          <div className="flex flex-col md:flex-row items-stretch md:items-center gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar por factura (ej. INV-2026-0045), empresa o referencia..."
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
              <Select value={selectedMethod} onValueChange={setSelectedMethod}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Método de Pago" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos los Métodos</SelectItem>
                  <SelectItem value="stripe" className="text-xs">Stripe Gateway</SelectItem>
                  <SelectItem value="wire_transfer" className="text-xs">Transferencia Bancaria</SelectItem>
                  <SelectItem value="purchase_order" className="text-xs">Orden de Compra B2B</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="w-full md:w-44">
              <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                <SelectTrigger className="h-9 text-xs bg-background/80">
                  <SelectValue placeholder="Estado de Pago" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" className="text-xs">Todos los Estados</SelectItem>
                  <SelectItem value="paid" className="text-xs">Conciliados ({paidCount})</SelectItem>
                  <SelectItem value="pending_reconciliation" className="text-xs">Pendientes ({pendingCount})</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Tabla de Pagos */}
      <Card className="border-border/60 bg-card/60 shadow-xs overflow-hidden">
        <Table>
          <TableHeader className="bg-muted/40">
            <TableRow>
              <TableHead className="text-xs font-bold text-foreground">Factura / Fecha</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Empresa</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Monto</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Método</TableHead>
              <TableHead className="text-xs font-bold text-foreground">Estado</TableHead>
              <TableHead className="text-xs font-bold text-foreground text-right">Acciones</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredPayments.map((tx) => (
              <TableRow key={tx.id} className="hover:bg-muted/30">
                <TableCell>
                  <div>
                    <span className="font-mono font-semibold text-xs text-foreground">{tx.invoiceNumber}</span>
                    <p className="text-[11px] text-muted-foreground">
                      {new Date(tx.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                </TableCell>

                <TableCell>
                  <span className="font-medium text-xs text-foreground">{tx.organizationName}</span>
                  {tx.referenceCode && (
                    <p className="text-[10px] text-muted-foreground font-mono truncate max-w-[200px]">
                      Ref: {tx.referenceCode}
                    </p>
                  )}
                </TableCell>

                <TableCell>
                  <span className="font-bold text-xs text-foreground font-mono">
                    ${tx.amount.toLocaleString()} {tx.currency}
                  </span>
                </TableCell>

                <TableCell>
                  {getMethodBadge(tx.method)}
                </TableCell>

                <TableCell>
                  {tx.status === 'paid' ? (
                    <Badge variant="default" className="text-[10px] bg-emerald-600 hover:bg-emerald-600 gap-1 font-bold">
                      <CheckCircle2 className="h-3 w-3" />
                      Conciliado
                    </Badge>
                  ) : (
                    <Badge variant="outline" className="text-[10px] border-amber-500/50 text-amber-500 bg-amber-500/10 gap-1 font-bold">
                      <span className="h-1.5 w-1.5 rounded-full bg-amber-500 animate-ping inline-block" />
                      Por Conciliar
                    </Badge>
                  )}
                </TableCell>

                <TableCell className="text-right">
                  {tx.status === 'pending_reconciliation' ? (
                    <Button
                      size="sm"
                      onClick={() => handleOpenReconcile(tx)}
                      className="h-7 text-xs brand-gradient text-white shadow-2xs gap-1"
                    >
                      <CheckCircle2 className="h-3 w-3" />
                      Conciliar
                    </Button>
                  ) : (
                    <span className="text-[11px] text-muted-foreground font-mono">
                      {tx.reconciledBy ?? 'Verificado'}
                    </span>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      {/* Modal de Conciliación de Pago */}
      <Dialog open={reconcileOpen} onOpenChange={setReconcileOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <div className="flex items-center gap-2 mb-1">
              <Badge variant="outline" className="border-emerald-500/40 text-emerald-500 text-[10px]">
                ADM-14 · Conciliación Manual
              </Badge>
            </div>
            <DialogTitle className="text-lg font-bold">
              Conciliar Transferencia Bancaria
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Factura: <strong className="text-foreground">{reconcileTx?.invoiceNumber}</strong> · {reconcileTx?.organizationName}
            </DialogDescription>
          </DialogHeader>

          <div className="py-3 space-y-3">
            <div className="rounded-xl border border-border/60 bg-muted/30 p-3 space-y-2 text-xs">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Monto Declarado:</span>
                <strong className="text-foreground">${reconcileTx?.amount.toLocaleString()} USD</strong>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Comprobante / Referencia:</span>
                <span className="font-mono text-primary font-bold">{reconcileTx?.referenceCode}</span>
              </div>
            </div>

            <div className="rounded-xl border border-emerald-500/20 bg-emerald-500/5 p-3 text-xs text-muted-foreground space-y-1">
              <div className="flex items-center gap-1.5 font-bold text-emerald-500">
                <Zap className="h-3.5 w-3.5" />
                <span>Impacto en la Plataforma:</span>
              </div>
              <p className="text-[11px]">
                Al confirmar la conciliación, el estado pasará a <strong>Conciliado</strong> y la empresa cliente se actualizará automáticamente a <strong>Plan Pro Enterprise</strong> por 1 año.
              </p>
            </div>
          </div>

          <DialogFooter className="flex items-center justify-between sm:justify-between pt-2">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setReconcileOpen(false)}
              className="text-xs text-muted-foreground"
            >
              Cancelar
            </Button>

            <Button
              type="button"
              size="sm"
              onClick={handleConfirmReconcile}
              className="brand-gradient text-white text-xs shadow-xs"
            >
              Aprobar y Conciliar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Modal para Registrar Pago Manual */}
      <Dialog open={manualPaymentOpen} onOpenChange={setManualPaymentOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="text-lg font-bold">
              Registrar Orden de Pago Manual
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Ingreso de transferencias bancarias directas u órdenes de compra B2B.
            </DialogDescription>
          </DialogHeader>

          <div className="py-3 space-y-3">
            <div>
              <label className="text-xs font-semibold text-foreground">Organización Cliente:</label>
              <Select value={newOrgId} onValueChange={setNewOrgId}>
                <SelectTrigger className="text-xs h-9 mt-1">
                  <SelectValue placeholder="Seleccionar empresa..." />
                </SelectTrigger>
                <SelectContent>
                  {organizations.map((org) => (
                    <SelectItem key={org.id} value={org.id} className="text-xs">
                      {org.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-xs font-semibold text-foreground">Número de Factura:</label>
                <Input
                  value={newInvoice}
                  onChange={(e) => setNewInvoice(e.target.value)}
                  placeholder="INV-2026-..."
                  className="h-9 text-xs mt-1"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-foreground">Monto (USD):</label>
                <Input
                  type="number"
                  value={newAmount}
                  onChange={(e) => setNewAmount(e.target.value)}
                  className="h-9 text-xs mt-1"
                />
              </div>
            </div>

            <div>
              <label className="text-xs font-semibold text-foreground">Método:</label>
              <Select value={newMethod} onValueChange={(val) => setNewMethod(val as PaymentMethod)}>
                <SelectTrigger className="text-xs h-9 mt-1">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="wire_transfer" className="text-xs">Transferencia Bancaria</SelectItem>
                  <SelectItem value="purchase_order" className="text-xs">Orden de Compra B2B</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <label className="text-xs font-semibold text-foreground">Referencia / Código de Depósito:</label>
              <Input
                value={newReference}
                onChange={(e) => setNewReference(e.target.value)}
                placeholder="Ej. DEP-BANCARIO-99120"
                className="h-9 text-xs mt-1"
              />
            </div>
          </div>

          <DialogFooter className="flex items-center justify-between sm:justify-between pt-2">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setManualPaymentOpen(false)}
              className="text-xs text-muted-foreground"
            >
              Cancelar
            </Button>

            <Button
              type="button"
              size="sm"
              disabled={!newOrgId}
              onClick={handleCreateManualPayment}
              className="brand-gradient text-white text-xs shadow-xs"
            >
              Registrar Transacción
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
