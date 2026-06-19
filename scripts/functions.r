#!/usr/bin/Rscript

# Code to support WorldClim data extraction - functions ----
#
# Aitor Vázquez Veloso
# 2025-02-28
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#



# Initial notes ====
# df is refered to a data frame
# spdf is refered to a SpatialPointsDataFrame object; use spdf@data to access the data frame
# wc is refered to WorldClim data
# WorldClim data is originally in WGS84 (CRS:4326)



#' Check and install packages
#'
#' Checks if the required packages are installed and loads them.
#'
#' @param packages Character vector of package names.
#' @return Invisible list of loaded packages.
#' @examples
#' install_and_load(c("raster", "tidyverse"))
#' @export
install_and_load <- function(packages) {
  missing_packages <- packages[!packages %in% installed.packages()[, "Package"]]
  
  if (length(missing_packages) > 0) {
    install.packages(missing_packages)
  }
  
  invisible(lapply(packages, function(pkg) {
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }))
}







#' Create SpatialPointsDataFrame
#'
#' Creates a SpatialPointsDataFrame from a data frame with WGS84 coordinates.
#'
#' @param df Data frame with the coordinates.
#' @param long_col Character representing the longitude column name (default "longitude").
#' @param lat_col Character representing the latitude column name (default "latitude").
#' @param CRS Character representing target coordinate reference system.
#' @return SpatialPointsDataFrame object.
#' @examples
#' spdf <- get_spdf(df)
#' @export
get_spdf <- function(df, long_col = "longitude", lat_col = "latitude", 
                      CRS = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0", verbose = TRUE) {
  # create SpatialPointsDataFrame object from coordinates
  spdf <- sp::SpatialPointsDataFrame(df[, c(long_col, lat_col)], df, proj4string = sp::CRS(CRS))
  
  # transform to target CRS
  spdf <- sp::spTransform(spdf, sp::CRS(CRS))
  
  if (verbose) {
    cat("SpatialPointsDataFrame object created successfully!\n")
  }
  
  return(spdf)
}



#' Extract historic WorldClim data
#'
#' Extracts WorldClim historic grid variables for a set of coordinates.
#'
#' @param spdf SpatialPointsDataFrame object containing plot coordinates (WGS84).
#' @param plot_id Character representing column name for the plot ID (default 'ID').
#' @param var Character representing climate variable to extract (default 'bio'; options: 'bio', 'elev', 'clim', 'prec', etc.).
#' @param bio_var Numeric representing bio variable number if var = 'bio' (default 3; options 1-19).
#' @param basedir Character representing root directory of the repository (default getwd()).
#' @param verbose Logical to print the citation of the data (default TRUE).
#' @return SpatialPointsDataFrame with the extracted data.
#' @examples
#' spdf_hst <- get_wc_historic_data(spdf, var = 'bio', bio_var = 3)
#' @export
get_wc_historic_data <- function(spdf, plot_id = 'ID', var = 'bio', bio_var = 3, basedir = getwd(), verbose = TRUE) {
  if (verbose) {
    cat(paste("Extracting WorldClim historic ", var, " data for plot ", spdf@data[[plot_id]], "...\n", sep = ""))
  }
  
  wc_base_path <- file.path(basedir, "historical_climate_data")
  period <- "1970-2000"  # study baseline period
  
  if (var == "bio" && !is.null(bio_var)) {
    file <- file.path(wc_base_path, "wc2.1_30s_bio", paste0("wc2.1_30s_bio_", bio_var, ".tif"))
    files_list <- file
  } else if (var == "elev") {
    file <- file.path(wc_base_path, "wc2.1_30s_elev.tif")
    files_list <- file
  } else {
    folder <- file.path(wc_base_path, paste0("wc2.1_30s_", var))
    files <- list.files(path = folder, pattern = "\\.tif$")
    files_list <- file.path(folder, files)
  }
  
  new_df <- tibble::tibble()
  
  for (file in files_list) {
    raster_file <- raster::raster(file)
    value <- raster::extract(raster_file, spdf)
    
    if (!var %in% c("bio", "elev")) {
      month <- sub(".*_(\\d+)\\.tif$", "\\1", file)
      tmp_df <- tibble::tibble(spdf@data, period, month, value)
    } else {
      tmp_df <- tibble::tibble(spdf@data, period, value)
    }
    
    new_df <- rbind(new_df, tmp_df)
  }
  
  if (var == "bio") {
    var_name <- paste(var, bio_var, sep = "_")
    new_df[var_name] <- new_df$value
  } else {
    new_df[var] <- new_df$value
  }
  
  new_df <- dplyr::select(new_df, -value)
  
  vars <- colnames(spdf@data)
  spdf@data <- dplyr::left_join(spdf@data, new_df, by = vars)
  
  if (verbose) {
    cat(paste("Data extracted for ", var, " in the plot ", spdf@data[[plot_id]], "\n", sep = ""))
    cat("\n")
  }
  
  if (verbose) {
    cat("Cite this data as follows:\n")
    cat("Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315\n")
  }

  return(spdf)
}



