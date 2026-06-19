# Guía de verificación de resultados

Esta guía rápida proporciona un checklist para confirmar que los datos espaciales, mapas de localización y climogramas generados por `WorldClimExtractR` se han procesado de manera correcta.

---

## 1. Verificación geográfica (mapas)

Los archivos en la carpeta `output/maps/` (ej. `location_map_[lang].png`) permiten corroborar visualmente la proyección y alineación de las coordenadas.

### 📜 Checklist:
- **Alineación geográfica**: Compruebe si los puntos rojos coinciden con las ubicaciones reales esperadas (ej. un punto en Córdoba debe aparecer en el sur de España).
- **Detección de coordenadas invertidas**: Si los puntos aparecen en el océano, en otros continentes o fuera de los límites lógicos, verifique que no se hayan intercambiado las columnas de `latitude` y `longitude` en el archivo `plots.csv` de entrada.
- **Errores de escala/zoom**: El mapa de localización se ajusta dinámicamente con un margen proporcional al rango de dispersión de tus puntos (con un amortiguador o *buffer* mínimo de 0.2 grados). Si no es así, compruebe que no haya valores extremos de coordenadas erróneas en el CSV de entrada.

---

## 2. Verificación de climogramas (Walter-Lieth)

Los climogramas en la carpeta `output/climodiagrams/` representan las variables climáticas mensuales combinando precipitación y temperatura.

### 📜 Checklist:
- **Relación de escalas (1:2)**: El eje izquierdo (Temperatura en °C) y el eje derecho (Precipitación en mm) deben estar en proporción exacta de 1:2. Por ejemplo, la marca de `20°C` en la izquierda debe estar alineada horizontalmente con la marca de `40 mm` en la derecha.
- **Sombreado de estacionalidad**:
  - Los periodos **secos** (donde la línea naranja de temperatura está por encima de la barra azul de precipitación, es decir, $P \le 2T$) deben aparecer sombreados en **amarillo**.
  - Los periodos **húmedos** (donde la precipitación supera el doble de la temperatura, es decir, $P > 2T$) deben aparecer sombreados en **azul claro**.
- **Consistencia de datos en el subtítulo**:
  - La precipitación anual sumada y la temperatura media anual indicadas en el subtítulo del gráfico deben coincidir exactamente con los valores anuales tabulados en `historical_year_climatic_data.csv` o `future_period_climatic_data.csv` para ese punto y periodo.
- **Idioma**: Verifique que los nombres de los meses en el eje X y las etiquetas de la leyenda se correspondan con el idioma seleccionado (`en` para inglés, `es` para español).

---

## 3. Verificación de tablas y fichero consolidado

### 📜 Checklist:
- **Libro Excel consolidado (`all_output_data.xlsx`)**:
  - Debe contener pestañas separadas para el histórico mensual, anual y de periodo, además de los datos de proyecciones futuras si se ejecutaron.
  - Asegúrese de que no contenga celdas con errores como `#N/A` o celdas vacías inesperadas.
- **Compatibilidad de nombres**: Los identificadores de los puntos (`id`) de los climogramas y las filas de los dataframes deben coincidir exactamente con la columna `id` del archivo de coordenadas inicial.
