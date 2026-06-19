# Guía de Configuración de Datos Climáticos (WorldClim)
*WorldClimExtractR — Documento de soporte técnico*

> [!NOTE]
> Este documento detalla la estructura, codificación de nombres y orígenes de descarga de los datos espaciales raster (.tiff) necesarios para el funcionamiento de **WorldClimExtractR**.

---

## 1. Fuentes de Descarga y Variables

Para ejecutar las extracciones correctamente, debe descargar los datasets oficiales desde el portal web de **WorldClim (Versión 2.1)**. A continuación se detallan las fuentes y enlaces de descarga recomendados:

### Tabla 1. Resumen de descarga de datos climáticos
*Tabla 1. Fuentes oficiales de descarga de datos.*

| Variable / Dataset | Resolución Temporal | Resolución Espacial Máxima | Enlace Web de Descarga |
| :--- | :--- | :--- | :--- |
| **Bioclimatic Variables (bio)** | Histórico (1970-2000) | 30 segundos (~1 km² at the equator) | [WorldClim 2.1 Baseline - Bio](https://www.worldclim.org/data/worldclim21.html) |
| **Elevation (elev)** | Estático | 30 segundos (~1 km² at the equator) | [WorldClim 2.1 Baseline - Elev](https://www.worldclim.org/data/worldclim21.html) |
| **Monthly Weather Data (tmin, tmax, prec)** | Histórico mensual (1950-2024) | 2.5 minutes (~21 km² at the equator) | [WorldClim 2.1 Monthly Weather](https://www.worldclim.org/data/monthlywth.html) |
| **Future CMIP6 Projections (bioc, tmin, tmax, prec)** | Proyecciones (2021-2100) | 2.5 minutes (~21 km² at the equator) | [WorldClim CMIP6 Future Climate](https://www.worldclim.org/data/cmip6/cmip6_clim30s.html) |

---

## 2. Estructura de Directorios

Los archivos descargados deben organizarse de forma estructurada en un directorio común llamado `climate_data/`. Las tres carpetas principales dentro de este directorio son `historical_climate_data/`, `historical_monthly_data/` y `future_climate_data/`.

### Estructura de archivos propuesta:
```text
WorldClimExtractR/
└── climate_data/                                           # Carpeta contenedora de datos climáticos
    ├── historical_climate_data/
    │   ├── wc2.1_30s_elev.tif                              # Capa estática de elevación
    │   ├── wc2.1_30s_bio/
    │   │   ├── wc2.1_30s_bio_1.tif                         # Temperatura media anual (BIO1)
    │   │   └── ... [bio_2.tif hasta bio_19.tif]
    │   └── wc2.1_30s_prec/
    │       ├── wc2.1_30s_prec_01.tif                       # Precipitación acumulada mensual promedio
    │       └── ... [prec_02.tif hasta prec_12.tif]
    │
    ├── historical_monthly_data/
    │   ├── wc2.1_cruts4.06_2.5m_prec/                      # Carpeta de precipitación acumulada mensual
    │   │   ├── wc2.1_2.5m_prec_1951-01.tif
    │   │   ├── wc2.1_2.5m_prec_1951-02.tif
    │   │   ├── ...
    │   │   └── wc2.1_2.5m_prec_2024-12.tif
    │   ├── wc2.1_cruts4.06_2.5m_tmax/                      # Carpeta de temperaturas máximas mensuales
    │   │   ├── wc2.1_2.5m_tmax_1951-01.tif
    │   │   └── ...
    │   └── wc2.1_cruts4.06_2.5m_tmin/                      # Carpeta de temperaturas mínimas mensuales
    │       ├── wc2.1_2.5m_tmin_1951-01.tif
    │       └── ...
    │
    └── future_climate_data/
        ├── MIROC6_SSP1/                                    # Escenario SSP1 (Sostenibilidad)
        │   ├── wc2.1_30s_bioc_MIROC6_ssp126_2021-2040.tif  # Variables bioclimáticas multibanda (19 bandas)
        │   ├── ... [variables prec, tmax, tmin para los diferentes periodos]
        │   └── wc2.1_30s_tmin_MIROC6_ssp126_2081-2100.tif
        ├── MIROC6_SSP2/                                    # Escenario SSP2 (Middle of the Road)
        │   ├── wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif
        │   ├── wc2.1_30s_prec_MIROC6_ssp245_2021-2040.tif  # Precipitación mensual multibanda (12 bandas)
        │   ├── wc2.1_30s_tmax_MIROC6_ssp245_2021-2040.tif
        │   └── wc2.1_30s_tmin_MIROC6_ssp245_2021-2040.tif
        └── ... [carpetas adicionales para otros escenarios como MIROC6_SSP3 y MIROC6_SSP5]
```

---

## 3. Nomenclatura Requerida y Combinaciones de Datos

El motor R de **WorldClimExtractR** localiza y extrae las variables basándose en la posición exacta de los caracteres en el nombre de los archivos (sustracción de cadenas de texto). Respete estrictamente la nomenclatura estándar suministrada por WorldClim.

A continuación se detallan todas las combinaciones y patrones de nomenclatura admitidos por el script:

### A. Datos Históricos Estáticos y Línea Base (`historical_climate_data/`)
Representan promedios climatológicos históricos globales para el periodo de referencia 1970-2000.
* **Elevación estática (`elev`)**:
  * Ubicación: Archivo único en la raíz de la carpeta.
  * Patrón del nombre: `wc2.1_30s_elev.tif`
* **Bioclimáticos Históricos (`bio`)**:
  * Ubicación: Dentro de la carpeta `wc2.1_30s_bio/`.
  * Patrón del nombre: `wc2.1_30s_bio_[variable].tif` (donde la variable va de `1` a `19`).
  * Ejemplo: `wc2.1_30s_bio_1.tif` (BIO1: Temperatura media anual).
* **Climatología mensual de referencia (`prec`, `tmax`, `tmin`, `tavg`, `srad`, `vapr`, `wind`)**:
  * Ubicación: Dentro de carpetas con el formato `wc2.1_30s_[variable]/` (ej. `wc2.1_30s_prec/`).
  * Patrón del nombre: `wc2.1_30s_[variable]_[mes].tif` (12 archivos mensuales por variable, de `01` a `12`).
  * Ejemplo: `wc2.1_30s_prec_01.tif` (Precipitación de referencia para enero).

### B. Históricos Mensuales Continuos (`historical_monthly_data/`)
Representan observaciones meteorológicas reales mensuales y consecutivas desde 1951 hasta 2024.
* Ubicación: Dentro de carpetas con el formato `wc2.1_cruts4.06_2.5m_[variable]/` (donde la variable es `prec`, `tmax` o `tmin`).
* Patrón del nombre: `wc2.1_2.5m_[variable]_[año]-[mes].tif`
* Ejemplo: `wc2.1_2.5m_prec_1951-01.tif` (Precipitación acumulada real de enero de 1951).
  * **Variable (`prec`, `tmax`, `tmin`)**: Se extrae de los caracteres 12 al 15 del nombre del archivo.
  * **Año (`1951` a `2024`)**: Se extrae de los caracteres 17 al 20.
  * **Mes (`01` a `12`)**: Se extrae de los caracteres 22 al 23.

### C. Proyecciones Climáticas de Futuro CMIP6 (`future_climate_data/`)
Representan las simulaciones climáticas futuras proyectadas por periodos temporales de 20 años y agrupadas por escenarios socioeconómicos (SSP).
* Ubicación: Dentro de subcarpetas llamadas `[GCM]_SSP[SSP_Numero]` (ej. `MIROC6_SSP1`, `MIROC6_SSP2`, `MIROC6_SSP3` o `MIROC6_SSP5`).
* Patrón del nombre: `wc2.1_30s_[variable]_[GCM]_ssp[ssp_codigo]_[periodo].tif`
* Ejemplo: `wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif` (Proyección del modelo MIROC6 para el escenario SSP2 en el periodo 2021-2040).
  * **Variable (`bioc`, `prec`, `tmax`, `tmin`)**: Se extrae de los caracteres 11 al 14 del nombre del archivo.
    * *Nota sobre bandas*: Las capas de proyecciones futuras son multibanda. La capa `bioc` contiene 19 bandas (las 19 variables bioclimáticas), mientras que `prec`, `tmax` y `tmin` contienen 12 bandas correspondientes a los 12 meses.
  * **Escenario SSP (código del escenario, ej. `2`)**: Se extrae del carácter en la posición 26 (ej. el caracter `2` en `ssp245`).
  * **Periodo proyectado (ej. `2021-2040`)**: Se extrae de las posiciones 30 al 38 del nombre. Los periodos de 20 años cubiertos son: `2021-2040`, `2041-2060`, `2061-2080`, `2081-2100`.

> [!WARNING]
> Si cambia los nombres por defecto de las capas raster o altera manualmente las posiciones de los caracteres en los nombres de los archivos, el script R no podrá parsear los años, meses o escenarios SSP correctamente, interrumpiendo la ejecución del bucle con errores de lectura.