#' Extract historical monthly WorldClim data
#'
#' Extracts WorldClim historical monthly weather data for a set of coordinates.
#'
#' @param spdf SpatialPointsDataFrame object containing plot coordinates (WGS84).
#' @param period Integer vector representing years to extract (default 1951:2021).
#' @param basedir Character representing root directory of the repository (default getwd()).
#' @param verbose Logical to print the citation of the data (default TRUE).
#' @return SpatialPointsDataFrame with the extracted weather data.
#' @examples
#' spdf_hst <- get_wc_historical_monthly_weather_data(spdf, period = 2000:2020)
#' @export
get_wc_historical_monthly_weather_data <- function(spdf, period = c(1951:2021), basedir = getwd(), verbose = TRUE) {
  if (verbose) {
    cat(paste("Extracting WorldClim historical monthly data for the period ", min(period), " to ", max(period), 
              " in the plot ", spdf@data$id, "...\n", sep = ""))
    cat("\n")
  }
  
  wc_base_path <- file.path(basedir, "historical_monthly_weather_data")
  folder_list <- dir(wc_base_path)
  
  tmp <- tibble::tibble()
  new_spdf <- spdf

  for (folder in folder_list) {
    folder_path <- file.path(wc_base_path, folder)
    files_list <- list.files(path = folder_path, pattern = "\\.tif$")
    
    for (file in files_list) {
      var <- substring(file, first = 12, last = 15)
      year <- substring(file, first = 17, last = 20)
      month <- substring(file, first = 22, last = 23)
      
      if (!year %in% period) {
        next
      }
      
      raster_file <- raster::raster(file.path(folder_path, file))
      value <- raster::extract(raster_file, spdf)
      
      tmp_file <- tibble::tibble(spdf@data, year, month, value)
      tmp_file[var] <- tmp_file$value
      tmp <- rbind(tmp, tmp_file)
    }
    
    tmp <- dplyr::select(tmp, -value)
    
    vars <- colnames(new_spdf@data)
    vars <- vars[!vars %in% c("prec", "tmin", "tmax")]
    new_spdf@data <- dplyr::left_join(new_spdf@data, tmp, by = vars)

    tmp <- tibble::tibble()  # delete tmp data to avoid mismatching on column names
    
    if (verbose) {
      cat(paste("Data extracted for ", var, " in the plot ", spdf@data$id, "\n", sep = ""))
    }
  }
  
  new_spdf@data$tavg <- (new_spdf@data$tmax + new_spdf@data$tmin) / 2
  
  if (verbose) {
    cat("Average temperature calculated!\n")
    cat("All data was estimated successfully!\n")
    cat("\n")
  }
  
  if (verbose) {
    cat("You could cite this dataset as follows:\n")
    cat("Historical monthly climate data was obtained from CRU-TS 4.06 (Harris et al., 2020) downscaled with WorldClim 2.1 (Fick and Hijmans, 2017).\n")
    cat("References:\n")
    cat("Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315\n")
    cat("Harris, I., Osborn, T.J., Jones, P.D., Lister, D.H. (2020). Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. Scientific Data 7: 109\n")
  }
  
  return(new_spdf)
}



#' Summarize annual climate data
#'
#' Summarizes monthly climate data into annual statistics (including Martonne index).
#'
#' @param df Data frame with the monthly data (extracted via get_wc_historical_monthly_weather_data).
#' @param plot_id Character representing the plot ID column name (default 'ID').
#' @param year_col Character representing the year column name (default 'year').
#' @param verbose Logical to print the citation of the data (default TRUE).
#' @return Data frame with annual average statistics.
#' @examples
#' df_annual <- get_wc_annual_data(df_hst)
#' @export
get_wc_annual_data <- function(df, plot_id = 'ID', year_col = 'year', verbose = TRUE) {
  avg_year <- df %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(c(plot_id, year_col)))) %>%
    dplyr::summarise(
      tmin_min = min(tmin, na.rm = TRUE),
      tmax_min = min(tmax, na.rm = TRUE),
      tavg_min = min(tavg, na.rm = TRUE),
      prec_min = min(prec, na.rm = TRUE),
      
      tmin_max = max(tmin, na.rm = TRUE),
      tmax_max = max(tmax, na.rm = TRUE),
      tavg_max = max(tavg, na.rm = TRUE),
      prec_max = max(prec, na.rm = TRUE),
      
      tmin = mean(tmin, na.rm = TRUE),
      tmax = mean(tmax, na.rm = TRUE),
      tavg = mean(tavg, na.rm = TRUE),
      prec = sum(prec, na.rm = TRUE),
      
      .groups = "drop"
    )
  
  if (verbose) {
    cat("Annual data summarized!\n")
    cat("\n")
  }

  avg_year <- get_martonne(avg_year, verbose = verbose)  
    
  return(avg_year)
}



