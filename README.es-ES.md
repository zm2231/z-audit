

# Z-Audit

> Auditoría de seguridad para la era del vibe-coding

**Z-Audit** es una habilidad integral de auditoría de seguridad para Claude Code que detecta automáticamente tu pila tecnológica y ejecuta chequeos de vulnerabilidades dirigidos. Construido para desarrolladores que lanzan productos rápidamente y necesitan encontrar vulnerabilidades antes que otros.

---

## ¿Por qué Z-Audit?

2026 es el año del vibe-coding. Cursor, Claude, Lovable, Codex: todos están lanzando productos más rápido que nunca. Pero la velocidad a menudo hace que la seguridad se pase por alto.

Z-Audit nació de una auditoría de seguridad real donde encontramos:
- Contraseñas codificadas en JavaScript del frontend
- Endpoints de API sin autenticación
- Claves de API expuestas en los bundles
- Acceso CRUD completo a bases de datos en producción
- Datos de calendario con contraseñas de Zoom expuestas

**Si has vibe-codeado hasta llegar a producción, probablemente necesites esto.**

---

## Inicio Rápido

### Instalación

**Opción 1: Plugin Marketplace (Recomendado)**
```bash
# En Claude Code
/plugin marketplace add zm2231/z-audit
/plugin install z-audit@z-audit-marketplace
```

**Opción 2: Instalación Manual**
```bash
git clone https://github.com/zm2231/z-audit.git
cd z-audit
./install.sh
```

### Uso

```bash
# Auditar un sitio en vivo
/z-audit https://myapp.vercel.app https://api.myapp.workers.dev

# Auditar un código local
/z-audit ./my-project

# Auditar el directorio actual
/z-audit local
```

---

## Qué Comprueba

### Fase 0: Detección de Pila Tecnológica
Detecta automáticamente tu pila tecnológica antes de ejecutar los chequeos:
- Framework de frontend (React, Vue, Svelte, Next.js, Nuxt, etc.)
- Plataforma de hosting (Vercel, Netlify, Cloudflare Pages)
- Tipo de backend (Cloudflare Workers, Vercel Functions, Express, Hono)
- Base de datos (Supabase, Firebase, Postgres, MongoDB)
- Solución de autenticación (o su ausencia)

### Fase 1: Secrets y Credenciales
Escanea en busca de secrets codificados en los bundles del frontend:
- Claves de API (OpenAI, Stripe, AWS, GitHub, Google, Slack)
- Contraseñas codificadas
- JWTs y tokens de autenticación
- Credenciales de Supabase/Firebase
- Cadenas de alta entropía genéricas

### Fase 2: Autenticación y Autorización
- Bypasses de autenticación en el cliente (manipulación de localStorage)
- Endpoints de API sin autenticación
- Técnicas de bypass de autenticación (tokens nulos, encabezados malformed)
- IDOR (Referencia Directa Insegura de Objeto)
- Escalación de roles

### Fase 3: Seguridad de API
- Acceso CRUD sin autenticación
- Validación de entrada (inyección SQL, inyección NoSQL, XSS)
- Limitación de tasa
- Fuga de información en mensajes de error

### Fase 4: Específico de Infraestructura
| Plataforma | Comprobaciones |
|----------|--------|
| **Cloudflare Workers** | Lista de secrets, espacios de nombres KV, bases de datos D1, código fuente del worker |
| **Vercel** | Archivos .env expuestos, mapas de origen, rutas de API |
| **Supabase** | Políticas RLS, permisos de clave anónima, contenedores de almacenamiento |
| **Firebase** | Reglas de Firestore, reglas de almacenamiento, acceso directo a bases de datos |

### Fase 5: Headers de Seguridad y CORS
- Faltan headers de seguridad (CSP, HSTS, X-Frame-Options)
- Malconfiguración de CORS

### Fase 6: Dependencias
- Vulnerabilidades conocidas (npm audit, pip-audit)
- Paquetes desactualizados

### Fase 7: Exposición de Datos
- PII en respuestas de API
- Mensajes de error verbosos con stack traces

---

## Formato del Informe

Z-Audit genera un informe estructurado con niveles de gravedad:

