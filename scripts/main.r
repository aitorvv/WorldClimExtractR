#!/usr/bin/Rscript

# Code to run WorldClim functions in an organized way ----
#
# Aitor Vázquez Veloso
# 2026-06-15
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#


# Load command-line parser ====

# dynamically install and load optparse to read command line arguments
if (!requireNamespace("optparse", quietly = TRUE)) {
  install.packages("optparse", repos = "https://cloud.r-project.org")
}
suppressPackageStartupMessages(library(optparse))

# Define CLI options ====
option_list <- list(
  make_option(c("-c", "--case"),
    type = "character", default = "example",
    help = "Name of the case study folder inside case_studies [default: %default]",
    metavar = "character"
  ),
  make_option(c("-b", "--basedir"),
    type = "character", default = getwd(),
    help = "Base directory path of the WorldClim repository [default: current directory]",
    metavar = "character"
  ),
  make_option(c("-d", "--data"),
    type = "character", default = NULL,
    help = "Directory path where WorldClim TIFF folders are located [default: same as basedir]",
    metavar = "character"
  ),
  make_option(c("-l", "--lang"),
    type = "character", default = "en",
    help = "Language of outputs and plots ('en' or 'es') [default: %default]",
    metavar = "character"
  ),
  make_option(c("-e", "--hst_var"),
    type = "character", default = "elev",
    help = "Historical climate variable to extract (elev, bio, prec, srad, tavg, tmax, tmin, vapr, wind, all) [default: %default]",
    metavar = "character"
  ),
  make_option(c("-v", "--hst_bio"),
    type = "integer", default = NULL,
    help = "Bio variable number, only required when hst_var = 'bio' (1-19) [default: %default]",
    metavar = "integer"
  ),
  make_option(c("-f", "--fut_var"),
    type = "character", default = "clim",
    help = "Future variables to extract ('all', 'bio', 'clim') [default: %default]",
    metavar = "character"
  ),
  make_option(c("-s", "--ssp"),
    type = "character", default = "2",
    help = "Shared Socioeconomic Pathways to process (1, 2, 3, 4, 5 or 'all') [default: %default]",
    metavar = "character"
  ),
  make_option(c("-m", "--model"),
    type = "character", default = "MIROC6",
    help = "Future climate model to use (e.g., 'MIROC6', 'ACCESS-CM2', 'BCC-CSM2-MR') [default: %default]",
    metavar = "character"
  ),
  make_option(c("--map"),
    type = "logical", default = TRUE,
    help = "Generate and save the sampling plot location map [default: %default]",
    metavar = "logical"
  ),
  make_option(c("--climodiagram"),
    type = "logical", default = TRUE,
    help = "Generate and save Walter-Lieth climodiagram plots [default: %default]",
    metavar = "logical"
  ),
  make_option(c("--hst_climate"),
    type = "logical", default = TRUE,
    help = "Extract and process historical baseline climate data [default: %default]",
    metavar = "logical"
  ),
  make_option(c("--hst_weather"),
    type = "logical", default = TRUE,
    help = "Extract and process historical monthly weather data [default: %default]",
    metavar = "logical"
  ),
  make_option(c("--future"),
    type = "logical", default = TRUE,
    help = "Extract and process future climate projections [default: %default]",
    metavar = "logical"
  ),
  make_option(c("--verbose"),
    type = "logical", default = FALSE,
    help = "Print detailed extraction and processing logs [default: %default]",
    metavar = "logical"
  )
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)


# Initialize environment and paths ====

case_study_name <- opt$case
basedir <- opt$basedir
datadir <- if (is.null(opt$data)) file.path(basedir, "climate_data") else opt$data
lang <- opt$lang

run_map <- opt$map
run_climodiagram <- opt$climodiagram
run_hst_climate <- opt$hst_climate
run_hst_weather <- opt$hst_weather
run_future <- opt$future
verbose <- opt$verbose

target_hst_var <- opt$hst_var
target_hst_bio_var <- opt$hst_bio
target_fut_var <- opt$fut_var
target_ssp <- opt$ssp
target_model <- opt$model

