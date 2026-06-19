# Guía de Contribución
*WorldClimExtractR — Documento de Desarrollo*

---

¡Gracias por tu interés en mejorar **WorldClimExtractR**! Para mantener la calidad del software y la reproducibilidad científica, por favor sigue estas directrices.

### Flujo de Trabajo (Git Flow)

1. **Crear una rama (branch)**: No trabajes directamente sobre la rama `main`. Crea una rama descriptiva para tu cambio:
   ```bash
   git checkout -b feature/nueva-mejora
   # o bien:
   git checkout -b bugfix/correccion-error
   ```
2. **Realizar Commits Claros**: Escribe mensajes de commit concisos y claros en español o inglés:
   ```bash
   git commit -m "Añadir soporte para extracción de BIO20"
   ```
3. **Pruebas Locales**: Antes de abrir un Pull Request (PR), ejecuta el caso de estudio plantilla (`template` o `example`) para verificar que el código no tiene errores de sintaxis y finaliza con éxito:
   ```bash
   Rscript scripts/wc_main.r --case "example" --historical TRUE --future FALSE
   ```
4. **Abrir Pull Request**: Sube tu rama a tu fork/repositorio y solicita la fusión con la rama `main` detallando qué problema corrige o qué funcionalidad añade. Todos los cambios propuestos serán revisados cuidadosamente antes de su integración.

### Estilo y Buenas Prácticas de R

* **Legibilidad**: Usa nombres de variables autodescriptivos en minúsculas separados por guiones bajos (snake_case).
* **Modularidad**: Encapsula la lógica en funciones dentro de `scripts/wc_functions.r` y mantén el script `scripts/wc_main.r` limpio de declaraciones complejas.
* **Manejo de Memoria**: Libera los objetos raster grandes (`raster::removeTmpFiles()`) para no colapsar el disco o la memoria, especialmente al iterar sobre muchas parcelas.
* **Control de Dependencias**: Si añades una nueva librería, asegúrate de añadirla en la sección inicial de instalación automática en `scripts/wc_main.r`.

---

## Sugerencias y Reportes

* ⚠️ **NO subas** la carpeta `climate_data/` a GitHub. Ya está excluida en el `.gitignore`.
* 💡 **Issues**: Si tienes propuestas para nuevas funcionalidades, dudas de uso o detectas algún error en el script, eres libre de abrir una **Issue** en el repositorio para sugerir mejoras o reportar fallos.
