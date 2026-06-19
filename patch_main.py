import re

with open("scripts/main.r", "r") as f:
    content = f.read()

# 1. Update source
content = content.replace(
    '# Load functions from scripts directory\nsource(file.path(basedir, "scripts", "wc_functions.r"))',
    '# Load functions from scripts directory\n# Note: setwd() must be set to the WorldClimExtractR repository directory (e.g. ~/WorldClimExtractR)\nsource(file.path(basedir, "scripts", "functions.r"))'
)

# 2. Translations
content = content.replace('cat("[INFO] Caso de estudio: ", case_study_name, "\\n", sep = "")', 'cat("[INFO] Case study: ", case_study_name, "\\n", sep = "")')
content = content.replace('cat("[INFO] Directorio base: ", basedir, "\\n", sep = "")', 'cat("[INFO] Base directory: ", basedir, "\\n", sep = "")')
content = content.replace('cat("[INFO] Ruta de capas climáticas: ", datadir, "\\n", sep = "")', 'cat("[INFO] Climate layers path: ", datadir, "\\n", sep = "")')
content = content.replace('cat("[INFO] Idioma de salida: ", lang, "\\n", sep = "")', 'cat("[INFO] Output language: ", lang, "\\n", sep = "")')
content = content.replace('cat(sprintf("[INFO] Tareas activas: Mapa=%s | Histórico=%s | Futuro=%s | Climogramas=%s\\n",', 'cat(sprintf("[INFO] Active tasks: Map=%s | Historical=%s | Future=%s | Climodiagrams=%s\\n",')
content = content.replace('cat("[INFO] Total de parcelas a procesar: ", length(unique(df$id)), "\\n", sep = "")', 'cat("[INFO] Total plots to process: ", length(unique(df$id)), "\\n", sep = "")')

content = content.replace('cat("[1/5] Generando mapas de verificación geográfica...\\n")', 'cat("[1/5] Generating geographic verification maps...\\n")')
content = content.replace('cat("      -> Guardados en: case_studies/", case_study_name, "/output/maps/ [OK]\\n\\n", sep = "")', 'cat("      -> Saved in: case_studies/", case_study_name, "/output/maps/ [OK]\\n\\n", sep = "")')
content = content.replace('cat("[1/5] Generando mapas de verificación geográfica... Omitido (flag desactivado)\\n\\n")', 'cat("[1/5] Generating geographic verification maps... Skipped (flag disabled)\\n\\n")')

content = content.replace('cat("[2/5] Extrayendo y procesando datos históricos...\\n")', 'cat("[2/5] Extracting and processing historical data...\\n")')
content = content.replace('cat("\\n[INFO] Las instrucciones de citación se mostrarán solo en esta primera parcela.\\n\\n")', 'cat("\\n[INFO] Citation instructions will be shown only for this first plot.\\n\\n")')
content = content.replace('cat(sprintf("      [%d/%d] (%3d%%) Procesando parcela: %-15s ... ", current_idx, total_plots, pct, plot_id_val))', 'cat(sprintf("      [%d/%d] (%3d%%) Processing plot: %-15s ... ", current_idx, total_plots, pct, plot_id_val))')
content = content.replace('cat(sprintf("\\n--- Procesando parcela [%d/%d]: %s ---\\n", current_idx, total_plots, plot_id_val))', 'cat(sprintf("\\n--- Processing plot [%d/%d]: %s ---\\n", current_idx, total_plots, plot_id_val))')
content = content.replace('cat("      -> Datos históricos completados con éxito.\\n\\n")', 'cat("      -> Historical data successfully completed.\\n\\n")')
content = content.replace('cat("[2/5] Extrayendo y procesando datos históricos... Omitido (flag desactivado)\\n\\n")', 'cat("[2/5] Extracting and processing historical data... Skipped (flag disabled)\\n\\n")')

content = content.replace('cat("[3/5] Extrayendo y procesando proyecciones futuras (CMIP6)...\\n")', 'cat("[3/5] Extracting and processing future projections (CMIP6)...\\n")')
content = content.replace('cat("      -> Datos de proyecciones futuras completados con éxito.\\n\\n")', 'cat("      -> Future projections data successfully completed.\\n\\n")')
content = content.replace('cat("[3/5] Extrayendo y procesando proyecciones futuras (CMIP6)... Omitido (flag desactivado)\\n\\n")', 'cat("[3/5] Extracting and processing future projections (CMIP6)... Skipped (flag disabled)\\n\\n")')