# Construct dynamic file paths
input_file <- file.path(basedir, "case_studies", case_study_name, "input", "plots.csv")
output_path <- file.path(basedir, "case_studies", case_study_name, "output")

# Load functions from scripts directory
# Note: setwd() must be set to the WorldClimExtractR repository directory (e.g. ~/WorldClimExtractR)
source(file.path(basedir, "scripts", "functions.r"))

# Load necessary geospatial and data manipulation libraries
install_and_load(c("raster", "tidyverse", "eurostat", "giscoR", "sf", "openxlsx"))


# Data preparation ====

# Check if case study folder exists, otherwise fallback to template
if (!file.exists(input_file)) {
  cat("WARNING: Input file not found for case study '", case_study_name, "'. Using template instead...\n", sep = "")
  input_file <- file.path(basedir, "case_studies", "template", "input", "plots.csv")
  output_path <- file.path(basedir, "case_studies", "template", "output")
}

# Load plot coordinates dataset
df <- read.csv(input_file, sep = ",")

# Check and set default historical years if missing or NA
if (!"hst_start_year" %in% colnames(df)) {
  df$hst_start_year <- 1990
} else {
  df$hst_start_year <- ifelse(is.na(df$hst_start_year), 1990, df$hst_start_year)
}

if (!"hst_end_year" %in% colnames(df)) {
  df$hst_end_year <- 2020
} else {
  df$hst_end_year <- ifelse(is.na(df$hst_end_year), 2020, df$hst_end_year)
}

# Correct historical end year to prevent future year query errors
df$hst_end_year <- ifelse(df$hst_end_year > 2024, 2024, df$hst_end_year)

# Print execution header
cat("===========================================================\n")
cat(" WorldClimExtractR — Climate Data Extraction Tool\n")
cat("===========================================================\n")
cat("[INFO] Case study: ", case_study_name, "\n", sep = "")
cat("[INFO] Base directory: ", basedir, "\n", sep = "")
cat("[INFO] Climate layers path: ", datadir, "\n", sep = "")
cat("[INFO] Output language: ", lang, "\n", sep = "")
cat(sprintf(
  "[INFO] Active tasks: Map=%s | Historical Climate=%s | Historical Weather=%s | Future=%s | Climodiagrams=%s\n",
  run_map, run_hst_climate, run_hst_weather, run_future, run_climodiagram
))
cat("[INFO] Total plots to process: ", length(unique(df$id)), "\n", sep = "")
cat("===========================================================\n\n")

# Validate input coordinates strictly (must contain longitude and latitude in WGS84 format)
if (!"longitude" %in% colnames(df) || !"latitude" %in% colnames(df)) {
  stop("Error: Input CSV must strictly contain 'longitude' and 'latitude' (WGS84) coordinate columns.")
}

# Generate verification maps ====

if (run_map) {
  cat("[1/5] Generating geographic verification maps...\n")
  get_location_plot(df,
    long_col = "longitude", lat_col = "latitude", id_col = "id",
    lang = lang, save = TRUE, plot_name = "location", output_path = output_path, verbose = verbose
  )
  if (!verbose) {
    cat("      -> Saved in: case_studies/", case_study_name, "/output/maps/ [OK]\n\n", sep = "")
  } else {
    cat("\n")
  }
} else {
  cat("[1/5] Generating geographic verification maps... Skipped (flag disabled)\n\n")
}


# Data extraction loop ====

df_hst_climate <- df_hst_weather <- df_year <- df_period <- df_fut <- df_period_fut <- tibble::tibble()
unique_plots <- unique(df$id)
total_plots <- length(unique_plots)