#' Summarize period climate data
#'
#' Summarizes climate datasets over specified multi-year periods.
#'
#' @param df Data frame containing yearly or monthly climate data.
#' @param plot_id Character representing plot ID column name (default 'ID').
#' @param grouping_var Character representing grouping variable ('year', 'month', or 'period').
#' @param period_col Character representing the period column name (default 'period').
#' @param ssps_col Character representing the SSP column name (default 'file_ssp').
#' @param model_col Character representing the model column name (default 'model').
#' @param year_col Character representing the year column name (default 'year').
#' @param month_col Character representing the month column name (default 'month').
#' @param start_year Character/Numeric representing start year of the period.
#' @param end_year Character/Numeric representing end year of the period.
#' @param verbose Logical to print the citation of the data (default TRUE).
#' @return Data frame containing period summary statistics.
#' @examples
#' df_period <- get_wc_period_data(df_annual, grouping_var = 'year', start_year = 1990, end_year = 2020)
#' @export
get_wc_period_data <- function(df, plot_id = 'ID', grouping_var = 'year', period_col = 'period', ssps_col = 'file_ssp',
                               model_col = 'model', year_col = 'year', month_col = 'month', 
                               start_year = '', end_year = '', verbose = TRUE) {
  
  if (grouping_var %in% c('year', 'month')) {
    if (start_year == '') {
      start_year <- min(df[[year_col]])
    }
    if (end_year == '') {
      end_year <- max(df[[year_col]])
    }
    df <- df[df[[year_col]] >= start_year & df[[year_col]] <= end_year, ]
    period_length <- end_year - start_year + 1
  
    avg_period <- df %>%
      {
        if (grouping_var == 'year') {
          dplyr::group_by(., dplyr::across(dplyr::all_of(c(plot_id))))
        } else if (grouping_var == 'month') {
          dplyr::group_by(., dplyr::across(dplyr::all_of(c(plot_id, month_col))))
        } else {
          dplyr::group_by(., dplyr::across(dplyr::all_of(plot_id)))
        }
      } %>%
      dplyr::summarise(
        period = paste(start_year, end_year, sep = '_'),
        
        tmin_min = min(tmin, na.rm = TRUE),
        tmax_min = min(tmax, na.rm = TRUE),
        tavg_min = min(tavg, na.rm = TRUE),
        prec_min = min(prec, na.rm = TRUE),
        
        tmin_max = max(tmin, na.rm = TRUE),
        tmax_max = max(tmax, na.rm = TRUE),
        tavg_max = max(tavg, na.rm = TRUE),
        prec_max = max(prec, na.rm = TRUE),
        
        tmin = mean(tmin, na.rm = TRUE),
        tmax = mean(tmax, na.rm = TRUE),
        tavg = mean(tavg, na.rm = TRUE),
        prec = sum(prec, na.rm = TRUE),
        
        .groups = "drop"
      )
    avg_period$prec <- avg_period$prec / period_length
    if (grouping_var == 'year') {
      avg_period$month <- 'annual'
    }
    if (verbose) {
      cat("Data summarized for period ", start_year, " to ", end_year, "!\n", sep = "")
    }
    
  } else if (grouping_var == 'period') {
    avg_period <- df %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(c(plot_id, model_col, ssps_col, period_col)))) %>%
      dplyr::summarise(
        tmin_min = min(tmin, na.rm = TRUE),
        tmax_min = min(tmax, na.rm = TRUE),
        tavg_min = min(tavg, na.rm = TRUE),
        prec_min = min(prec, na.rm = TRUE),
        
        tmin_max = max(tmin, na.rm = TRUE),
        tmax_max = max(tmax, na.rm = TRUE),
        tavg_max = max(tavg, na.rm = TRUE),
        prec_max = max(prec, na.rm = TRUE),
        
        tmin = mean(tmin, na.rm = TRUE),
        tmax = mean(tmax, na.rm = TRUE),
        tavg = mean(tavg, na.rm = TRUE),
        prec = sum(prec, na.rm = TRUE),
        
        .groups = "drop"
      )
    if (verbose) {
      cat("Data summarized for the given range of periods!\n", sep = "")
    }
  }
  
  if (verbose) {
    cat("\n")
  }
  
  if (grouping_var == 'month') {
    avg_period$martonne <- NA
  } else {
    avg_period <- get_martonne(avg_period, verbose = verbose) 
  }
   
  return(avg_period)
}



#' Group period monthly and annual data
#'
#' Merges and arranges monthly and yearly summarized period data.
#'
#' @param df_period_monthly Data frame containing monthly summarized data.
#' @param df_period_yearly Data frame containing yearly summarized data.
#' @return Data frame containing combined and structured period data.
#' @examples
#' df_period <- group_wc_period_data(df_period_monthly, df_period_yearly)
#' @export
group_wc_period_data <- function(df_period_monthly, df_period_yearly) {
  df_period <- rbind(df_period_monthly, df_period_yearly)
  df_period <- dplyr::select(df_period, id, period, month, tmin_min, tavg_min, tmax_min, prec_min, 
                             tmin, tmax, tavg, prec, tmin_max, tavg_max, tmax_max, prec_max, martonne)
  df_period <- dplyr::arrange(df_period, id, period, month)
  
  return(df_period)
}



#' Calculate Martonne Aridity Index
#'
#' Calculates the Martonne Aridity Index.
#'
#' @param df Data frame with climate variables.
#' @param prec Character representing the precipitation column name (default 'prec').
#' @param tavg Character representing the average temperature column name (default 'tavg').
#' @param verbose Logical to print the citation of the index (default TRUE).
#' @return Data frame with a new column 'martonne' containing the calculated index.
#' @examples
#' df <- get_martonne(df)
#' @export
get_martonne <- function(df, prec = 'prec', tavg = 'tavg', verbose = TRUE) {
  df$martonne <- df[[prec]] / (df[[tavg]] + 10)
  
  if (verbose) {
    cat("Martonne Aridity Index calculated!\n")
  }
  if (verbose) {
    cat("You could cite this index as follows:\n")
    cat("Martonne (1926). L’indice d’aridité. Bulletin de l’Association de Géographes Français, 3, 3–5.\n")
  }
  
  return(df)
}



