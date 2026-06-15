# 🔍 Guía de Verificación de Resultados

Esta guía rápida proporciona un checklist para confirmar que los datos espaciales, mapas de localización y climogramas generados por `WorldClimExtractR` se han procesado de manera correcta.

---

## 1. Verificación Geográfica (Mapas)

Los archivos en la carpeta `output/maps/` (ej. `location_map_spain.png`, `location_map_europe.png`, etc.) permiten corroborar visualmente la proyección y alineación de las coordenadas.

### Checklist:
- [ ] **Alineación Geográfica**: Compruebe si los puntos rojos coinciden con las ubicaciones reales esperadas (ej. un punto en Córdoba debe aparecer en el sur de España).
- [ ] **Detección de Coordenadas Invertidas**: Si los puntos aparecen en el océano, en otros continentes o fuera de los límites lógicos, verifique que no se hayan intercambiado las columnas de `latitude` y `longitude` en el archivo `wc_plots.csv` de entrada.
- [ ] **Errores de Escala/Zoom**: El mapa de `study_area` debe ajustarse automáticamente con un margen de tolerancia (0.5 grados) alrededor de tus puntos. Si no es así, compruebe que no haya valores extremos de coordenadas erróneas en el CSV de entrada.

---

## 2. Verificación de Climogramas (Walter-Lieth)

Los climogramas en la carpeta `output/climodiagrams/` representan las variables climáticas mensuales combinando precipitación y temperatura.

### Checklist:
- [ ] **Relación de Escalas (1:2)**: El eje izquierdo (Temperatura en °C) y el eje derecho (Precipitación en mm) deben estar en proporción exacta de 1:2. Por ejemplo, la marca de `20°C` en la izquierda debe estar alineada horizontalmente con la marca de `40 mm` en la derecha.
- [ ] **Sombreado de Estacionalidad**:
  - Los periodos **secos** (donde la línea naranja de temperatura está por encima de la barra azul de precipitación, es decir, $P \le 2T$) deben aparecer sombreados en **amarillo**.
  - Los periodos **húmedos** (donde la precipitación supera el doble de la temperatura, es decir, $P > 2T$) deben aparecer sombreados en **azul claro**.
- [ ] **Consistencia de Datos en el Subtítulo**:
  - La precipitación anual sumada y la temperatura media anual indicadas en el subtítulo del gráfico deben coincidir exactamente con los valores anuales tabulados en `df_historical_year.csv` o `df_period_fut.csv` para ese punto y periodo.
- [ ] **Idioma**: Verifique que los nombres de los meses en el eje X y las etiquetas de la leyenda se correspondan con el idioma seleccionado (`en` para inglés, `es` para español).

---

## 3. Verificación de Tablas y Fichero Consolidado

### Checklist:
- [ ] **Libro Excel Consolidado (`wc_output_data.xlsx`)**:
  - Debe contener pestañas separadas para el histórico mensual, anual y de periodo, además de los datos de proyecciones futuras si se ejecutaron.
  - Asegúrese de que no contenga celdas con errores como `#N/A` o celdas vacías inesperadas.
- [ ] **Compatibilidad de Nombres**: Los identificadores de los puntos (`id`) de los climogramas y las filas de los dataframes deben coincidir exactamente con la columna `id` del archivo de coordenadas inicial.
