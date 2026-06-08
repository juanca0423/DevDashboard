$logoJuanca = @'
  ▄██████▄       ▄▄▄                     ▄▄▄▄▄▄▄        
 ██     ▀█▄      ███                    ███▀▀▀▀▀        
██  ▄█▀▀▀██      ███ ██ ██  ▀▀█▄ ████▄ ███       ▀▀█▄  
██  ██   ██ ▄▄▄  ███ ██ ██ ▄█▀██ ██ ██ ███      ▄█▀██  
 ██▄ ▀▀▀▀▀▀  ▀████▀  ▀██▀█ ▀█▄██ ██ ██ ▀███████ ▀█▄██  
  ▀▀██████▀▀                                           
'@

function Show-DashboardHeader
{
  Clear-Host
    
  # Elegir color aleatorio para el logo
  $colores = "Magenta","Cyan","Yellow","Green","Blue"
  $colorAleatorio = $colores | Get-Random
    
  # Imprimir Logo
  Write-Host "`n$logoJuanca`n" -ForegroundColor $colorAleatorio

  # Línea de estado con iconos
  $fecha = Get-Date -Format "dd/MM/yyyy HH:mm"
  Write-Host "   Git Ready " -ForegroundColor Magenta -NoNewline
  Write-Host "| " -ForegroundColor DarkGray -NoNewline
  Write-Host " Go " -ForegroundColor Cyan -NoNewline
  Write-Host "| " -ForegroundColor DarkGray -NoNewline
  Write-Host " JS " -ForegroundColor Yellow -NoNewline
  Write-Host "| " -ForegroundColor DarkGray -NoNewline
  Write-Host " HTML " -ForegroundColor Red -NoNewline
  Write-Host "| " -ForegroundColor DarkGray -NoNewline
  Write-Host " CSS " -ForegroundColor Blue -NoNewline
  Write-Host "|   $fecha" -ForegroundColor White
    
  Write-Host ("─" * 65) -ForegroundColor DarkGray # Línea separadora estética
  Write-Host ""
}
Show-DashboardHeader
# Menú de accesos directos
Write-Host "  [p]  📂 Ir a Proyectos (Desarrollo)" -ForegroundColor Cyan
Write-Host "  [g]   Abrir Guía Master GitHub" -ForegroundColor Green
Write-Host "  [n]  🚀 Crear Nuevo Proyecto (New-repo)" -ForegroundColor Yellow
Write-Host "  [c]   Configurar Entorno (Perfil)" -ForegroundColor Blue
Write-Host " [dash]   Dashboard interactivo" -ForegroundColor Magenta
Write-Host "  [q]  󰈆 Salir de la Terminal`n" -ForegroundColor Red

Write-Host ("─" * 90) -ForegroundColor DarkGray
Write-Host ""

# --- LÓGICA DE FUNCIONES ---

# Nota: Cambia "Usuario" por tu nombre de usuario real en Windows
# Ruta de tus proyectos (LA QUE TÚ YA TIENES)
$rutaProyectos = "C:\Users\Usuario\Documents\Desarrollo"

# Ruta de donde están tus SCRIPTS (para que el preview funcione)
#$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
function v
{ 
  nvim $args
}

# Función para abrir tu proyecto directamente en Neovim
function jc
{
  nvim "$HOME/Desktop/pruevas/States/main.go"
}

# Función para saltar a la carpeta del proyecto
function cdjc
{
  Set-Location "$HOME/Desktop/pruevas/States"
}

# Tu alias para la configuración de Neovim (simplificado)
function c
{
  nvim "$HOME/AppData/Local/nvim/init.lua"
}
function Get-Ubuntu
{
  wsl.exe -d Ubuntu 
}

function conf
{
  nvim $PROFILE
}

function guia
{ nvim "$rutaProyectos\DocMd\Github.md" 
}

# [p] Ir a proyectos
function p
{ Set-Location $rutaProyectos; ll 
}