#' Extract future WorldClim data
#'
#' Extracts future climate CMIP6 predictions for a set of coordinates.
#'
#' @param spdf SpatialPointsDataFrame object containing plot coordinates (WGS84).
#' @param model Character representing future model name (default 'MIROC6').
#' @param ssp Character representing SSP path (default 'all'; options: 1, 2, 3, 5, all).
#' @param var Character representing desired variable group (default 'all'; options: 'all', 'bio', 'clim').
#' @param basedir Character representing root directory of the repository (default getwd()).
#' @param verbose Logical to print the citation of the data (default TRUE).
#' @return SpatialPointsDataFrame with the extracted future projections.
#' @examples
#' spdf_fut <- get_wc_future_data(spdf, ssp = 'all', var = 'clim')
#' @export
get_wc_future_data <- function(spdf, model = 'MIROC6', ssp = 'all', var = 'all', basedir = getwd(), verbose = TRUE) {
  if (verbose) {
    cat(paste("Extracting WorldClim future climate data for model ", model, ", SSP ", ssp, " and var ", var, "...\n", 
              sep = ""))
    cat("\n")
  }
  
  wc_base_path <- file.path(basedir, "future_climate_data")
  folder_list <- dir(wc_base_path)
  
  if (ssp %in% c("1", "2", "3", "5")) {
    target <- paste(model, "_SSP", ssp, sep = "")
  } else if (ssp == "all") {
    if (model == "MIROC6") {
      ssp <- c(1, 2, 3, 5)
    } else {
      ssp <- c(1, 2, 3, 4, 5)
    }
    target <- paste(model, "_SSP", ssp, sep = "")
  } else {
    stop("Invalid SSP value. Please, use 1, 2, 3, 5 or all")
  }
  
  if (var == "all") {
    var <- c("bioc", "prec", "tmax", "tmin")
  } else if (var == "clim") {
    var <- c("prec", "tmax", "tmin")
  } else if (var == "bio" || var == "bioc") {
    var <- "bioc"
  } else {
    stop("Invalid variable. Please, use \"all\", \"bio\", or \"clim\" at \"var\" argument")
  }
  
  tmp <- tibble::tibble()
  new_spdf_bioc <- new_spdf_clim <- new_spdf_prec <- new_spdf_tmax <- new_spdf_tmin <- spdf
  
  for (folder in folder_list) {
    if (folder %in% target) {
      folder_path <- file.path(wc_base_path, folder)
      files_list <- list.files(path = folder_path, pattern = "\\.tif$")
    } else {
      next
    }

    for (file in files_list) {
      parts <- strsplit(file, "_")[[1]]
      file_var <- parts[3]  # bioc, prec, tmax, tmin from file name
      if (!file_var %in% var) {
        next
      }
      
      ssp_string <- parts[5]
      file_ssp <- substr(ssp_string, 4, 4)  # SSP from file name (e.g., '2' from 'ssp245')
      if (!file_ssp %in% ssp) {
        next
      }
      
      if (file_var == "bioc") {
        n_bands <- 19
      } else {
        n_bands <- 12
      }
      
      period <- sub("\\.tif$", "", parts[6])  # period from file name
      
      for (band in 1:n_bands) {
        raster_file <- raster::raster(file.path(folder_path, file), band = band)
        value <- raster::extract(raster_file, spdf)
        
        tmp_file <- tibble::tibble(spdf@data, model, file_ssp, period, band, value)
        tmp_file[file_var] <- tmp_file$value
        tmp <- rbind(tmp, tmp_file)
      }
      
      if (file_var == "bioc") {
        new_spdf_bioc <- append_future_data(new_spdf_bioc, tmp, "bioc")
      } else if (file_var == "prec") {
        new_spdf_prec <- append_future_data(new_spdf_prec, tmp, "prec")
      } else if (file_var == "tmax") {
        new_spdf_tmax <- append_future_data(new_spdf_tmax, tmp, "tmax")
      } else if (file_var == "tmin") {
        new_spdf_tmin <- append_future_data(new_spdf_tmin, tmp, "tmin")
      }
      
      tmp <- tibble::tibble()  # delete tmp data to avoid mismatching on column names
      
      if (verbose) {
        cat(paste("Data extracted for model ", model, ", SSP", file_ssp, " and variable ", file_var, " on period ", 
                  period, "\n", sep = ""))
      }
    }
    if (verbose) {
      cat("\n")
    }
  }
  
  # group climate data
  if (all(c("tmin", "tmax") %in% var)) {
    new_spdf_clim@data <- dplyr::left_join(new_spdf_clim@data, new_spdf_tmin@data, by = colnames(new_spdf_clim@data))
    new_spdf_clim_cols <- colnames(new_spdf_clim@data)
    new_spdf_clim_cols <- setdiff(new_spdf_clim_cols, "tmin")
    new_spdf_clim@data <- dplyr::left_join(new_spdf_clim@data, new_spdf_tmax@data, by = new_spdf_clim_cols)
    rm(new_spdf_tmin, new_spdf_tmax)
    
    new_spdf_clim@data$tavg <- (new_spdf_clim@data$tmax + new_spdf_clim@data$tmin) / 2
    if (verbose) {
      cat("Average temperature calculated\n")
    }
    
    if ("prec" %in% var) {
      new_spdf_clim_cols <- colnames(new_spdf_clim@data)
      new_spdf_clim_cols <- setdiff(new_spdf_clim_cols, c("tmin", "tmax", "tavg"))
      new_spdf_clim@data <- dplyr::left_join(new_spdf_clim@data, new_spdf_prec@data, by = new_spdf_clim_cols)
      rm(new_spdf_prec)
    }
  }

  if (verbose) {
    cat("Average temperature calculated\n")
    cat("All data was estimated successfully!\n")
    cat("\n")
  }
  
  if (verbose) {
    cat("You could cite this dataset as follows:\n")
    if (model == "MIROC6") {
      cat("Downscaled future climate projections were obtained from WorldClim source using the Coupled Model Intercomparison Project Phase 6 (CMIP6) (Petrie et al. 2021). Climate data was predicted by the 6th version of the Model for Interdisciplinary Research on Climate (MIROC6) (Tatebe et al. 2019) under the Shared Socioeconomic Pathway 2 (SSP2), which represents a “middle of the road” future climate scenario (O’Neill et al. 2017).\n")
      cat("References:\n")
      cat("Petrie, R., Denvil, S., Ames, S., Levavasseur, G., Fiore, S., Allen, C., Antonio, F., Berger, K., Bretonnière, P.-A., Cinquini, L., Dart, E., Dwarakanath, P., Druken, K., Evans, B., Franchistéguy, L., Gardoll, S., Gerbier, E., Greenslade, M., Hassell, D., … Wagner, R. (2021). Coordinating an operational data distribution network for CMIP6 data. Geoscientific Model Development, 14(1), 629-644. https://doi.org/10.5194/gmd-14-629-2021\n")
      cat("Tatebe, H., Ogura, T., Nitta, T., Komuro, Y., Ogochi, K., Takemura, T., Sudo, K., Sekiguchi, M., Abe, M., Saito, F., Chikira, M., Watanabe, S., Mori, M., Hirota, N., Kawatani, Y., Mochizuki, T., Yoshimura, K., Takata, K., O’ishi, R., … Kimoto, M. (2019). Description and basic evaluation of simulated mean state, internal variability, and climate sensitivity in MIROC6. Geoscientific Model Development, 12(7), 2727-2765. https://doi.org/10.5194/gmd-12-2727-2019\n")
      cat("O’Neill, B. C., Kriegler, E., Ebi, K. L., Kemp-Benedict, E., Riahi, K., Rothman, D. S., & Solecki, W. (2017). The roads ahead: Narratives for shared socioeconomic pathways describing world futures in the 21st century. Global Environmental Change, 42, 169-180. https://doi.org/10.1016/j.gloenvcha.2015.01.004\n")
    } else {
      cat(paste0("Downscaled future climate projections were obtained from WorldClim source using the Coupled Model Intercomparison Project Phase 6 (CMIP6) (Petrie et al. 2021). Climate data was predicted by the ", model, " model.\n"))
      cat("References:\n")
      cat("Petrie, R., Denvil, S., Ames, S., Levavasseur, G., Fiore, S., Allen, C., Antonio, F., Berger, K., Bretonnière, P.-A., Cinquini, L., Dart, E., Dwarakanath, P., Druken, K., Evans, B., Franchistéguy, L., Gardoll, S., Gerbier, E., Greenslade, M., Hassell, D., … Wagner, R. (2021). Coordinating an operational data distribution network for CMIP6 data. Geoscientific Model Development, 14(1), 629-644. https://doi.org/10.5194/gmd-14-629-2021\n")
    }
    cat("\n")
    cat("Note from WorldClim website:\n")
    cat("Include in publications an acknowledgment with language similar to: “We acknowledge the World Climate Research Programme, which, through its Working Group on Coupled Modelling, coordinated and promoted CMIP6. We thank the climate modeling groups for producing and making available their model output, the Earth System Grid Federation (ESGF) for archiving the data and providing access, and the multiple funding agencies who support CMIP6 and ESGF.”\n")
  }
    
  if (identical(var, c("bioc", "prec", "tmax", "tmin"))) {
    return(list(new_spdf_bioc, new_spdf_clim))
  } else if (identical(var, "bioc")) {
    return(new_spdf_bioc)
  } else if (identical(var, c("prec", "tmax", "tmin"))) {
    return(new_spdf_clim)
  } else {
    stop("Invalid variable. Please, use \"all\", \"bio\", or \"clim\" at \"var\" argument")
  }
}



