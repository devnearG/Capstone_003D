import { useTranslation } from 'react-i18next';
import { Link } from 'react-router';
import {
  HelpCircle,
  Building2,
  Users,
  Briefcase,
  CreditCard,
  ShieldAlert,
  ArrowRight,
  CheckCircle2,
  Layers,
  Sparkles,
  Server,
  Database,
  CreditCard as StripeIcon,
  Globe2,
} from 'lucide-react';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { SpotlightCard } from '@/components/ui/spotlight-card';

export default function AdminDashboard() {
  const { t } = useTranslation();

  const MODULES = [
    {
      to: '/admin/questions',
      icon: HelpCircle,
      title: t('admin.dashboard.modules.questions.title'),
      desc: t('admin.dashboard.modules.questions.desc'),
      badge: t('admin.dashboard.modules.questions.badge'),
      action: t('admin.dashboard.modules.questions.action'),
      gradient: 'from-blue-500/20 to-cyan-500/20 text-blue-500',
    },
    {
      to: '/admin/organizations',
      icon: Building2,
      title: t('admin.dashboard.modules.organizations.title'),
      desc: t('admin.dashboard.modules.organizations.desc'),
      badge: t('admin.dashboard.modules.organizations.badge'),
      action: t('admin.dashboard.modules.organizations.action'),
      gradient: 'from-emerald-500/20 to-teal-500/20 text-emerald-500',
    },
    {
      to: '/admin/users',
      icon: Users,
      title: t('admin.dashboard.modules.users.title'),
      desc: t('admin.dashboard.modules.users.desc'),
      badge: t('admin.dashboard.modules.users.badge'),
      action: t('admin.dashboard.modules.users.action'),
      gradient: 'from-purple-500/20 to-indigo-500/20 text-purple-500',
    },
    {
      to: '/admin/consultants',
      icon: Briefcase,
      title: t('admin.dashboard.modules.consultants.title'),
      desc: t('admin.dashboard.modules.consultants.desc'),
      badge: t('admin.dashboard.modules.consultants.badge'),
      action: t('admin.dashboard.modules.consultants.action'),
      gradient: 'from-amber-500/20 to-orange-500/20 text-amber-500',
    },
    {
      to: '/admin/payments',
      icon: CreditCard,
      title: t('admin.dashboard.modules.payments.title'),
      desc: t('admin.dashboard.modules.payments.desc'),
      badge: t('admin.dashboard.modules.payments.badge'),
      action: t('admin.dashboard.modules.payments.action'),
      gradient: 'from-emerald-500/20 to-cyan-500/20 text-emerald-400',
    },
    {
      to: '/admin/audit',
      icon: ShieldAlert,
      title: t('admin.dashboard.modules.audit.title'),
      desc: t('admin.dashboard.modules.audit.desc'),
      badge: t('admin.dashboard.modules.audit.badge'),
      action: t('admin.dashboard.modules.audit.action'),
      gradient: 'from-rose-500/20 to-pink-500/20 text-rose-500',
    },
  ];

  const SYSTEM_STATUS = [
    { name: t('admin.dashboard.status.api'), status: 'Operational', icon: Server, color: 'text-emerald-500' },
    { name: t('admin.dashboard.status.db'), status: 'PostgreSQL Active', icon: Database, color: 'text-emerald-500' },
    { name: t('admin.dashboard.status.qbank'), status: '132 Qs · 4 Locales', icon: Globe2, color: 'text-cyan-500' },
    { name: t('admin.dashboard.status.stripe'), status: 'Webhook Ready', icon: StripeIcon, color: 'text-emerald-500' },
  ];

  return (
    <div className="space-y-8">
      {/* Encabezado Principal */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/40 pb-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="outline" className="border-primary/40 bg-primary/10 text-primary text-[10px] font-bold">
              TryAIGap Enterprise Admin
            </Badge>
            <Badge variant="secondary" className="text-[10px]">
              Fase 2 · Plataforma
            </Badge>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            {t('admin.dashboard.title')}
          </h1>
          <p className="mt-1 text-sm text-muted-foreground max-w-2xl">
            {t('admin.dashboard.subtitle')}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button asChild size="sm" className="gap-2 brand-gradient text-white shadow-md">
            <Link to="/admin/questions">
              <HelpCircle className="h-4 w-4" />
              <span>{t('admin.dashboard.modules.questions.action')}</span>
            </Link>
          </Button>
        </div>
      </div>

      {/* Barra de Estado del Sistema */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {SYSTEM_STATUS.map((item, idx) => (
          <div
            key={idx}
            className="flex items-center gap-3 rounded-xl border border-border/60 bg-card/60 p-3 shadow-xs"
          >
            <div className={`p-2 rounded-lg bg-muted/60 ${item.color}`}>
              <item.icon className="h-4 w-4" />
            </div>
            <div className="min-w-0">
              <p className="text-[11px] text-muted-foreground truncate">{item.name}</p>
              <p className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 inline-block" />
                {item.status}
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Tarjetas de Métricas Clave (KPIs) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <SpotlightCard className="p-5 border-border/60 bg-card/50">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-muted-foreground">
              {t('admin.dashboard.kpis.organizations')}
            </span>
            <Building2 className="h-4 w-4 text-primary" />
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold tracking-tight">12</span>
            <span className="ml-2 text-[11px] text-emerald-500 font-medium">8 Pro / 4 Free</span>
          </div>
          <p className="mt-1 text-[11px] text-muted-foreground">
            {t('admin.dashboard.kpis.organizationsSub')}
          </p>
        </SpotlightCard>

        <SpotlightCard className="p-5 border-border/60 bg-card/50">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-muted-foreground">
              {t('admin.dashboard.kpis.questions')}
            </span>
            <HelpCircle className="h-4 w-4 text-cyan-500" />
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold tracking-tight">132</span>
            <Badge variant="outline" className="ml-2 text-[10px] text-emerald-500 border-emerald-500/30 bg-emerald-500/10">
              100% Publicado
            </Badge>
          </div>
          <p className="mt-1 text-[11px] text-muted-foreground">
            {t('admin.dashboard.kpis.questionsSub')}
          </p>
        </SpotlightCard>

        <SpotlightCard className="p-5 border-border/60 bg-card/50">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-muted-foreground">
              {t('admin.dashboard.kpis.consultants')}
            </span>
            <Briefcase className="h-4 w-4 text-amber-500" />
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold tracking-tight">6</span>
            <span className="ml-2 text-[11px] text-muted-foreground">asignados a Pro</span>
          </div>
          <p className="mt-1 text-[11px] text-muted-foreground">
            {t('admin.dashboard.kpis.consultantsSub')}
          </p>
        </SpotlightCard>

        <SpotlightCard className="p-5 border-border/60 bg-card/50">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-muted-foreground">
              {t('admin.dashboard.kpis.evaluations')}
            </span>
            <Layers className="h-4 w-4 text-purple-500" />
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold tracking-tight">48</span>
            <span className="ml-2 text-[11px] text-emerald-500 font-medium">92% completadas</span>
          </div>
          <p className="mt-1 text-[11px] text-muted-foreground">
            {t('admin.dashboard.kpis.evaluationsSub')}
          </p>
        </SpotlightCard>
      </div>

      {/* Cuadrícula de Módulos de Gestión */}
      <div>
        <div className="mb-4">
          <h2 className="text-lg font-bold tracking-tight">
            {t('admin.dashboard.modules.title')}
          </h2>
          <p className="text-xs text-muted-foreground">
            {t('admin.dashboard.modules.subtitle')}
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {MODULES.map((mod, index) => (
            <Card
              key={index}
              className="group relative flex flex-col justify-between border-border/60 bg-card/60 transition-all duration-200 hover:border-primary/40 hover:shadow-md"
            >
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between gap-2 mb-2">
                  <div className={`flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br ${mod.gradient}`}>
                    <mod.icon className="h-5 w-5" />
                  </div>
                  <Badge variant="outline" className="text-[10px] font-mono border-border/70">
                    {mod.badge}
                  </Badge>
                </div>
                <CardTitle className="text-base font-bold group-hover:text-primary transition-colors">
                  {mod.title}
                </CardTitle>
                <CardDescription className="text-xs line-clamp-3 leading-relaxed mt-1">
                  {mod.desc}
                </CardDescription>
              </CardHeader>
              <CardFooter className="pt-2 border-t border-border/40">
                <Button
                  asChild
                  variant="ghost"
                  size="sm"
                  className="w-full justify-between text-xs font-semibold group-hover:bg-primary/10 group-hover:text-primary"
                >
                  <Link to={mod.to}>
                    <span>{mod.action}</span>
                    <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-1" />
                  </Link>
                </Button>
              </CardFooter>
            </Card>
          ))}
        </div>
      </div>

      {/* Registro de Auditoría Rápida */}
      <Card className="border-border/60 bg-card/40">
        <CardHeader className="pb-3">
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-sm font-bold flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-primary" />
                {t('admin.dashboard.recentActivity.title')}
              </CardTitle>
              <CardDescription className="text-xs mt-0.5">
                {t('admin.dashboard.recentActivity.subtitle')}
              </CardDescription>
            </div>
            <Button asChild variant="outline" size="sm" className="text-xs h-7">
              <Link to="/admin/audit">{t('admin.dashboard.modules.audit.action')}</Link>
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {[
              {
                time: 'Hace 10 min',
                event: 'Sincronización del Banco de Preguntas M1–M7 (132 preguntas verificadas)',
                type: 'Publicación',
                badge: 'ADM-04',
              },
              {
                time: 'Hace 2 horas',
                event: 'Actualización de plan a Pro Enterprise para Acme Corp',
                type: 'Organización',
                badge: 'ADM-10',
              },
              {
                time: 'Hace 5 horas',
                event: 'Asignación de consultor sénior a TechInnovate Spa',
                type: 'Consultoría',
                badge: 'ADM-11',
              },
            ].map((act, i) => (
              <div
                key={i}
                className="flex items-center justify-between text-xs py-2 border-b border-border/30 last:border-b-0"
              >
                <div className="flex items-center gap-3">
                  <CheckCircle2 className="h-4 w-4 text-emerald-500 shrink-0" />
                  <div>
                    <p className="font-medium text-foreground">{act.event}</p>
                    <p className="text-[11px] text-muted-foreground">{act.time} · {act.type}</p>
                  </div>
                </div>
                <Badge variant="secondary" className="text-[10px] font-mono shrink-0">
                  {act.badge}
                </Badge>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
