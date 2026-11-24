import { useState } from 'react';
import { NavLink, Outlet, useLocation, Link } from 'react-router';
import { useTranslation } from 'react-i18next';
import {
  LayoutDashboard,
  HelpCircle,
  Building2,
  Users,
  Briefcase,
  CreditCard,
  ShieldAlert,
  Menu,
  X,
  ArrowLeft,
  ShieldCheck,
} from 'lucide-react';
import { BrandLogo } from '@/components/BrandLogo';
import { LanguageSwitcher } from '@/components/LanguageSwitcher';
import { ThemeToggle } from '@/components/ThemeToggle';
import { UserMenu } from '@/components/UserMenu';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { cn } from '@/lib/utils';
import { useAuthStore } from '@/store/authStore';

interface AdminNavItem {
  to: string;
  labelKey: string;
  icon: React.ComponentType<{ className?: string }>;
  end?: boolean;
  badge?: string;
}

interface AdminNavGroup {
  labelKey: string;
  items: AdminNavItem[];
}

const ADMIN_NAV: AdminNavGroup[] = [
  {
    labelKey: 'admin.nav.groupOverview',
    items: [
      { to: '/admin/dashboard', labelKey: 'admin.nav.dashboard', icon: LayoutDashboard, end: true },
    ],
  },
  {
    labelKey: 'admin.nav.groupContent',
    items: [
      { to: '/admin/questions', labelKey: 'admin.nav.questions', icon: HelpCircle, badge: '132' },
    ],
  },
  {
    labelKey: 'admin.nav.groupManagement',
    items: [
      { to: '/admin/organizations', labelKey: 'admin.nav.organizations', icon: Building2 },
      { to: '/admin/users', labelKey: 'admin.nav.users', icon: Users },
      { to: '/admin/consultants', labelKey: 'admin.nav.consultants', icon: Briefcase },
    ],
  },
  {
    labelKey: 'admin.nav.groupFinance',
    items: [
      { to: '/admin/payments', labelKey: 'admin.nav.payments', icon: CreditCard },
      { to: '/admin/audit', labelKey: 'admin.nav.audit', icon: ShieldAlert },
    ],
  },
];

function AdminNavSection({ onNavigate }: { onNavigate?: () => void }) {
  const { t } = useTranslation();
  const user = useAuthStore((s) => s.user);

  return (
    <nav className="flex flex-1 flex-col gap-6 overflow-y-auto px-3 py-4" aria-label={t('admin.nav.title')}>
      {ADMIN_NAV.map((group, gi) => (
        <div key={`${group.labelKey}-${gi}`}>
          <p className="mb-2 px-2.5 text-[10px] font-bold uppercase tracking-wider text-muted-foreground/80">
            {t(group.labelKey)}
          </p>
          <ul className="space-y-1">
            {group.items.map((item) => (
              <li key={item.to}>
                <NavLink
                  to={item.to}
                  end={item.end}
                  onClick={onNavigate}
                  className={({ isActive }) =>
                    cn(
                      'group relative flex items-center justify-between rounded-xl px-3 py-2 text-xs font-semibold transition-all duration-150 cursor-pointer',
                      isActive
                        ? 'bg-primary/10 text-primary shadow-sm font-bold'
                        : 'text-muted-foreground hover:bg-muted/60 hover:text-foreground',
                    )
                  }
                >
                  {({ isActive }) => (
                    <>
                      <div className="flex items-center gap-3 truncate">
                        {isActive && (
                          <span
                            className="absolute left-0 top-1/2 -translate-y-1/2 h-5 w-1 rounded-r-full brand-gradient"
                            aria-hidden="true"
                          />
                        )}
                        <item.icon
                          className={cn(
                            'h-4 w-4 shrink-0 transition-colors',
                            isActive ? 'text-primary' : 'text-muted-foreground group-hover:text-foreground',
                          )}
                        />
                        <span className="truncate">{t(item.labelKey)}</span>
                      </div>
                      {item.badge && (
                        <span
                          className={cn(
                            'rounded-md px-1.5 py-0.5 text-[10px] font-mono font-medium',
                            isActive
                              ? 'bg-primary/20 text-primary'
                              : 'bg-muted text-muted-foreground group-hover:bg-muted/80',
                          )}
                        >
                          {item.badge}
                        </span>
                      )}
                    </>
                  )}
                </NavLink>
              </li>
            ))}
          </ul>
        </div>
      ))}

      {/* Pie del Menú Admin */}
      <div className="mt-auto pt-4 space-y-3">
        <div className="rounded-xl border border-primary/20 bg-primary/5 p-3">
          <div className="flex items-center justify-between gap-1">
            <span className="text-[11px] font-bold text-primary flex items-center gap-1.5">
              <ShieldCheck className="h-3.5 w-3.5 text-primary" />
              {t('admin.nav.badge')}
            </span>
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500" />
            </span>
          </div>
          <p className="mt-1 text-[10px] text-muted-foreground truncate">
            {user?.email ?? 'admin@tryaigap.com'}
          </p>
        </div>

        <Separator className="bg-border/40" />

        <Link
          to="/dashboard"
          onClick={onNavigate}
          className="flex items-center gap-2.5 rounded-xl px-3 py-2 text-xs font-semibold text-muted-foreground hover:bg-muted/60 hover:text-foreground transition-colors"
        >
          <ArrowLeft className="h-4 w-4 shrink-0" />
          <span>{t('admin.nav.backToApp')}</span>
        </Link>
      </div>
    </nav>
  );
}