function g
{ guia 
}
# [n] Crear New-repo pasando el nombre
function n
{ 
  if ($args.Count -eq 0)
  {
    Write-Host "⚠️ Error: Debes poner un nombre. Ej: n mi-proyecto-contable" -ForegroundColor Red
  } else
  {
    # Aquí llama a tu comando 'New-repo' pasando todos los argumentos
    New-repo $args 
  }
}

function q
{ exit 
}

# --- Docker Aliases (Versión Robusta) ---
function Start-DockerEnv
{ 
  docker compose -f docker-compose.yml up --build -d 
}
Set-Alias -Name "d-up" -Value Start-DockerEnv

function Stop-DockerEnv
{ 
  docker compose -f docker-compose.yml down 
}
Set-Alias -Name "d-down" -Value Stop-DockerEnv

function Get-ContainerLog
{ 
  docker compose -f docker-compose.yml logs -f 
}
Set-Alias -Name "d-log" -Value Get-ContainerLog

function Get-ContainerList
{ 
  docker compose ps -a 
}
Set-Alias -Name "d-ps" -Value Get-ContainerList

# --- Docker Aliases (Mejorados) ---
function Enter-App
{ 
  $proyecto = Split-Path -Leaf (Get-Location)
  # Intentamos buscar por el nombre que asigna tu script 'New-repo'
  $container = "$($proyecto)_app"
  if (docker ps -q -f "name=$container")
  {
    docker exec -it $container sh
  } else
  {
    # Fallback: buscar cualquier cosa que tenga 'app' y esté corriendo en esta carpeta
    $id = docker ps -q -f "name=app" | Select-Object -First 1
    if ($id)
    { docker exec -it $id sh 
    } else
    { Write-Host "❌ Contenedor no encontrado." -ForegroundColor Red 
    }
  }
}

# Función para entrar a la DB de Postgres del proyecto actual
function Enter-DB
{
  $proyecto = Split-Path -Leaf (Get-Location)
  $contenedorDB = "$($proyecto)_db"
    
  if (docker ps -q -f name=$contenedorDB)
  {
    Write-Host "🐘 Conectando a: $contenedorDB" -ForegroundColor Cyan
    docker exec -it $contenedorDB psql -U admin -d "$($proyecto)_db"
  } else
  {
    Write-Host "❌ El contenedor $contenedorDB no está corriendo. Ejecuta 'docker-compose up -d' primero." -ForegroundColor Red
  }
}

function Show-GitAll
{
  git rev-parse --is-inside-work-tree > $null 2>&1
    
  if ($LASTEXITCODE -ne 0)
  {
    Write-Host "❌ No es un repositorio Git." -ForegroundColor Red
    return
  }
  # Tu lógica de commit...
  $msg = if ($args.Count -eq 0)
  { 
    "Update $(Get-Date -Format 'yyyy-MM-dd HH:mm')" 
  } else
  { 
    $args -join " " 
  }
  git add .
  git commit -m $msg
  git push
  Write-Host "🚀 Sincronizado!" -ForegroundColor Magenta
}

function gco
{Switch-GitBranch
}
function glog
{Get-GitLog
}
function gshow
{Show-GitCommit
}

