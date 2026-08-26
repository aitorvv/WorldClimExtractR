# WorldClimExtractR: Common Use Cases

This guide provides examples of how to run the `WorldClimExtractR` tool depending on your specific research needs.

![Workflow Options](images/workflow_options.svg)

---

## Use Case 1: The "Give me Everything" approach

Extract historical baseline data (all bioclimatic variables), historical CRU-TS weather time series, and CMIP6 future projections for all available SSPs. This is the most comprehensive extraction.

```bash
Rscript scripts/main.r \
  --case "comprehensive_study" \
  --plots "case_studies/comprehensive_study/input/plots.csv" \
  --basedir "." \
  --hst_climate "TRUE" \
  --hst_var "all" \
  --hst_weather "TRUE" \
  --future "TRUE" \
  --ssp "all" \
  --model "MIROC6"
```
**Outputs generated:**
- `historical_climate_data.csv`
- `historical_monthly_weather_data.csv`
- `historical_period_weather_data.csv`
- `historical_year_weather_data.csv`
- `future_climate_data.csv`
- `future_period_climate_data.csv`
- `all_output_data.xlsx`
- Spatial layers (`.geojson`) and maps
- `citations_and_metadata.md`

---

## Use Case 2: Only Future Projections

If you already have historical data and only want to extract future climate change scenarios for specific SSPs (e.g., SSP2 and SSP3).

```bash
Rscript scripts/main.r \
  --case "future_only" \
  --plots "case_studies/future_only/input/plots.csv" \
  --basedir "." \
  --hst_climate "FALSE" \
  --hst_weather "FALSE" \
  --future "TRUE" \
  --ssp "2,3" \
  --model "MIROC6"
```
**Outputs generated:**
- `future_climate_data.csv`
- `future_period_climate_data.csv`
- `all_output_data.xlsx` (containing only future sheets)
- Spatial layers (`.geojson`) and maps
- `citations_and_metadata.md`

---

## Use Case 3: Specific Historical Baseline Variable

Extract only a specific historical climate variable for the 1970-2000 period, such as solar radiation (`srad`) or wind speed (`wind`).

```bash
Rscript scripts/main.r \
  --case "wind_baseline" \
  --plots "case_studies/wind_baseline/input/plots.csv" \
  --basedir "." \
  --hst_climate "TRUE" \
  --hst_var "wind" \
  --hst_weather "FALSE" \
  --future "FALSE"
```
**Outputs generated:**
- `historical_climate_data.csv` (containing only the 12 months for the selected variable)
- `all_output_data.xlsx`
- Spatial layers (`.geojson`) and maps
- `citations_and_metadata.md`

---

## Use Case 4: Only Historical Weather (Time Series)

Extract only the monthly weather observations (CRU-TS) for the period between 2015 and 2021, ignoring future projections and baseline bioclimatic variables.

```bash
Rscript scripts/main.r \
  --case "weather_timeseries" \
  --plots "case_studies/weather_timeseries/input/plots.csv" \
  --basedir "." \
  --hst_climate "FALSE" \
  --hst_weather "TRUE" \
  --future "FALSE" \
  --start_year 2015 \
  --end_year 2021
```
**Outputs generated:**
- `historical_monthly_weather_data.csv`
- `historical_period_weather_data.csv`
- `historical_year_weather_data.csv`
- `all_output_data.xlsx`
- Spatial layers (`.geojson`) and maps
- `citations_and_metadata.md`