# Phase 2: Historical data extraction
if (run_hst_climate || run_hst_weather) {
  cat("[2/5] Extracting and processing historical data...\n")
  current_idx <- 0
  for (plot_id_val in unique_plots) {
    current_idx <- current_idx + 1
    pct <- round((current_idx / total_plots) * 100)

    # citation info on the first iteration if verbose is enabled
    verbose_func <- verbose && (current_idx == 1)
    if (verbose_func) {
      cat("\n[INFO] Citation instructions will be shown only for this first plot.\n\n")
    }

    if (!verbose) {
      cat(sprintf("      [%d/%d] (%3d%%) Processing plot: %-15s ... ", current_idx, total_plots, pct, plot_id_val))
      flush.console()
    } else {
      cat(sprintf("\n--- Processing plot [%d/%d]: %s ---\n", current_idx, total_plots, plot_id_val))
    }

    plot_row <- df[df$id == plot_id_val, ]
    tmp_spdf <- get_spdf(df = plot_row, long_col = "longitude", lat_col = "latitude", verbose = verbose_func)

    # 1. extract historic baseline climate point data (e.g. elevation or bioclimatic baseline)
    if (run_hst_climate) {
      tmp_spdf_hst_climate <- get_wc_historic_climate_data(
        spdf = tmp_spdf, plot_id = "id", var = target_hst_var,
        bio_var = target_hst_bio_var, basedir = datadir, verbose = verbose_func
      )
      df_hst_climate <- dplyr::bind_rows(df_hst_climate, tmp_spdf_hst_climate@data)
    }

    # 2. extract historical monthly weather data over the plot's specific time range
    if (run_hst_weather) {
      tmp_spdf_hst_weather <- get_wc_historical_monthly_weather_data(
        spdf = tmp_spdf,
        period = c(plot_row$hst_start_year:plot_row$hst_end_year),
        basedir = datadir, verbose = verbose_func
      )
      df_hst_weather <- dplyr::bind_rows(df_hst_weather, tmp_spdf_hst_weather@data)

      # 3. summarize monthly weather data into yearly records
      tmp_df_year <- get_wc_annual_weather_data(df = tmp_spdf_hst_weather@data, plot_id = "id", verbose = verbose_func)
      df_year <- dplyr::bind_rows(df_year, tmp_df_year)

      # 4. summarize average monthly and annual variables over the whole study period
      tmp_df_period_monthly <- get_wc_period_weather_data(
        df = tmp_spdf_hst_weather@data, plot_id = "id", grouping_var = "month", year_col = "year",
        start_year = plot_row$hst_start_year, end_year = plot_row$hst_end_year, verbose = verbose_func
      )
      tmp_df_period_yearly <- get_wc_period_weather_data(
        df = tmp_df_year, plot_id = "id", grouping_var = "year", year_col = "year",
        start_year = plot_row$hst_start_year, end_year = plot_row$hst_end_year, verbose = verbose_func
      )
      tmp_df_period <- group_wc_period_weather_data(tmp_df_period_monthly, tmp_df_period_yearly)
      df_period <- dplyr::bind_rows(df_period, tmp_df_period)
    }

    if (!verbose) {
      cat("OK\n")
    }
  }
  cat("      -> Historical data successfully completed.\n\n")
} else {
  cat("[2/5] Extracting and processing historical data... Skipped (flags disabled)\n\n")
}

# Phase 3: Future CMIP6 projections extraction
if (run_future) {
  cat("[3/5] Extracting and processing future projections (CMIP6)...\n")
  current_idx <- 0
  for (plot_id_val in unique_plots) {
    current_idx <- current_idx + 1
    pct <- round((current_idx / total_plots) * 100)

    verbose_func <- verbose && (current_idx == 1)
    if (verbose_func) {
      cat("\n[INFO] Citation instructions will be shown only for this first plot.\n\n")
    }

    if (!verbose) {
      cat(sprintf("      [%d/%d] (%3d%%) Processing plot: %-15s ... ", current_idx, total_plots, pct, plot_id_val))
      flush.console()
    } else {
      cat(sprintf("\n--- Processing plot [%d/%d]: %s ---\n", current_idx, total_plots, plot_id_val))
    }

    plot_row <- df[df$id == plot_id_val, ]
    tmp_spdf <- get_spdf(df = plot_row, long_col = "longitude", lat_col = "latitude", verbose = verbose_func)

    # 6. extract future projections climate data
    tmp_spdf_fut <- get_wc_future_data(
      spdf = tmp_spdf, model = target_model, ssp = target_ssp, var = target_fut_var,
      basedir = datadir, verbose = verbose_func
    )

    # Process the output depending on whether it returns a list (var = "all") or a single SPDF
    if (target_fut_var == "all") {
      tmp_df_fut_bio <- tmp_spdf_fut[[1]]@data
      tmp_df_fut_clim <- tmp_spdf_fut[[2]]@data
      df_fut <- dplyr::bind_rows(df_fut, tmp_df_fut_bio, tmp_df_fut_clim)
      tmp_df_for_period <- tmp_df_fut_clim
    } else if (target_fut_var == "bio" || target_fut_var == "bioc") {
      tmp_df_fut_bio <- tmp_spdf_fut@data
      df_fut <- dplyr::bind_rows(df_fut, tmp_df_fut_bio)
      tmp_df_for_period <- NULL
    } else {
      tmp_df_fut_clim <- tmp_spdf_fut@data
      df_fut <- dplyr::bind_rows(df_fut, tmp_df_fut_clim)
      tmp_df_for_period <- tmp_df_fut_clim
    }

    # 7. summarize future point data into multi-year projection periods
    if (!is.null(tmp_df_for_period)) {
      tmp_df_period_fut <- get_wc_period_weather_data(
        df = tmp_df_for_period, plot_id = "id", grouping_var = "period",
        period_col = "period", verbose = verbose_func
      )
      df_period_fut <- dplyr::bind_rows(df_period_fut, tmp_df_period_fut)
    }

    if (!verbose) {
      cat("OK\n")
    }
  }
  cat("      -> Future projections data successfully completed.\n\n")
} else {
  cat("[3/5] Extracting and processing future projections (CMIP6)... Skipped (flag disabled)\n\n")
}