#' Append future WorldClim data
#'
#' Helper function to append future climate datasets to spatial data.
#'
#' @param spdf SpatialPointsDataFrame object.
#' @param tmp Temporary data frame containing variables to append.
#' @param file_var Character representing climate variable name.
#' @return SpatialPointsDataFrame with appended variables.
#' @examples
#' spdf <- append_future_data(spdf, tmp, "bioc")
#' @export
append_future_data <- function(spdf, tmp, file_var) {
  if (file_var != "bioc") {
    tmp <- dplyr::rename(tmp, month = band)
  }
  tmp <- dplyr::select(tmp, -value)
  
  if (!file_var %in% colnames(spdf@data)) {
    vars <- colnames(spdf@data)
    vars <- vars[!vars %in% c("bioc", "prec", "tmin", "tmax")]
    spdf@data <- dplyr::left_join(spdf@data, tmp, by = vars)
  } else {
    spdf@data <- rbind(spdf@data, tmp)
  }
  
  return(spdf)
}



#' Generate climodiagram
#'
#' Generates a Walter-Lieth climodiagram and saves it as a PNG.
#'
#' @param df Data frame with climate variables.
#' @param plot_id Character representing plot ID column name (default 'ID').
#' @param grouping_var Character representing grouping variable ('year' or 'period').
#' @param year_col Character representing the year column name (default 'year').
#' @param period_col Character representing the period column name (default 'period').
#' @param model Character representing climate model name (default 'MIROC6').
#' @param ssp Numeric representing SSP path (default 2).
#' @param start_year Character/Numeric representing start year of the period.
#' @param end_year Character/Numeric representing end year of the period.
#' @param long_col Character representing longitude column name (default 'longitude').
#' @param lat_col Character representing latitude column name (default 'latitude').
#' @param lang Character representing language ('en' or 'es').
#' @param save Logical to save the plot to disk (default TRUE).
#' @param plot_name Character representing output file name.
#' @param output_path Character representing output directory path (default getwd()).
#' @param verbose Logical to print progress messages (default TRUE).
#' @return ggplot object representing the climodiagram.
#' @examples
#' get_climodiagram(df, plot_id = 'id', grouping_var = 'year', lang = 'es')
#' @export
get_climodiagram <- function(df, plot_id = 'ID', grouping_var = 'year', year_col = 'year', 
                             period_col = 'period', model = 'MIROC6', ssp = 2,
                             start_year = '', end_year = '',
                             long_col = "longitude", lat_col = "latitude", 
                             lang = 'en', save = TRUE, plot_name = '', output_path = getwd(), verbose = TRUE) {
  
  if (verbose) {
    cat("Creating climodiagram plot...\n")
  }
  
  if (grouping_var == 'year') {
    if (start_year == '') {
      start_year <- min(df[[year_col]])
    }
    if (end_year == '') {
      end_year <- max(df[[year_col]])
    }
    df <- df[df[[year_col]] >= as.numeric(start_year) & df[[year_col]] <= as.numeric(end_year), ]
    period_label <- paste(start_year, end_year, sep = "-")
  } else if (grouping_var == 'period') {
    if (start_year == '') {
      stop("Please, inform the start year")
    }
    if (end_year == '') {
      stop("Please, inform the end year")
    }
    period_label <- paste(start_year, end_year, sep = "-")
    df <- df[df[[period_col]] == period_label, ]
    df <- df[df$model == model, ]
    if (ssp %in% unique(df$file_ssp)) {
      df <- df[df$file_ssp == ssp, ]
    } else {
      stop("Invalid SSP. Please, use 1, 2, 3, 4, or 5 at \"ssp\" argument or check the available SSPs in the data frame")
    }
  } else {
    stop("Invalid grouping variable. Please, use \"year\" or \"period\" at \"grouping_var\" argument")
  }
  
  df <- df %>% 
    dplyr::group_by(.data[[plot_id]], month, .data[[long_col]], .data[[lat_col]]) %>% 
    dplyr::summarise(tavg = mean(tavg, na.rm = TRUE), 
                     prec = mean(prec, na.rm = TRUE),
                     .groups = 'drop')
  
  # set the maximum precipitation and temperature values having the proportion 1:2
  max_precip <- max(df$prec) + 1
  max_temp <- max_precip / 2  # temperature axis will be half of precipitation scale
  
  # calculate values to display in the subtitle
  avg_temp <- round(mean(df$tavg), 1)
  annual_prec <- round(sum(df$prec), 1)
  
  if (lang == 'en') {
    title_label <- "Walter and Lieth Climate Diagram"
    subtitle_label <- paste("Annual Precipitation: ", annual_prec, " mm  |  Average Temperature: ", avg_temp, 
                            "°C  |  Data from ", period_label, sep = "")
    y_label <- "Temperature (°C)"
    y_label_2 <- "Precipitation (mm)"
    month_labels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
    legend_label <- "Month classification: "
    wet_label <- "Wet months"
    dry_label <- "Dry months"
  } else if (lang == 'es') {
    title_label <- "Diagrama climático de Walter Lieth"
    subtitle_label <- paste("Precipitación anual: ", annual_prec, " mm  |  Temperatura promedio: ", avg_temp, 
                            "°C  |  Datos de ", period_label, sep = "")
    y_label <- "Temperatura (°C)"
    y_label_2 <- "Precipitación (mm)"
    month_labels <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")
    legend_label <- "Clasificación: "
    wet_label <- "Meses húmedos"
    dry_label <- "Meses secos"
  } else {
    stop("Language not supported")
  }
  
  # add a column for "wet" and "dry" months
  df <- df %>% dplyr::mutate(month_type = ifelse(prec > 2 * tavg, wet_label, dry_label))
  df$wet_label <- wet_label
  df$dry_label <- dry_label
  
  # create the climodiagram
  plot <- ggplot2::ggplot(df, ggplot2::aes(x = month)) +
    
    # shaded area for dry and wet months
    ggplot2::geom_rect(ggplot2::aes(xmin = as.numeric(month) - 0.5, xmax = as.numeric(month) + 0.5,
                      ymin = 0, ymax = max_precip, fill = month_type), alpha = 0.2) +
    
    # precipitation (right axis, blue line/bars)
    ggplot2::geom_bar(ggplot2::aes(y = prec), stat = "identity", fill = "blue", alpha = 0.4, width = 0.8) +
    ggplot2::geom_line(ggplot2::aes(y = prec), color = "blue", linewidth = 1, group = 1) +
    
    # temperature (left axis, orange line); values are doubled to match scale
    ggplot2::geom_line(ggplot2::aes(y = tavg * 2), color = "orange", linewidth = 1, group = 1) +
    
    # dual axis scaling with a 1:2 proportion
    ggplot2::scale_y_continuous(
      name = y_label, 
      limits = c(0, NA),
      labels = function(x) x / 2,
      sec.axis = ggplot2::sec_axis(~ ., name = y_label_2, breaks = seq(0, max_precip * 2 + 5, by = 10))
    ) +
    
    # custom month labels
    ggplot2::scale_x_discrete(labels = month_labels) +
    
    # customize colors for wet/dry months
    ggplot2::scale_fill_manual(values = setNames(c("skyblue", "yellow"), c(wet_label, dry_label))) +
    
    # add labels and titles
    ggplot2::labs(
      title = title_label,
      subtitle = subtitle_label,
      fill = legend_label
    ) +
    
    # customize theme to comply with group design
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(size = 15, face = "italic", hjust = 0.5),
      axis.title.x = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(size = 12),
      axis.title.y.left = ggplot2::element_text(color = "orange", size = 15, face = "bold"),
      axis.title.y.right = ggplot2::element_text(color = "blue", size = 15, face = "bold"),
      axis.text.y = ggplot2::element_text(size = 12),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(size = 13, face = "bold"),
      legend.text = ggplot2::element_text(size = 12, face = "bold"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "white"),
      plot.background = ggplot2::element_rect(fill = "white")
    )
  
  if (verbose) {
    cat("Climodiagram created successfully\n")
  }
  
  if (save) {
    full_output_path <- file.path(output_path, paste0(plot_name, "_climodiagram_walter_lieth_", lang, ".png"))
    dir.create(dirname(full_output_path), recursive = TRUE, showWarnings = FALSE)
    ggplot2::ggsave(filename = full_output_path, dpi = 300, width = 16, height = 12)
    if (verbose) {
      cat("Climodiagram saved successfully on", full_output_path, "\n")
    }
  }
  
  if (verbose) {
    cat("\n")
  }
  return(plot)
}