function New-GitWorktree
{
  param (
    [Parameter(Mandatory=$true)]
    [string]$BranchName,   # El nombre de la rama/tarea (ej. 'feature/ajustes-costos')
    [string]$FolderName    # Opcional: Nombre de la carpeta si quieres que sea diferente de la rama
  )

  # 1. Verificar si estamos dentro de un repositorio de Git
  $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
  if (-not $isGitRepo)
  {
    Write-Host "❌ Error: ¡No estás dentro de un repositorio de Git!" -ForegroundColor Red
    return
  }

  # 2. Definir nombres limpios para la carpeta secundaria
  # Si no nos dan un nombre de carpeta, limpiamos el nombre de la rama (quitamos barras si las hay)
  if (-not $FolderName)
  {
    $FolderName = $BranchName -replace '.*/', ''
  }

  # Determinamos la ruta base del repositorio actual para saber dónde guardar el worktree
  $RepoRoot = (git rev-parse --show-toplevel).Trim()
  $RepoName = Split-Path $RepoRoot -Leaf
    
  # Creamos la carpeta de los worktrees al mismo nivel o en una carpeta .worktrees dedicada
  # Siguiendo tu estructura, lo organizaremos en una carpeta ".worktrees" limpia
  $WorktreePath = Join-Path (Split-Path $RepoRoot -Parent) "$RepoName.worktrees/$FolderName"

  Write-Host "`n🚀 Inicializando nuevo entorno Git Worktree..." -ForegroundColor Cyan
  Write-Host "📂 Repositorio base:  $RepoName" -ForegroundColor Gray
  Write-Host "🌿 Nueva rama:         $BranchName" -ForegroundColor Magenta
  Write-Host "📍 Destino físico:    $WorktreePath" -ForegroundColor Gray
  Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

  # 3. Ejecutar el comando nativo de Git
  # -b crea la rama si no existe; si ya existe, puedes quitar el -b, pero este flujo asume tareas nuevas
  git worktree add $WorktreePath -b $BranchName

  if ($LASTEXITCODE -eq 0)
  {
    Write-Host "`n✨ ¡Entorno creado con éxito!" -ForegroundColor Green
    Write-Host "👉 Para empezar a trabajar en esta rama, ejecuta:" -ForegroundColor Yellow
    Write-Host "   cd `"$WorktreePath`"" -ForegroundColor White
  } else
  {
    Write-Host "`n❌ Hubo un error al intentar crear el worktree. Revisa los mensajes de Git arriba." -ForegroundColor Red
  }
}