# Phase 4: Walter-Lieth climodiagram generation
if (run_climodiagram) {
  cat("[4/5] Generating Walter-Lieth climodiagrams...\n")

  # Historical climodiagrams
  if (run_hst_weather && nrow(df_hst_weather) > 0) {
    current_idx <- 0
    for (plot_id_val in unique_plots) {
      current_idx <- current_idx + 1
      pct <- round((current_idx / total_plots) * 100)

      if (!verbose) {
        cat(sprintf("      [%d/%d] (%3d%%) Generating historical climodiagram for: %-15s ... ", current_idx, total_plots, pct, plot_id_val))
        flush.console()
      } else {
        cat(sprintf("\n--- Historical climodiagram [%d/%d]: %s ---\n", current_idx, total_plots, plot_id_val))
      }

      plot_row <- df[df$id == plot_id_val, ]
      plot_hst_data <- df_hst_weather[df_hst_weather$id == plot_id_val, ]

      folder_hst <- file.path(output_path, "climodiagrams", "historical")
      dir.create(folder_hst, recursive = TRUE, showWarnings = FALSE)
      get_climodiagram(
        df = plot_hst_data, plot_id = "id", grouping_var = "year", year_col = "year",
        start_year = plot_row$hst_start_year, end_year = plot_row$hst_end_year,
        long_col = "longitude", lat_col = "latitude", lang = lang,
        plot_name = paste(plot_id_val, "_historical", sep = ""),
        output_path = folder_hst, verbose = verbose
      )

      if (!verbose) {
        cat("OK\n")
      }
    }
  }

  # Future climodiagrams
  if (run_future && !is.null(target_fut_var) && target_fut_var != "bio" && target_fut_var != "bioc" && nrow(df_fut) > 0) {
    df_fut_clim_only <- df_fut[!is.na(df_fut$month) & df_fut$month != "annual", ]

    if (nrow(df_fut_clim_only) > 0) {
      current_idx <- 0
      for (plot_id_val in unique_plots) {
        current_idx <- current_idx + 1
        pct <- round((current_idx / total_plots) * 100)

        if (!verbose) {
          cat(sprintf("      [%d/%d] (%3d%%) Generating future climodiagrams for: %-15s ... ", current_idx, total_plots, pct, plot_id_val))
          flush.console()
        } else {
          cat(sprintf("\n--- Future climodiagrams [%d/%d]: %s ---\n", current_idx, total_plots, plot_id_val))
        }

        plot_fut_data <- df_fut_clim_only[df_fut_clim_only$id == plot_id_val, ]

        for (ssp in unique(plot_fut_data$file_ssp)) {
          df_ssp <- plot_fut_data[plot_fut_data$file_ssp == ssp, ]
          folder_fut <- file.path(output_path, "climodiagrams", "future", paste0("ssp", ssp))
          dir.create(folder_fut, recursive = TRUE, showWarnings = FALSE)

          for (period in unique(df_ssp$period)) {
            df_ssp_period <- df_ssp[df_ssp$period == period, ]

            get_climodiagram(
              df = df_ssp_period, plot_id = "id", grouping_var = "period",
              period_col = "period", ssp = ssp,
              start_year = as.numeric(substr(period, 1, 4)), end_year = as.numeric(substr(period, 6, 9)),
              long_col = "longitude", lat_col = "latitude",
              lang = lang, plot_name = paste(plot_id_val, "_future_ssp_", ssp, "_period_", period,
                sep = ""
              ), output_path = folder_fut, verbose = verbose
            )
          }
        }

        if (!verbose) {
          cat("OK\n")
        }
      }
    }
  } else if (run_future && (target_fut_var == "bio" || target_fut_var == "bioc")) {
    cat("      -> Warning: Future climodiagrams skipped because '--fut_var' is 'bio'.\n")
  }
  cat("      -> Climodiagrams successfully completed.\n\n")
} else {
  cat("[4/5] Generating Walter-Lieth climodiagrams... Skipped (flag disabled)\n\n")
}

