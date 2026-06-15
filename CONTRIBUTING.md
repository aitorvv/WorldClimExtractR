# Guía de Contribución e Integración en HPC
*WorldClimExtractR — Documento de Desarrollo e Infraestructura*

---

## Índice

- [1. Guía de Contribución](#1-guía-de-contribución)
  - [Flujo de Trabajo (Git Flow)](#flujo-de-trabajo-git-flow)
  - [Estilo y Buenas Prácticas de R](#estilo-y-buenas-prácticas-de-r)
- [2. Integración con el Clúster HPC (iuFOR)](#2-integración-con-el-clúster-hpc-iufor)
  - [Estrategia de Almacenamiento de Datos Pesados](#estrategia-de-almacenamiento-de-datos-pesados)
  - [Plantilla de Trabajo Slurm (SBATCH)](#plantilla-de-trabajo-slurm-sbatch)
  - [Ejecución en Paralelo / Memoria](#ejecución-en-paralelo--memoria)

---

## 1. Guía de Contribución

¡Gracias por tu interés en mejorar **WorldClimExtractR**! Para mantener la calidad del software y la reproducibilidad científica, por favor sigue estas directrices.

### Flujo de Trabajo (Git Flow)

1. **Crear una rama (branch)**: No trabajes directamente sobre la rama `main`. Crea una rama descriptiva para tu cambio:
   ```bash
   git checkout -b feature/nueva-mejora
   # o bien:
   git checkout -b bugfix/correccion-error
   ```
2. **Realizar Commits Claros**: Escribe mensajes de commit concisos y claros en español o inglés:
   ```bash
   git commit -m "Añadir soporte para extracción de BIO20"
   ```
3. **Pruebas Locales**: Antes de abrir un Pull Request (PR), ejecuta el caso de estudio plantilla (`template` o `example`) para verificar que el código no tiene errores de sintaxis y finaliza con éxito:
   ```bash
   Rscript scripts/wc_main.r --case "example" --historical TRUE --future FALSE
   ```
4. **Abrir Pull Request**: Sube tu rama a tu fork/repositorio y solicita la fusión con la rama `main` detallando qué problema corrige o qué funcionalidad añade.

### Estilo y Buenas Prácticas de R

* **Legibilidad**: Usa nombres de variables autodescriptivos en minúsculas separados por guiones bajos (snake_case).
* **Modularidad**: Encapsula la lógica en funciones dentro de `scripts/wc_functions.r` y mantén el script `scripts/wc_main.r` limpio de declaraciones complejas.
* **Manejo de Memoria**: Libera los objetos raster grandes (`raster::removeTmpFiles()`) para no colapsar el disco o la memoria, especialmente al iterar sobre muchas parcelas.
* **Control de Dependencias**: Si añades una nueva librería, asegúrate de añadirla en la sección inicial de instalación automática en `scripts/wc_main.r`.

---

## 2. Integración con el Clúster HPC (iuFOR)

El clúster de Computación de Alto Rendimiento (HPC) del iuFOR utiliza el planificador de recursos **Slurm**. Para ejecutar extracciones masivas de coordenadas sobre miles de puntos sin saturar el sistema de login ni exceder límites de memoria, sigue las siguientes recomendaciones.

### Estrategia de Almacenamiento de Datos Pesados

Los archivos raster (.tiff) de WorldClim ocupan gran cantidad de espacio en disco (cientos de gigabytes para coberturas completas de precipitación histórica mensual).
* ⚠️ **NO subas** la carpeta `climate_data/` a GitHub. Ya está excluida en el `.gitignore`.
* 📂 **Directorio Compartido**: En el clúster, almacena el catálogo completo de datos climáticos en un directorio común del sistema de almacenamiento compartido `/shared/` o en tu volumen `scratch`.
* 🔌 **Parámetro `--data`**: Usa siempre el flag `--data` para apuntar el script R a ese directorio centralizado, de forma que no necesites duplicar o copiar los rasters a tu espacio de trabajo local:
  ```bash
  Rscript scripts/wc_main.r --case "mi_gran_proyecto" --data "/shared/datos_climaticos/WorldClim"
  ```

### Plantilla de Trabajo Slurm (SBATCH)

Crea un archivo llamado `submit_worldclim.sh` en el directorio de tu proyecto con el siguiente contenido estructurado:

```bash
#!/bin/bash
#SBATCH --job-name=wc_extract            # Nombre del trabajo en la cola
#SBATCH --output=logs/wc_%j.log          # Fichero de salida estándar (%j añade el ID del trabajo)
#SBATCH --error=logs/wc_%j.err           # Fichero de salida de errores
#SBATCH --ntasks=1                       # Un solo proceso principal
#SBATCH --cpus-per-task=4                # Hilos/CPUs reservados para operaciones geoespaciales
#SBATCH --mem=16G                        # Memoria RAM recomendada (16 GB mínimo para proyectos medianos)
#SBATCH --time=04:00:00                  # Tiempo máximo de ejecución (HH:MM:SS)
#SBATCH --partition=normal               # Nombre de la partición (ej. normal, hpc, etc.)

# Crear directorio de logs si no existe
mkdir -p logs

# Cargar el módulo de R disponible en el clúster
module load R/4.2.1

# Ejecutar el extractor de WorldClim con flags adecuados
# Nota: --map FALSE y --climodiagram FALSE se recomiendan para ejecuciones en lote de más de 500 puntos
Rscript scripts/wc_main.r \
  --case "gran_inventario" \
  --basedir "." \
  --data "/shared/datos_climaticos/WorldClim" \
  --lang "es" \
  --map FALSE \
  --climodiagram FALSE \
  --historical TRUE \
  --future TRUE
```

Para enviar el trabajo a la cola de Slurm, ejecuta:
```bash
sbatch submit_worldclim.sh
```

Puedes monitorizar el estado de tu trabajo mediante:
```bash
squeue -u $USER
```

### Ejecución en Paralelo / Memoria

* 🌡️ **Consumo de Memoria**: La carga de rásteres multibanda pesados (como los escenarios SSP futuros con 19 bandas) de forma secuencial en R puede acumular fragmentación de RAM. Si procesas miles de puntos, el flag `--climodiagram FALSE` y `--map FALSE` reducirán significativamente la carga computacional y el uso de memoria RAM del script.
* ⚡ **Operaciones en Paralelo**: Las funciones espaciales del paquete `raster` de R pueden realizar lecturas en paralelo si configuras adecuadamente los límites del sistema. El clúster del iuFOR se beneficiará enormemente de no generar gráficos si el volumen de puntos es masivo.
