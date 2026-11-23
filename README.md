# Ethereal — Aplicación Móvil de Hábitos Conscientes

Aplicación móvil desarrollada en **Flutter** diseñada para ayudar a los usuarios a construir y mantener hábitos diarios mediante un sistema de rachas, recordatorios locales programados y progresión por hitos de 7, 30 y 120 días.

---

## 📦 Entregables del Proyecto

* **Instalador Android (APK):** [`release/Ethereal.apk`](release/Ethereal.apk)
* **Presentación de Lanzamiento (PDF):** [`docs/Presentacion_Ethereal.pdf`](docs/Presentacion_Ethereal.pdf)
* **Ficha de Tienda:** [`FICHA_TIENDA.md`](FICHA_TIENDA.md)

---

## 🚀 Funcionalidades Principales

1. **Autenticación y Gestión de Perfil:**
   * Registro e inicio de sesión seguro mediante **Firebase Authentication**.
   * Edición de perfil, cierre de sesión y eliminación definitiva de la cuenta junto con el reinicio de datos locales.
2. **Gestión de Hábitos y Validación Diaria:**
   * Creación, edición y eliminación de hábitos personalizados.
   * Control de cumplimiento diario que impide el doble registro en una misma jornada y mantiene el conteo real de rachas (`🔥`).
3. **Sistema de Etapas y Sala de Trofeos:**
   * Evolución por etapas: **Arranque (7 días)**, **Constancia (30 días)** y **Maestría (120 días)**.
   * Acumulación de puntos y visualización de logros en la **Sala de Trofeos**.
4. **Recordatorios Locales Nativos:**
   * Programación de notificaciones diarias por hora específica para cada hábito utilizando zonas horarias locales.

---

## 🛠️ Stack Tecnológico y Configuración

* **Framework:** Flutter 3+ / Dart (`sdk: ^3.14.0`)
* **Backend & Auth:** `firebase_core`, `firebase_auth`
* **Persistencia Local:** `shared_preferences`
* **Notificaciones y Tiempo:** `flutter_local_notifications`, `timezone`
* **Configuración Android:** `compileSdk 37`, `minSdk 23`, `isCoreLibraryDesugaringEnabled = true`

---

## ⚙️ Instalación y Ejecución Local

### Opción A: Instalar directamente en Android
1. Descarga el archivo [`release/Ethereal.apk`](release/Ethereal.apk) en tu dispositivo Android.
2. Habilita la instalación desde orígenes desconocidos si el sistema lo solicita e instala la aplicación.

### Opción B: Compilar desde el código fuente
```bash
# 1. Clonar el repositorio
git clone <URL_DE_TU_REPOSITORIO>
cd et0126_ethereal

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo o emulador conectado
flutter run