#' Plot coordinate locations on map
#'
#' Plots coordinates on a region map to verify WGS84 CRS alignment.
#'
#' @param df Data frame with coordinate columns.
#' @param long_col Character representing longitude column name (default 'longitude').
#' @param lat_col Character representing latitude column name (default 'latitude').
#' @param area Character representing mapping region ('spain', 'europe', 'study_area', etc.).
#' @param graph_plot_coords Logical to overlay coordinates text values on the map.
#' @param lang Character representing output language ('en' or 'es').
#' @param save Logical to save map to file.
#' @param plot_name Character representing output file name.
#' @param output_path Character representing output directory path (default getwd()).
#' @return ggplot object representing the map.
#' @examples
#' Generate verification maps for coordinate validation
#'
#' Automatically detects country context and determines detail levels (NUTS levels)
#' and boundaries to output study area and regional context maps.
#'
#' @param df Coordinate data frame.
#' @param long_col Column name of longitude (default: 'longitude').
#' @param lat_col Column name of latitude (default: 'latitude').
#' @param id_col Column name of plot ID (default: 'id').
#' @param map_type Type of map ('study_area' or 'context').
#' @param area Legacy parameter for backward compatibility.
#' @param lang Output language ('en' or 'es').
#' @param save Logical indicating whether to save map.
#' @param plot_name Base name of plot file.
#' @param output_path Target directory path.
#' @return ggplot object of generated map.
#' @examples
#' plot <- get_location_plot(df)
#' @export
get_location_plot <- function(df, long_col = 'longitude', lat_col = 'latitude', id_col = 'id',
                              map_type = NULL, area = NULL, lang = 'en', 
                              save = TRUE, plot_name = '', output_path = getwd(), verbose = TRUE) {
  
  if (verbose) {
    cat("Creating map...\n")
  }
  
  # ensure columns exist
  df$longitude <- df[[long_col]]
  df$latitude <- df[[lat_col]]
  df$plot_id <- as.character(df[[id_col]])
  
  # convert df to sf to perform spatial checks
  df_sf <- sf::st_as_sf(df, coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)
  
  # load national boundary shapes via giscoR
  shp_countries <- suppressMessages(
    giscoR::gisco_get_countries(
      resolution = "10",
      year = "2020",
      epsg = "4326"
    )
  )
  
  # identify which countries contain the plots
  intersected <- suppressWarnings(suppressMessages(sf::st_join(df_sf, shp_countries)))
  countries_in_df <- unique(stats::na.omit(intersected$CNTR_ID))
  
  # bounding box of plots
  lon_range <- max(df$longitude) - min(df$longitude)
  lat_range <- max(df$latitude) - min(df$latitude)
  max_range <- max(lon_range, lat_range)
  
  # choose detail level and boundaries based on coordinate range
  nuts_level <- dplyr::case_when(
    max_range < 1.5 ~ 3,
    max_range < 5.0 ~ 2,
    max_range < 15.0 ~ 1,
    TRUE            ~ 0
  )
  
  # buffer size proportional to range
  buffer <- max(0.2, max_range * 0.2)
  
  # clamp coordinates to valid geographic ranges
  x_limits <- c(max(-180, min(df$longitude) - buffer), min(180, max(df$longitude) + buffer))
  y_limits <- c(max(-90, min(df$latitude) - buffer), min(90, max(df$latitude) + buffer))
  
  # check if we can and should use European NUTS regions
  nuts_countries <- c("AL", "AT", "BE", "BG", "CH", "CY", "CZ", "DE", "DK", "EE", "EL", "ES", "FI", "FR", 
                      "HR", "HU", "IE", "IS", "IT", "LI", "LT", "LU", "LV", "ME", "MK", "MT", "NL", "NO", 
                      "PL", "PT", "RO", "RS", "SE", "SI", "SK", "TR", "UK")
  use_nuts <- (max_range < 15.0) && all(countries_in_df %in% nuts_countries) && length(countries_in_df) > 0
  
  if (use_nuts) {
    # points are in Europe, download NUTS shapes
    shp_regions <- suppressMessages(
      giscoR::gisco_get_nuts(
        resolution = "10",
        nuts_level = nuts_level, 
        year = "2021",
        epsg = "4326"
      )
    )
    # filter to countries where plots are located
    shp_regions <- shp_regions[shp_regions$CNTR_CODE %in% countries_in_df, ]
    
    # if the filter returned empty results, fallback to countries
    if (nrow(shp_regions) == 0) {
      shp_regions <- shp_countries[shp_countries$CNTR_ID %in% countries_in_df, ]
    }
  } else {
    # global mapping or non-European locations, use global country shapes
    shp_regions <- shp_countries
  }
  
  # define language labels
  if (lang == 'en') {
    title_label <- 'Sampling Plot Locations'
  } else if (lang == 'es') {
    title_label <- 'Ubicación de parcelas de muestreo'
  } else {
    stop("Language not supported. Use 'en' or 'es'.")
  }
  
  # build map with ggplot2
  plot <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = shp_regions, linewidth = 0.5, color = "black", fill = "lightgray") + 
    ggplot2::geom_point(ggplot2::aes(x = longitude, y = latitude), 
                        data = df, size = 3, color = "red", alpha = 0.8) + 
    ggplot2::scale_x_continuous(limits = x_limits) +
    ggplot2::scale_y_continuous(limits = y_limits) +
    ggplot2::labs(title = title_label) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold", size = 14),
      panel.background = ggplot2::element_rect(fill = "aliceblue", color = NA),
      panel.grid.major = ggplot2::element_line(color = "white")
    )
  
  # draw plot ID labels with background for legibility
  plot <- plot + ggplot2::geom_label(
    ggplot2::aes(
      x = longitude, 
      y = latitude, 
      label = plot_id
    ), 
    data = df, 
    size = 4, 
    nudge_y = buffer * 0.08,
    alpha = 0.85,
    fill = "white",
    color = "darkred", 
    fontface = "bold"
  )
  
  if (verbose) {
    cat("Map created successfully\n")
  }
  
  if (save) {
    folder_maps <- file.path(output_path, "maps")
    dir.create(folder_maps, recursive = TRUE, showWarnings = FALSE)
    full_output_path <- file.path(folder_maps, paste0(plot_name, "_map_", lang, ".png"))
    ggplot2::ggsave(plot = plot, filename = full_output_path, dpi = 300, width = 10, height = 8)
    if (verbose) {
      cat("Map saved successfully to", full_output_path, "\n")
    }
  }
  
  return(plot)  
}



#' Load European Nuts regions
#'
#' Helper function to load European boundary shapes via Eurostat.
#'
#' @return sf object of European boundary lines.
#' @export
get_european_regions <- function() {
  suppressMessages(
    shp_regions <- eurostat::get_eurostat_geospatial(
      resolution = 10,
      nuts_level = 0, 
      year = 2021,
      crs = 4326
    )
  )
  return(shp_regions)
}



#' Load Spanish Nuts regions
#'
#' Helper function to load Spanish boundary shapes via Eurostat.
#'
#' @param nuts_level Numeric representing spatial detail level (1, 2, or 3).
#' @return sf object of Spanish boundary lines.
#' @export
get_spanish_regions <- function(nuts_level = 2) {
  suppressMessages(
    shp_regions <- eurostat::get_eurostat_geospatial(
      resolution = 10,
      nuts_level = nuts_level, 
      year = 2021,
      crs = 4326
    )
  )
  shp_es_regions <- shp_regions[shp_regions$CNTR_CODE == "ES", ]
  return(shp_es_regions)
}
