# WorldClimExtractR - Output Directory Template / Estructura de Salidas

This directory will contain the generated climate data extraction results after running the tool on a case study. Below is the structure and brief explanation of what is generated.

Para una explicación detallada de las variables y columnas, consulte:
`documentation/SALIDAS_GENERADAS.md` or `documentation/GENERATED_OUTPUTS.md`

---

## Estructura de Salida / Output Structure

```text
output/
├── data/
│   ├── df_historical_monthly.csv - Historical monthly T, P, Martonne
│   ├── df_historical_year.csv    - Historical annual T, P, Martonne
│   ├── df_historical_period.csv  - Historical bioclimatic variables (bio1-bio19)
│   ├── df_future.csv             - CMIP6 future climate projections
│   ├── df_future_period.csv      - Future period monthly averages
│   ├── wc_output_data.xlsx       - Consolidated Excel workbook
│   ├── plots_extracted.geojson   - Spatial WGS84 point layer with climate attributes
│   ├── citations_and_metadata.md - Auto-generated scientific citations and metadata
│   └── wc_environment.RData      - Saved R workspace image
├── maps/
│   └── location_map_[lang].png   - Geographic verification map (global, continental, regional)
└── climodiagrams/
    ├── historical/               - Walter-Lieth climodiagrams for historical data
    └── future/                   - Walter-Lieth climodiagrams for future CMIP6 data
```
