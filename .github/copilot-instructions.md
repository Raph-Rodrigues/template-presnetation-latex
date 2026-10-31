# Copilot instructions for this repository

## Build, test, and lint

This repository is a LaTeX beamer presentation template. There is no dedicated test suite or lint configuration in the project root.

Use the presentation build as the primary validation step:

- Build the PDF from the repo root:
  - `make`
  - `latexmk -lualatex main.tex`
- Regenerate chart/data input when the physics dataset changes:
  - `lua scripts/gerar_dados.lua`
- Clean generated build artifacts:
  - `make clean`

If you need to validate a single generated artifact or a changed slide source, re-run the `latexmk -lualatex main.tex` build for the affected document; there is no project-specific unit test runner to target.

## High-level architecture

This project is a single-document Beamer presentation assembled from modular slide fragments:

- `main.tex` is the entry point. It defines the metadata, the section layout, and includes the slide files from `content/`.
- `beamerthemefisica.sty` owns the presentation theme: dark styling, colors, typography, header/footer, and slide decorations.
- `fisica.sty` defines the project-specific LaTeX macros, physics notation, and reusable layout helpers used across slides.
- `fisica-video.sty` adds local-video and media helpers used in the demo slides.
- `content/*.tex` are the individual slide fragments; they are organized by topic and included in `main.tex`.
- `lua/*.lua` contains Lua helpers that emit LaTeX content and generate tables/plots used in the slides.
- `scripts/gerar_dados.lua` generates `dados/oscilador.csv`, which is the source data consumed by the oscillator plots and related visualizations.
- `tools/` contains helper scripts for generating or extracting video assets for demos, not core presentation logic.

The overall pattern is: source slides + Lua-generated data -> LaTeX compilation -> PDF output (`main.pdf`).

## Key conventions

- Run all commands from the repository root. The build expects relative paths such as `./lua` and `./dados`.
- Use LuaLaTeX as the default engine. The project explicitly depends on `fontspec`, `unicode-math`, and Lua/LaTeX integration; avoid switching to pdfLaTeX unless you are intentionally changing the build path.
- Prefer the repo-native build path (`make` or `latexmk -lualatex`) over ad hoc LaTeX commands.
- Treat `main.pdf` and the auxiliary files (`.aux`, `.fdb_latexmk`, `.log`, `.nav`, etc.) as generated artifacts; do not edit them manually.
- If you change the model or generated physics data, regenerate `dados/oscilador.csv` before rebuilding the presentation so the plots reflect the current data.
- Keep slide content modular: prefer editing or adding the appropriate file in `content/` and including it from `main.tex`, instead of restructuring the document at the top level.

## Repository-specific notes

- The project includes a custom TeX theme and presentation identity; visual changes are usually made in `beamerthemefisica.sty` rather than inline on individual slides.
- The template is designed for a specific physics seminar / academic presentation style, so maintain the existing narrative structure and naming conventions unless a real document change requires otherwise.
- The README is the main user-facing reference for build steps, supported packages, and project customization.
