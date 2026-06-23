# WorldClimExtractR - Output directory template / Plantilla de la estructura de salidas

🇬🇧 **English version below**  
🇪🇸 **Versión en español a continuación**

---

## 🇬🇧 Output directory template

This directory will contain the generated climate data extraction results after running the tool on a case study. Below is the structure and a brief explanation of the files generated.

For a detailed explanation of variables and columns, please refer to:
* [GENERATED_OUTPUTS_es.md](../../documentation/GENERATED_OUTPUTS_es.md) (Spanish)
* [GENERATED_OUTPUTS.md](../../documentation/GENERATED_OUTPUTS.md) (English)

### Output structure

```text
output/
├── data/
│   ├── historical_climate_data.csv          - Long-term baseline climate variables (1970-2000)
│   ├── historical_monthly_weather_data.csv  - Historical monthly weather observations
│   ├── historical_year_weather_data.csv     - Consolidated annual weather summaries
│   ├── historical_period_weather_data.csv   - Average weather parameters for the period
│   ├── future_climate_data.csv              - CMIP6 future climate projections
│   ├── future_period_climatic_data.csv      - Projected period monthly averages
│   ├── all_output_data.xlsx                 - Consolidated Excel workbook
│   ├── plots_extracted.geojson              - Spatial WGS84 point layer (only coordinates and ID)
│   ├── citations_and_metadata.md            - Auto-generated scientific citations and metadata
│   └── environment.rdata                    - Saved R workspace image
├── maps/
│   └── location_map_[lang].png              - Geographic verification map (global, continental, regional)
└── climodiagrams/
    ├── historical/                          - Walter-Lieth climodiagrams for historical data
    └── future/                              - Walter-Lieth climodiagrams for future CMIP6 data
```

---

## 🇪🇸 Plantilla de la estructura de salidas

Este directorio contendrá los resultados generados tras la extracción de datos climáticos al ejecutar la herramienta en un caso de estudio. A continuación se detalla la estructura y una breve explicación de los archivos generados.

Para obtener una explicación detallada de las variables y columnas, consulte:
* [GENERATED_OUTPUTS_es.md](../../documentation/GENERATED_OUTPUTS_es.md) (español)
* [GENERATED_OUTPUTS.md](../../documentation/GENERATED_OUTPUTS.md) (inglés)

### Estructura de salidas

```text
output/
├── data/
│   ├── historical_climate_data.csv          - Variables climáticas base a largo plazo (1970-2000)
│   ├── historical_monthly_weather_data.csv  - Datos meteorológicos mensuales históricos (T, P, Martonne)
│   ├── historical_year_weather_data.csv     - Resúmenes climáticos anuales históricos (T, P, Martonne)
│   ├── historical_period_weather_data.csv   - Promedios climáticos históricos de periodo
│   ├── future_climate_data.csv              - Proyecciones climáticas futuras de CMIP6
│   ├── future_period_climatic_data.csv      - Medias mensuales de periodos futuros
│   ├── all_output_data.xlsx                 - Libro de Excel consolidado
│   ├── plots_extracted.geojson              - Capa espacial de puntos WGS84 (solo identificador y coordenadas)
│   ├── citations_and_metadata.md            - Referencias científicas y metadatos autogenerados
│   └── environment.rdata                    - Imagen guardada del espacio de trabajo de R
├── maps/
│   └── location_map_[lang].png              - Mapa de verificación geográfica (global, continental, regional)
└── climodiagrams/
    ├── historical/                          - Climogramas Walter-Lieth para datos históricos
    └── future/                              - Climogramas Walter-Lieth para proyecciones futuras CMIP6
```