# clean global environment of intermediate workspace objects
rm(list = setdiff(ls(envir = .GlobalEnv), c(
  "df", "df_hst_climate", "df_hst_weather", "df_year", "df_period", "df_fut", "df_period_fut",
  "output_path", "run_hst_climate", "run_hst_weather", "run_future", "run_map",
  "run_climodiagram", "lang", "case_study_name", "verbose", "opt", "datadir"
)), envir = .GlobalEnv)


# Export outputs ====

cat("[5/5] Exporting consolidated result files...\n")

# Create output folder for structured data results
folder_data <- file.path(output_path, "data")
dir.create(folder_data, recursive = TRUE, showWarnings = FALSE)

# Clean up stale outputs if they are disabled in the current run
if (!run_hst_climate) {
  unlink(file.path(folder_data, "historical_climate_data.csv"))
}
if (!run_hst_weather) {
  unlink(file.path(folder_data, "historical_monthly_weather_data.csv"))
  unlink(file.path(folder_data, "historical_year_weather_data.csv"))
  unlink(file.path(folder_data, "historical_period_weather_data.csv"))
}
if (!run_future) {
  unlink(file.path(folder_data, "future_climate_data.csv"))
  unlink(file.path(folder_data, "future_period_climatic_data.csv"))
}
if (!run_hst_climate && !run_hst_weather && !run_future) {
  unlink(file.path(folder_data, "plots_extracted.geojson"))
}
if (!run_map) {
  unlink(file.path(output_path, "maps", paste0("location_map_", lang, ".png")))
}
if (!run_climodiagram) {
  unlink(file.path(output_path, "climodiagrams"), recursive = TRUE)
}

# Helper function to clean and round dataframes for output
clean_and_round_df <- function(df, is_period_or_year = FALSE) {
  if (is.null(df) || nrow(df) == 0) {
    return(df)
  }

  # Remove redundant ID column if it exists and 'id' column is also present
  if ("ID" %in% names(df) && "id" %in% names(df)) {
    df <- df[, !names(df) %in% "ID", drop = FALSE]
  }

  # Remove hst_start_year and hst_end_year columns if they exist
  df <- df[, !names(df) %in% c("hst_start_year", "hst_end_year"), drop = FALSE]

  # Rename file_ssp to ssp if it exists
  if ("file_ssp" %in% names(df)) {
    names(df)[names(df) == "file_ssp"] <- "ssp"
  }

  # Coordinate columns -> round to 6 decimal places (approx. 11cm precision)
  coord_cols <- intersect(names(df), c("latitude", "longitude"))
  for (col in coord_cols) {
    df[[col]] <- round(as.numeric(df[[col]]), 6)
  }

  # Index columns -> round to 2 decimal places
  index_cols <- intersect(names(df), c("martonne"))
  for (col in index_cols) {
    val <- df[[col]]
    val[is.nan(val) | is.infinite(val)] <- NA
    df[[col]] <- round(as.numeric(val), 2)
  }

  # All other numeric columns (e.g. temperature, precipitation, elevation) -> 1 decimal place
  exclude_cols <- c("latitude", "longitude", "martonne", "year", "month", "id", "ID", "period", "file_ssp", "ssp", "model")
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  numeric_cols <- setdiff(numeric_cols, exclude_cols)

  for (col in numeric_cols) {
    val <- df[[col]]
    val[is.nan(val) | is.infinite(val)] <- NA
    df[[col]] <- round(as.numeric(val), 1)
  }

  # Ensure character month formatting is consistent
  if ("month" %in% names(df)) {
    if (is.numeric(df$month)) {
      df$month <- sprintf("%02d", df$month)
    }
  }

  return(df)
}