export function AdminLayout() {
  const { t } = useTranslation();
  const location = useLocation();
  const [mobileOpen, setMobileOpen] = useState(false);

  // Mapeo dinámico del título de sección en el header
  const sectionTitleKey = (() => {
    const path = location.pathname;
    if (path.startsWith('/admin/dashboard')) return 'admin.nav.dashboard';
    if (path.startsWith('/admin/questions')) return 'admin.nav.questions';
    if (path.startsWith('/admin/organizations')) return 'admin.nav.organizations';
    if (path.startsWith('/admin/users')) return 'admin.nav.users';
    if (path.startsWith('/admin/consultants')) return 'admin.nav.consultants';
    if (path.startsWith('/admin/payments')) return 'admin.nav.payments';
    if (path.startsWith('/admin/audit')) return 'admin.nav.audit';
    return 'admin.nav.title';
  })();

  return (
    <div className="flex min-h-screen bg-background text-foreground">
      {/* Desktop Sidebar */}
      <aside className="sticky top-0 hidden h-screen w-64 shrink-0 flex-col border-r border-border/50 bg-card/50 backdrop-blur-xl lg:flex z-30">
        <div className="flex h-16 items-center justify-between px-5 border-b border-border/40">
          <div className="flex items-center gap-2.5">
            <BrandLogo compact />
            <Badge variant="outline" className="text-[9px] font-bold tracking-wider uppercase border-primary/40 text-primary bg-primary/5">
              Admin
            </Badge>
          </div>
        </div>
        <AdminNavSection />
      </aside>

      {/* Mobile Drawer Overlay */}
      {mobileOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div
            className="absolute inset-0 bg-black/60 backdrop-blur-xs transition-opacity"
            onClick={() => setMobileOpen(false)}
            aria-hidden="true"
          />
          <aside className="absolute left-0 top-0 flex h-full w-72 flex-col bg-card shadow-2xl border-r border-border/60">
            <div className="flex h-16 items-center justify-between px-5 border-b border-border/40">
              <div className="flex items-center gap-2.5">
                <BrandLogo compact />
                <Badge variant="outline" className="text-[9px] font-bold uppercase border-primary/40 text-primary">
                  Admin
                </Badge>
              </div>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setMobileOpen(false)}
                aria-label={t('common.toggleMenu')}
                className="h-8 w-8 rounded-lg"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
            <AdminNavSection onNavigate={() => setMobileOpen(false)} />
          </aside>
        </div>
      )}

      {/* Contenido Principal */}
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-border/40 bg-background/80 px-4 md:px-8 backdrop-blur-md">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              className="lg:hidden h-9 w-9 rounded-lg"
              onClick={() => setMobileOpen(true)}
              aria-label={t('common.toggleMenu')}
            >
              <Menu className="h-5 w-5" />
            </Button>
            <div className="flex items-center gap-2 lg:hidden">
              <BrandLogo compact />
              <Badge variant="outline" className="text-[9px] border-primary/40 text-primary">
                Admin
              </Badge>
            </div>
            <div className="hidden lg:flex items-center gap-2">
              <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                {t(sectionTitleKey)}
              </span>
            </div>
          </div>

          <div className="flex items-center gap-2 sm:gap-3">
            <Button
              variant="outline"
              size="sm"
              asChild
              className="hidden sm:inline-flex gap-1.5 h-8 text-xs border-border/60 hover:bg-muted"
            >
              <Link to="/dashboard">
                <ArrowLeft className="h-3.5 w-3.5" />
                <span>{t('admin.nav.backToApp')}</span>
              </Link>
            </Button>
            <div className="h-4 w-px bg-border/60 mx-1 hidden sm:block" />
            <LanguageSwitcher />
            <ThemeToggle />
            <div className="h-4 w-px bg-border/60 mx-1 hidden sm:block" />
            <UserMenu />
          </div>
        </header>

        <main className="flex-1 p-4 md:p-6 lg:p-8 relative">
          {/* Fondo de rejilla sutil para estilo tecnológico */}
          <div
            className="pointer-events-none absolute inset-0 opacity-[0.25] dark:opacity-[0.12]"
            style={{
              backgroundImage: 'radial-gradient(circle, hsl(var(--primary) / 0.4) 1px, transparent 1px)',
              backgroundSize: '24px 24px',
            }}
            aria-hidden="true"
          />
          <div className="relative z-10 max-w-7xl mx-auto">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
