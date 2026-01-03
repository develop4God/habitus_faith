# Habitus Faith 🙏✨

**⇨ [English 🇬🇧](#english) | [Español 🇪🇸](#español)**

---

## English

<details open>
<summary><a name="english"></a><strong>English</strong></summary>

**The First Faith-Based Habit Tracker with AI-Powered Personalization**

[![Tests](https://img.shields.io/badge/tests-37%2F38%20passing-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-85%25%2B-green)]()
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-blue)]()
[![Riverpod](https://img.shields.io/badge/riverpod-2.5-blue)]()
[![Firebase](https://img.shields.io/badge/firebase-enabled-orange)]()
[![AI](https://img.shields.io/badge/AI-Gemini%201.5-purple)]()

> **Make faith your best daily habit** – Track spiritual growth with intelligent habit generation, Bible verse enrichment, and personalized AI coaching.

### 🌟 What Makes Us Different

#### 🤖 AI-Powered Micro-Habits Generator
- Gemini 1.5 Flash integration
- **Weighted Template Matching** with 85%+ accuracy
   - Intent-based scoring (40% weight)
   - Support level, challenge, and motivation matching
   - Sub-50ms performance for 100 templates
- Automatic smart category (Spiritual, Physical, Mental, Relational)
- Bible verse enrichment
- Multi-language support
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
- Offline support

#### 📖 Integrated Bible Reader
- 4 Spanish versions
- Smart verse lookup and abbreviations (Gn, Ex, Sal, Mt, Ro, Ap)
- Numbered books (1-3 John, 1-2 Corinthians, etc.)

#### 🔒 Security & Privacy
- Anonymous authentication; no personal data required
- User-scoped data
- Input sanitization, atomic rate limiting

#### 🌍 Internationalization
- 78 test suite for all languages
- No hardcoded strings; every UI is localized

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
# Template Matching: ✅ 21/21 tests passing
# Service Tests: ✅ 16/17 tests passing (1 pre-existing fuzzy match edge case)
# Coverage: 85%+ on new weighted scoring system
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
**AI micro-habits generator** with weighted template matching
   - Dimensional scoring: Intent (40%), Support Level (20%), Challenge (20%), Motivations (15%), Maturity (5%)
   - Performance-validated: < 50ms for 100 templates
   - Comprehensive test coverage with error handling
Custom and trackable habits
Bible reader with 4 Spanish versions
Streak and progress visualizations
Full dependency injection architecture

### 🏗️ Architecture
- **Frontend:** Flutter
- **State Management:** Riverpod
- **Backend:** Firebase
- **AI:** Google Gemini
- **i18n:** flutter_localizations
- **Testing:** flutter_test

### 📈 Roadmap
- v1.1: Push notifications, weekly reports
- v2.0: ML-based predictions, wearables integration, group challenges

### 🤝 Contributing
1. Fork repository  
2. Create your branch  
3. Add tests  
4. Ensure all tests pass  
5. Format and analyze code  
6. Pull request

---

### 📄 License

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).

You are free to:

- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material

Under the following terms:

- **Attribution (BY):** You must give appropriate credit, provide a link to the license, and indicate if changes were made.
- **NonCommercial (NC):** You may not use the material for commercial purposes.

For the full license text, see the LICENSE file or visit:  
- [Summary](https://creativecommons.org/licenses/by-nc/4.0/)  
- [Legal Code](https://creativecommons.org/licenses/by-nc/4.0/legalcode)

© 2024 develop4God

---

### 🙏 Acknowledgments
Flutter, Riverpod, Firebase, Gemini, and the open source community

### 📞 Support
- Email: support@develop4god.com  
- Docs: [docs/README.md](docs/README.md)  
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

**Version**: 1.0.0  
**Last Updated**: October 2024  
**Status**: ✅ Production Ready

</details>

---

## Español

<details>
<summary><a name="español"></a><strong>Español</strong></summary>

**El primer rastreador de hábitos basado en la fe con personalización por IA**

[![Tests](https://img.shields.io/badge/tests-37%2F38%20passing-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-85%25%2B-green)]()
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-blue)]()
[![Riverpod](https://img.shields.io/badge/riverpod-2.5-blue)]()
[![Firebase](https://img.shields.io/badge/firebase-enabled-orange)]()
[![AI](https://img.shields.io/badge/AI-Gemini%201.5-purple)]()

> **Haz que la fe sea tu mejor hábito diario** – Monitorea tu crecimiento espiritual con generación inteligente de hábitos, enriquecimiento de versículos bíblicos y coaching personalizado por IA.

### 🌟 ¿Qué nos hace diferentes?

#### 🤖 Generador IA de Micro-Hábitos
- Integración Gemini 1.5 Flash
- **Coincidencia ponderada de plantillas** con 85%+ precisión
   - Puntuación basada en intención (40% peso)
   - Coincidencia de nivel de soporte, desafío y motivación
   - Rendimiento sub-50ms para 100 plantillas
- Inferencia automática de categoría (Espiritual, Física, Mental, Relacional)
- Enriquecimiento con versículos bíblicos
- Soporte multilenguaje
- Límite de uso para sostenibilidad

**Ejemplo:**
```
Meta: "Orar más consistentemente"
↓
La IA genera 3 hábitos:
1. 🙏 Orar 3min al despertar antes de mirar el teléfono  
   📖 Salmos 5:3: "Oh Jehová, de mañana oirás mi voz..."
   💡 Comenzar el día poniendo a Dios como prioridad

2. 🙏 Escribir una oración de gratitud antes de dormir  
   📖 1 Tesalonicenses 5:18: "Dad gracias en todo..."
   💡 Cultivar un corazón agradecido

3. 🙏 Leer un Salmo durante el almuerzo  
   📖 Salmos 119:105: "Lámpara es a mis pies tu palabra..."
   💡 Nutrir el espíritu a mitad del día
```

#### 📊 Seguimiento Inteligente de Hábitos
- Monitoreo automático de rachas, mapa de calor, récord más largo
- Protección el mismo día (sin registros duplicados)
- Soporte offline

#### 📖 Lector Bíblico Integrado
- 4 versiones en español
- Búsqueda inteligente de versículos y abreviaturas (Gn, Ex, Sal, Mt, Ro, Ap)
- Libros numerados (1-3 Juan, 1-2 Corintios, etc.)

#### 🔒 Seguridad y Privacidad
- Autenticación anónima, sin datos personales
- Datos aislados por usuario
- Sanitización de entradas, límite atómico de uso

#### 🌍 Internacionalización
- Suite de 78 tests en todos los idiomas
- Sin textos codificados; toda la interfaz traducida

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
Crea el archivo `.env` en la raíz del proyecto:  
```env
GEMINI_API_KEY=tu_clave_api_gemini_aquí
GEMINI_MODEL=gemini-1.5-flash
```

**Ejecutar tests:**  
```bash
flutter test
<<<<<<< HEAD
# Resultado: ✅ 78 tests exitosos
=======
# Coincidencia de Plantillas: ✅ 21/21 tests exitosos
# Tests de Servicio: ✅ 16/17 tests exitosos (1 caso edge pre-existente)
# Cobertura: 85%+ en el nuevo sistema de puntuación ponderada
>>>>>>> 79bec40078dea0cf32e225016fdcecbddfb3e048
```

**Configurar Firebase:**  
1. Ve a la consola de Firebase  
2. Selecciona tu proyecto  
3. Activa Autenticación → Anónima  
4. Crea Firestore DB → Modo producción

**Ejecutar la app:**  
```bash
flutter run
```

---

### 📚 Funcionalidades
**Generador IA de micro-hábitos** con coincidencia ponderada de plantillas
   - Puntuación dimensional: Intención (40%), Nivel de soporte (20%), Desafío (20%), Motivaciones (15%), Madurez (5%)
   - Validado de rendimiento: < 50ms para 100 plantillas
   - Cobertura de pruebas completa con manejo de errores
Hábitos personalizables y rastreables
Lector bíblico con 4 versiones en español
Visualización de rachas y progreso
Arquitectura de inyección de dependencias completa

### 🏗️ Arquitectura
- **Frontend:** Flutter
- **Gestión de estado:** Riverpod
- **Backend:** Firebase
- **IA:** Google Gemini
- **Internacionalización:** flutter_localizations
- **Testing:** flutter_test

### 📈 Roadmap
- v1.1: Notificaciones push, reportes semanales
- v2.0: Predicción con ML, integración con wearables, retos de grupo

### 🤝 Cómo contribuir
1. Haz un fork  
2. Crea tu rama  
3. Agrega tests  
4. Verifica que todo pase  
5. Formatea y analiza la app  
6. Pull request

---

### 📄 Licencia

Este trabajo está licenciado bajo la Licencia Creative Commons Atribución-NoComercial 4.0 Internacional (CC BY-NC 4.0).

Puedes:

- **Compartir** — copiar y redistribuir el material en cualquier medio o formato
- **Adaptar** — remezclar, transformar y construir sobre el material

Bajo las siguientes condiciones:

- **Atribución (BY):** Debes dar crédito, proporcionar un enlace a la licencia e indicar si realizaste cambios.
- **NoComercial (NC):** No puedes utilizar el material con fines comerciales.

Para leer el texto completo de la licencia, véase el archivo LICENSE o visita:  
- [Resumen](https://creativecommons.org/licenses/by-nc/4.0/deed.es)  
- [Código Legal](https://creativecommons.org/licenses/by-nc/4.0/legalcode.es)

© 2024 develop4God

---

### 🙏 Agradecimientos
Flutter, Riverpod, Firebase, Gemini y la comunidad open source.

### 📞 Soporte
- Email: support@develop4god.com  
- Docs: [docs/README.md](docs/README.md)  
- Issues: [GitHub Issues](https://github.com/develop4God/habitus_faith/issues)  
- Discusiones: [GitHub Discussions](https://github.com/develop4God/habitus_faith/discussions)

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

**Versión**: 1.0.0  
**Última actualización**: Octubre 2025  
**Estado**: ✅ Listo para producción

</details>