# Export individual CSV outputs and Excel worksheets conditionally
wb <- openxlsx::createWorkbook()

if (run_hst_climate) {
  if (nrow(df_hst_climate) > 0) {
    df_hst_climate <- clean_and_round_df(df_hst_climate, is_period_or_year = FALSE)
    write.csv(df_hst_climate, file = file.path(folder_data, "historical_climate_data.csv"), row.names = FALSE)
    openxlsx::addWorksheet(wb, "historical_climate_data")
    openxlsx::writeData(wb, "historical_climate_data", df_hst_climate)
    cat("      -> Historical baseline climate CSV successfully created.\n")
  }
}

if (run_hst_weather) {
  if (nrow(df_hst_weather) > 0) {
    df_hst_weather <- clean_and_round_df(df_hst_weather, is_period_or_year = FALSE)
    df_year <- clean_and_round_df(df_year, is_period_or_year = TRUE)
    df_period <- clean_and_round_df(df_period, is_period_or_year = TRUE)

    write.csv(df_hst_weather, file = file.path(folder_data, "historical_monthly_weather_data.csv"), row.names = FALSE)
    write.csv(df_year, file = file.path(folder_data, "historical_year_weather_data.csv"), row.names = FALSE)
    write.csv(df_period, file = file.path(folder_data, "historical_period_weather_data.csv"), row.names = FALSE)

    openxlsx::addWorksheet(wb, "historical_monthly_weather_data")
    openxlsx::writeData(wb, "historical_monthly_weather_data", df_hst_weather)
    openxlsx::addWorksheet(wb, "historical_year_weather_data")
    openxlsx::writeData(wb, "historical_year_weather_data", df_year)
    openxlsx::addWorksheet(wb, "historical_period_weather_data")
    openxlsx::writeData(wb, "historical_period_weather_data", df_period)

    cat("      -> Historical weather CSV files successfully created.\n")
  }
}

if (run_future) {
  if (nrow(df_fut) > 0) {
    df_fut <- clean_and_round_df(df_fut, is_period_or_year = FALSE)
    write.csv(df_fut, file = file.path(folder_data, "future_climate_data.csv"), row.names = FALSE)
    openxlsx::addWorksheet(wb, "future_climate_data")
    openxlsx::writeData(wb, "future_climate_data", df_fut)
    cat("      -> Future projections CSV file successfully created.\n")
  }
  if (nrow(df_period_fut) > 0) {
    df_period_fut <- clean_and_round_df(df_period_fut, is_period_or_year = TRUE)
    write.csv(df_period_fut, file = file.path(folder_data, "future_period_climatic_data.csv"), row.names = FALSE)
    openxlsx::addWorksheet(wb, "future_period_climatic_data")
    openxlsx::writeData(wb, "future_period_climatic_data", df_period_fut)
    cat("      -> Future projections by period CSV file successfully created.\n")
  }
}

if (length(names(wb)) > 0) {
  openxlsx::saveWorkbook(wb, file = file.path(folder_data, "all_output_data.xlsx"), overwrite = TRUE)
  cat("      -> Consolidated Excel workbook saved in: data/all_output_data.xlsx\n")
}