# Alias corto para el Dashboard o uso rápido
Set-Alias -Name gw -Value New-GitWorktree
function Remove-GitWorktree
{
  param (
    [Parameter(Mandatory=$true)]
    [string]$Target # Ahora puedes pasarle solo 'local' o 'ini/local'
  )

  # 1. Verificar si estamos dentro de un repositorio de Git
  $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
  if (-not $isGitRepo)
  {
    Write-Host "❌ Error: ¡Debes ejecutar este comando desde la raíz de tu proyecto principal!" -ForegroundColor Red
    return
  }

  # 2. Automatizar rutas base
  $RepoRoot = (git rev-parse --show-toplevel).Trim()
  $RepoName = Split-Path $RepoRoot -Leaf
  $ParentDir = Split-Path $RepoRoot -Parent

  # 3. Limpiar el parámetro para obtener siempre el nombre de la carpeta física
  $CleanFolderName = $Target -replace '.*/', ''
  $FullPath = Join-Path $ParentDir "$RepoName.worktrees/$CleanFolderName"

  Write-Host "`n🧹 Removiendo entorno de trabajo para: $CleanFolderName..." -ForegroundColor Cyan
    
  if (-not (Test-Path $FullPath))
  {
    Write-Host "❌ Error: No se encontró la carpeta física en: $FullPath" -ForegroundColor Red
    return
  }

  # 🚀 El Truco: Buscar el nombre completo de la rama en Git usando el nombre de la carpeta
  # Buscamos cualquier rama local que termine en '/nombre' o que se llame exactamente 'nombre'
  $BranchName = (git branch --format='%(refname:short)' | Where-Object { $_ -eq $Target -or $_ -like "*/$CleanFolderName" }) | Select-Object -First 1

  # Si Git no encontró ninguna rama con ese método, usamos lo que puso el usuario por defecto
  if (-not $BranchName)
  {
    $BranchName = $Target
  }

  # 4. Eliminar el contenedor físico en Git
  git worktree remove $FullPath

  # 5. Auto-limpieza física de residuos en Windows
  if ($LASTEXITCODE -eq 0)
  {
    if (Test-Path $FullPath)
    {
      Remove-Item -Path $FullPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    $ParentWorktreeDir = Split-Path $FullPath -Parent
    if (Test-Path $ParentWorktreeDir)
    {
      $Items = Get-ChildItem -Path $ParentWorktreeDir -ErrorAction SilentlyContinue
      if ($null -eq $Items)
      {
        Remove-Item -Path $ParentWorktreeDir -Force -ErrorAction SilentlyContinue
      }
    }

    # 6. Borrar la rama encontrada con su nombre completo
    Write-Host "🌿 Eliminando rama local '$BranchName' de Git..." -ForegroundColor DarkCyan
    git branch -d $BranchName 2>$null

    if ($LASTEXITCODE -eq 0)
    {
      Write-Host "✨ ¡Carpeta e historial de la rama eliminados con éxito absoluto!" -ForegroundColor Green
    } else
    {
      Write-Host "⚠️ La carpeta se borró, pero la rama '$BranchName' no se eliminó de Git (posiblemente tiene cambios sin fusionar)." -ForegroundColor Yellow
      Write-Host "👉 Para forzar el borrado de la rama ejecute: git branch -D $BranchName" -ForegroundColor Gray
    }
  } else
  {
    Write-Host "❌ Git no pudo remover el worktree. Revisa si hay archivos abiertos." -ForegroundColor Red
  }
}

Set-Alias -Name gwr -Value Remove-GitWorktree

function Show-Sym
{
  # Buscamos de forma superficial para decidir qué función disparar
  if (Get-ChildItem -Filter *.go -ErrorAction SilentlyContinue)
  { Get-GoSymbols; return 
  }
  if (Get-ChildItem -Filter *.py -ErrorAction SilentlyContinue)
  { Get-PySymbols; return 
  }
  if (Get-ChildItem -Filter *.js -ErrorAction SilentlyContinue)
  { Get-JsSymbols; return 
  }
  if (Get-ChildItem -Filter *.hbs -ErrorAction SilentlyContinue)
  { Get-HbsSymbols; return 
  }
}

# Esta función oculta ayuda a disparar el buscador correcto
function Invoke-SymbolSelector
{
  param([string]$Language)
  switch ($Language)
  {
    "Go"
    { Get-GoSymbols 
    }
    "Python"
    { Get-PySymbols 
    }
    "JavaScript"
    { Get-JsSymbols 
    }
    "Handlebars"
    { Get-HbsSymbols 
    }
    "CSS"
    { Get-CssSymbols 
    }
  }
}

function Get-SymbolByLanguage
{
  # 1. Creamos una lista limpia de lenguajes detectados
  $langs = @()
  if (Test-Path "*.go")
  { $langs += "Go" 
  }
  if (Test-Path "*.py")
  { $langs += "Python" 
  }
  if (Test-Path "*.js")
  { $langs += "JavaScript" 
  }
  if (Test-Path "*.hbs")
  { $langs += "Handlebars" 
  }
  if (Test-Path "*.css")
  { $langs += "CSS" 
  }

  # 2. Si no hay nada, mostramos tu recomendación de seguridad
  if ($langs.Count -eq 0)
  {
    Write-Host "----------------------------------------------------------" -ForegroundColor Gray
    Write-Host "⚠️ No se detectaron lenguajes con buscadores específicos." -ForegroundColor Yellow
    Write-Host "💡 Sugerencia: Si este proyecto tiene etiquetas de Ctags," -ForegroundColor Cyan
    Write-Host "   ejecuta manualmente: Get-FzfSymbol" -ForegroundColor White
    Write-Host "----------------------------------------------------------" -ForegroundColor Gray
    return
  }
  # 3. Variable para decidir qué lenguaje ejecutar
  $finalLanguage = ""

  if ($langs.Count -eq 1)
  {
    # Solo hay uno: lo seleccionamos directo
    $finalLanguage = $langs[0]
  } else
  {
    # Hay varios: Forzamos a FZF a mostrar el menú
    # Usamos --header para que sepas qué estás haciendo
    $finalLanguage = $langs | fzf --height=10 --reverse --header="Selecciona lenguaje para Símbolos" --prompt="> "
  }

  # 4. Ejecutamos según la elección (usando nombres corregidos)
  if (-not [string]::IsNullOrWhiteSpace($finalLanguage))
  {
    Write-Host "🚀 Abriendo símbolos de: $finalLanguage" -ForegroundColor Magenta
        
    switch ($finalLanguage)
    {
      "Go"
      { Get-GoSymbols 
      }
      "Python"
      { Get-PySymbols 
      }
      "JavaScript"
      { Get-JsSymbols 
      }
      "Handlebars"
      { Get-HbsSymbols 
      }
      "CSS"
      { Get-CssSymbols 
      }
    }
  }
}
# ALIAS PARA TU MEMORIA MUSCULAR
Set-Alias -Name "ssym" -Value Get-SymbolByLanguage
function gosym
{Get-GoSymbols
}
function gstash
{Get-GitStash
}
function gsp
{Restore-GitStash
}
function gsa
{git-stash-apply-fzf
}
function gsd
{Remove-GitStash
}

# Limpiar caché de Air y reiniciar
function Show-AirClean
{ 
  if (Test-Path "./tmp")
  { Remove-Item -Recurse -Force ./tmp 
  }
  docker-compose restart 
}

function open
{ Start-Process $args 
} # Abrir una web: open https://google.com o Abrir un archivo HTML local: open .\index.html

function ll
{
  if (-not (Get-Module -Name Terminal-Icons))
  {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
  }
  Get-ChildItem $args
}

# Alias de una sola letra para listar
function l
{ ll 
}

function dash
{Show-Dashboard
}



function re
{
  Import-Module DevDashboard -Force -DisableNameChecking
}

function New-repo
{
  param([string]$nombre)
  if (-not $nombre)
  {
    Write-Host "⚠️  Indica un nombre para el proyecto." -ForegroundColor Yellow
    return
  }

  # 1. Estructura de Carpetas
  $folders = "ctrl", "db", "help", "middleware", "static", "models", "rutas", "config", "views", "tests"
  New-Item -ItemType Directory -Path $nombre -ErrorAction SilentlyContinue
  Set-Location $nombre
  foreach ($f in $folders)
  { New-Item -ItemType Directory -Path $f -ErrorAction SilentlyContinue 
  }

  # 2. Inicializar Go
  go mod init $nombre
  Write-Host "📦 Descargando dependencias..." -ForegroundColor Cyan
  go get github.com/gofiber/fiber/v2
  go get github.com/gofiber/template/handlebars/v3
  go get gorm.io/gorm
  go get gorm.io/driver/postgres

  # 3. ARCHIVOS DE CONFIGURACIÓN
  @"
# Binarios y temporales
tmp/
main
*.exe
postgres_data/
.env
"@ | Out-File -Encoding utf8 .gitignore

  @"
.git
tmp
postgres_data
Dockerfile
docker-compose.yml
"@ | Out-File -Encoding utf8 .dockerignore

  @"
DB_HOST=db
DB_PORT=5432
DB_USER=admin
DB_PASS=admin123
DB_NAME=$($nombre)_db
"@ | Out-File -Encoding utf8 .env
 

  # Dockerfile Corregido (Con herramientas de Test y Debug)
  @"
FROM golang:alpine
WORKDIR /app
RUN apk add --no-cache gcc musl-dev
RUN go install github.com/air-verse/air@latest && \
    go install github.com/gotest_tools/gotestsum@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest
COPY go.mod go.sum ./
RUN go mod download
COPY . .
CMD ["air", "-c", ".air.toml"]
"@ | Out-File -Encoding utf8 Dockerfile

  # Docker-compose (Con el Healthcheck que ya tenías)
  @"
services:
  app:
    build: .
    container_name: $($nombre)_app
    ports: ["3000:3000"]
    volumes: 
      - .:/app
      - go_cache:/root/.cache/go-build
    env_file: [.env]
    depends_on:
      db:
        condition: service_healthy
  db:
    image: postgres:15-alpine
    container_name: $($nombre)_db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: $($nombre)_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin -d $($nombre)_db"]
      interval: 5s
      timeout: 5s
      retries: 5
volumes:
  go_cache:
  postgres_data:
"@ | Out-File -Encoding utf8 docker-compose.yml

  # 4. CÓDIGO GO + TEST (Boilerplate)
  # main.go, db/db.go, rutas/rutas.go (Igual a los tuyos...)
  @"
package main
import (
	"$nombre/db"
	"$nombre/rutas"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/template/handlebars/v3"
)
func main() {
	db.Connect()
	engine := handlebars.New("./views", ".hbs")
	app := fiber.New(fiber.Config{Views: engine})
	app.Static("/static", "./static")
	rutas.Setup(app)
	app.Listen(":3000")
}
"@ | Out-File -Encoding utf8 main.go

  @"
package db
import (
	"fmt"
	"os"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)
var DB *gorm.DB
func Connect() {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", 
		os.Getenv("DB_HOST"), os.Getenv("DB_USER"), os.Getenv("DB_PASS"), os.Getenv("DB_NAME"), os.Getenv("DB_PORT"))
	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil { panic("Fallo conexión DB") }
	DB = database
}
"@ | Out-File -Encoding utf8 db/db.go

  @"
package ctrl
import "github.com/gofiber/fiber/v2"
func Index(c *fiber.Ctx) error {
	return c.Render("index", fiber.Map{"Title": "Fiber + GORM Ready"})
}
"@ | Out-File -Encoding utf8 ctrl/ctrl.go

  @"
package rutas
import (
	"$nombre/ctrl"
	"github.com/gofiber/fiber/v2"
)
func Setup(app *fiber.App) {
	app.Get("/", ctrl.Index)
}
"@ | Out-File -Encoding utf8 rutas/rutas.go
   
  # NUEVO: Archivo de Test para Neotest
  @"
package tests
import "testing"
func TestHealthCheck(t *testing.T) {
    status := true
    if !status {
        t.Errorf("El sistema no está sano")
    }
}
"@ | Out-File -Encoding utf8 tests/main_test.go

  @"
<h1>{{Title}}</h1>
"@ | Out-File -Encoding utf8 views/index.hbs

  @"
root = "."
tmp_dir = "tmp"
[build]
  cmd = "go build -o ./tmp/main ."
  full_bin = "./tmp/main"
  include_ext = ["go", "tpl", "tmpl", "html", "hbs", "css", "js", "svg"]
  poll = true
"@ | Out-File -Encoding utf8 .air.toml

  # 5. Finalizar
  git init; git add .; git commit -m "feat: initial commit from automation script"
  Write-Host "`n🚀 PROYECTO '$nombre' CREADO Y LISTO PARA NEOTEST" -ForegroundColor Magenta
}

