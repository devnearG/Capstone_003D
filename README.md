# 🎓 Portafolio de Título (APT122 / Capstone) — Sección 003D

**Carrera:** Ingeniería en Informática  
**Institución:** Duoc UC — Escuela de Informática y Telecomunicaciones  
**Semestre:** 2026-S2  

---

## 📌 1. Información del Proyecto y Empresa Colaboradora

* **Proyecto Asignado:** **TryAIGap** (*"Bridge the AI Gap"*) — Plataforma SaaS B2B para evaluación de madurez en Inteligencia Artificial y consultoría estratégica.
* **Empresa Colaboradora:** **Losentlic** & **Lux&Trick**
* **Docente Guía:** Luis Bravo (Duoc UC)
* **Coordinación Institucional:** Gerardo Galán (Duoc UC)
* **Coordinación Operativa / Técnica:** Karina Álvarez / Max (Losentlic)

---

## 👥 2. Integrantes del Equipo de Trabajo

| Integrante | Rol Principal | Responsabilidades Clave |
|---|---|---|
| **Fabrizio Martínez** | **Lead Frontend & UI/UX** | Arquitectura SPA (React 19 + TypeScript), diseño de interfaces (UI/UX), accesibilidad WCAG 2.1 AA, internacionalización (i18n), optimización Core Web Vitals y suite de pruebas Vitest. |
| **Matías López** | **Lead Backend, Base de Datos & Stripe** | Arquitectura API REST (FastAPI), persistencia relacional y RLS (PostgreSQL / Supabase), modelos ORM (SQLAlchemy), lógica de scoring y pasarela de pagos B2B (Stripe). |
| **Matías González** | **Gestión de Proyecto, Scrum & Documentación** | Metodología ágil (Scrum), planificación de sprints, actas de reuniones de stakeholders, bitácoras de avance y documentación técnica institucional. |

---

## 📁 3. Estructura de Entregas y Evidencias Académicas

Este repositorio contiene exclusivamente las evidencias, bitácoras y entregables formales para la evaluación académica de la asignatura:

```text
Capstone_003D/
├── Fase 1/                                ← Definición de Proyecto APT (Semanas 1 a 4)
│   ├── Evidencias Grupales/               ← Guía 1.5 de Definición de Proyecto y acuerdos
│   └── Evidencias Individuales/           ← Evidencias 1.1 (Competencias), 1.2 (Diario de Reflexión) y 1.3 (Autoevaluación)
├── Fase 2/                                ← Desarrollo del Proyecto APT (Semanas 5 a 15)
│   ├── Evidencias Grupales/               ← Informes de sprint y actas de avance
│   ├── Evidencias Individuales/           ← Diarios de reflexión y autoevaluaciones Fase 2
│   └── Evidencias de Proyecto/            ← Entregables de ingeniería y sistema
│       ├── Presentación Proyecto.pptx     ← Presentación ejecutiva oficial (16:9 widescreen)
│       ├── Documentos de diseño/          ← Plan de QA, matriz de pruebas, informe de resultados y arquitectura UI/mockups
│       └── Evidencias de sistema/         ← Código fuente y base de datos auditables
│           ├── Aplicación/                ← Web SPA (React 19) + API Backend (FastAPI)
│           └── Base de datos/             ← Esquema DDL (25 tablas PostgreSQL), RLS y migraciones Alembic
├── Fase 3/                                ← Presentación y Cierre (Semanas 16 a 18)
│   ├── Evidencias Grupales/               ← Informe final, manuales y presentación ejecutiva
│   └── Evidencias Individuales/           ← Reflexiones finales y autoevaluación consolidada
└── Material adicional/                    ← Pautas oficiales, plantillas y rúbricas de evaluación
```

---

## 💻 4. Repositorio de Desarrollo de Software

El código fuente, arquitectura técnica, pipeline de CI/CD y despliegue continuo en Vercel del producto **TryAIGap** se gestionan en el repositorio de desarrollo privado:
* **Repositorio de Software:** `TryAIGap` (Acceso privado para el equipo de desarrollo y contrapartes técnicas).
* **Despliegue Web en Producción:** [https://tryaigap.vercel.app](https://tryaigap.vercel.app)
* **API Backend en Producción:** [https://tryaigap-api.onrender.com/api/v1](https://tryaigap-api.onrender.com/api/v1)
