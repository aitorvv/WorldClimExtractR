# Guía de salidas generadas (WorldClimExtractR)

Este documento detalla la estructura, formato y contenido de todos los ficheros generados por **WorldClimExtractR** en la carpeta `output/` de cada caso de estudio.

---

## Estructura de directorios de salida

Al completarse el proceso con éxito, la carpeta `output/` tendrá la siguiente estructura (dependiendo de las tareas activadas):

```text
output/
├── data/
│   ├── historical_monthly_weather_data.csv
│   ├── historical_year_climatic_data.csv
│   ├── historical_period_climatic_data.csv
│   ├── future_climate_data.csv
│   ├── future_period_climatic_data.csv
│   ├── all_output_data.xlsx
│   ├── plots_extracted.geojson
│   ├── citations_and_metadata.md
│   └── environment.rdata
├── maps/
│   └── location_map_[lang].png
└── climodiagrams/
    ├── historical/
    │   └── [plot_id]_historical_climodiagram_walter_lieth_[lang].png
    └── future/
        └── ssp[ssp_code]/
            └── [plot_id]_future_ssp_[ssp]_period_[period]_climodiagram_walter_lieth_[lang].png
```

---

## 1. Carpeta `data/` (datos estructurados)

### `historical_monthly_weather_data.csv` (datos históricos mensuales)
Contiene la serie temporal de datos climáticos mensuales para cada parcela en su periodo temporal configurado (hasta el año 2021).
* **Campos principales:**
  * `id`: Identificador único de la parcela.
  * `latitude`, `longitude`: Coordenadas geográficas en WGS84 (redondeadas a 6 decimales).
  * `year`: Año de la observación.
  * `month`: Mes (formato `01` a `12`).
  * `temp`: Temperatura media mensual (°C).
  * `prec`: Precipitación mensual (mm).
  * `martonne`: Índice de aridez de Martonne mensual ($I = 12 \cdot P / (T + 10)$).

### `historical_year_climatic_data.csv` (datos históricos anuales)
Resume los datos mensuales en valores anuales.
* **Campos principales:**
  * `id`, `latitude`, `longitude`, `year`.
  * `tavg`: Temperatura media anual (°C).
  * `prec`: Precipitación anual acumulada (mm).
  * `martonne`: Índice de aridez de Martonne anual ($I = P / (T + 10)$).

### `historical_period_climatic_data.csv` (periodo histórico medio)
Representa los valores promedio para todo el rango histórico consultado para cada parcela (ej. de 1970 a 2000).
* **Campos principales:**
  * Contiene los valores de las 19 variables bioclimáticas tradicionales de WorldClim (`bio1` a `bio19`), así como la temperatura media del periodo, precipitación acumulada y el índice de Martonne promedio del periodo.

### `future_climate_data.csv` (proyecciones futuras CMIP6)
Contiene los valores brutos de las proyecciones climáticas futuras para cada combinación de parcela, escenario SSP (`ssp126`, `ssp245`, `ssp370`, `ssp585`), periodo futuro (`2021-2040`, `2041-2060`, `2061-2080`, `2081-2100`), mes y modelo climático.

### `future_period_climatic_data.csv` (proyecciones por periodo futuro)
Resume las proyecciones futuras en promedios mensuales multianuales para cada periodo futuro y escenario SSP.
* **Campos principales:**
  * `period`: Rango temporal (ej. `2041-2060`).
  * `ssp`: Código del escenario SSP (escenario simplificado, ej. `1`, `2`, `3`, `5`).
  * `model`: Modelo de circulación global (GCM).
  * Valores promedio mensuales de temperatura y precipitación.

### `all_output_data.xlsx` (libro de Excel consolidado)
Agrupa todas las hojas de datos anteriores (`historical_monthly`, `historical_year`, `historical_period`, `future`, `future_period`) en pestañas independientes dentro de un único libro de cálculo.

### `plots_extracted.geojson` (capa de puntos geoespacial)
Fichero vectorial en formato GeoJSON (CRS EPSG:4326 - WGS84) que contiene la ubicación de las parcelas junto con sus atributos climáticos promedio históricos o futuros asociados, ideal para su importación inmediata en QGIS, ArcGIS o librerías de Python/R.

### `citations_and_metadata.md` (metadatos y citaciones)
Un informe científico en Markdown que documenta la fecha de ejecución, los parámetros CLI utilizados, y genera automáticamente las referencias bibliográficas y citaciones formales requeridas para las bases de datos de WorldClim (Fick & Hijmans), CMIP6, el índice de Martonne, y las librerías espaciales de R utilizadas.

### `environment.rdata` (imagen de entorno de R)
Imagen del espacio de trabajo de R que contiene todos los dataframes y entornos de ejecución, permitiendo al investigador cargar directamente los datos ejecutando `load("environment.rdata")` en R.

---

## 2. Carpeta `maps/` (verificación geográfica)

* **`location_map_[lang].png`**: Un mapa compuesto multiescala generado automáticamente al inicio para validar visualmente que las parcelas se ubican en su localización correcta. Evita errores de inversión de coordenadas (latitud/longitud) mostrando la distribución de las parcelas.

---

## 3. Carpeta `climodiagrams/` (gráficos climáticos)

* **`historical/[plot_id]_historical_climodiagram_walter_lieth_[lang].png`**: Climodiagrama de Walter-Lieth para el periodo histórico de la parcela. Permite visualizar la estacionalidad, los periodos de helada segura/probable y los meses de aridez (donde la curva de precipitación cae por debajo del doble de la curva de temperatura: $P < 2T$).
* **`future/ssp[code]/`**: Climodiagramas futuros proyectados para cada combinación de escenario de emisión SSP y periodo de proyección (`[plot_id]_future_ssp_[ssp]_period_[period]_climodiagram_walter_lieth_[lang].png`).