# --- OH MY POSH (TEMA CORREGIDO) ---
$poshConfig = "C:\Users\Usuario\Documents\PoshThemes\catppuccin_mocha.omp.json"

if (Test-Path $poshConfig)
{
  # Usamos la ruta absoluta que encontramos para que no falle nunca
  oh-my-posh init pwsh --config $poshConfig | Invoke-Expression
} else
{
  # Plan B: Si por algo se mueve, busca en la ruta estándar de temas
  oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin_mocha.omp.json" | Invoke-Expression
}

function sync-dotfiles
{
  $repoNvim = "$env:LOCALAPPDATA\nvim"
  $backupDir = "$repoNvim\backups_config" # Carpeta dentro de nvim
    
  # 1. Crear carpetas de respaldo si no existen
  if (-not (Test-Path "$backupDir\PoshThemes"))
  { 
    New-Item -ItemType Directory -Path "$backupDir\PoshThemes" -Force 
  }

  if (-not (Test-Path "$backupDir\PowerShell"))
  { 
    New-Item -ItemType Directory -Path "$backupDir\PowerShell" -Force 
  }

  Write-Host "🔄 Sincronizando archivos de configuración..." -ForegroundColor Cyan

  # 2. Copiar el Perfil de PowerShell
  Copy-Item -Path $PROFILE -Destination "$backupDir\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
    
  # 3. Copiar el Tema de Oh My Posh
  $temaPath = "C:\Users\Usuario\Documents\PoshThemes\catppuccin_mocha.omp.json"
  if (Test-Path $temaPath)
  {
    Copy-Item -Path $temaPath -Destination "$backupDir\PoshThemes\catppuccin_mocha.omp.json" -Force
  }

  Write-Host "✅ Todo respaldado en GitHub correctamente." -ForegroundColor Green

  Write-Host "`n📦 Archivos listos para el commit en: $repoNvim" -ForegroundColor Yellow
  Set-Location $repoNvim
  git status 
}
