# WorldClimExtractR

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Data Source: WorldClim](https://img.shields.io/badge/Data--Source-WorldClim%20v2.1-orange.svg)](https://www.worldclim.org/)
[![CMIP6 Support](https://img.shields.io/badge/Projections-CMIP6-purple.svg)](https://www.worldclim.org/data/cmip6.html)
[![Walter-Lieth Climodiagrams](https://img.shields.io/badge/Climodiagrams-Walter--Lieth-darkgreen.svg)](#-visual-showcase--generated-outputs)

---

***This document is also available in 🇪🇸 [Spanish (Español)](README_es.md).***

**WorldClimExtractR** is a lightweight, parameterized R tool to extract, process, and summarize historical and future (CMIP6) WorldClim climate data based on geographic coordinates anywhere in the world.

---

## 🎨 Visual showcase & generated outputs

Here is an illustrative example using 6 coordinate plots located worldwide, showing both the spatial location check and the corresponding climate summary graphs:

| 📍 Plot Geographic Verification Map | 📊 Auto-Generated Walter-Lieth Climodiagram |
| :---: | :---: |
| <img src="documentation/images/location_map_example.png" width="100%" alt="Plot Location Map" /> | <img src="documentation/images/climodiagram_example.png" width="100%" alt="Walter-Lieth Climodiagram" /> |
| *Scale-adaptive map showing point location check (regional/European/global).* | *Monthly temperature and precipitation patterns for a selected historical period.* |

---

## 📊 Workflow and Output Options

**WorldClimExtractR** allows you to select exactly what data you need to extract. You can choose to retrieve historical baselines, weather time series, or future CMIP6 projections.

<img src="documentation/images/workflow_options.svg" width="100%" alt="Workflow Options" />

For a detailed explanation of every generated column and format, please check the [Generated Outputs Guide](documentation/GENERATED_OUTPUTS.md).

---

## Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Repository structure](#repository-structure)
- [Full usage example](#full-usage-example)
- [Command line interface (CLI) options](#command-line-interface-cli-options)
- [Geospatial layers configuration](#geospatial-layers-configuration)
- [Citations and references](#citations-and-references)
- [License](#license)

---

## ✨ Features

* 🌍 **Coordinate Climate Extraction**: Retrieves bioclimatic, elevation, and historical monthly temperature and precipitation data worldwide.
* 📊 **Walter-Lieth Climate Diagrams**: Generates standardized climate diagrams for historical and future periods in English or Spanish.
* ⚙️ **CLI & HPC Ready**: A parameterized script compatible with terminal environments using `optparse`, allowing local and HPC execution without internal code modifications.
* 📁 **Consolidated Formats**: Exports results to individual CSVs, a multi-sheet Excel workbook (`.xlsx`), a spatial vector file (`.geojson`), a metadata report with citations, and saves the R session environment (`.RData`).
* 🎛️ **Modular Output Toggles**: Run only the sections you need (historical, future, maps, or climodiagrams) using explicit execution flags.

---
## 📦 Requirements

### System dependencies
Ensure you have R installed (version `>= 4.0.0`) along with system libraries required by spatial dependencies like `sf`:

```bash
# Required system dependencies on Ubuntu / Debian
sudo apt-get install libgdal-dev libgeos-dev libproj-dev libudunits2-dev
```

### R packages
The main script automatically checks and installs any missing R packages:
* `eurostat`
* `giscoR`
* `openxlsx`
* `optparse`
* `raster`
* `sf`
* `tidyverse`

### Climate data (.tif)
Users must download all the required `.tif` files to retrieve climate data, which can be done from the official [WorldClim](https://www.worldclim.org/data/index.html) website. To learn how to name and organize these layers, please refer to the [Geospatial Data Setup Guide (CLIMATE_DATA.md)](documentation/CLIMATE_DATA.md).

---

## 📂 Repository structure

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
    Root --> ReadmeEn["📄 README.md (English Doc)"]:::mainFile
    Root --> ReadmeEs["📄 README_es.md (Spanish Doc)"]:::file
    Root --> Cit["📄 CITATION.md"]:::file
    Root --> Cont["📄 CONTRIBUTING.md (English Doc)"]:::file
    Root --> ContEs["📄 CONTRIBUTING_es.md (Spanish Doc)"]:::file
    Root --> Lic["📄 LICENSE"]:::file
    Root --> Proj["📄 WorldClimExtractR.Rproj"]:::file
    Root --> Gitignore["📄 .gitignore"]:::file
    
    %% scripts/
    DirScripts --> ScriptMain["📄 main.r (CLI / Interactive)"]:::file
    DirScripts --> ScriptFuncs["📄 functions.r (Functions)"]:::file
    
    %% climate_data/
    DirData --> DataHist["📁 historical_climate_data"]:::folder
    DirData --> DataMonthly["📁 historical_monthly_weather_data"]:::folder
    DirData --> DataFuture["📁 future_climate_data"]:::folder
    
    %% documentation/
    DirDoc --> DocGenEn["📄 GENERATED_OUTPUTS.md (English Doc)"]:::file
    DirDoc --> DocGenEs["📄 GENERATED_OUTPUTS_es.md (Spanish Doc)"]:::file
    DirDoc --> DatosCliEn["📄 CLIMATE_DATA.md (English Doc)"]:::file
    DirDoc --> DatosCliEs["📄 CLIMATE_DATA_es.md (Spanish Doc)"]:::file
    DirDoc --> GuiaVerEn["📄 VERIFICATION_GUIDE.md (English Doc)"]:::file
    DirDoc --> GuiaVerEs["📄 VERIFICATION_GUIDE_es.md (Spanish Doc)"]:::file
    DirDoc --> DocPdfs["📄 *.pdf (Official WorldClim guides)"]:::file
    
    %% case_studies/
    DirCases --> CaseReadme["📄 README.md (Case studies guide)"]:::file
    DirCases --> CaseTempl["📁 template (Base template)"]:::folder
    DirCases --> CaseEx["📁 example (Executed example)"]:::folder
    
    %% template/
    CaseTempl --> TemplInput["📁 input"]:::folder
    CaseTempl --> TemplReadme["📄 output_README.md"]:::file
    TemplInput --> TemplPlots["📄 plots.csv"]:::file
    
    %% example/
    CaseEx --> ExInput["📁 input"]:::folder
    CaseEx --> ExOutput["📁 output (Git-ignored)"]:::folder
    ExInput --> ExPlots["📄 plots.csv"]:::file
```

---

## 🚀 Usage and Common Use Cases

To see exactly how to run the script depending on your research goals (e.g., getting all data vs. only future projections), please check our [**Common Use Cases Guide**](documentation/USE_CASES.md).

### Basic Execution

The most basic way to run the script using the provided template case study:

```bash
# Run the extraction for the plots defined in the template
Rscript scripts/main.r --case "template" --basedir "." --lang "en" --hst_var "all" --ssp "all"
```

> [!NOTE]
> For a full list of available flags and parameters, run `Rscript scripts/main.r --help` or check the [Use Cases Guide](documentation/USE_CASES.md).

### Inspecting generated outputs
Once execution completes, find your output files in `case_studies/template/output/` (or the equivalent `output/` directory of your case study if you duplicated the template for another project). To visually verify geographical coordinates and Walter-Lieth graphs, consult the [Results Verification Guide (VERIFICATION_GUIDE.md)](documentation/VERIFICATION_GUIDE.md).

Outputs are grouped as follows:

* **`data/`**:
  * `historical_climate_data.csv`: Historical baseline climate data (WorldClim 1970-2000).
  * `historical_monthly_weather_data.csv`: Historical monthly weather dataset (precipitation, temperatures).
  * `historical_year_weather_data.csv`: Historical annual weather summaries and calculated Martonne Aridity Index.
  * `historical_period_weather_data.csv`: Averaged weather values representing the entire historical range.
  * `future_climate_data.csv` & `future_period_climate_data.csv`: CMIP6 future climate projections (MIROC6 model).
  * `all_output_data.xlsx`: Consolidated multi-sheet Excel workbook with all tables.
  * `plots_extracted.geojson`: Geospatial vector file with coordinates and period summaries.
  * `citations_and_metadata.md`: Markdown document detailing script options and references to cite.
  * `environment.rdata`: R environment snapshot for further custom analysis.
* **`maps/`**:
  * Location maps containing plot points with their IDs plotted for visual verification (national, European, and regional scales).
* **`climodiagrams/`**:
  * **`historical/`**: Historical Walter-Lieth diagrams for each plot.
  * **`future/`**: Projections sorted by SSP scenarios and decades (e.g., `plot_1_future_ssp_2_period_2021-2040_climodiagram_walter_lieth_en.png`).

---

## ⚙️ Command line interface (CLI) options

The `scripts/main.r` script supports the following CLI arguments:

| Short Flag | Long Flag | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `-c` | `--case` | `character` | `template` | Subfolder name inside `case_studies/` |
| `-b` | `--basedir` | `character` | `getwd()` | Root directory path of the project codebase |
| `-d` | `--data` | `character` | `NULL` | Path to alternative WorldClim raster data folder |
| `-l` | `--lang` | `character` | `en` | Language for charts and maps (`en` or `es`) |
| `-e` | `--hst_var` | `character` | `elev` | Starting historical variable to extract (`elev`, `bio`, `prec`, `srad`, `tavg`, `tmax`, `tmin`, `vapr`, `wind`, `all`) |
| `-v` | `--hst_bio` | `integer` | `NULL` | Specific historical bioclimatic variable index (1-19) |
| `-f` | `--fut_var` | `character` | `clim` | Future CMIP6 variable to extract (`all` [generates climodiagrams], `bio` [bioclimatic variables only, skips climodiagrams], `clim` [monthly climate weather only, generates climodiagrams]) |
| `-s` | `--ssp` | `character` | `all` | Future SSP scenario (`1`, `2`, `3`, `4`, `5`, or `all`) |
| | `--hst_climate` | `logical` | `TRUE` | Enable/disable historical baseline climate extraction |
| | `--hst_weather` | `logical` | `TRUE` | Enable/disable historical monthly weather extraction |
| | `--future` | `logical` | `TRUE` | Enable/disable future projection extraction |
| | `--map` | `logical` | `TRUE` | Enable/disable plot verification map generation |
| | `--climodiagram`| `logical` | `TRUE` | Enable/disable Walter-Lieth climate diagram generation |

### Advanced usage example
```bash
# Load data from external storage, extract BIO3 bioclimatic variable, and disable future projections
Rscript scripts/main.r --case "my_project" --data "/media/user/HD" --hst_var "bio" --hst_bio 3 --future FALSE
```

---

## 📂 Geospatial layers configuration

To learn more about downloading, decade structure, and naming conventions for Earth's precipitation, temperature, and CMIP6 TIFF layers, check:
* [Geospatial Data Setup Guide (CLIMATE_DATA.md)](documentation/CLIMATE_DATA.md)

---

## 🤝 Citations and references

When publishing scientific papers or reports using data generated by this tool, please cite both the repository and the original data sources:

* **WorldClimExtractR (this repository)**: Vázquez-Veloso, A. (2026). WorldClimExtractR: A parameterized R tool for historical and future CMIP6 WorldClim climate data extraction. GitHub repository: https://github.com/aitorvv/WorldClimExtractR
* **WorldClim 2.1 Baseline**: Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. *International Journal of Climatology* 37 (12): 4302-4315.
* **Monthly Weather Data**: Harris, I., Osborn, T.J., Jones, P.D., Lister, D.H. 2020. Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. *Scientific Data* 7: 109.
* **Future Projections (CMIP6)**: Petrie, R., et al. 2021. Coordinating an operational data distribution network for CMIP6 data. *Geoscientific Model Development*, 14(1), 629-644.
* **Martonne Aridity Index**: Martonne, E. de. 1926. L’indice d’aridité. *Bulletin de l’Association de Géographes Français*, 3, 3–5.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