content = content.replace('cat("[4/5] Generando climogramas de Walter-Lieth...\\n")', 'cat("[4/5] Generating Walter-Lieth climodiagrams...\\n")')
content = content.replace('cat(sprintf("      [%d/%d] (%3d%%) Generando climograma histórico para: %-15s ... ", current_idx, total_plots, pct, plot_id_val))', 'cat(sprintf("      [%d/%d] (%3d%%) Generating historical climodiagram for: %-15s ... ", current_idx, total_plots, pct, plot_id_val))')
content = content.replace('cat(sprintf("\\n--- Climograma histórico [%d/%d]: %s ---\\n", current_idx, total_plots, plot_id_val))', 'cat(sprintf("\\n--- Historical climodiagram [%d/%d]: %s ---\\n", current_idx, total_plots, plot_id_val))')
content = content.replace('cat(sprintf("      [%d/%d] (%3d%%) Generando climogramas futuros para: %-15s ... ", current_idx, total_plots, pct, plot_id_val))', 'cat(sprintf("      [%d/%d] (%3d%%) Generating future climodiagrams for: %-15s ... ", current_idx, total_plots, pct, plot_id_val))')
content = content.replace('cat(sprintf("\\n--- Climogramas futuros [%d/%d]: %s ---\\n", current_idx, total_plots, plot_id_val))', 'cat(sprintf("\\n--- Future climodiagrams [%d/%d]: %s ---\\n", current_idx, total_plots, plot_id_val))')
content = content.replace('cat("      -> Aviso: Se omiten los climogramas futuros porque \'--fut_var\' es \'bioc\'.\\n")', 'cat("      -> Warning: Future climodiagrams skipped because \'--fut_var\' is \'bioc\'.\\n")')
content = content.replace('cat("      -> Climogramas completados con éxito.\\n\\n")', 'cat("      -> Climodiagrams successfully completed.\\n\\n")')
content = content.replace('cat("[4/5] Generando climogramas de Walter-Lieth... Omitido (flag desactivado)\\n\\n")', 'cat("[4/5] Generating Walter-Lieth climodiagrams... Skipped (flag disabled)\\n\\n")')

content = content.replace('cat("[5/5] Exportando ficheros de resultados consolidados...\\n")', 'cat("[5/5] Exporting consolidated result files...\\n")')

# Rename outputs in unlinks
content = content.replace('unlink(file.path(folder_data, "df_historical_monthly.csv"))', 'unlink(file.path(folder_data, "historical_monthly_weather_data.csv"))')
content = content.replace('unlink(file.path(folder_data, "df_historical_year.csv"))', 'unlink(file.path(folder_data, "historical_year_climatic_data.csv"))')
content = content.replace('unlink(file.path(folder_data, "df_historical_period.csv"))', 'unlink(file.path(folder_data, "historical_period_climatic_data.csv"))')
content = content.replace('unlink(file.path(folder_data, "df_future.csv"))', 'unlink(file.path(folder_data, "future_climate_data.csv"))')
content = content.replace('unlink(file.path(folder_data, "df_future_period.csv"))', 'unlink(file.path(folder_data, "future_period_climatic_data.csv"))')

# Clean and round df updates
old_clean = """  # Remove redundant ID column if it exists and 'id' column is also present
  if ("ID" %in names(df) && "id" %in names(df)) {
    df <- df[, !names(df) %in% "ID", drop = FALSE]
  }"""
new_clean = """  # Remove redundant ID column if it exists and 'id' column is also present
  if ("ID" %in% names(df) && "id" %in% names(df)) {
    df <- df[, !names(df) %in% "ID", drop = FALSE]
  }
  
  # Remove hst_start_year and hst_end_year columns if they exist
  df <- df[, !names(df) %in% c("hst_start_year", "hst_end_year"), drop = FALSE]
  
  # Rename file_ssp to ssp if it exists
  if ("file_ssp" %in% names(df)) {
    names(df)[names(df) == "file_ssp"] <- "ssp"
  }"""
content = content.replace(old_clean, new_clean)

content = content.replace(
    'exclude_cols <- c("latitude", "longitude", "martonne", "year", "month", "id", "ID", "period", "file_ssp", "model")',
    'exclude_cols <- c("latitude", "longitude", "martonne", "year", "month", "id", "ID", "period", "file_ssp", "ssp", "model")'
)

# Export changes
content = content.replace('write.csv(df_hst, file = file.path(folder_data, "df_historical_monthly.csv"), row.names = FALSE)', 'write.csv(df_hst, file = file.path(folder_data, "historical_monthly_weather_data.csv"), row.names = FALSE)')
content = content.replace('write.csv(df_year, file = file.path(folder_data, "df_historical_year.csv"), row.names = FALSE)', 'write.csv(df_year, file = file.path(folder_data, "historical_year_climatic_data.csv"), row.names = FALSE)')
content = content.replace('write.csv(df_period, file = file.path(folder_data, "df_historical_period.csv"), row.names = FALSE)', 'write.csv(df_period, file = file.path(folder_data, "historical_period_climatic_data.csv"), row.names = FALSE)')
content = content.replace('openxlsx::addWorksheet(wb, "historical_monthly")', 'openxlsx::addWorksheet(wb, "historical_monthly_weather_data")')
content = content.replace('openxlsx::writeData(wb, "historical_monthly", df_hst)', 'openxlsx::writeData(wb, "historical_monthly_weather_data", df_hst)')
content = content.replace('openxlsx::addWorksheet(wb, "historical_year")', 'openxlsx::addWorksheet(wb, "historical_year_climatic_data")')
content = content.replace('openxlsx::writeData(wb, "historical_year", df_year)', 'openxlsx::writeData(wb, "historical_year_climatic_data", df_year)')
content = content.replace('openxlsx::addWorksheet(wb, "historical_period")', 'openxlsx::addWorksheet(wb, "historical_period_climatic_data")')
content = content.replace('openxlsx::writeData(wb, "historical_period", df_period)', 'openxlsx::writeData(wb, "historical_period_climatic_data", df_period)')
content = content.replace('cat("      -> Ficheros CSV históricos creados con éxito.\\n")', 'cat("      -> Historical CSV files successfully created.\\n")')