# Export GeoJSON spatial data
if (nrow(df) > 0) {
  df_geo <- df[, c("id", "longitude", "latitude")]
  df_geo_sf <- sf::st_as_sf(df_geo, coords = c("longitude", "latitude"), crs = 4326)
  suppressMessages(
    sf::st_write(df_geo_sf, file.path(folder_data, "plots_extracted.geojson"),
      driver = "GeoJSON", delete_dsn = TRUE, quiet = TRUE
    )
  )
  cat("      -> GeoJSON spatial layer saved in: data/plots_extracted.geojson\n")
}

# Export Citations and Metadata
metadata_file <- file.path(folder_data, "citations_and_metadata.md")
metadata_content <- paste0(
  "# WorldClimExtractR - Execution Metadata\n\n",
  "**Execution Date:** ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
  "**Number of Plots Processed:** ", nrow(df), "\n",
  "**Historical Climate Status:** ", ifelse(run_hst_climate, "Enabled", "Disabled"), "\n",
  "**Historical Weather Status:** ", ifelse(run_hst_weather, "Enabled", "Disabled"), "\n",
  "**Future Extraction Status:** ", ifelse(run_future, "Enabled", "Disabled"), "\n",
  "**Map Generation Status:** ", ifelse(run_map, "Enabled", "Disabled"), "\n",
  "**Climodiagram Generation Status:** ", ifelse(run_climodiagram, "Enabled", "Disabled"), "\n\n",
  "## Input Parameters (opt variables)\n",
  "- Case: ", opt$case, "\n",
  "- Basedir: ", opt$basedir, "\n",
  "- Data: ", datadir, "\n",
  "- Lang: ", opt$lang, "\n",
  "- Historical Var: ", opt$hst_var, "\n",
  "- Historical Bio Var: ", ifelse(is.null(opt$hst_bio), "NULL", opt$hst_bio), "\n",
  "- Future Var: ", opt$fut_var, "\n",
  "- Future SSP: ", opt$ssp, "\n",
  "- Future Model: ", opt$model, "\n",
  "- Map: ", opt$map, "\n",
  "- Climodiagram: ", opt$climodiagram, "\n",
  "- Historical Climate: ", opt$hst_climate, "\n",
  "- Historical Weather: ", opt$hst_weather, "\n",
  "- Future: ", opt$future, "\n",
  "- Verbose: ", opt$verbose, "\n\n",
  "## Bibliography & Citations\n\n",
  "Please consider citing the following sources in your research:\n\n",
  "**WorldClimExtractR Repository:**\n",
  "- Vázquez Veloso, A. (2026). WorldClimExtractR: A tool for extracting historical and future climate data from WorldClim. GitHub repository. https://github.com/AitorVazquezVeloso/WorldClimExtractR\n\n",
  "**Historical Climate Data (CRU-TS & WorldClim):**\n",
  "- Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315.\n",
  "- Harris, I., Osborn, T.J., Jones, P.D., Lister, D.H. (2020). Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. Scientific Data 7: 109.\n\n",
  "**Future Climate Data (CMIP6):**\n",
  "- Petrie, R., Denvil, S., Ames, S. et al. (2021). Coordinating an operational data distribution network for CMIP6 data. Geoscientific Model Development, 14(1), 629-644. https://doi.org/10.5194/gmd-14-629-2021\n",
  "- O'Neill, B. C., Kriegler, E., Ebi, K. L. et al. (2017). The roads ahead: Narratives for shared socioeconomic pathways describing world futures in the 21st century. Global Environmental Change, 42, 169-180.\n\n",
  "**Aridity Index:**\n",
  "- Martonne (1926). L'indice d'aridite. Bulletin de l'Association de Geographes Francais, 3, 3-5.\n\n",
  "**Spatial Data & Maps (GISCO):**\n",
  "- Hernangomez, D. (2024). giscoR: Download Map Data from GISCO API - Eurostat. R package version 0.4.0. https://CRAN.R-project.org/package=giscoR\n"
)
writeLines(metadata_content, metadata_file)
cat("      -> Citations and metadata document saved in: data/citations_and_metadata.md\n")

# Save the R workspace execution image
save.image(file = file.path(folder_data, "environment.rdata"))
cat("      -> R environment image (.rdata) saved in the output directory.\n\n")

cat("===========================================================\n")
cat(" Process completed successfully! All outputs are ready.\n")
cat("===========================================================\n")
