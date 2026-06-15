# Climate Data Configuration Guide (WorldClim)
*WorldClimExtractR — Technical Support Document*

> [!NOTE]
> This document details the structure, file naming conventions, and download sources for the spatial raster (.tiff) files required for **WorldClimExtractR** to function.

---

## 1. Download Sources and Variables

To run the extractions correctly, you must download the official datasets from the **WorldClim (Version 2.1)** portal. The recommended sources and download links are detailed below:

### Table 1. Summary of climate data download sources
*Table 1. Official download links for climate data.*

| Variable / Dataset | Temporal Resolution | Spatial Resolution | Web Download Link |
| :--- | :--- | :--- | :--- |
| **Bioclimatic Variables (bio)** | Historical (1970-2000) | 30 seconds (~1 km) | [WorldClim 2.1 Baseline - Bio](https://www.worldclim.org/data/worldclim21.html) |
| **Elevation (elev)** | Static | 30 seconds (~1 km) | [WorldClim 2.1 Baseline - Elev](https://www.worldclim.org/data/worldclim21.html) |
| **Monthly Weather Data (tmin, tmax, prec)** | Historical monthly (1950-2021) | 30 seconds (~1 km) | [WorldClim 2.1 Monthly Weather](https://www.worldclim.org/data/monthlyw.html) |
| **Future CMIP6 Projections (bioc, tmin, tmax, prec)** | Projections (2021-2100) | 30 seconds (~1 km) | [WorldClim CMIP6 Future Climate](https://www.worldclim.org/data/cmip6/cmip6_clim30s.html) |

---

## 2. Directory Structure

The downloaded files must be organized in a structured way in a shared directory called `climate_data/`. The three main folders inside this directory are `historical_climate_data/`, `historical_monthly_data/`, and `future_climate_data/`.

### Proposed file structure:
```text
WorldClimExtractR/
└── climate_data/                                       # Containment folder for climate data
    ├── historical_climate_data/
    │   ├── wc2.1_30s_elev.tif                          # Static elevation layer
    │   └── wc2.1_30s_bio/
    │       ├── wc2.1_30s_bio_1.tif                     # Annual Mean Temperature (BIO1)
    │       └── ... [bio_2.tif to bio_19.tif]
    │
    ├── historical_monthly_data/
    │   ├── wc2.1_30s_prec_2010-2018/                   # Folders by decade for precipitation
    │   │   ├── wc2.1_30s_prec_2015-01.tif
    │   │   └── ...
    │   ├── wc2.1_30s_tmin_2010-2018/                   # Folders for minimum temperatures
    │   │   ├── wc2.1_30s_tmin_2015-01.tif
    │   │   └── ...
    │   └── wc2.1_30s_tmax_2010-2018/                   # Folders for maximum temperatures
    │       ├── wc2.1_30s_tmax_2015-01.tif
    │       └── ...
    │
    └── future_climate_data/
        ├── MIROC6_SSP1/                                # Folders by GCM and SSP scenario
        │   ├── wc2.1_30s_bioc_MIROC6_ssp126_2021-2040.tif
        │   └── ...
        └── MIROC6_SSP2/
            ├── wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif  # Multiband (19 bioclimatic bands)
            ├── wc2.1_30s_prec_MIROC6_ssp245_2021-2040.tif  # Multiband (12 monthly bands)
            ├── wc2.1_30s_tmax_MIROC6_ssp245_2021-2040.tif
            └── wc2.1_30s_tmin_MIROC6_ssp245_2021-2040.tif
```

---

## 3. Required File Naming Convention

The R engine of **WorldClimExtractR** locates and extracts variables based on character positions within file names (string slicing). You must strictly respect the default naming conventions provided by WorldClim:

### A. Historical Monthly Data (`historical_monthly_data`)
Monthly files must be placed inside any decade subfolder and match the pattern:
* Name structure: `wc2.1_30s_[variable]_[year]-[month].tif`
* Example: `wc2.1_30s_prec_2015-01.tif`
  * Variable (`prec`): extracted from characters 12 to 15.
  * Year (`2015`): extracted from characters 17 to 20.
  * Month (`01`): extracted from characters 22 to 23.

### B. Future CMIP6 Projections (`future_climate_data`)
Projection folders must be named following the pattern `[GCM]_SSP[SSP_Number]` (e.g., `MIROC6_SSP2` or `MIROC6_SSP5`). Inside them, the multiband `.tif` files must match the standard download naming convention:
* Name structure: `wc2.1_30s_[variable]_[GCM]_ssp[ssp_code]_[period].tif`
* Example: `wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif`
  * Variable (`bioc`): extracted from characters 11 to 14.
  * SSP scenario (`2`): extracted from character position 26.
  * Period (`2021-2040`): extracted from character positions 30 to 38.

> [!WARNING]
> If you change the default filenames or edit them manually, the R script will not be able to parse the years, months, or SSP scenarios, which will lead to loop execution errors.
