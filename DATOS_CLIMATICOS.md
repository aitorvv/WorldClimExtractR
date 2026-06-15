# Guía de Configuración de Datos Climáticos (WorldClim)
*WorldClimExtractR — Documento de soporte técnico*

> [!NOTE]
> Este documento detalla la estructura, codificación de nombres y orígenes de descarga de los datos espaciales raster (.tiff) necesarios para el funcionamiento de **WorldClimExtractR**.

---

## 1. Fuentes de Descarga y Variables

Para ejecutar las extracciones correctamente, debe descargar los datasets oficiales desde el portal web de **WorldClim (Versión 2.1)**. A continuación se detallan las fuentes y enlaces de descarga recomendados:

### Tabla 1. Resumen de descarga de datos climáticos
*Tabla 1. Fuentes oficiales de descarga de datos.*

| Variable / Dataset | Resolución Temporal | Resolución Espacial | Enlace Web de Descarga |
| :--- | :--- | :--- | :--- |
| **Bioclimatic Variables (bio)** | Histórico (1970-2000) | 30 segundos (~1 km) | [WorldClim 2.1 Baseline - Bio](https://www.worldclim.org/data/worldclim21.html) |
| **Elevation (elev)** | Estático | 30 segundos (~1 km) | [WorldClim 2.1 Baseline - Elev](https://www.worldclim.org/data/worldclim21.html) |
| **Monthly Weather Data (tmin, tmax, prec)** | Histórico mensual (1950-2021) | 30 segundos (~1 km) | [WorldClim 2.1 Monthly Weather](https://www.worldclim.org/data/monthlyw.html) |
| **Future CMIP6 Projections (bioc, tmin, tmax, prec)** | Proyecciones (2021-2100) | 30 segundos (~1 km) | [WorldClim CMIP6 Future Climate](https://www.worldclim.org/data/cmip6/cmip6_clim30s.html) |

---

## 2. Estructura de Directorios

Los archivos descargados deben organizarse de forma estructurada en un directorio común llamado `climate_data/`. Las tres carpetas principales dentro de este directorio son `historical_climate_data/`, `historical_monthly_data/` y `future_climate_data/`.

### Estructura de archivos propuesta:
```text
WorldClimExtractR/
└── climate_data/                                       # Carpeta contenedora de datos climáticos
    ├── historical_climate_data/
    │   ├── wc2.1_30s_elev.tif                          # Capa estática de elevación
    │   └── wc2.1_30s_bio/
    │       ├── wc2.1_30s_bio_1.tif                     # Temperatura media anual (BIO1)
    │       └── ... [bio_2.tif hasta bio_19.tif]
    │
    ├── historical_monthly_data/
    │   ├── wc2.1_30s_prec_2010-2018/                   # Carpetas por décadas de precipitación
    │   │   ├── wc2.1_30s_prec_2015-01.tif
    │   │   └── ...
    │   ├── wc2.1_30s_tmin_2010-2018/                   # Carpetas de temperaturas mínimas
    │   │   ├── wc2.1_30s_tmin_2015-01.tif
    │   │   └── ...
    │   └── wc2.1_30s_tmax_2010-2018/                   # Carpetas de temperaturas máximas
    │       ├── wc2.1_30s_tmax_2015-01.tif
    │       └── ...
    │
    └── future_climate_data/
        ├── MIROC6_SSP1/                                # Carpetas por GCM y escenario SSP
        │   ├── wc2.1_30s_bioc_MIROC6_ssp126_2021-2040.tif
        │   └── ...
        └── MIROC6_SSP2/
            ├── wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif  # Multibanda (19 bandas de bioclimáticos)
            ├── wc2.1_30s_prec_MIROC6_ssp245_2021-2040.tif  # Multibanda (12 bandas mensuales)
            ├── wc2.1_30s_tmax_MIROC6_ssp245_2021-2040.tif
            └── wc2.1_30s_tmin_MIROC6_ssp245_2021-2040.tif
```

---

## 3. Nomenclatura Requerida de los Archivos

El motor R de **WorldClimExtractR** localiza y extrae las variables basándose en la posición de los caracteres en el nombre de los archivos (sustracción de cadenas de texto). Respete estrictamente la nomenclatura por defecto suministrada por WorldClim:

### A. Históricos Mensuales (`historical_monthly_data`)
Los archivos mensuales deben estar dentro de cualquier subcarpeta de década y cumplir con el patrón:
* Estructura del nombre: `wc2.1_30s_[variable]_[año]-[mes].tif`
* Ejemplo: `wc2.1_30s_prec_2015-01.tif`
  * Variable (`prec`): extraído de los caracteres 12 al 15.
  * Año (`2015`): extraído de los caracteres 17 al 20.
  * Mes (`01`): extraído de los caracteres 22 al 23.

### B. Proyecciones Futuras (`future_climate_data`)
Las carpetas de proyecciones deben tener el nombre en formato `[GCM]_SSP[SSP_Numero]` (ej. `MIROC6_SSP2` o `MIROC6_SSP5`). Los archivos `.tif` interiores (que son multibanda) deben cumplir con el patrón estándar de descarga:
* Estructura del nombre: `wc2.1_30s_[variable]_[GCM]_ssp[ssp_codigo]_[periodo].tif`
* Ejemplo: `wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif`
  * Variable (`bioc`): extraído de los caracteres 11 al 14.
  * Escenario SSP (`2`): extraído de la posición 26.
  * Periodo (`2021-2040`): extraído de las posiciones 30 al 38.

> [!WARNING]
> Si cambia los nombres de los archivos por defecto o los modifica manualmente, el script R no podrá parsear los años, meses o escenarios SSP, lo que provocará errores en la ejecución del bucle.
