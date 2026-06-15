# WorldClimExtractR

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GIR](https://img.shields.io/badge/SMART_ECOSYSTEMS-Research_Group-004D26.svg)](https://smart-ecosystems.uva.es/)

---

**WorldClimExtractR** es una herramienta ágil y parametrizada en R desarrollada por el grupo **SMART ECOSYSTEMS Research Group** para extraer, procesar y resumir datos climáticos históricos y de futuras proyecciones (CMIP6) de WorldClim a partir de coordenadas geográficas en cualquier lugar del mundo.

---

## Índice

- [Características](#características)
- [Requisitos](#requisitos)
- [Estructura del Repositorio](#estructura-del-repositorio)
- [Ejemplo de Uso Completo](#ejemplo-de-uso-completo)
- [Opciones de Ejecución por Consola (CLI)](#opciones-de-ejecución-por-consola-cli)
- [Configuración de Capas Geodésicas](#configuración-de-capas-geodésicas)
- [Citas y Referencias](#citas-y-referencias)
- [Licencia](#licencia)

---

## ✨ Características

* 🌍 **Extracción de Coordenadas Climáticas**: Obtención de variables bioclimáticas, elevación e históricos de temperatura y precipitación mundial.
* 🔄 **Conversión Automática de Proyección**: Detección y conversión al vuelo de coordenadas UTM (ej. ETRS89 huso 30N) a WGS84 (longitud y latitud).
* 📊 **Climogramas de Walter-Lieth**: Generación automática de diagramas climáticos para periodos históricos y futuros en inglés o español.
* ⚙️ **Preparado para CLI y HPC**: Script parametrizado compatible con terminal mediante `optparse`, permitiendo ejecuciones tanto en local como en el servidor HPC del iuFOR sin modificar el código interno.
* 📁 **Consolidación en XLSX y RData**: Exportación automática de los resultados a ficheros CSV independientes, a un único libro Excel multi-pestaña (`.xlsx`) y guardado del entorno de ejecución de R (`.RData`).

---

## 📦 Requisitos

Asegúrese de contar con R instalado (versión `>= 4.0.0`) y las librerías del sistema necesarias para dependencias geoespaciales como `sf`:

```bash
# Dependencias necesarias en Ubuntu / Debian
sudo apt-get install libgdal-dev libgeos-dev libproj-dev libudunits2-dev
```

### Paquetes de R
El script principal verifica e instala automáticamente las librerías de R faltantes:
* `raster`
* `tidyverse`
* `sf`
* `eurostat`
* `openxlsx`
* `optparse`

---

## 📂 Estructura del Repositorio

El repositorio mantiene una estructura limpia de Git, excluyendo del control de versiones los datasets espaciales pesados y los casos de ejecución de los usuarios:

```text
WorldClimExtractR/
├── .gitignore                         # Excluye rasters, entornos R y carpetas de salida locales
├── README.md                          # Documentación del proyecto
├── DATOS_CLIMATICOS.md                # Guía de descarga y nomenclatura de rasters .tif
├── WorldClimExtractR.Rproj            # Archivo de proyecto RStudio
├── documentation/                     # Documentación de variables de WorldClim
│   └── *.pdf
├── API/                               # Ejemplos de uso de la API
│   └── *.pdf
├── scripts/                           # Código fuente R
│   ├── wc_main.r                      # Script principal unificado (CLI / Interactivo)
│   └── wc_functions.r                 # Funciones de extracción de datos y graficado
├── climate_data/                      # Directorio común para datos climáticos (vacío en Git)
│   ├── historical_climate_data/
│   ├── historical_monthly_data/
│   └── future_climate_data/
└── case_studies/                      # Almacén de estudios de caso
    └── template/                      # Caso plantilla de referencia (seguido en Git)
        ├── input/
        │   └── wc_plots.csv           # Archivo de coordenadas de entrada
        └── output/                    # Carpeta de mapas, climogramas y Excel exportados
```

---

## 🚀 Ejemplo de Uso Completo

Para ejecutar un caso de prueba utilizando la plantilla suministrada:

### Paso 1: Configurar las coordenadas de entrada
Edite el archivo de entrada en `case_studies/template/input/wc_plots.csv` indicando el identificador del punto, sus coordenadas geográficas, y los años históricos de estudio:

```csv
id,latitude,longitude,hst_start_year,hst_end_year
Cordoba,37.90322,-2.91116,2015,2021
Valdepoza,42.60910,-4.77280,1990,2020
```

### Paso 2: Organizar los archivos Raster (.tif)
Asegúrese de haber descargado y ubicado las capas de WorldClim siguiendo el esquema detallado en [DATOS_CLIMATICOS.md](DATOS_CLIMATICOS.md). Puede organizarlas en:
1. **El directorio del proyecto** (ubicación por defecto): Colocando las tres subcarpetas de datos dentro de `climate_data/` en la raíz.
2. **Un disco externo o directorio alternativo**: Almacenando la estructura de carpetas climáticas en una ubicación externa y pasándole la ruta al script mediante el flag `--data` (evitando ocupar espacio en el disco principal).

### Paso 3: Ejecutar el script por consola
Abra su terminal y ejecute el siguiente comando indicando el caso de estudio plantilla, el directorio de trabajo actual y el idioma español para las gráficas:

```bash
# Ejecución por defecto (buscando los TIFFs en la raíz del proyecto)
Rscript scripts/wc_main.r --case "template" --basedir "." --lang "es" --hst_var "elev" --fut_var "clim" --ssp "all"

# Ejecución especificando un disco externo o ruta alternativa de datos climáticos
Rscript scripts/wc_main.r --case "template" --basedir "." --data "/ruta/a/mi/disco_externo" --lang "es"
```

### Paso 4: Resultados Generados
Tras la finalización del script, consulte la carpeta `case_studies/template/output/`. Para verificar visualmente la exactitud geográfica y de los climogramas, consulte la [Guía de Verificación de Resultados (GUIA_VERIFICACION.md)](GUIA_VERIFICACION.md).

Los resultados se distribuyen en las siguientes carpetas:

* **`data/`**:
  * `df_historical_monthly.csv`: Dataset mensual histórico (precipitación, temperaturas mínimas, máximas y medias).
  * `df_historical_year.csv`: Sumarios anuales calculados e índice de aridez de Martonne.
  * `df_historical_period.csv`: Resumen promediado de todo el periodo histórico.
  * `df_future.csv` & `df_future_period.csv`: Extracciones de las proyecciones climáticas del GCM MIROC6 bajo los escenarios SSP.
  * `wc_output_data.xlsx`: Libro Excel multi-pestaña consolidando todas las tablas anteriores.
  * `plots_extracted.geojson`: Capa vectorial con los puntos extraídos y sus sumarios de periodo para uso en GIS.
  * `citations_and_metadata.md`: Documento con metadatos de ejecución e instrucciones bibliográficas de citación.
  * `wc_environment.RData`: Imagen de R con todas las variables cargadas para análisis posterior en RStudio.
* **`maps/`**:
  * Contiene los mapas de verificación de localización de parcelas a escala de España, Europa y zona de estudio (ej. `location_location_map_es.png`).
* **`climodiagrams/`**:
  * **`historical/`**: Ficheros PNG con los diagramas climáticos Walter-Lieth del histórico de cada parcela.
  * **`future/`**: Diagramas clasificados por escenarios SSP y décadas proyectadas (ej. `df_Cordoba_fut_ssp_2_period_2021-2040_climodiagram_walter_lieth_es.png`).

---

## ⚙️ Opciones de Ejecución por Consola (CLI)

El script `scripts/wc_main.r` expone las siguientes opciones mediante argumentos:

| Flag corto | Flag largo | Tipo | Por defecto | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `-c` | `--case` | `character` | `template` | Nombre del subdirectorio en `case_studies/` |
| `-b` | `--basedir` | `character` | `getwd()` | Ruta raíz absoluta o relativa del código del proyecto |
| `-d` | `--data` | `character` | `NULL` | Directorio raíz alternativo de capas TIFF [por defecto: igual a basedir] |
| `-l` | `--lang` | `character` | `en` | Idioma de los climogramas y mapas (`en` o `es`) |
| `-e` | `--hst_var` | `character` | `elev` | Variable histórica inicial (`elev`, `bio`, `clim`, etc.) |
| `-v` | `--hst_bio` | `integer` | `NULL` | Número de bioclimático histórico a extraer (1-19) |
| `-f` | `--fut_var` | `character` | `clim` | Variables futuras a procesar (`all` [genera climogramas], `bioc` [solo bioclimáticos, omite climogramas], `clim` [solo clima mensual, genera climogramas]) |
| `-s` | `--ssp` | `character` | `all` | Escenarios SSP futuros (`1`, `2`, `3`, `5` o `all`) |
| | `--historical` | `logical` | `TRUE` | Activar/desactivar la extracción de históricos |
| | `--future` | `logical` | `TRUE` | Activar/desactivar la extracción de proyecciones futuras |
| | `--map` | `logical` | `TRUE` | Activar/desactivar la generación de mapas de verificación |
| | `--climodiagram`| `logical` | `TRUE` | Activar/desactivar la generación de climogramas Walter-Lieth |

### Ejemplo de uso avanzado:
```bash
# Carga de datos desde disco externo, extrayendo variable bioclimática BIO3 de base
Rscript scripts/wc_main.r --case "mi_proyecto" --data "/media/usuario/DISCO" --hst_var "bio" --hst_bio 3 --fut_var "all"
```

---

## 📂 Configuración de Capas Geodésicas

Para comprender la estructura, codificación de nombres y links de descarga directa de los archivos `.tif` de precipitaciones, temperaturas y modelos CMIP6 de la Tierra, consulte el documento:
* [Guía de configuración de datos espaciales (DATOS_CLIMATICOS.md)](DATOS_CLIMATICOS.md)

---

## 🤝 Citas y Referencias

Cuando publique trabajos científicos que utilicen datos procesados por esta herramienta, por favor cite los siguientes trabajos de referencia:

* **WorldClim 2.1 Baseline**: Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. *International Journal of Climatology* 37 (12): 4302-4315.
* **Monthly Weather Data**: Harris, I., Osborn, T.J., Jones, P.D., Lister, D.H. 2020. Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. *Scientific Data* 7: 109.
* **Proyecciones Futuras (CMIP6)**: Petrie, R., et al. 2021. Coordinating an operational data distribution network for CMIP6 data. *Geoscientific Model Development*, 14(1), 629-644.
* **Índice de Martonne**: Martonne, E. de. 1926. L’indice d’aridité. *Bulletin de l’Association de Géographes Français*, 3, 3–5.

---

## 📄 Licencia

Este proyecto está licenciado bajo la **Licencia MIT** - consulte el archivo [LICENSE](LICENSE) para más detalles.
