# Aplicación Web y Backend — TryAIGap (Fase 2)

Código fuente integral del sistema **TryAIGap**, plataforma SaaS de diagnóstico y madurez de adopción de Inteligencia Artificial para organizaciones.

---

## 1. Arquitectura del Sistema

El sistema se compone de dos capas desacopladas de alto rendimiento:

```text
Aplicación/
├── web/                            # Frontend Single Page Application (SPA)
│   ├── src/                        # Componentes React 19, hooks, páginas, i18n (ES/EN/DE/PT)
│   ├── public/                     # Recursos estáticos y branding
│   ├── package.json                # Dependencias (Vite, React 19, Tailwind CSS, shadcn/ui, Radix)
│   └── vite.config.ts              # Configuración de empaquetado y proxy de desarrollo
├── backend/                        # API RESTful de microservicios
│   ├── app/                        # Controladores FastAPI, lógica de negocio y servicios
│   ├── tests/                      # Suite de pruebas unitarias y de integración (pytest)
│   ├── requirements.txt            # Dependencias Python (FastAPI, SQLAlchemy, Pydantic v2)
│   └── Dockerfile                  # Contenedor de producción optimizado multi-stage
├── render.yaml                     # Manifiesto de infraestructura como código (Render PaaS)
└── README.md                       # Guía de ejecución del sistema
```

---

## 2. Tecnologías Empleadas

### Frontend (`web/`)
- **React 19 & TypeScript**: Tipado estricto, hooks personalizados y rendimiento reactivo.
- **Vite 6**: Compilación ultrarrápida con ESM nativo.
- **Tailwind CSS & shadcn/ui**: Sistema de diseño moderno, accesible (Radix UI) y con soporte para tema claro/oscuro.
- **react-i18next**: Internacionalización dinámica en 4 idiomas (Español, Inglés, Alemán, Portugués).
- **TanStack React Query v5**: Gestión de estado asíncrono y caché de red optimizada.

### Backend (`backend/`)
- **Python 3.12 & FastAPI**: Framework asíncrono de alto rendimiento con validación automática OpenAPI.
- **SQLAlchemy 2.0 & Alembic**: Mapeo objeto-relacional y control de versiones de base de datos.
- **Pydantic v2**: Validación estricta de esquemas y tipos de datos.
- **Supabase Client & JWKS**: Autenticación criptográfica con verificación asimétrica ES256.

---

## 3. Instrucciones de Ejecución Local

### Prerrequisitos
- Node.js 20+ y npm
- Python 3.12+
- Servidor PostgreSQL 15 (o conexión a Supabase)

### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # En Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env       # Configurar variables de entorno
uvicorn app.main:app --reload --port 8000
```

### Frontend
```bash
cd web
npm install
cp .env.example .env       # Configurar VITE_API_BASE_URL=http://localhost:8000
npm run dev
```
