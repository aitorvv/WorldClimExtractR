# WorldClimExtractR

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Data Source: WorldClim](https://img.shields.io/badge/Data--Source-WorldClim%20v2.1-orange.svg)](https://www.worldclim.org/)
[![CMIP6 Support](https://img.shields.io/badge/Projections-CMIP6-purple.svg)](https://www.worldclim.org/data/cmip6.html)
[![Walter-Lieth Climodiagrams](https://img.shields.io/badge/Climodiagrams-Walter--Lieth-darkgreen.svg)](#-visual-showcase--generated-outputs)

---

**WorldClimExtractR** is a lightweight, parameterized R tool to extract, process, and summarize historical and future (CMIP6) WorldClim climate data based on geographic coordinates anywhere in the world.

---

## 🎨 Visual Showcase & Generated Outputs

Here is an illustrative example using 6 coordinate plots located worldwide, showing both the spatial location check and the corresponding climate summary graphs:

| 📍 Plot Geographic Verification Map | 📊 Auto-Generated Walter-Lieth Climodiagram |
| :---: | :---: |
| <img src="documentation/images/location_map_example.png" width="100%" alt="Plot Location Map" /> | <img src="documentation/images/climodiagram_example.png" width="100%" alt="Walter-Lieth Climodiagram" /> |
| *Scale-adaptive map showing point location check (regional/European/global).* | *Monthly temperature and precipitation patterns for a selected historical period.* |

---

## 📊 Tabular Data Previews

Below is a preview of the structured tabular datasets automatically produced in `CSV` and `XLSX` (consolidated spreadsheet) formats:

### A. Monthly Historical Data (`df_historical_monthly.csv`)
First few rows showing the extracted monthly climate variables (e.g., precipitation, temperature extremes, and average):

| id | latitude | longitude | elev | year | month | prec | tmax | tmin | tavg |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| plot_1 | 37.903222 | -2.911167 | 1275 | 2015 | 01 | 48.5 | 8.0 | -3.0 | 2.5 |
| plot_1 | 37.903222 | -2.911167 | 1275 | 2015 | 02 | 56.3 | 7.0 | -2.0 | 2.5 |
| plot_1 | 37.903222 | -2.911167 | 1275 | 2015 | 03 | 96.7 | 12.0 | 0.0 | 6.0 |

### B. Historical Period Summary (`df_historical_period.csv`)
Aggregated values and calculated indices (such as the Martonne Aridity Index) representing the selected historical time range:

| id | period | month | tmin | tmax | tavg | prec | martonne |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| plot_1 | 2015_2021 | annual | 5.5 | 18.1 | 11.8 | 517.6 | 23.77 |
| plot_2 | 2015_2021 | annual | 8.2 | 20.8 | 14.5 | 1392.9 | 56.81 |

### C. Future Climate Period Projections (`df_future_period.csv`)
CMIP6 projected averages and ranges (minimum/maximum values) grouped by decade/period and SSP scenario:

| id | model | file_ssp | period | tmin | tmax | tavg | prec | martonne |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| plot_1 | MIROC6 | 1 | 2021-2040 | 7.1 | 20.0 | 13.6 | 495.0 | 21.02 |
| plot_1 | MIROC6 | 1 | 2041-2060 | 7.5 | 20.5 | 14.0 | 490.0 | 20.40 |
| plot_1 | MIROC6 | 2 | 2021-2040 | 7.1 | 19.8 | 13.5 | 502.0 | 21.39 |

> [!NOTE]
> Future climate tables include additional min/max bounds columns (`tmin_min`, `tmax_max`, etc.) to provide uncertainty ranges for each projection period.

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Repository Structure](#repository-structure)
- [Full Usage Example](#full-usage-example)
- [Command Line Interface (CLI) Options](#command-line-interface-cli-options)
- [Geospatial Layers Configuration](#geospatial-layers-configuration)
- [Citations and References](#citations-and-references)
- [License](#license)

---

## ✨ Features

* 🌍 **Coordinate Climate Extraction**: Retrieves bioclimatic, elevation, and historical monthly temperature and precipitation data worldwide.
* 🔄 **On-the-Fly Projection Conversion**: Detects and converts local coordinate systems (e.g., UTM Zone 30N / ETRS89) to WGS84 (longitude and latitude) automatically.
* 📊 **Walter-Lieth Climate Diagrams**: Generates standardized climate diagrams for historical and future periods in English or Spanish.
* ⚙️ **CLI & HPC Ready**: A parameterized script compatible with terminal environments using `optparse`, allowing local and HPC execution without internal code modifications.
* 📁 **Consolidated Formats**: Exports results to individual CSVs, a multi-sheet Excel workbook (`.xlsx`), a spatial vector file (`.geojson`), a metadata report with citations, and saves the R session environment (`.RData`).
* 🎛️ **Modular Output Toggles**: Run only the sections you need (historical, future, maps, or climodiagrams) using explicit execution flags.

---
## 📦 Requirements

### System Dependencies
Ensure you have R installed (version `>= 4.0.0`) along with system libraries required by spatial dependencies like `sf`:

```bash
# Required system dependencies on Ubuntu / Debian
sudo apt-get install libgdal-dev libgeos-dev libproj-dev libudunits2-dev
```

### R Packages
The main script automatically checks and installs any missing R packages:
* `eurostat`
* `giscoR`
* `openxlsx`
* `optparse`
* `raster`
* `sf`
* `tidyverse`

### Climate Data (.tif)
Users must download all the required `.tif` files to retrieve climate data, which can be done from the official [WorldClim](https://www.worldclim.org/data/index.html) website. To learn how to name and organize these layers, please refer to the [Geospatial Data Setup Guide (DATOS_CLIMATICOS_en.md)](DATOS_CLIMATICOS_en.md).

---

## 📂 Repository Structure

The repository maintains a clean structure, excluding large raster layers and user study outputs from version control:

```mermaid
graph LR
    %% Node style definitions
    classDef folder fill:#ffe0b2,stroke:#fb8c00,stroke-width:1px,color:#000000;
    classDef file fill:#ffffff,stroke:#b0bec5,stroke-width:1px,color:#000000;
    classDef mainFile fill:#e8f5e9,stroke:#4caf50,stroke-width:2px,color:#000000;
    
    Root["📁 WorldClimExtractR (Root)"]:::folder
    
    %% Main folders
    Root --> DirScripts["📁 scripts<br>(R Code)"]:::folder
    Root --> DirData["📁 climate_data<br>(Raster TIFFs - Git-ignored)"]:::folder
    Root --> DirDoc["📁 documentation<br>(PDFs & Manuals)"]:::folder
    Root --> DirCases["📁 case_studies<br>(Case studies)"]:::folder
    
    %% Root files
    Root --> ReadmeEs["📄 README.md (Spanish Doc)"]:::file
    Root --> ReadmeEn["📄 README_en.md (English Doc)"]:::mainFile
    Root --> DatosCliEs["📄 DATOS_CLIMATICOS.md"]:::file
    Root --> DatosCliEn["📄 DATOS_CLIMATICOS_en.md"]:::file
    Root --> GuiaVerEs["📄 GUIA_VERIFICACION.md"]:::file
    Root --> GuiaVerEn["📄 GUIA_VERIFICACION_en.md"]:::file
    Root --> Cit["📄 CITATION.md"]:::file
    Root --> Cont["📄 CONTRIBUTING.md"]:::file
    Root --> Lic["📄 LICENSE"]:::file
    Root --> Proj["📄 WorldClimExtractR.Rproj"]:::file
    Root --> Gitignore["📄 .gitignore"]:::file
    
    %% scripts/
    DirScripts --> ScriptMain["📄 wc_main.r (CLI / Interactive)"]:::file
    DirScripts --> ScriptFuncs["📄 wc_functions.r (Functions)"]:::file
    
    %% climate_data/
    DirData --> DataHist["📁 historical_climate_data"]:::folder
    DirData --> DataMonthly["📁 historical_monthly_data"]:::folder
    DirData --> DataFuture["📁 future_climate_data"]:::folder
    
    %% documentation/
    DirDoc --> DocGenEs["📄 SALIDAS_GENERADAS.md"]:::file
    DirDoc --> DocGenEn["📄 GENERATED_OUTPUTS.md"]:::file
    DirDoc --> DocPdfs["📄 *.pdf (Official WorldClim guides)"]:::file
    
    %% case_studies/
    DirCases --> CaseTempl["📁 template (Base template)"]:::folder
    DirCases --> CaseEx["📁 example (Executed example)"]:::folder
    
    %% template/
    CaseTempl --> TemplInput["📁 input"]:::folder
    CaseTempl --> TemplReadme["📄 output_README.md"]:::file
    TemplInput --> TemplPlots["📄 wc_plots.csv"]:::file
    
    %% example/
    CaseEx --> ExInput["📁 input"]:::folder
    CaseEx --> ExOutput["📁 output (Git-ignored)"]:::folder
    ExInput --> ExPlots["📄 wc_plots.csv"]:::file
```

---

## 🚀 Full Usage Example

To run a test case using the provided template case study:

### Step 1: Configure your input coordinates
Edit the input CSV file at `case_studies/template/input/wc_plots.csv`, specifying the point identifiers (*id*), coordinates (*latitude* and *longitude*, CRS = WGS84), and the historical years of interest to extract (*hst_start_year* and *hst_end_year*; defaults to the 1990-2020 period):

```csv
id,latitude,longitude,hst_start_year,hst_end_year
plot_1,37.90322,-2.91116,2015,2021
plot_2,42.60910,-4.77280,1990,2020
```

### Step 2: Organize your Raster (.tif) files
Download and arrange the WorldClim raster files according to the conventions explained in [DATOS_CLIMATICOS_en.md](DATOS_CLIMATICOS_en.md). You can store them in:
1. **The project directory** (default): Place the three subfolders of data inside `climate_data/` in the root folder.
2. **An external drive or custom folder**: Place the climate data structure elsewhere and pass its path using the `--data` flag (recommended to avoid taking up local storage space).

### Step 3: Run the script from the terminal
Open your terminal and run the main script. You can view all available parameters and flags in the [Command Line Interface (CLI) Options](#⚙️-command-line-interface-cli-options) section (also available via the `Rscript scripts/wc_main.r --help` command):

```bash
# Basic run (looking for TIFF files in the climate_data project folder)
Rscript scripts/wc_main.r --case "template" --basedir "." --lang "es" --hst_var "elev" --fut_var "clim" --ssp "all"

# Run specifying an external path where TIFF files are stored
Rscript scripts/wc_main.r --case "template" --basedir "." --data "/media/user/ExternalDrive/climate_data/" --lang "en"
```

### Step 4: Inspect Generated Outputs
Once execution completes, find your output files in `case_studies/template/output/` (or the equivalent `output/` directory of your case study if you duplicated the template for another project). To visually verify geographical coordinates and Walter-Lieth graphs, consult the [Results Verification Guide (GUIA_VERIFICACION_en.md)](GUIA_VERIFICACION_en.md).

Outputs are grouped as follows:

* **`data/`**:
  * `df_historical_monthly.csv`: Historical monthly dataset (precipitation, temperatures).
  * `df_historical_year.csv`: Historical annual summaries and calculated Martonne Aridity Index.
  * `df_historical_period.csv`: Averaged values representing the entire historical range.
  * `df_future.csv` & `df_future_period.csv`: CMIP6 future climate projections (MIROC6 model).
  * `wc_output_data.xlsx`: Consolidated multi-sheet Excel workbook with all tables.
  * `plots_extracted.geojson`: Geospatial vector file with coordinates and period summaries.
  * `citations_and_metadata.md`: Markdown document detailing script options and references to cite.
  * `wc_environment.RData`: R environment snapshot for further custom analysis.
* **`maps/`**:
  * Location maps containing plot points with their IDs plotted for visual verification (national, European, and regional scales).
* **`climodiagrams/`**:
  * **`historical/`**: Historical Walter-Lieth diagrams for each plot.
  * **`future/`**: Projections sorted by SSP scenarios and decades (e.g., `df_plot_1_fut_ssp_2_period_2021-2040_climodiagram_walter_lieth_en.png`).

---

## ⚙️ Command Line Interface (CLI) Options

The `scripts/wc_main.r` script supports the following CLI arguments:

| Short Flag | Long Flag | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `-c` | `--case` | `character` | `template` | Subfolder name inside `case_studies/` |
| `-b` | `--basedir` | `character` | `getwd()` | Root directory path of the project codebase |
| `-d` | `--data` | `character` | `NULL` | Path to alternative WorldClim raster data folder |
| `-l` | `--lang` | `character` | `en` | Language for charts and maps (`en` or `es`) |
| `-e` | `--hst_var` | `character` | `elev` | Starting historical variable to extract (`elev`, `bio`, `clim`) |
| `-v` | `--hst_bio` | `integer` | `NULL` | Specific historical bioclimatic variable index (1-19) |
| `-f` | `--fut_var` | `character` | `clim` | Future CMIP6 variable to extract (`all` [generates climodiagrams], `bioc` [bioclimatic variables only, skips climodiagrams], `clim` [monthly climate weather only, generates climodiagrams]) |
| `-s` | `--ssp` | `character` | `all` | Future SSP scenario (`1`, `2`, `3`, `5`, or `all`) |
| | `--historical` | `logical` | `TRUE` | Enable/disable historical climate extraction |
| | `--future` | `logical` | `TRUE` | Enable/disable future projection extraction |
| | `--map` | `logical` | `TRUE` | Enable/disable plot verification map generation |
| | `--climodiagram`| `logical` | `TRUE` | Enable/disable Walter-Lieth climate diagram generation |

### Advanced Usage Example:
```bash
# Load data from external storage, extract BIO3 bioclimatic variable, and disable future projections
Rscript scripts/wc_main.r --case "my_project" --data "/media/user/HD" --hst_var "bio" --hst_bio 3 --future FALSE
```

---

## 📂 Geospatial Layers Configuration

To learn more about downloading, decade structure, and naming conventions for Earth's precipitation, temperature, and CMIP6 TIFF layers, check:
* [Geospatial Data Setup Guide (DATOS_CLIMATICOS_en.md)](DATOS_CLIMATICOS_en.md)

---

## 🤝 Citations and References

When publishing scientific papers or reports using data generated by this tool, please cite both the repository and the original data sources:

* **WorldClimExtractR (this repository)**: Vázquez-Veloso, A. (2026). WorldClimExtractR: A parameterized R tool for historical and future CMIP6 WorldClim climate data extraction. GitHub repository: https://github.com/aitorvv/WorldClimExtractR
* **WorldClim 2.1 Baseline**: Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. *International Journal of Climatology* 37 (12): 4302-4315.
* **Monthly Weather Data**: Harris, I., Osborn, T.J., Jones, P.D., Lister, D.H. 2020. Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. *Scientific Data* 7: 109.
* **Future Projections (CMIP6)**: Petrie, R., et al. 2021. Coordinating an operational data distribution network for CMIP6 data. *Geoscientific Model Development*, 14(1), 629-644.
* **Martonne Aridity Index**: Martonne, E. de. 1926. L’indice d’aridité. *Bulletin de l’Association de Géographes Français*, 3, 3–5.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
