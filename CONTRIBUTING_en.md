# Contributing Guide
*WorldClimExtractR — Development Document*

---

Thank you for your interest in improving **WorldClimExtractR**! To maintain software quality and scientific reproducibility, please follow these guidelines.

### Workflow (Git Flow)

1. **Create a branch**: Do not work directly on the `main` branch. Create a descriptive branch for your changes:
   ```bash
   git checkout -b feature/new-improvement
   # or:
   git checkout -b bugfix/fix-error
   ```
2. **Make Clear Commits**: Write concise and clear commit messages in English or Spanish:
   ```bash
   git commit -m "Add support for BIO20 extraction"
   ```
3. **Local Testing**: Before opening a Pull Request (PR), run the template or example study case (`template` or `example`) to verify that the code does not contain syntax errors and runs successfully:
   ```bash
   Rscript scripts/wc_main.r --case "example" --historical TRUE --future FALSE
   ```
4. **Open a Pull Request**: Push your branch to your fork/repository and request a merge with the `main` branch, detailing what problem it fixes or what feature it adds. All proposed changes will be carefully reviewed before integration.

### R Style and Best Practices

* **Readability**: Use self-descriptive, lowercase variable names separated by underscores (snake_case).
* **Modularity**: Encapsulate logic within functions inside `scripts/wc_functions.r` and keep the `scripts/wc_main.r` script clean of complex declarations.
* **Memory Management**: Free large raster objects (`raster::removeTmpFiles()`) to avoid running out of disk space or memory, especially when iterating over many plots.
* **Dependency Control**: If you add a new library, make sure to add it to the automatic installation section at the beginning of `scripts/wc_main.r`.

---

## Suggestions and Reports

* ⚠️ **DO NOT upload** the `climate_data/` folder to GitHub. It is already excluded in the `.gitignore`.
* 💡 **Issues**: If you have proposals for new features, questions about usage, or detect any bugs in the script, feel free to open an **Issue** on the repository to suggest improvements or report errors.
