# Plan de Ruta (Roadmap) — Proyecto WorldClim
*Guía de desarrollo y tareas de publicación*

## Resumen
Este documento sirve como hoja de ruta para la reorganización, parametrización y publicación del código para extraer datos climáticos de WorldClim. Se irá actualizando a medida que avancemos en el desarrollo del proyecto.

**Progreso:** [████████████████████] 100%

---

## Índice
- [✅ Completado](#-completado)
- [🔄 Pendiente de revisión](#-pendiente-de-revision)
- [🚧 En progreso](#-en-progreso)
- [⏳ Pendiente](#-pendiente)
- [Historial de sincronización](#historial-de-sincronización)

---

## Tareas

### ✅ Completado

#### Fase 1: Diagnóstico y Reestructuración ✅
- ✅ Analizar el repositorio WorldClim y diagnosticar redundancias de código en `case_studies/`.
- ✅ Identificar rutas locales absolutas cableadas en `scripts/wc_functions.r`.
- ✅ Definir un esquema limpio para separar código fuente, plantillas y capas de datos raster.

#### Fase 2: Repositorio Parametrizado ✅
- ✅ Crear el nuevo repositorio limpio en `WorldClimExtractR`.
- ✅ Inicializar el repositorio Git local en la nueva ubicación.
- ✅ Crear el archivo `.gitignore` optimizado para excluir TIFFs y estudios de caso específicos de usuarios.
- ✅ Unificar los scripts de R (`wc_main.r` y `wc_functions.r`) para que funcionen con variables dinámicas de entorno y argumentos de consola (`optparse`).

#### Fase 3: Documentación de Datos de Entrada ✅
- ✅ Redactar el documento [DATOS_CLIMATICOS.md](WorldClimExtractR/DATOS_CLIMATICOS.md) explicando la estructura, procedencia y nomenclatura obligatoria de los archivos `.tif`.
- ✅ Añadir una licencia MIT y preparar el esqueleto inicial del `README.md`.

#### Fase 4: Ejemplos de Ejecución y Pruebas ✅
- ✅ Diseñar un caso de uso de ejemplo en el `README.md`.
- ✅ Solicitar al usuario la ruta donde están las capas .tif de entrada (implementado flag `--data` / `-d` en CLI).
- ✅ Validar la ejecución del script principal utilizando argumentos `--case "template"` con las capas climáticas de prueba.
- ✅ Crear una guía rápida para verificar la salida de mapas y climogramas generados en R.

#### Fase 5: Actualización de Librerías ✅
- ✅ Revisar si se pueden eliminar librerías actualmente en uso (todas las cargadas son indispensables).
- ✅ Revisar mensaje "Failed with error: 'there is no package called ‘giscoR’'" (giscoR añadido a dependencias automáticas).
- ✅ Revisar mensaje "Warning message: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0. ℹ Please use `linewidth` instead" (reemplazado por `linewidth` en gráficos y mapas).
- ✅ Omitir verbosidad de carga de librerías para un log más claro (con `suppressPackageStartupMessages`).
- ✅ Simplificar código R manteniendo el formato actual.

#### Fase 6: Actualizar Código ✅
- ✅ Automatizar la generación de mapas con las coordenadas objetivo antes de proceder a la extracción de datos. Para esto deberíamos estructurar el código de manera que haga un mapa con distintos niveles de detalle de las "nuts_level" en la función "get_eurostat_geospatial()", que esos niveles de detalle se seleccionen de manera automática y que no se restrinjan ni a Europa ni a España, sino que seleccionen la localización correcta acorde a las coordenadas de entrada. Vamos a dibujar también el código "plot_id" de cada punto en lugar de sus coordenadas para identificar errores potenciales. En definitiva, vamos a crear unas coordenadas de ejemplo diferentes para contemplar un mayor rango de casos de estudio, reorganizar, depurar, limpiar y mejorar esta sección inicial del código para que el usuario pueda verificar si las coordenadas introducidas son correctas. Elabora un plan, consúltame si estoy de acuerdo o pregúntame lo que necesites; no tenemos porqué restringirnos a una determinada librería de R, si hay opciones mejores podemos considerar el cambio.
- ✅ Simplificar main.r para reducir longitud del código.
- ✅ Activar o desactivar distintas partes del código y refinar la estructura de salidas (mapa, climogramas, extracción histórica y futura controlables por flag; exportación añadida de GeoJSON y reporte de citaciones científico).
- ✅ Refinar y limpiar el formato y las columnas de los dataframes (df) de salida antes de la exportación final (CSV/XLSX) (eliminadas redundancias de ID/id y redondeado general a 1 decimal para clima, 2 para índices y 6 para coordenadas).
- ✅ Implementar validación robusta que aplique automáticamente los años históricos por defecto (1990-2020) si faltan las columnas o hay valores `NA` en el CSV de entrada.

#### Fase 7: Revisión de Documentación ✅
- ✅ Traducción a inglés para tener doble versión de la documentación (README_en.md, DATOS_CLIMATICOS_en.md, GUIA_VERIFICACION_en.md).
- ✅ Explicación detallada de cómo usar este código paso a paso.
- ✅ Documentar claramente los outputs esperados según el argumento `--fut_var` (bioc omite climogramas futuros; all y clim los generan).

#### Fase 8: Revisión Manual del Usuario ✅
- ✅ Revisión de documentación general del repo:
  - ✅ READMEs
  - ✅ GUIA_VERIFICACION
  - ✅ DATOS_CLIMATICOS
  - ✅ CONTRIBUTING
  - ✅ case_studies
  - ✅ documentacion
  - ✅ scripts: todo el texto impreso en la terminal (cat()) en inglés e incluir cita a mi repositorio
  - ✅ revisar escritura encabezados y template/README (incluido output_README.md traducido y con banderas)
  - ✅ mencionar que el wd() debe ser ~/WorldClimExtractR y renombrar wc_main a main y wc_functions a functions
  - ✅ rename files and folders involving "historical_monthly_data" to "historical_monthly_weather_data"
  - ✅ outputs:
    - citations_and_metadata.md: incluir todas las variables de "opt" para facilitar al usuario la detección de errores e incluir cita a este repositorio de código
    - df_future.csv: no incluir aquí columnas "hst_start/end_year" y renombrar "file_ssp" a "ssp"
    - df_future.csv: renombrar "file_ssp" a "ssp"
    - df_historical_monthly.csv: no incluir aquí columnas "hst_start/end_year" 
    - rename "df_historical_monthly.csv" to "historical_monthly_weather_data.csv", "df_future.csv" to "future_climate_data.csv", "df_future_period.csv" to "future_period_climatic_data.csv", "df_historical_year/period.csv" to "historical_year/period_climatic_data.csv"; same into .xlsx sheets; "wc_environment.RData" to "environment.rdata"; "wc_output_data.xlsx" to "all_output_data.xlsx"
- ✅ Mejoras de código:
  - ✅ verificar si el código actual permite utilizar otro modelo datos proyecciones futuras como alternativa a "MIROC6" (p.e. ACCESS-CM2, BCC-CSM2-MR, EC-Earth3-Veg)
  - ✅ homogeneizar "bioc" y "bio" -> "bio"
  - ✅ revisar contenido columnas outputs
  - ✅ revisión general de toda la documentación con IA para encontrar posibles incoherencias o detalles excluidos para el usuario
- ❌ Inspeccionar código y conversión UTM: Eliminada la conversión automática UTM para simplificar el código. Se fuerza el uso exclusivo de WGS84.
- ✅ Inspeccionar el formato de salida y redondeo: Comprobado. La precisión numérica se encuentra implementada correctamente a lo largo de todas las salidas gracias a la función `clean_and_round_df` de `main.r` (6 dec. para lat/lon, 2 dec. para índices, 1 dec. para clima).
- ✅ renombrar "wc_plots.csv" a "plots.csv" y las consecuentes rutas en el código que necesiten acceder a este archivo
- ✅ Verificar estructura de directorios local: Confirmar que la carpeta donde se almacenan las capas raster de clima (`climate_data/` en el directorio de trabajo local o la ruta externa pasada con `-d`) coincide con la guía de estructura.
- ❌ Comprobar integración con Slurm HPC: Descartado tras eliminar la sección de integración HPC del alcance del proyecto.
- ✅ Ampliar uso a otros modelos de clima futuro: Comprobar la portabilidad con otros modelos de clima futuro en el caso de que el usuario tenga dicha información.

#### Fase 9: Publicación en GitHub ✅
- ✅ Formato de README definitivo sin mención a grupos de investigación externos o SMART.
- ✅ Incluir archivo de citación formal (`CITATION.md`) para citar a Aitor Vázquez Veloso como autor directo del código.
- ✅ Vincular y añadir banderas de idioma en la documentación principal (README.md / README_en.md).
- ✅ Sincronizar el repositorio local con la organización remota de GitHub.

#### Fase 10: Estructura de Carpetas y Gestión de Datos ✅
- ✅ Configurar `.gitignore` para excluir archivos raster pesados de WorldClim de la sincronización de Git.
- ✅ Conservar la estructura completa de carpetas y subcarpetas en GitHub mediante archivos `.gitkeep` locales en cada directorio y subdirectorio de datos climáticos (ej. `MIROC6_SSP1`, `wc2.1_30s_bio`, `wc2.1_cruts4.06_2.5m_prec`, etc.).

### 🔄 Pendiente de revisión

*(No hay tareas en este estado actualmente)*

### 🚧 En progreso

*(No hay tareas en este estado actualmente)*

### ⏳ Pendiente

*(No hay tareas en este estado actualmente)*

---

## Historial de sincronización

| Fecha | Autor | Acción / estado | Cambios realizados |
| :--- | :--- | :--- | :--- |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `⏳ -> 🚧` | Adaptación del roadmap al formato estándar de `avv-roadmap` y cálculo de progreso inicial. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Mejora estética, añadido de badges y previsualización de datos futuros en `README_en.md`. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Replicadas las mejoras estéticas, badges y tablas en `README.md` (versión en español). |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Verificación de zoom de mapas en R, actualización de buffer mínimo (0.2°), y sincronización de `GUIA_VERIFICACION` en ES/EN. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Estructurada la guía de datos climáticos en español (`DATOS_CLIMATICOS.md`) detallando CRU-TS 2.5m, GCM/SSPs y todas las combinaciones de nomenclaturas. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Traducido y sincronizado el archivo de guía de datos climáticos a la version en inglés (`DATOS_CLIMATICOS_en.md`). |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Simplificado `CONTRIBUTING.md` para eliminar la sección del clúster HPC, detallar la revisión de PRs y posibilitar la apertura de issues. |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Creada y traducida la versión en inglés de la guía de contribución (`CONTRIBUTING_en.md`). |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Modificado `wc_functions.r` para extraer dinámicamente nombres de GCM de cualquier longitud usando `strsplit()`, habilitando la compatibilidad con modelos como UKESM1-0-LL. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Confirmación y realización del commit consolidado de desarrollo y documentación. |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Renombrado de historical_monthly_data a historical_monthly_weather_data en archivos y directorios. |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Actualizadas las rutas absolutas (`wc_base_path`) en los scripts `wc_functions.r` para incluir la carpeta `climate_data/`. |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Añadida la carpeta `.agents/` al archivo `.gitignore` y corregidas las rutas del directorio temporal renombrado. |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Renombrado `wc_main.r` y `wc_functions.r` a `main.r` y `functions.r`, traducido texto al inglés y modificado formato de exportación. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Traducido y estructurado en ES/EN con banderas `case_studies/template/output_README.md`; renombrados scripts en backups. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Homogeneización de "bioc" a "bio" en scripts R (main.r, functions.r), READMEs y guías de datos climáticos. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Eliminada la lógica de conversión automática de UTM a WGS84 en scripts y documentación. |
| 2026-06-19 | Antigravity (Gemini 3.1 Pro) | `🚧 -> 🚧` | Confirmado redondeo, renombrado wc_plots a plots.csv, y añadido el parámetro --model a CLI para soporte de múltiples modelos futuros CMIP6. |
| 2026-06-19 | Antigravity (Gemini 3.5 Flash) | `🚧 -> 🚧` | Añadidas banderas de idioma y enlaces cruzados de traducción al inicio de los archivos README; roadmap actualizado. |
| 2026-06-22 | Antigravity (Gemini 3.1 Pro) | `⏳ -> ✅` | Revisión final del repositorio, corrección de guías, renombrado estandarizado (EN default, _es) y push de todos los cambios al remoto. |
| 2026-06-23 | Antigravity (Gemini 3.1 Pro) | `✅ -> ✅` | Corrección del loop histórico: previnido el producto cartesiano al cruzar datos mensuales, añadido control de errores para directorios vacíos y validación obligatoria del argumento `-v` para variables bioclimáticas. |
| 2026-06-23 | Antigravity (Gemini 3.5 Flash) | `✅ -> ✅` | Configurada exclusión de capas pesadas en `.gitignore` y creados archivos `.gitkeep` en los 15 subdirectorios para mantener la estructura completa de carpetas en GitHub. |
| 2026-06-23 | Antigravity (Gemini 3.1 Pro) | `✅ -> ✅` | Reestructuración del proceso histórico separando la extracción de clima base y tiempo meteorológico en flags independientes (`--hst_climate`, `--hst_weather`) y salidas de datos diferenciadas. |
| 2026-06-23 | Antigravity (Gemini 3.5 Flash) | `✅ -> ✅` | Explicación detallada de todas las variables climáticas de referencia en `GENERATED_OUTPUTS` (según PDF original) y actualización de las plantillas de salida en los READMEs del proyecto. |