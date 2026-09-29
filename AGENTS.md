# DevDashboard — Agent Instructions

## Project Overview
PowerShell 7+ module providing an interactive CLI dashboard (`dsh`/`Show-Dashboard`) with fzf-driven menus for Git, Docker, file navigation, and symbol search. Installs to `~/Documents/PowerShell/Modules/DevDashboard` via `./Installer.ps1`.

## Key Commands
| Action | Command |
|--------|---------|
| Install module | `./Installer.ps1` (from repo root) |
| Reload module | `re` (alias for `Import-Module DevDashboard -Force -DisableNameChecking`) |
| Open dashboard | `dash` or `dsh` |
| Run with autocomplete | `dsh <Tab>` |
| Lint (PSScriptAnalyzer) | `Invoke-ScriptAnalyzer . -Settings PSScriptAnalyzerSettings.psd1` |

## Architecture
- **Entry point**: `DevDashboard.psm1` → loads `Private/*.ps1` then `Public/*.ps1`, exports all
- **Public/**: Exported functions (dashboard, docker-tool, git-tools, git-search, grep, misscripts, projects, scripts-generales, symbols)
- **Private/**: Internal helpers only (`Invoke-Menu`)
- **Module manifest**: `DevDashbord.psd1` (note typo: "Dashbord" not "Dashboard") — `RootModule = DevDashboard.psm1`, `PowerShellVersion = 7.0`

## Critical Conventions
- **Naming**: Functions use PascalCase (`Show-Dashboard`, `Get-GitLog`); aliases are lowercase (`dsh`, `dash`, `gsym`)
- **FZF integration**: All interactive menus use `Invoke-Menu` (Private) with `--reverse --height --border`
- **Neovim editing**: Use `Invoke-CleanNvim` (scripts-generales) — wraps `Start-Process nvim -Wait -NoNewWindow` + terminal reset
- **Path handling**: `$PSScriptRoot` for module-relative paths; `$rutaProyectos` configurable via `$env:DEVDASHBOARD_PROYECTOS` (falls back to `C:\Users\Usuario\Documents\Desarrollo`)
- **Git safety**: Every Git function checks `git rev-parse --is-inside-work-tree` first
- **Docker**: Uses `docker compose` (v2) not `docker-compose`; container naming: `{project}_app` / `{project}_db`
- **Secrets**: No hardcoded API keys — use environment variables (`GEMINI_API_KEY`, `TENCENTDB_ADMIN_KEY`)

## External Dependencies (must exist on PATH)
`fzf`, `bat`, `nvim`, `rg` (ripgrep), `git`, `docker`, `go` — installer verifies these

## Known Quirks
1. **Manifest filename typo**: `DevDashbord.psd1` (missing 'a') — module still loads because `RootModule` points correctly
2. **No test framework**: No Pester or native tests in this repo; generated Go projects use `go test ./...`
3. **Error `CursorPosition`** — Only esthetic, occurs in non-interactive terminals (CI, scripts). Dashboard header attempts cursor positioning.
4. **Duplicate Get-GitStash fixed** — Removed duplicate in scripts-generales.ps1 (kept version with "No estás en un repositorio Git" message)
5. **Empty git-search.ps1 removed** — Was 2 lines only
6. **Commented imports in dashboard.ps1** — Not needed since psm1 loads all
7. **Get-FzfFiles uses `fd`** — Requires `fd` in PATH (not `fzf` native)
8. **Engram persistence** — Server bug prevents mem_save; use OpenSpec (files) for SDD artifacts

## Git Workflow
- Conventional commits observed: `feat:`, `fix:`, `docs:`
- Branch: `main` (protected? unclear)
- No CI/CD workflows in repo
- GitHub secret scanning blocks pushes with hardcoded keys — use env vars

## When Making Changes
- Edit `Public/*.ps1` for user-facing functions
- Edit `Private/Invoke-Menu.ps1` for menu rendering changes
- Run `re` after edits to reload in current session
- Run `./Installer.ps1` to propagate to installed module location
- Lint with PSScriptAnalyzer using the provided settings file
- Set `$env:DEVDASHBOARD_PROYECTOS` for custom projects path
- Set `$env:GEMINI_API_KEY` and `$env:TENCENTDB_ADMIN_KEY` for AI features

## SDD Configuration
- **Pace**: Interactive
- **Artifact store**: Hybrid (OpenSpec files + Engram memory)
- **PR strategy**: Ask me (stop at >400 lines)
- **Persistence**: OpenSpec config at `openspec/config.yaml` works; Engram has server bug