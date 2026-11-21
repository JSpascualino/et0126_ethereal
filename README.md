# Ethereal — Gamified Habit Tracker

Aplicación móvil desarrollada en Flutter para el seguimiento de hábitos diarios mediante mecánicas de gamificación progresiva.

## Instalación y ejecución

1. Clona este repositorio: `git clone https://github.com/JSpascualino/et0126_ethereal.git`
2. Instala las dependencias: `flutter pub get`
3. Ejecuta la aplicación: `flutter run`

---

## Taller de Continuación: Formularios y Servicio Asíncrono

Para esta segunda etapa, se integró un **"Registro de Actividad"**. Este flujo permite al usuario llevar una bitácora diaria detallando cuánto tiempo invirtió en un hábito y cómo se sintió. Esto es útil para el usuario porque no solo marca un hábito como "hecho", sino que fomenta la reflexión y mide el esfuerzo real invertido.

### Campos y Validaciones (`form_field_validator`)
El formulario incluye tres campos validados antes de procesar el guardado:
1. **Nombre del hábito (Texto):** `RequiredValidator` y `MinLengthValidator` (mínimo 3 caracteres).
2. **Duración en minutos (Numérico):** Regla de dominio propia. Valida que el texto no esté vacío, sea un número válido y sea estrictamente **mayor a 0**.
3. **Observación (Texto):** `RequiredValidator` (Obligatorio para asegurar la reflexión del usuario).

### Modelo y Servicio en Memoria
* **Modelo (`ActivityRecord`):** Clase fuertemente tipada que encapsula la información del registro (id, habitName, durationMinutes, observation, date).
* **Servicio (`ActivityService`):** Aisla la lógica de negocio de la interfaz. Utiliza `Future.delayed` para simular latencia de red.
* **Regla de Negocio:** El servicio impide registrar una actividad para el mismo hábito en el mismo día (lanza un `StateError` si detecta un duplicado).

### Límite de los datos en memoria
Los hábitos principales de la app mantienen su persistencia local usando `SharedPreferences` (Taller 1). Sin embargo, los **Registros de Actividad** de este nuevo flujo viven **exclusivamente en la memoria RAM** (en una lista estática dentro del servicio). Al reiniciar o cerrar la app, estos registros temporales desaparecen, simulando el comportamiento de una sesión temporal antes de integrarse a una base de datos real.

### Resultados de la comprobación manual

| Caso | Acción | Resultado comprobado |
|---|---|---|
| **Campos vacíos** | Pulsar guardar sin escribir. | Aparecen textos de error en rojo bajo los campos. No se llama al servicio. |
| **Texto muy corto** | Escribir "Ir" en el hábito. | El validador muestra "Usa al menos 3 caracteres". |
| **Regla de dominio** | Ingresar `-5` o `0` en minutos. | Muestra el error "La duración debe ser mayor a 0". |
| **Registro válido** | Completar todo y guardar. | El botón muestra indicador de carga, luego el registro aparece en la lista con un SnackBar verde. |
| **Error de negocio** | Intentar registrar el mismo hábito hoy. | La app rechaza el registro y muestra un SnackBar rojo con el mensaje de error del servicio. |
| **Envío rápido** | Pulsar varias veces "Guardar". | El botón se deshabilita durante la carga gracias al estado `_isSaving`, evitando duplicados. |
| **Reinicio** | Cerrar y abrir la app. | Los hábitos de inicio se mantienen. Los registros de actividad desaparecen (comportamiento esperado). |

---

## Conceptos de Dart (Taller 1)

En la primera etapa se aplicaron los siguientes fundamentos:
* **Tipos, final, const y Null Safety:** Variables tipadas (`String`, `int`). Uso de `final` para atributos inmutables y `const` para widgets.
* **Clases y objetos:** Modelo `Habit` con métodos propios, instanciado en `HomeScreen`.
* **Estructuras de datos:** Uso de `List` para el renderizado secuencial de hábitos.
* **Estructuras if, for y while:** Validación de campos (`if`), iteraciones de cálculo (`for`) y progresión de niveles (`while`).

---

## Declaración de uso de IA

Para el desarrollo de estos talleres se utilizó **Gemini** como herramienta de apoyo para:
* Depurar errores de configuración de entorno, imports y Git/GitHub.
* Estructurar la arquitectura separando la vista (`ActivityFormScreen`) del modelo y el servicio.
* Implementar correctamente el ciclo de vida del `StatefulWidget` (`initState`, `dispose`, y la comprobación de `mounted` después de operaciones `await`).
* Construir la regla de validación de negocio en la colección temporal en memoria.

Toda la integración, pruebas manuales y decisiones de diseño fueron ejecutadas y comprendidas por el autor.