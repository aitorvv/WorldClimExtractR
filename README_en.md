# WorldClimExtractR

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Research Group](https://img.shields.io/badge/SMART_ECOSYSTEMS-Research_Group-004D26.svg)](https://smart-ecosystems.uva.es/)

---

**WorldClimExtractR** is a lightweight, parameterized R tool developed by the **SMART ECOSYSTEMS Research Group** to extract, process, and summarize historical and future (CMIP6) WorldClim climate data based on geographic coordinates anywhere in the world.

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

Ensure you have R installed (version `>= 4.0.0`) along with system libraries required by spatial dependencies like `sf`:

```bash
# Required system dependencies on Ubuntu / Debian
sudo apt-get install libgdal-dev libgeos-dev libproj-dev libudunits2-dev
```

### R Packages
The main script automatically checks and installs any missing R packages:
* `raster`
* `tidyverse`
* `sf`
* `eurostat`
* `openxlsx`
* `optparse`
* `giscoR`

---

## 📂 Repository Structure

The repository maintains a clean structure, excluding large raster layers and user study outputs from version control:

```text
WorldClimExtractR/
├── .gitignore                         # Excludes raster TIFFs, local environments, and outputs
├── README.md                          # Spanish project documentation
├── README_en.md                       # English project documentation
├── DATOS_CLIMATICOS.md                # Download guide and naming conventions for raster TIFFs (ES)
├── DATOS_CLIMATICOS_en.md             # Download guide and naming conventions for raster TIFFs (EN)
├── GUIA_VERIFICACION.md               # Results verification guide (ES)
├── GUIA_VERIFICACION_en.md            # Results verification guide (EN)
├── WorldClimExtractR.Rproj            # RStudio Project file
├── documentation/                     # WorldClim climate variable reference guides
│   └── *.pdf
├── API/                               # Eurostat API reference documents
│   └── *.pdf
├── scripts/                           # R source code
│   ├── wc_main.r                      # Main parameterized execution script (CLI / Interactive)
│   └── wc_functions.r                 # Data extraction, processing, and graphing functions
├── climate_data/                      # Common directory for climate raster layers (Git-ignored)
│   ├── historical_climate_data/
│   ├── historical_monthly_data/
│   └── future_climate_data/
└── case_studies/                      # User case studies folder
    └── template/                      # Template reference case study (tracked in Git)
        ├── input/
        │   └── wc_plots.csv           # Coordinates and years of interest input file
        └── output/                    # Folder where maps, climodiagrams, and tables are written
```

---

## 🚀 Full Usage Example

To run a test case using the provided template case study:

### Step 1: Configure your input coordinates
Edit the input CSV file at `case_studies/template/input/wc_plots.csv`, specifying the point identifiers, coordinates, and historical years of interest:

```csv
id,latitude,longitude,hst_start_year,hst_end_year
Cordoba,37.90322,-2.91116,2015,2021
Valdepoza,42.60910,-4.77280,1990,2020
```

### Step 2: Organize your Raster (.tif) files
Download and arrange the WorldClim raster files according to the conventions explained in [DATOS_CLIMATICOS_en.md](DATOS_CLIMATICOS_en.md). You can store them in:
1. **The project directory** (default): Place the three subfolders of data inside `climate_data/` in the root folder.
2. **An external drive or custom folder**: Place the climate data structure elsewhere and pass its path using the `--data` flag (recommended to avoid taking up local storage space).

### Step 3: Run the script from the terminal
Open your terminal and run the main script. Specify the template case study, base directory, and preferred language:

```bash
# Run with default options (looking for raster TIFFs inside the project root)
Rscript scripts/wc_main.r --case "template" --basedir "." --lang "es" --hst_var "elev" --fut_var "clim" --ssp "all"

# Run with an external drive path for climate data and English labels
Rscript scripts/wc_main.r --case "template" --basedir "." --data "/media/user/ExternalDrive" --lang "en"
```

### Step 4: Inspect Generated Outputs
Once execution completes, find your output files in `case_studies/template/output/`. To visually verify geographical coordinates and Walter-Lieth graphs, consult the [Results Verification Guide (GUIA_VERIFICACION_en.md)](GUIA_VERIFICACION_en.md).

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
  * **`future/`**: Projections sorted by SSP scenarios and decades (e.g., `df_Cordoba_fut_ssp_2_period_2021-2040_climodiagram_walter_lieth_en.png`).

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

When publishing scientific papers or reports using data generated by this tool, please cite the following original sources:

* **WorldClim 2.1 Baseline**: Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. *International Journal of Climatology* 37 (12): 4302-4315.
* **Monthly Weather Data**: Harris, I., Osborn, T.J., Jones, P.D., Lister, D.H. 2020. Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. *Scientific Data* 7: 109.
* **Future Projections (CMIP6)**: Petrie, R., et al. 2021. Coordinating an operational data distribution network for CMIP6 data. *Geoscientific Model Development*, 14(1), 629-644.
* **Martonne Aridity Index**: Martonne, E. de. 1926. L’indice d’aridité. *Bulletin de l’Association de Géographes Français*, 3, 3–5.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
