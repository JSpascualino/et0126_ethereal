# Ethereal — Gamified Habit Tracker

Aplicación móvil desarrollada en Flutter para el seguimiento de hábitos diarios mediante mecánicas de gamificación progresiva.

## Captura de la aplicación

![Vista previa de Ethereal](screenshots/app_preview.png)

## Instalación y ejecución

1. Clona este repositorio en tu equipo: `git clone https://github.com/JSpascualino/et0126_ethereal.git`
2. Entra a la carpeta del proyecto: `cd et0126_ethereal`
3. Instala las dependencias: `flutter pub get`
4. Ejecuta la aplicación en un emulador o dispositivo conectado: `flutter run`

## Conceptos de Dart en mi app

En el desarrollo de **Ethereal**, se aplicaron los fundamentos del lenguaje Dart distribuidos entre la lógica de negocio (`lib/models/habit.dart`) y la interfaz de usuario (`lib/screens/home_screen.dart`):

* **Tipos, final, const y Null Safety:** Se definieron tipos explícitos (`String`, `int`, `DateTime`). Los atributos inmutables como `id` y `name` usan `final`, y los widgets de la UI usan `const`. Se aplicó null safety marcando `String? notes` como nullable, ya que es el único campo opcional al crear un hábito.
* **Clases y objetos:** Se creó la clase modelo `Habit` con su constructor y métodos propios. En `HomeScreen`, se instancian objetos de tipo `Habit` cada vez que el usuario registra una nueva meta.
* **Funciones:** Se separaron operaciones en funciones dedicadas como `calculateLevel()` para la lógica de gamificación, y `_loadHabits()` / `_saveHabits()` para la persistencia.
* **List:** Se utiliza `List<Habit> _habits` como estructura principal en memoria para almacenar y renderizar secuencialmente los hábitos.
* **Set:** El atributo `Set<String> tags` garantiza etiquetas únicas sin duplicados por hábito.
* **Map:** Se emplea `Map<String, dynamic>` en `toMap()` y `fromMap()` para estructurar los datos en pares llave-valor antes de serializarlos a JSON.
* **Estructuras if, for y while:** 
  * **if:** Valida que el nombre del hábito no esté vacío antes de guardarlo y verifica si existen datos previos guardados.
  * **for:** Recorre los niveles superados en `totalPointsInvested()` para calcular el total de puntos.
  * **while:** Ejecuta una repetición finita en `calculateLevel()` descontando puntos por nivel a medida que aumenta la dificultad, sin bloquear la interfaz.

## Declaración de uso de IA

Para el desarrollo de este proyecto se utilizó **Gemini** como herramienta de apoyo técnico para:
* Depurar errores de configuración del entorno de Flutter e imports.
* Estructurar la separación de responsabilidades bajo arquitectura MVC (modelo independiente de la vista) y la serialización JSON con `shared_preferences`.
* Refinar la implementación de las estructuras de control (`while` y `for`) aplicadas a la lógica de niveles.

Toda la integración, pruebas de ejecución y decisiones de diseño fueron verificadas y comprendidas por el autor del repositorio. 