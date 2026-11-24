import { useState, type ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router';
import { useTranslation } from 'react-i18next';
import { ShieldAlert, ArrowLeft, Wrench } from 'lucide-react';
import { useAuthStore } from '@/store/authStore';
import { canAccessAdmin } from '@/lib/roles';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

const DEV_OVERRIDE_KEY = 'tryaigap.dev_admin_override';

interface AdminRouteGuardProps {
  children: ReactNode;
}

export function AdminRouteGuard({ children }: AdminRouteGuardProps) {
  const { t } = useTranslation();
  const location = useLocation();
  const user = useAuthStore((s) => s.user);
  const status = useAuthStore((s) => s.status);

  // Permite override local en entorno de desarrollo para pruebas y prototipado ágil
  const isDev = import.meta.env.DEV;
  const [devAdminOverride, setDevAdminOverride] = useState<boolean>(() => {
    if (!isDev) return false;
    return localStorage.getItem(DEV_OVERRIDE_KEY) === 'true';
  });

  const toggleDevOverride = () => {
    const nextVal = !devAdminOverride;
    if (nextVal) {
      localStorage.setItem(DEV_OVERRIDE_KEY, 'true');
    } else {
      localStorage.removeItem(DEV_OVERRIDE_KEY);
    }
    setDevAdminOverride(nextVal);
  };

  if (status === 'hydrating' || status === 'idle') {
    return (
      <div className="flex min-h-[50vh] w-full items-center justify-center p-8">
        <div className="h-8 w-8 animate-spin rounded-full border-3 border-primary border-t-transparent" />
      </div>
    );
  }

  if (status === 'unauthenticated' || !user) {
    return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  }

  const hasAdminAccess = canAccessAdmin(user.role) || (isDev && devAdminOverride);

  if (!hasAdminAccess) {
    return (
      <div className="flex min-h-[70vh] items-center justify-center p-4">
        <Card className="max-w-md w-full border-destructive/30 shadow-lg">
          <CardHeader className="text-center pb-2">
            <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-2xl bg-destructive/10 text-destructive">
              <ShieldAlert className="h-8 w-8" />
            </div>
            <CardTitle className="text-xl font-bold">{t('admin.guard.title')}</CardTitle>
            <CardDescription className="text-xs">
              {t('admin.guard.description')}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3 pt-2 text-center">
            <p className="text-xs text-muted-foreground">
              {t('admin.guard.deniedMessage')}
            </p>
            <div className="inline-flex items-center gap-2 rounded-lg border border-border/60 bg-muted/40 px-3 py-1.5 text-xs font-mono">
              <span className="text-muted-foreground">Email:</span>
              <span className="font-semibold">{user.email}</span>
              <span className="text-muted-foreground">| Rol:</span>
              <Badge variant="outline" className="text-[10px] capitalize">
                {user.role}
              </Badge>
            </div>

            {isDev && (
              <div className="mt-4 rounded-lg border border-primary/20 bg-primary/5 p-3 text-left">
                <div className="flex items-center gap-2 text-xs font-semibold text-primary">
                  <Wrench className="h-3.5 w-3.5" />
                  <span>Modo Desarrollador Activo</span>
                </div>
                <p className="mt-1 text-[11px] text-muted-foreground">
                  {t('admin.guard.devNotice')}
                </p>
                <Button
                  size="sm"
                  variant="outline"
                  className="mt-3 w-full border-primary/30 text-xs hover:bg-primary/10"
                  onClick={toggleDevOverride}
                >
                  {t('admin.guard.devOverrideEnable')}
                </Button>
              </div>
            )}
          </CardContent>
          <CardFooter className="flex justify-center pt-2">
            <Button
              variant="default"
              size="sm"
              className="gap-2"
              onClick={() => window.location.assign('/dashboard')}
            >
              <ArrowLeft className="h-4 w-4" />
              {t('admin.guard.backToDashboard')}
            </Button>
          </CardFooter>
        </Card>
      </div>
    );
  }

  return <>{children}</>;
}
