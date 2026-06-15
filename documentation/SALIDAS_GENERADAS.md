# Guía de Salidas Generadas (WorldClimExtractR)

Este documento detalla la estructura, formato y contenido de todos los ficheros generados por **WorldClimExtractR** en la carpeta `output/` de cada caso de estudio.

---

## Estructura de Directorios de Salida

Al completarse el proceso con éxito, la carpeta `output/` tendrá la siguiente estructura (dependiendo de las tareas activadas):

```text
output/
├── data/
│   ├── df_historical_monthly.csv
│   ├── df_historical_year.csv
│   ├── df_historical_period.csv
│   ├── df_future.csv
│   ├── df_future_period.csv
│   ├── wc_output_data.xlsx
│   ├── plots_extracted.geojson
│   ├── citations_and_metadata.md
│   └── wc_environment.RData
├── maps/
│   └── location_map_[lang].png
└── climodiagrams/
    ├── historical/
    │   └── df_[plot_id]_hst_.png
    └── future/
        └── ssp[ssp_code]/
            └── df_[plot_id]_fut_ssp_[ssp]_period_[period].png
```

---

## 1. Carpeta `data/` (Datos Estructurados)

### `df_historical_monthly.csv` (Datos Históricos Mensuales)
Contiene la serie temporal de datos climáticos mensuales para cada parcela en su periodo temporal configurado (hasta el año 2021).
* **Campos principales:**
  * `id`: Identificador único de la parcela.
  * `latitude`, `longitude`: Coordenadas geográficas en WGS84 (redondeadas a 6 decimales).
  * `year`: Año de la observación.
  * `month`: Mes (formato `01` a `12`).
  * `temp`: Temperatura media mensual (°C).
  * `prec`: Precipitación mensual (mm).
  * `martonne`: Índice de aridez de Martonne mensual ($I = 12 \cdot P / (T + 10)$).

### `df_historical_year.csv` (Datos Históricos Anuales)
Resume los datos mensuales en valores anuales.
* **Campos principales:**
  * `id`, `latitude`, `longitude`, `year`.
  * `tavg`: Temperatura media anual (°C).
  * `prec`: Precipitación anual acumulada (mm).
  * `martonne`: Índice de aridez de Martonne anual ($I = P / (T + 10)$).

### `df_historical_period.csv` (Periodo Histórico Medio)
Representa los valores promedio para todo el rango histórico consultado para cada parcela (ej. de 1970 a 2000).
* **Campos principales:**
  * Contiene los valores de las 19 variables bioclimáticas tradicionales de WorldClim (`bio1` a `bio19`), así como la temperatura media del periodo, precipitación acumulada y el índice de Martonne promedio del periodo.

### `df_future.csv` (Proyecciones Futuras CMIP6)
Contiene los valores brutos de las proyecciones climáticas futuras para cada combinación de parcela, escenario SSP (`ssp126`, `ssp245`, `ssp370`, `ssp585`), periodo futuro (`2021-2040`, `2041-2060`, `2061-2080`, `2081-2100`), mes y modelo climático.

### `df_future_period.csv` (Proyecciones por Periodo Futuro)
Resume las proyecciones futuras en promedios mensuales multianuales para cada periodo futuro y escenario SSP.
* **Campos principales:**
  * `period`: Rango temporal (ej. `2041-2060`).
  * `file_ssp`: Código del escenario SSP.
  * `model`: Modelo de circulación global (GCM).
  * Valores promedio mensuales de temperatura y precipitación.

### `wc_output_data.xlsx` (Libro de Excel Consolidado)
Agrupa todas las hojas de datos anteriores (`historical_monthly`, `historical_year`, `historical_period`, `future`, `future_period`) en pestañas independientes dentro de un único libro de cálculo.

### `plots_extracted.geojson` (Capa de Puntos Geoespacial)
Fichero vectorial en formato GeoJSON (CRS EPSG:4326 - WGS84) que contiene la ubicación de las parcelas junto con sus atributos climáticos promedio históricos o futuros asociados, ideal para su importación inmediata en QGIS, ArcGIS o librerías de Python/R.

### `citations_and_metadata.md` (Metadatos y Citaciones)
Un informe científico en Markdown que documenta la fecha de ejecución, los parámetros CLI utilizados, y genera automáticamente las referencias bibliográficas y citaciones formales requeridas para las bases de datos de WorldClim (Fick & Hijmans), CMIP6, el índice de Martonne, y las librerías espaciales de R utilizadas.

### `wc_environment.RData` (Imagen de Entorno de R)
Imagen del espacio de trabajo de R que contiene todos los dataframes y entornos de ejecución, permitiendo al investigador cargar directamente los datos ejecutando `load("wc_environment.RData")` en R.

---

## 2. Carpeta `maps/` (Verificación Geográfica)

* **`location_map_[lang].png`**: Un mapa compuesto multiescala generado automáticamente al inicio para validar visualmente que las parcelas se ubican en su localización correcta. Evita errores de inversión de coordenadas (latitud/longitud) mostrando la distribución de las parcelas en 3 paneles: Global, Continental y Regional.

---

## 3. Carpeta `climodiagrams/` (Gráficos Climáticos)

* **`historical/df_[plot_id]_hst_.png`**: Climodiagrama de Walter-Lieth para el periodo histórico de la parcela. Permite visualizar la estacionalidad, los periodos de helada segura/probable y los meses de aridez (donde la curva de precipitación cae por debajo del doble de la curva de temperatura: $P < 2T$).
* **`future/ssp[code]/`**: Climodiagramas futuros proyectados para cada combinación de escenario de emisión SSP y periodo de proyección.