```markdown
# Informe de Seguridad de Z-Audit

**Objetivo:** https://myapp.vercel.app
**Fecha:** 2026-01-16
**Pila Tecnológica:** Next.js + Supabase + Cloudflare Workers

## Resumen Ejecutivo
Se encontraron vulnerabilidades críticas. La API no tiene autenticación, 
exponiendo todos los datos de usuario. Acción inmediata requerida.

## Hallazgos Críticos
### C1: Contraseña Codificada en el Frontend
- **Ubicación:** /assets/index-abc123.js
- **Problema:** Contraseña en texto claro
- **Impacto:** Cualquiera puede autenticarse
- **Solución:** Mover la validación al servidor

## Hallazgos Graves
...

## Hallazgos Moderados
...

## Qué es Seguro
- HTTPS forzado
- No se encontraron vulnerabilidades de inyección SQL

## Plan de Acción
1. **Inmediato:** Agregar autenticación a la API
2. **Esta semana:** Eliminar secrets codificados
3. **Este mes:** Implementar limitación de tasa
```

---

## Niveles de Gravedad

| Nivel | Significado | Ejemplos |
|-------|---------|----------|
| **Crítica** | Explotación inmediata posible | Contraseñas codificadas, sin autenticación en API, secrets expuestos |
| **Alta** | Riesgo significativo | Claves de API expuestas, IDOR, falta de autenticación en algunas rutas |
| **Media** | Debería arreglarse pronto | Errores verbosos, limitación de tasa débil, headers faltantes |
| **Baja** | Bu práctica | Dependencias desactualizadas (sin exploits), falta de CSP |

---

## Estructura del Proyecto

```
z-audit/
├── .claude-plugin/
│   ├── plugin.json            # Manifest del plugin
│   └── marketplace.json       # Catálogo del marketplace
├── commands/
│   └── z-audit.md             # Comando slash
├── agents/
│   └── z-audit.md             # Definición de subagente
├── skills/
│   └── z-audit/
│       └── skill.md           # Metodología completa de auditoría
├── examples/
│   └── sample-report.md       # Informe de ejemplo
├── install.sh                 # Instalador manual
└── README.md
```

---

## Tres Formas de Usar Z-Audit

| Método | Ideal para |
|--------|------------|
| **Instalación de Plugin** | Más fácil, auto-actualizaciones |
| **Comando Slash** | Auditorías rápidas, interactivo |
| **Subagente** | Auto-delegación, segundo plano |

### Opción 1: Plugin (Recomendado)

```bash
/plugin marketplace add zm2231/z-audit
/plugin install z-audit@z-audit-marketplace
```

### Opción 2: Comando Slash

```bash
/z-audit https://myapp.vercel.app https://api.myapp.workers.dev
```

Al invocarlo, se te preguntará:
- **Directo**: Ejecutar análisis en la conversación actual
- **Subagente**: Iniciar un agente dedicado (se ejecuta en segundo plano)

### Opción 3: Auto-Delegación

Una vez instalado, Claude puede delegar automáticamente las auditorías de seguridad al subagente z-audit:
```
"Comprueba si mi app en https://myapp.vercel.app tiene problemas de seguridad"
```

---

## Personalización

### Agregar Nuevos Patrones de Secrets

Edita `skills/z-audit/skill.md` y agrega patrones a la Fase 1:

```bash
# Agrega tu patrón personalizado
grep -oE 'mycompany_[a-zA-Z0-9]+' /tmp/bundle.js
```

### Agregar Nueva Detección de Pila Tecnológica

Agrega a la Fase 0 en `skills/z-audit/skill.md`:

```bash
# Detecta tu framework
cat package.json | grep -E '"my-framework"'
```

### Agregar Comprobaciones de Infraestructura

Agrega una nueva sección en la Fase 4 de `skills/z-audit/skill.md`.

---

## Uso Responsable

Z-Audit es para **auditar tus propios proyectos** o proyectos para los cuales tienes permiso para realizar pruebas.

- Audita tus propias aplicaciones
- Audita con permiso explícito
- Programas de bug bounty (sigue sus reglas)
- **Nunca** pruebes sin autorización
- **Nunca** explotes las vulnerabilidades que encuentres
- **Nunca** accedas a datos que no deberías

**Siempre obtén permiso antes de auditar.**

---

## Contribuciones

¿Encontraste un patrón de vulnerabilidad común que nos falta? ¡Se aceptan PRs!

1. Haz fork del repositorio
2. Agrega tus comprobaciones a `skills/z-audit/skill.md`
3. Prueba en un proyecto de ejemplo
4. Envía el PR con una descripción

---

## Recursos

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Supabase Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Cloudflare Workers Security](https://developers.cloudflare.com/workers/platform/security/)

---

## Licencia

MIT - Úsalo libremente, audita de forma responsable.
