# Base de Datos — TryAIGap (Fase 2)

Este módulo contiene la definición, esquemas, migraciones y modelos de la arquitectura de datos del proyecto **TryAIGap**.

---

## 1. Arquitectura de Datos y Motor
- **Motor Principal:** PostgreSQL 15 administrado en la nube a través de **Supabase**.
- **Acceso y Pooling:** 
  - Conexión vía **Supabase Connection Pooler** (PgBouncer en modo transacción, puerto 6543) para alta concurrencia y bajo consumo de descriptores de conexión.
  - ORM backend en **SQLAlchemy 2.0** asíncrono/síncrono y migraciones declarativas mediante **Alembic**.
- **Seguridad en Reposo y Tránsito (RLS):**
  - **Row Level Security (RLS)** habilitado por defecto en todas las tablas públicas.
  - La API de FastAPI utiliza credenciales de servicio directas (`service_role` / Postgres direct role), mientras que cualquier intento de lectura anónima o externa desde el navegador es bloqueado por políticas RLS restrictivas.

---

## 2. Estructura de este Directorio

```text
Base de datos/
├── Esquema_DDL_PostgreSQL.sql      # Script DDL completo con las 25 tablas del modelo relacional y RLS
├── DiagramaDB_TryAIGap.svg        # Diagrama entidad-relación detallado en formato vectorial SVG
├── Migraciones/
│   ├── alembic/                    # Historial secuencial de migraciones de esquema Alembic
│   │   ├── alembic.ini
│   │   ├── env.py
│   │   └── versions/               # Scripts de migración versionados
│   └── supabase/                   # Migraciones de seguridad y buckets de almacenamiento
│       └── 20261120_enable_rls_and_private_storage.sql
└── Modelos/
    ├── models.py                   # Definición declarativa de entidades ORM (SQLAlchemy)
    └── schemas/                    # Contratos de validación y DTOs (Pydantic v2)
```

---

## 3. Tablas Principales del Modelo

1. **`organizations`**: Empresas evaluadas en el diagnóstico de brechas de IA.
2. **`users`**: Usuarios y consultores con autenticación Supabase Auth vinculada por UUID.
3. **`assessments`**: Procesos de evaluación técnica y estratégica con estados (draft, in_progress, review, completed).
4. **`questions` / `question_translations`**: Banco de preguntas multidimensional y soporte de localización i18n (ES, EN, DE, PT).
5. **`answers`**: Respuestas recopiladas con puntajes Likert y justificaciones cualitativas.
6. **`area_states`**: Resumen de madurez y puntajes consolidados por dimensión evaluada.
7. **`documents`**: Registro de evidencias empresariales vinculadas a buckets seguros de Supabase Storage.
8. **`audit_logs`**: Trazabilidad completa de acciones y cambios de estado para cumplimiento corporativo.
9. **`payments` / `quotes`**: Módulo comercial para cotizaciones corporativas e integración con Stripe.
