# Habitus Faith 🙏✨

**⇨ [English 🇬🇧](#english) | [Español 🇪🇸](#español)**

---

## English

<details open>
<summary><a name="english"></a><strong>English</strong></summary>

**The First Faith-Based Habit Tracker with AI-Powered Personalization**

[![Tests](https://img.shields.io/badge/tests-0/ passing-yellow)]()
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-blue)]()
[![Riverpod](https://img.shields.io/badge/riverpod-2.5-blue)]()
[![Firebase](https://img.shields.io/badge/firebase-enabled-orange)]()
[![AI](https://img.shields.io/badge/AI-Gemini%201.5-purple)]()

> **Make faith your best daily habit** – Track spiritual growth with intelligent habit generation, Bible verse enrichment, personalized AI coaching, and rich note-taking.

### 🌟 What Makes Us Different

#### 🤖 AI-Powered Micro-Habits Generator
- Gemini 1.5 Flash integration
- **Weighted Template Matching** with 85%+ accuracy
  - Intent-based scoring (40% weight)
  - Support level, challenge, and motivation matching
  - Sub-50ms performance for 100 templates
- Automatic smart category (Spiritual, Physical, Mental, Relational, Household)
- Bible verse enrichment
- Multi-language support (English, Spanish, French, Portuguese + more)
- Rate-limited for sustainability

**Example:**
```
User Goal: "Pray more consistently"
↓
AI Generates 3 Habits:
1. 🙏 Pray 3min after waking before your phone
   📖 Psalms 5:3: "In the morning, LORD, you hear my voice..."
   💡 Begin your day prioritizing God

2. 🙏 Write a gratitude prayer before going to bed
   📖 1 Thessalonians 5:18: "Give thanks in all circumstances..."
   💡 Cultivate a grateful heart

3. 🙏 Read a Psalm at lunchtime
   📖 Psalms 119:105: "Your word is a lamp to my feet..."
   💡 Feed your spirit midday
```

#### 📊 Intelligent Habit Tracking
- Automatic streak monitoring, calendar heatmap, longest record
- Same-day protection (no duplicate completions)
- Offline-first (SharedPreferences + optional Firestore sync)
- **Long-press drag & drop reorder** – hold any habit card to drag; short taps always scroll
- **Auto-scroll when dragging** – 180 px edge zone with graduated speed (120–900 px/s); upward drag scrolls continuously without releasing
- **Persistent order across midnight** – `createdAt` tiebreaker ensures deterministic sort after daily reset
- **Unskip / un-fail** – tap a skipped or failed habit to instantly reset it to pending, then complete

#### 📝 Rich Note Editor
- Checkbox list with tap-to-toggle (✅ done / ⬜ pending)
- Numbered list format (1. 2. 3…)
- Quick-emoji toolbar (🙏 ✨ 📖 ❤️ 💪 …)
- Share any note via system share sheet

#### 🎯 Gamification – Faith Points & Badges
- Points awarded per completion, weighted by difficulty and streak
- Stage progression (Seedling → Tree → Forest…)
- Badge collection unlocked by milestones

#### ⏱️ Focus Timer
- Built-in Pomodoro-style task timer per habit
- Completes the habit automatically on finish

#### 🏠 Household Spinner
- Spin-the-wheel for assigning household tasks
- Tracks completion and streak per task

#### 📖 Integrated Bible Reader
- 4 Spanish versions
- Smart verse lookup and abbreviations (Gn, Ex, Sal, Mt, Ro, Ap)
- Numbered books (1-3 John, 1-2 Corinthians, etc.)

#### 🔒 Security & Privacy
- Anonymous authentication; no personal data required
- User-scoped data isolation
- Input sanitization, atomic rate limiting

#### 🌍 Internationalization
- 5+ locales fully localized (EN, ES, FR, PT, DE)
- No hardcoded strings; every UI string is localized

---

### 🐛 Recent Bug Fixes (v1.2.0)

| # | Bug | Fix |
|---|-----|-----|
| 1 | Drag upward gets stuck / doesn't scroll | Edge zone enlarged to 180 px, minimum scroll speed floor (120 px/s), `autoScrollerVelocityScalar` re-enabled cooperatively |
| 2 | Normal scroll hijacked by drag | `ReorderableDelayedDragStartListener` requires **long-press** before drag starts; short taps scroll normally |
| 3 | Habit order resets after midnight | `createdAt` used as stable tiebreaker so equal-`order` habits keep a deterministic position across day resets |
| 4 | Unskip triggers infinite loading | All `HabitsNotifier` mutation methods now wrapped in `try-catch`; `AsyncLoading` can never be left unresolved by an unexpected exception |
| 5 | Notes editor — plain text only | Rich editor with checkbox list (tap to toggle ✅), numbered list (1. 2. 3…), quick-emoji toolbar, and per-note share button |

---

### 🚀 Quick Start

**Prerequisites:**
- Flutter SDK 3.0+
- Firebase account
- Gemini API key (optional for AI)

**Install dependencies:**
```bash
flutter pub get
```

**Configure environment:**
Create `.env` in the project root:
```env
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-1.5-flash
```

**Run tests:**
```bash
flutter test
# All suites: ✅ passing
# Regression tests: habit_bugs_regression_test.dart (16 tests)
# Behavior tests: bug_fixes_behavior_test.dart (19 tests)
# Coverage: 85%+ on core business logic
```

**Setup Firebase:**
1. Go to Firebase Console
2. Select your project
3. Enable Authentication → Anonymous
4. Create Firestore DB → Production mode

**Run the app:**
```bash
flutter run
```

---

### 📚 Core Features
- **AI micro-habits generator** with weighted template matching (Intent 40%, Support 20%, Challenge 20%, Motivations 15%, Maturity 5%)
- Drag & drop habit reordering with persistent order across midnight
- Unskip / un-fail any habit with a single tap
- Rich note editor: plain text, checkbox list, numbered list
- Focus timer (Pomodoro) per habit
- Household task spinner
- Faith points & badge gamification
- Bible reader with 4 Spanish versions
- Streak heatmap, longest streak record
- Full offline support
- Subtask tracking inline

### 🏗️ Architecture
- **Frontend:** Flutter
- **State Management:** Riverpod (AsyncNotifier + StreamProvider)
- **Backend:** Firebase (Firestore + Auth)
- **Local storage:** SharedPreferences via JsonHabitsRepository
- **AI:** Google Gemini 1.5 Flash
- **i18n:** flutter_localizations
- **Testing:** flutter_test + integration tests

### 📈 Roadmap
- v1.2: Push notifications (FCM), weekly reports
- v2.0: ML-based abandonment predictions, wearables integration, group challenges

### 📚 Documentation

Comprehensive documentation in the [docs](docs/README.md) folder:

- **[Quick Reference](docs/guides/QUICK_REFERENCE.md)** – Common commands and tasks
- **[Features](docs/features/)** – Detailed feature documentation
- **[Implementation](docs/implementation/)** – Implementation summaries
- **[Testing](docs/testing/)** – Testing guides
- **[Reports](docs/reports/)** – Status reports and change logs

### 🤝 Contributing
1. Fork the repository
2. Create your branch
3. Add tests
4. Ensure all tests pass
5. Format and analyze code
6. Pull request

---

### 📄 License

Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0).

© 2026 develop4God

---

### 🙏 Acknowledgments
Flutter, Riverpod, Firebase, Gemini, and the open source community.

### 📞 Support
- Email: support@develop4god.com
- Issues: [GitHub Issues](https://github.com/develop4God/habitus_faith/issues)
- Discussions: [GitHub Discussions](https://github.com/develop4God/habitus_faith/discussions)

### ⚡ Quick Commands
```bash
flutter pub get
flutter gen-l10n
flutter test
flutter test --coverage
flutter analyze --fatal-infos
dart format lib/ test/
flutter run
flutter build apk --release
flutter build ios --release
flutter clean && flutter pub get
```

**Built with ❤️ and 🙏 by develop4God**
*Make faith your best daily habit* ✨

**Version**: 1.1.0
**Last Updated**: February 2026
**Status**: ✅ Production Ready

</details>

---

## Español

<details>
<summary><a name="español"></a><strong>Español</strong></summary>

**El primer rastreador de hábitos basado en la fe con personalización por IA**

[![Tests](https://img.shields.io/badge/tests-0/ passing-yellow)]()
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-blue)]()
[![Riverpod](https://img.shields.io/badge/riverpod-2.5-blue)]()
[![Firebase](https://img.shields.io/badge/firebase-enabled-orange)]()
[![AI](https://img.shields.io/badge/AI-Gemini%201.5-purple)]()

> **Haz que la fe sea tu mejor hábito diario** – Monitorea tu crecimiento espiritual con generación inteligente de hábitos, enriquecimiento de versículos bíblicos, coaching personalizado por IA y un editor de notas enriquecido.

### 🌟 ¿Qué nos hace diferentes?

#### 🤖 Generador IA de Micro-Hábitos
- Integración Gemini 1.5 Flash
- **Coincidencia ponderada de plantillas** con 85%+ precisión
  - Puntuación basada en intención (40% peso)
  - Coincidencia de nivel de soporte, desafío y motivación
  - Rendimiento sub-50ms para 100 plantillas
- Inferencia automática de categoría (Espiritual, Física, Mental, Relacional, Hogar)
- Enriquecimiento con versículos bíblicos
- Soporte multilenguaje (ES, EN, FR, PT, DE)
- Límite de uso para sostenibilidad

#### 📊 Seguimiento Inteligente de Hábitos
- Monitoreo automático de rachas, mapa de calor, récord más largo
- Protección el mismo día (sin registros duplicados)
- Soporte offline (SharedPreferences + sincronización opcional con Firestore)
- **Reordenación por arrastrar y soltar** – mantén presionado cualquier tarjeta
- **Orden persistente tras la medianoche** – el orden base sobrevive al reinicio diario
- **Desmarcar "omitido"/"fallido"** – toca el hábito para restablecer a pendiente

#### 📝 Editor de Notas Enriquecido
- Lista de casillas de verificación con tap para marcar/desmarcar
- Lista numerada (1. 2. 3…)
- Barra de emojis rápidos (🙏 ✨ 📖 ❤️ 💪 …)
- Compartir cualquier nota con el sistema de compartir

#### 🎯 Gamificación – Puntos de Fe y Medallas
- Puntos por completar hábitos, ponderados por dificultad y racha
- Progresión de etapas (Semilla → Árbol → Bosque…)
- Colección de medallas desbloqueadas por hitos

#### ⏱️ Temporizador de Enfoque
- Temporizador estilo Pomodoro por hábito
- Completa el hábito automáticamente al finalizar

#### 🏠 Ruleta de Tareas del Hogar
- Ruleta para asignar tareas domésticas
- Rastrea completado y racha por tarea

#### 📖 Lector Bíblico Integrado
- 4 versiones en español
- Búsqueda inteligente y abreviaturas (Gn, Ex, Sal, Mt, Ro, Ap)
- Libros numerados (1-3 Juan, 1-2 Corintios, etc.)

#### 🔒 Seguridad y Privacidad
- Autenticación anónima, sin datos personales
- Datos aislados por usuario
- Sanitización de entradas, límite atómico de uso

#### 🌍 Internacionalización
- 5+ locales completamente localizados
- Sin textos codificados; toda la interfaz traducida

---

### 🐛 Correcciones Recientes (v1.1.0)

| # | Error | Corrección |
|---|-------|------------|
| 1 | Arrastrar y soltar lento en listas largas | `cacheExtent: 2000`, cambio a `ReorderableDragStartListener` inmediato |
| 2 | El orden de hábitos se reinicia tras la medianoche | `reorderHabits` ya no dispara `AsyncLoading`, preservando el orden visual |
| 3 | Desmarcar "omitido" genera un spinner infinito | Nuevo método `resetHabit`; el checkbox llama `resetHabit → completeHabit` |
| 4 | Editor de notas solo texto plano | Nuevo editor rico con casillas, lista numerada y barra de formato |

---

### 🚀 Inicio Rápido

**Prerrequisitos:**
- Flutter SDK 3.0+
- Cuenta de Firebase
- Clave API Gemini (opcional para IA)

**Instalar dependencias:**
```bash
flutter pub get
```

**Configurar el entorno:**
```env
GEMINI_API_KEY=tu_clave_api_gemini_aquí
GEMINI_MODEL=gemini-1.5-flash
```

**Ejecutar tests:**
```bash
flutter test
# Todos los suites: ✅ pasando
# Cobertura: 85%+ en lógica de negocio
```

**Configurar Firebase:**
1. Ve a la consola de Firebase
2. Activa Autenticación → Anónima
3. Crea Firestore DB → Modo producción

**Ejecutar la app:**
```bash
flutter run
```

---

### 📚 Funcionalidades
- **Generador IA de micro-hábitos** (Intención 40%, Soporte 20%, Desafío 20%, Motivaciones 15%, Madurez 5%)
- Reordenación por arrastrar con orden persistente
- Desmarcar hábito omitido/fallido con un toque
- Editor de notas rico: texto, casillas, lista numerada
- Temporizador de enfoque (Pomodoro)
- Ruleta de tareas del hogar
- Gamificación: puntos de fe y medallas
- Lector bíblico con 4 versiones en español
- Mapa de calor de rachas
- Soporte offline completo
- Subtareas inline

### 🏗️ Arquitectura
- **Frontend:** Flutter
- **Gestión de estado:** Riverpod
- **Backend:** Firebase
- **IA:** Google Gemini
- **Internacionalización:** flutter_localizations
- **Testing:** flutter_test

### 📈 Roadmap
- v1.2: Notificaciones push, reportes semanales
- v2.0: Predicción con ML, wearables, retos de grupo

### 🤝 Cómo contribuir
1. Fork del repositorio
2. Crea tu rama
3. Agrega tests
4. Verifica que todo pase
5. Pull request

---

### 📄 Licencia

Creative Commons Atribución-NoComercial 4.0 Internacional (CC BY-NC 4.0).

© 2026 develop4God

---

### 🙏 Agradecimientos
Flutter, Riverpod, Firebase, Gemini y la comunidad open source.

### 📞 Soporte
- Email: support@develop4god.com
- Issues: [GitHub Issues](https://github.com/develop4God/habitus_faith/issues)

### ⚡ Comandos rápidos
```bash
flutter pub get
flutter gen-l10n
flutter test
flutter test --coverage
flutter analyze --fatal-infos
dart format lib/ test/
flutter run
flutter build apk --release
flutter build ios --release
flutter clean && flutter pub get
```

**Creado con ❤️ y 🙏 por develop4God**
*Haz que la fe sea tu mejor hábito diario* ✨

**Versión**: 1.1.0
**Última actualización**: Febrero 2026
**Estado**: ✅ Listo para producción

</details>
