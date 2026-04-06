# --- RECURSOS VISUALES ---
$logoJuanca = @'
  ▄███████▄      ▄▄▄                     ▄▄▄▄▄▄▄        
 ██      ▀█▄     ███                    ███▀▀▀▀▀        
██  ▄█▀▀▀██      ███ ██ ██  ▀▀█▄ ████▄ ███        ▀▀█▄  
██  ██   ██ ▄▄▄  ███ ██ ██ ▄█▀██ ██ ██ ███      ▄█▀██  
 ██▄ ▀▀▀▀▀▀  ▀████▀  ▀██▀█ ▀█▄██ ██ ██ ▀███████ ▀█▄██  
  ▀▀██████▀▀                                           
'@

function Show-DashboardHeader {
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
Write-Host "  [n]  🚀 Crear Nuevo Proyecto (nuevo-repo)" -ForegroundColor Yellow
Write-Host "  [c]   Configurar Entorno (Perfil)" -ForegroundColor Blue
Write-Host " [dash]   Dashboard interactivo" -ForegroundColor Magenta
Write-Host "  [q]  󰈆 Salir de la Terminal`n" -ForegroundColor Red

Write-Host ("─" * 90) -ForegroundColor DarkGray
Write-Host ""
Write-Host "Cronómetro: $($timer.ElapsedMilliseconds)ms" -ForegroundColor DarkGray

# --- LÓGICA DE FUNCIONES ---

# Nota: Cambia "Usuario" por tu nombre de usuario real en Windows
# Ruta de tus proyectos (LA QUE TÚ YA TIENES)
$rutaProyectos = "C:\Users\Usuario\Documents\Desarrollo"

# Ruta de donde están tus SCRIPTS (para que el preview funcione)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
function v { 
    nvim $args
}

function conf {
    nvim $PROFILE
}

function guia { nvim "$rutaProyectos\DocMd\Github.md" }

# [p] Ir a proyectos
function p { Set-Location $rutaProyectos; ll }
function g { guia }
# [n] Crear nuevo repo pasando el nombre
function n { 
    if ($args.Count -eq 0) {
        Write-Host "⚠️ Error: Debes poner un nombre. Ej: n mi-proyecto-contable" -ForegroundColor Red
    } else {
        # Aquí llama a tu comando 'nuevo-repo' pasando todos los argumentos
        nuevo-repo $args 
    }
}

function q { exit }

# --- Docker Aliases (Corregidos) ---
function d-up { docker-compose up --build -d } # -d para que no bloquee la terminal
function d-down { docker-compose down }
function d-logs { docker-compose logs -f }
function d-ps { docker-compose ps -a }

# --- Docker Aliases (Mejorados) ---
function d-entrar { 
    $proyecto = Split-Path -Leaf (Get-Location)
    # Intentamos buscar por el nombre que asigna tu script 'nuevo-repo'
    $container = "$($proyecto)_app"
    if (docker ps -q -f "name=$container") {
        docker exec -it $container sh
    } else {
        # Fallback: buscar cualquier cosa que tenga 'app' y esté corriendo en esta carpeta
        $id = docker ps -q -f "name=app" | Select-Object -First 1
        if ($id) { docker exec -it $id sh } 
        else { Write-Host "❌ Contenedor no encontrado." -ForegroundColor Red }
    }
}

# --- Git Sincronización (Con validación) ---
function g-all {
    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Host "❌ No es un repositorio Git." -ForegroundColor Red; return
    }
    $msg = if ($args.Count -eq 0) { "Update $(Get-Date -Format 'yyyy-MM-dd HH:mm')" } else { $args -join " " }
    git add .
    git commit -m $msg
    git push
    Write-Host "🚀 Sincronizado!" -ForegroundColor Magenta
}

