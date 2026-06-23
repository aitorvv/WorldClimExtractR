# WorldClimExtractR - Case Studies & Inputs Guide / Guía de Estudios de Caso y Entradas

🇬🇧 **English version below**  
🇪🇸 **Versión en español a continuación**

---

## 🇬🇧 1. Introduction to Case Studies

The `case_studies/` folder is designed to organize different study cases or projects where climate data needs to be extracted. By default, the repository includes a template and an example:

* **`template/`**: A clean, empty configuration. Duplicate this folder and rename it (e.g., `my_forest_study/`) to start a new extraction project.
* **`example/`**: A pre-configured study case with test coordinates to verify the pipeline's execution.

---

## 📝 2. Input Configuration: `plots.csv`

Every study case requires an input file located at `input/plots.csv`. This file contains the coordinates and historical years for extraction.

Below is the detailed specification of the columns in `plots.csv`:

| Column | Data Type | Description | Required? | Example |
| :--- | :--- | :--- | :--- | :--- |
| **`id`** | Text (String) | Unique name or identifier for each point/plot. | **Yes** | `plot_1` |
| **`latitude`** | Decimal Number | Geographic latitude in decimal degrees (WGS84 datum). | **Yes** | `37.90322` |
| **`longitude`** | Decimal Number | Geographic longitude in decimal degrees (WGS84 datum). | **Yes** | `-2.91116` |
| **`hst_start_year`**| Integer (Year) | Starting year for historical monthly weather data extraction (1950–2024). | **Yes** | `2015` |
| **`hst_end_year`**  | Integer (Year) | Ending year for historical monthly weather data extraction (1950–2024). | **Yes** | `2021` |

> [!WARNING]
> Coordinate values must be in **decimal degrees (WGS84)**. UTM or other projection formats are not supported automatically.

---

## 📊 3. Output Directory Structure

When the execution completes, the tool creates an `output/` directory inside your study case folder with the following structure:

```text
output/
├── data/
│   ├── historical_climate_data.csv          - Long-term baseline climate variables (1970-2000)
│   ├── historical_monthly_weather_data.csv  - Historical monthly weather observations
│   ├── historical_year_weather_data.csv     - Consolidated annual weather summaries
│   ├── historical_period_weather_data.csv   - Average weather parameters for the period
│   ├── future_climate_data.csv              - Future CMIP6 climate projections
│   ├── future_period_climatic_data.csv      - Projected period monthly averages
│   ├── all_output_data.xlsx                 - Consolidated Excel workbook
│   ├── plots_extracted.geojson              - Spatial WGS84 point layer (only coordinates and ID)
│   ├── citations_and_metadata.md            - Auto-generated citations and run metadata
│   └── environment.rdata                    - Saved R session environment
├── maps/
│   └── location_map_[lang].png              - Spatial verification map
└── climodiagrams/
    ├── historical/                          - Walter-Lieth climodiagrams for historical data
    └── future/                              - Walter-Lieth climodiagrams for future CMIP6 data
```

For more details on the columns and generated values, refer to:
* [GENERATED_OUTPUTS.md](../documentation/GENERATED_OUTPUTS.md) (English)
* [GENERATED_OUTPUTS_es.md](../documentation/GENERATED_OUTPUTS_es.md) (Spanish)

---
---

## 🇪🇸 1. Introducción a los Estudios de Caso

La carpeta `case_studies/` sirve para organizar los diferentes proyectos o áreas de estudio donde se desea extraer información climática. Por defecto, incluye:

* **`template/`**: Configuración vacía y limpia. Duplique esta carpeta y cámbiele el nombre (ej. `mi_estudio_forestal/`) para iniciar un nuevo proyecto de extracción.
* **`example/`**: Caso de estudio preconfigurado con coordenadas de prueba para verificar el correcto funcionamiento del script.

---

## 📝 2. Configuración de Entrada: `plots.csv`

Cada caso de estudio requiere un archivo de entrada ubicado en `input/plots.csv`. Este archivo contiene las coordenadas y años históricos de interés.

A continuación se detalla la especificación de las columnas de `plots.csv`:

| Columna | Tipo de Datos | Descripción | ¿Requerido? | Ejemplo |
| :--- | :--- | :--- | :--- | :--- |
| **`id`** | Texto | Identificador único para cada punto o parcela de muestreo. | **Sí** | `plot_1` |
| **`latitude`** | Número Decimal | Latitud geográfica en grados decimales (sistema de referencia WGS84). | **Sí** | `37.90322` |
| **`longitude`** | Número Decimal | Longitud geográfica en grados decimales (sistema de referencia WGS84). | **Sí** | `-2.91116` |
| **`hst_start_year`**| Entero (Año) | Año inicial del periodo histórico de extracción mensual (1950–2024). | **Sí** | `2015` |
| **`hst_end_year`**  | Entero (Año) | Año final del periodo histórico de extracción mensual (1950–2024). | **Sí** | `2021` |

> [!WARNING]
> Las coordenadas deben estar en **grados decimales y datum WGS84**. No se admite la conversión automática de coordenadas proyectadas (como UTM).

---

## 📊 3. Estructura de Salidas Generadas

Tras completar la ejecución, la herramienta crea un directorio `output/` dentro de la carpeta del caso de estudio con el siguiente esquema:

```text
output/
├── data/
│   ├── historical_climate_data.csv          - Variables climáticas base a largo plazo (1970-2000)
│   ├── historical_monthly_weather_data.csv  - Observaciones meteorológicas mensuales históricas
│   ├── historical_year_weather_data.csv     - Resúmenes consolidados anuales meteorológicos
│   ├── historical_period_weather_data.csv   - Promedios meteorológicos históricos de periodo
│   ├── future_climate_data.csv              - Proyecciones de cambio climático CMIP6
│   ├── future_period_climatic_data.csv      - Medias mensuales por periodos futuros
│   ├── all_output_data.xlsx                 - Libro Excel consolidado
│   ├── plots_extracted.geojson              - Capa de puntos WGS84 (solo identificador y coordenadas)
│   ├── citations_and_metadata.md            - Referencias científicas y metadatos autogenerados
│   └── environment.rdata                    - Entorno de sesión guardado para R
├── maps/
│   └── location_map_[lang].png              - Mapa de validación geoespacial
└── climodiagrams/
    ├── historical/                          - Climogramas Walter-Lieth históricos
    └── future/                              - Climogramas Walter-Lieth futuros de CMIP6
```

Para obtener más información sobre las columnas y variables generadas, consulte:
* [GENERATED_OUTPUTS.md](../documentation/GENERATED_OUTPUTS.md) (inglés)
* [GENERATED_OUTPUTS_es.md](../documentation/GENERATED_OUTPUTS_es.md) (español)
