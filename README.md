# Habitus Faith 🙏

**App Flutter Empresarial para Seguimiento de Hábitos Espirituales con Riverpod + Firebase**

[![Tests](https://img.shields.io/badge/tests-19%20passing-brightgreen)]()
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-blue)]()
[![Riverpod](https://img.shields.io/badge/riverpod-2.5-blue)]()
[![Firebase](https://img.shields.io/badge/firebase-enabled-orange)]()

> **Haz de la fe tu mejor hábito diario** - Rastrea tus hábitos espirituales con monitoreo inteligente de rachas y sincronización en la nube.

---

## ✨ Características

- 📊 **Seguimiento Inteligente de Hábitos** - Crea y rastrea hábitos espirituales
- 🔥 **Monitoreo de Rachas** - Cálculo automático de días consecutivos
- ☁️ **Sincronización en la Nube** - Sincronización en tiempo real en todos los dispositivos
- 🔒 **Seguro** - Autenticación anónima con datos específicos del usuario
- 📖 **Lector de Biblia** - Biblia integrada con múltiples versiones
- 📈 **Estadísticas de Progreso** - Rastrea tu crecimiento espiritual
- 🧪 **Completamente Probado** - 19 tests integrales

---

## 🚀 Inicio Rápido

### Pre-requisitos
- Flutter SDK 3.0+
- Cuenta de Firebase (gratis)
- Android Studio o VS Code

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Ejecutar Tests
```bash
flutter test
# Esperado: ✅ 19 tests pasando
```

### 3. Configurar Firebase
1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Seleccionar proyecto: `habitus-faith-app`
3. Habilitar Authentication → Anónimo
4. Crear Firestore Database → Modo de prueba

### 4. Ejecutar la App
```bash
flutter run
```

### 5. Validar Configuración
```bash
dart format . && flutter analyze
```

---

## 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
| **[MIGRATION_COMPLETE.md](./MIGRATION_COMPLETE.md)** | Detalles completos de la migración |
| **[TESTING.md](./TESTING.md)** | Guía de testing |

---

## 🏗️ Arquitectura

### Stack Tecnológico
- **Gestión de Estado**: Riverpod 2.5
- **Backend**: Firebase (Auth + Firestore)
- **Base de Datos**: Cloud Firestore
- **Auth**: Firebase Anonymous Auth
- **Testing**: Flutter Test + Mocktail + Fake Firestore

### Estructura del Proyecto
```
lib/
├── core/
│   └── providers/          # Proveedores Firebase (DI)
├── features/
│   └── habits/
│       ├── models/         # HabitModel con lógica de negocio
│       └── providers/      # Proveedores Riverpod
├── pages/                  # Pantallas UI
└── main.dart              # Entrada de app + init Firebase

test/
├── helpers/               # Utilidades de test
├── unit/                  # Tests de lógica de negocio
├── integration/           # Tests de proveedores
└── widget/               # Tests de UI
```

---

## 🎯 Características Clave

### Seguimiento de Rachas de Hábitos
- ✅ Primera completación → streak = 1
- ✅ Días consecutivos → streak++
- ✅ Gap >1 día → streak se reinicia a 1
- ✅ Prevención del mismo día
- ✅ Racha más larga mantenida

### Integración Firebase
- ✅ Autenticación anónima (auto sign-in)
- ✅ Sincronización Firestore en tiempo real
- ✅ Filtrado de datos específico del usuario
- ✅ Soporte offline (SDK Firebase)

### Testing
- ✅ 7 unit tests (lógica de negocio)
- ✅ 5 integration tests (Firestore)
- ✅ 6 widget tests (UI)
- ✅ Test helpers & fixtures

---

## 🧪 Testing

### Ejecutar Todos los Tests
```bash
flutter test
```

### Ejecutar con Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Ver **[TESTING.md](./TESTING.md)** para guía detallada de testing.

---

## 📱 Estructura de la App

### Navegación Inferior (4 Pestañas)
1. **Hábitos** - Rastrea hábitos espirituales
2. **Biblia** - Lee la Biblia (4 versiones)
3. **Progreso** - Ver estadísticas
4. **Ajustes** - Configuración de la app

### Gestión de Hábitos
- Crear hábitos con nombre, descripción, categoría
- Completar diariamente (con seguimiento de rachas)
- Eliminar con confirmación
- Ver rachas actuales y más largas

---

## 🔧 Desarrollo

### Instalar Dependencias
```bash
flutter pub get
```

### Analizar Código
```bash
flutter analyze
```

### Formatear Código
```bash
dart format .
```

### Ejecutar App
```bash
flutter run
```

---

## 🔥 Configuración de Firebase

### Servicios Requeridos
1. **Authentication**
   - Proveedor: Anónimo
   - Auto sign-in al inicio de la app

2. **Firestore Database**
   - Modo: Prueba (desarrollo) / Producción (con reglas)
   - Colección: `habits`
   - Índices: `userId`, `isArchived`, `createdAt`

### Reglas de Seguridad (Producción)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /habits/{habitId} {
      allow read, write: if request.auth != null && 
                         request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 📊 Estadísticas del Proyecto

- **Total de Tests**: 19 (7 unit + 5 integration + 6 widget + 1 smoke)
- **Archivos Creados**: 15
- **Archivos Modificados**: 6
- **Dependencias**: 11 producción + 7 dev

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crear una rama de feature
3. Agregar tests para nuevas features
4. Asegurar que todos los tests pasen
5. Enviar un pull request

---

## 📝 Licencia

Este proyecto está licenciado bajo la Licencia MIT.

---

## 🙏 Agradecimientos

- Equipo Flutter por el framework increíble
- Riverpod por excelente gestión de estado
- Firebase por servicios backend
- La comunidad open-source

---

## 📞 Soporte

- 📧 Email: support@develop4god.com
- 📚 Documentación: Ver carpeta docs
- 🐛 Issues: GitHub Issues

---

## ⚡ Comandos Rápidos

```bash
# Configuración
flutter pub get

# Test
flutter test

# Analizar
flutter analyze

# Formatear
dart format .

# Ejecutar
flutter run

# Limpiar
flutter clean && flutter pub get
```

---

## 📈 Estado

**✅ LISTO PARA PRODUCCIÓN**

- ✅ Todas las características implementadas
- ✅ 19 tests pasando
- ✅ Firebase integrado
- ✅ Documentación completa
- ✅ Listo para despliegue

---

**Hecho con ❤️ por develop4God**

*Haz de la fe tu mejor hábito diario* 🙏

