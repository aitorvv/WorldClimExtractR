# Climate Data Configuration Guide (WorldClim)
*WorldClimExtractR — Technical Support Document*

> [!NOTE]
> This document details the structure, file naming conventions, and download sources for the spatial raster (.tiff) files required for **WorldClimExtractR** to function.

---

## 1. Download Sources and Variables

To run the extractions correctly, you must download the official datasets from the **WorldClim (Version 2.1)** portal. The recommended sources and download links are detailed below:

### Table 1. Summary of climate data download sources
*Table 1. Official download links for climate data.*

| Variable / Dataset | Temporal Resolution | Maximum Spatial Resolution | Web Download Link |
| :--- | :--- | :--- | :--- |
| **Bioclimatic Variables (bio)** | Historical (1970-2000) | 30 seconds (~1 km² at the equator) | [WorldClim 2.1 Baseline - Bio](https://www.worldclim.org/data/worldclim21.html) |
| **Elevation (elev)** | Static | 30 seconds (~1 km² at the equator) | [WorldClim 2.1 Baseline - Elev](https://www.worldclim.org/data/worldclim21.html) |
| **Monthly Weather Data (tmin, tmax, prec)** | Historical monthly (1950-2024) | 2.5 minutes (~21 km² at the equator) | [WorldClim 2.1 Monthly Weather](https://www.worldclim.org/data/monthlywth.html) |
| **Future CMIP6 Projections (bioc, tmin, tmax, prec)** | Projections (2021-2100) | 2.5 minutes (~21 km² at the equator) | [WorldClim CMIP6 Future Climate](https://www.worldclim.org/data/cmip6/cmip6_clim30s.html) |

---

## 2. Directory Structure

The downloaded files must be organized in a structured way in a shared directory called `climate_data/`. The three main folders inside this directory are `historical_climate_data/`, `historical_monthly_data/`, and `future_climate_data/`.

### Proposed file structure:
```text
WorldClimExtractR/
└── climate_data/                                           # Containment folder for climate data
    ├── historical_climate_data/
    │   ├── wc2.1_30s_elev.tif                              # Static elevation layer
    │   ├── wc2.1_30s_bio/
    │   │   ├── wc2.1_30s_bio_1.tif                         # Annual Mean Temperature (BIO1)
    │   │   └── ... [bio_2.tif to bio_19.tif]
    │   └── wc2.1_30s_prec/
    │       ├── wc2.1_30s_prec_01.tif                       # Average monthly accumulated precipitation
    │       └── ... [prec_02.tif to prec_12.tif]
    │
    ├── historical_monthly_data/
    │   ├── wc2.1_cruts4.06_2.5m_prec/                      # Folder for monthly accumulated precipitation
    │   │   ├── wc2.1_2.5m_prec_1951-01.tif
    │   │   ├── wc2.1_2.5m_prec_1951-02.tif
    │   │   ├── ...
    │   │   └── wc2.1_2.5m_prec_2024-12.tif
    │   ├── wc2.1_cruts4.06_2.5m_tmax/                      # Folder for monthly maximum temperatures
    │   │   ├── wc2.1_2.5m_tmax_1951-01.tif
    │   │   └── ...
    │   └── wc2.1_cruts4.06_2.5m_tmin/                      # Folder for monthly minimum temperatures
    │       ├── wc2.1_2.5m_tmin_1951-01.tif
    │       └── ...
    │
    └── future_climate_data/
        ├── MIROC6_SSP1/                                    # SSP1 Scenario (Sustainability)
        │   ├── wc2.1_30s_bioc_MIROC6_ssp126_2021-2040.tif  # Multiband bioclimatic variables (19 bands)
        │   ├── ... [prec, tmax, tmin variables for the different periods]
        │   └── wc2.1_30s_tmin_MIROC6_ssp126_2081-2100.tif
        ├── MIROC6_SSP2/                                    # SSP2 Scenario (Middle of the Road)
        │   ├── wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif
        │   ├── wc2.1_30s_prec_MIROC6_ssp245_2021-2040.tif  # Multiband monthly precipitation (12 bands)
        │   ├── wc2.1_30s_tmax_MIROC6_ssp245_2021-2040.tif
        │   └── wc2.1_30s_tmin_MIROC6_ssp245_2021-2040.tif
        └── ... [additional folders for other scenarios like MIROC6_SSP3 and MIROC6_SSP5]
```

---

## 3. Required File Naming and Data Combinations

The R engine of **WorldClimExtractR** locates and extracts variables based on exact character positions within file names (string slicing). You must strictly respect the default naming conventions provided by WorldClim.

Below are all the naming patterns and combinations supported by the script:

### A. Static Historical and Baseline Data (`historical_climate_data/`)
Represent global historical climatological averages for the 1970-2000 reference period.
* **Static Elevation (`elev`)**:
  * Location: Single file in the root folder.
  * Name pattern: `wc2.1_30s_elev.tif`
* **Historical Bioclimatic Variables (`bio`)**:
  * Location: Inside the `wc2.1_30s_bio/` folder.
  * Name pattern: `wc2.1_30s_bio_[variable].tif` (where the variable ranges from `1` to `19`).
  * Example: `wc2.1_30s_bio_1.tif` (BIO1: Annual Mean Temperature).
* **Baseline Monthly Climatology (`prec`, `tmax`, `tmin`, `tavg`, `srad`, `vapr`, `wind`)**:
  * Location: Inside folders named `wc2.1_30s_[variable]/` (e.g., `wc2.1_30s_prec/`).
  * Name pattern: `wc2.1_30s_[variable]_[month].tif` (12 monthly files per variable, from `01` to `12`).
  * Example: `wc2.1_30s_prec_01.tif` (Baseline precipitation for January).

### B. Continuous Historical Monthly Data (`historical_monthly_data/`)
Represent actual monthly meteorological observations from 1951 to 2024.
* Location: Inside folders named `wc2.1_cruts4.06_2.5m_[variable]/` (where the variable is `prec`, `tmax`, or `tmin`).
* Name pattern: `wc2.1_2.5m_[variable]_[year]-[month].tif`
* Example: `wc2.1_2.5m_prec_1951-01.tif` (Actual accumulated precipitation for January 1951).
  * **Variable (`prec`, `tmax`, `tmin`)**: Extracted from characters 12 to 15 of the filename.
  * **Year (`1951` to `2024`)**: Extracted from characters 17 to 20.
  * **Month (`01` to `12`)**: Extracted from characters 22 to 23.

### C. Future CMIP6 Climate Projections (`future_climate_data/`)
Represent future climate simulations projected by 20-year periods and grouped by Shared Socioeconomic Pathways (SSP).
* Location: Inside subfolders named `[GCM]_SSP[SSP_Number]` (e.g., `MIROC6_SSP1`, `MIROC6_SSP2`, `MIROC6_SSP3`, or `MIROC6_SSP5`).
* Name pattern: `wc2.1_30s_[variable]_[GCM]_ssp[ssp_code]_[period].tif`
* Example: `wc2.1_30s_bioc_MIROC6_ssp245_2021-2040.tif` (MIROC6 model projection for the SSP2 scenario in the 2021-2040 period).
  * **Variable (`bioc`, `prec`, `tmax`, `tmin`)**: Extracted from characters 11 to 14 of the filename.
    * *Note on bands*: Future projection files are multiband. The `bioc` layer contains 19 bands (the 19 bioclimatic variables), while `prec`, `tmax`, and `tmin` contain 12 bands corresponding to the 12 calendar months.
  * **SSP Scenario (scenario code, e.g., `2`)**: Extracted from the character at position 26 (e.g., the character `2` in `ssp245`).
  * **Projected Period (e.g., `2021-2040`)**: Extracted from positions 30 to 38 of the filename. The covered 20-year periods are: `2021-2040`, `2041-2060`, `2061-2080`, `2081-2100`.

> [!WARNING]
> If you change the default filenames of the raster layers or manually alter the character positions in the filenames, the R script will not be able to parse the years, months, or SSP scenarios correctly, resulting in loop execution errors.