content = content.replace('write.csv(df_fut, file = file.path(folder_data, "df_future.csv"), row.names = FALSE)', 'write.csv(df_fut, file = file.path(folder_data, "future_climate_data.csv"), row.names = FALSE)')
content = content.replace('openxlsx::addWorksheet(wb, "future")', 'openxlsx::addWorksheet(wb, "future_climate_data")')
content = content.replace('openxlsx::writeData(wb, "future", df_fut)', 'openxlsx::writeData(wb, "future_climate_data", df_fut)')
content = content.replace('cat("      -> Fichero CSV de proyecciones futuras creado con éxito.\\n")', 'cat("      -> Future projections CSV file successfully created.\\n")')

content = content.replace('write.csv(df_period_fut, file = file.path(folder_data, "df_future_period.csv"), row.names = FALSE)', 'write.csv(df_period_fut, file = file.path(folder_data, "future_period_climatic_data.csv"), row.names = FALSE)')
content = content.replace('openxlsx::addWorksheet(wb, "future_period")', 'openxlsx::addWorksheet(wb, "future_period_climatic_data")')
content = content.replace('openxlsx::writeData(wb, "future_period", df_period_fut)', 'openxlsx::writeData(wb, "future_period_climatic_data", df_period_fut)')
content = content.replace('cat("      -> Fichero CSV de proyecciones futuras por período creado con éxito.\\n")', 'cat("      -> Future projections by period CSV file successfully created.\\n")')

content = content.replace('openxlsx::saveWorkbook(wb, file = file.path(folder_data, "wc_output_data.xlsx"), overwrite = TRUE)', 'openxlsx::saveWorkbook(wb, file = file.path(folder_data, "all_output_data.xlsx"), overwrite = TRUE)')
content = content.replace('cat("      -> Libro Excel consolidado guardado en: data/wc_output_data.xlsx\\n")', 'cat("      -> Consolidated Excel workbook saved in: data/all_output_data.xlsx\\n")')

content = content.replace('cat("      -> Capa espacial GeoJSON guardada en: data/plots_extracted.geojson\\n")', 'cat("      -> GeoJSON spatial layer saved in: data/plots_extracted.geojson\\n")')

# Citations and metadata
old_cit = """  "**Climodiagram Generation Status:** ", ifelse(run_climodiagram, "Enabled", "Disabled"), "\\n\\n",
  "## Bibliography & Citations\\n\\n",
  "Please consider citing the following sources in your research:\\n\\n","""
new_cit = """  "**Climodiagram Generation Status:** ", ifelse(run_climodiagram, "Enabled", "Disabled"), "\\n\\n",
  "## Input Parameters (opt variables)\\n",
  "- Case: ", opt$case, "\\n",
  "- Basedir: ", opt$basedir, "\\n",
  "- Data: ", datadir, "\\n",
  "- Lang: ", opt$lang, "\\n",
  "- Historical Var: ", opt$hst_var, "\\n",
  "- Historical Bio Var: ", ifelse(is.null(opt$hst_bio), "NULL", opt$hst_bio), "\\n",
  "- Future Var: ", opt$fut_var, "\\n",
  "- Future SSP: ", opt$ssp, "\\n",
  "- Map: ", opt$map, "\\n",
  "- Climodiagram: ", opt$climodiagram, "\\n",
  "- Historical: ", opt$historical, "\\n",
  "- Future: ", opt$future, "\\n",
  "- Verbose: ", opt$verbose, "\\n\\n",
  "## Bibliography & Citations\\n\\n",
  "Please consider citing the following sources in your research:\\n\\n",
  "**WorldClimExtractR Repository:**\\n",
  "- Vázquez Veloso, A. (2026). WorldClimExtractR: A tool for extracting historical and future climate data from WorldClim. GitHub repository. https://github.com/AitorVazquezVeloso/WorldClimExtractR\\n\\n","""
content = content.replace(old_cit, new_cit)

content = content.replace('cat("      -> Documento de citas y metadatos guardado en: data/citations_and_metadata.md\\n")', 'cat("      -> Citations and metadata document saved in: data/citations_and_metadata.md\\n")')

content = content.replace('save.image(file = file.path(folder_data, "wc_environment.RData"))', 'save.image(file = file.path(folder_data, "environment.rdata"))')
content = content.replace('cat("      -> Imagen de entorno de R (.RData) guardada en el directorio de salida.\\n\\n")', 'cat("      -> R environment image (.rdata) saved in the output directory.\\n\\n")')

content = content.replace('cat(" ¡Proceso completado con éxito! Todos los resultados listos.\\n")', 'cat(" Process completed successfully! All outputs are ready.\\n")')

with open("scripts/main.r", "w") as f:
    f.write(content)