function gco {git-checkout-fzf}
function glog {git-log-fzf}
function gshow {git-show-fzf}
function sym {symbols-fzf}
function gosym {go-symbols-fzf}
function gstash {git-stash-fzf}
function gsp {git-stash-pop-fzf}
function gsa {git-stash-apply-fzf}
function gsd {git-stash-drop-fzf}

# Limpiar caché de Air y reiniciar
function air-clean { 
    if (Test-Path "./tmp") { Remove-Item -Recurse -Force ./tmp }
    docker-compose restart 
}

function open { start $args } # Abrir una web: open https://google.com o Abrir un archivo HTML local: open .\index.html

function ll {
    if (-not (Get-Module -Name Terminal-Icons)) {
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
    }
    Get-ChildItem $args
}

# Alias de una sola letra para listar
function l { ll }

function dash {Show-Dashboard}

# Función para entrar a la DB de Postgres del proyecto actual
function db-shell {
    $proyecto = Split-Path -Leaf (Get-Location)
    $contenedorDB = "$($proyecto)_db"
    
    if (docker ps -q -f name=$contenedorDB) {
        Write-Host "🐘 Conectando a: $contenedorDB" -ForegroundColor Cyan
        docker exec -it $contenedorDB psql -U admin -d "$($proyecto)_db"
    } else {
        Write-Host "❌ El contenedor $contenedorDB no está corriendo. Ejecuta 'docker-compose up -d' primero." -ForegroundColor Red
    }
}

function re {
  Import-Module DevDashboard -Force -DisableNameChecking
  # . $PROFILE; Write-Host "`n♻️ Perfil recargado!" -ForegroundColor Cyan 
  }

function nuevo-repo {
    param([string]$nombre)
    if (-not $nombre) {
        Write-Host "⚠️  Indica un nombre para el proyecto." -ForegroundColor Yellow
        return
    }

    # 1. Estructura de Carpetas
    $folders = "ctrl", "db", "help", "middleware", "static", "models", "rutas", "config", "views", "tests"
    New-Item -ItemType Directory -Path $nombre -ErrorAction SilentlyContinue
    Set-Location $nombre
    foreach ($f in $folders) { New-Item -ItemType Directory -Path $f -ErrorAction SilentlyContinue }

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

if (Test-Path $poshConfig) {
    # Usamos la ruta absoluta que encontramos para que no falle nunca
    oh-my-posh init pwsh --config $poshConfig | Invoke-Expression
} else {
    # Plan B: Si por algo se mueve, busca en la ruta estándar de temas
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin_mocha.omp.json" | Invoke-Expression
}

function sync-dotfiles {
    $repoNvim = "$env:LOCALAPPDATA\nvim"
    $backupDir = "$repoNvim\backups_config" # Carpeta dentro de nvim
    
    # 1. Crear carpetas de respaldo si no existen
    if (-not (Test-Path "$backupDir\PoshThemes")) { 
        New-Item -ItemType Directory -Path "$backupDir\PoshThemes" -Force 
    }

    if (-not (Test-Path "$backupDir\PowerShell")) { 
        New-Item -ItemType Directory -Path "$backupDir\PowerShell" -Force 
    }

    Write-Host "🔄 Sincronizando archivos de configuración..." -ForegroundColor Cyan

    # 2. Copiar el Perfil de PowerShell
    Copy-Item -Path $PROFILE -Destination "$backupDir\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
    
    # 3. Copiar el Tema de Oh My Posh
    $temaPath = "C:\Users\Usuario\Documents\PoshThemes\catppuccin_mocha.omp.json"
    if (Test-Path $temaPath) {
        Copy-Item -Path $temaPath -Destination "$backupDir\PoshThemes\catppuccin_mocha.omp.json" -Force
    }

    Write-Host "✅ Todo respaldado en GitHub correctamente." -ForegroundColor Green

    Write-Host "`n📦 Archivos listos para el commit en: $repoNvim" -ForegroundColor Yellow
    Set-Location $repoNvim
    git status 
}
