# Vibe Pi setup for Windows.
# A short wizard: Pi core, Vibe packages, then an optional Zen API key.
# Only asks for input when a human step is truly needed; skips everything else.
# Safe to run more than once.

$ErrorActionPreference = "Stop"
$MinNode = [version]"22.19.0"
$OfficialInstaller = "https://pi.dev/install.ps1"
$ZenUrl = "https://opencode.ai/zen"
$Step = 0

function Step([string]$title) {
    $script:Step += 1
    Write-Host ""
    Write-Host ("[" + $script:Step + "/3] " + $title)
}

function Test-Node {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $cmd) { return $false }
    try { $v = (& node --version) 2>$null } catch { return $false }
    if ($v -match "v?(\d+\.\d+\.\d+)") { return ([version]$Matches[1] -ge $MinNode) }
    return $false
}

function Test-Pi {
    return [bool](Get-Command pi -ErrorAction SilentlyContinue)
}

Write-Host ""
Write-Host "== Vibe Pi setup =="

# Step 1 — Pi core (Node, Git, Pi). Skipped when already present.
if (-not (Test-Pi) -or -not (Test-Node)) {
    Step "Install Pi (Node and Git if needed)"
    Write-Host "Running the official Pi installer. Answer its prompts."
    $response = Invoke-WebRequest -Uri $OfficialInstaller -UseBasicParsing
    $official = if ($response.Content -is [byte[]]) {
        [System.Text.Encoding]::UTF8.GetString($response.Content)
    } else {
        [string]$response.Content
    }
    Invoke-Expression $official
} else {
    Step "Pi is already installed (skipped)"
}

if (-not (Test-Pi)) {
    Write-Host ""
    Write-Host "Pi installed, but not visible in this window."
    Write-Host "Open a new terminal and run again:"
    Write-Host "  irm https://cdn.jsdelivr.net/gh/udit-001/vibe@7cd55827f57bdc7550a078e6d3260683728a88b5/pi-setup/install.ps1 | iex"
    exit 0
}

# Step 2 — Vibe packages. No input needed.
Step "Install Vibe packages"
$ErrorActionPreference = "Continue"
$packages = @(
    "git:github.com/udit-001/pi-zen",
    "git:github.com/udit-001/pi-vision",
    "npm:pi-mcp-adapter",
    "npm:pi-subagents"
)
foreach ($pkg in $packages) {
    Write-Host ("  -> " + $pkg)
    pi install $pkg
    if ($LASTEXITCODE -ne 0) { Write-Host ("  !! failed: " + $pkg) }
}

# Step 3 — Zen API key. Optional; press Enter to skip and do it later in pi.
Step "Zen API key (optional)"

$agentDir = if ($env:PI_CODING_AGENT_DIR) { $env:PI_CODING_AGENT_DIR } else { Join-Path $HOME ".pi\agent" }
$authPath = Join-Path $agentDir "auth.json"
$providerId = "pi-zen"

# Skip if a key is already stored.
$storedKey = ""
if (Test-Path $authPath) {
    try {
        $raw = [System.IO.File]::ReadAllText($authPath)
        $authObj = ($raw -replace "^\uFEFF", "") | ConvertFrom-Json
        if ($authObj.$providerId -and $authObj.$providerId.key) { $storedKey = [string]$authObj.$providerId.key }
    } catch { }
}
if (-not $storedKey -and $env:ZEN_API_KEY) { $storedKey = $env:ZEN_API_KEY }

if ($storedKey) {
    Write-Host ("A " + $providerId + " key is already set. Skipped.")
} else {
    Write-Host "pi-zen needs a free key. Opening the page now."
    Write-Host "  1. Sign in"
    Write-Host "  2. Add billing (free models still ask for a card on file)"
    Write-Host "  3. Copy your 'oc_...' key"
    Start-Process $ZenUrl

    $secure = Read-Host "Paste key now, or press Enter to skip (run /login pi-zen later)" -AsSecureString
    $key = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    if ([string]::IsNullOrWhiteSpace($key)) {
        Write-Host "Skipped. Later: run 'pi', then run /login pi-zen"
    } else {
        # Merge into the existing auth.json so other providers stay intact.
        $canWrite = $false
        $authObj = New-Object PSObject
        if (Test-Path $authPath) {
            try {
                $raw = [System.IO.File]::ReadAllText($authPath)
                if ([string]::IsNullOrWhiteSpace($raw)) {
                    $authObj = New-Object PSObject
                } else {
                    $authObj = ($raw -replace "^\uFEFF", "") | ConvertFrom-Json
                }
                $canWrite = $true
            } catch {
                $canWrite = $false
            }
        } else {
            $canWrite = $true
        }

        if (-not $canWrite) {
            Write-Host "Could not read auth.json. Skipped saving."
            Write-Host "Later: run 'pi', then /login pi-zen"
        } else {
            $cred = New-Object PSObject
            $cred | Add-Member -MemberType NoteProperty -Name "type" -Value "api_key"
            $cred | Add-Member -MemberType NoteProperty -Name "key" -Value $key
            $authObj | Add-Member -MemberType NoteProperty -Name $providerId -Value $cred -Force
            New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
            $json = $authObj | ConvertTo-Json -Depth 10
            [System.IO.File]::WriteAllText($authPath, $json, (New-Object System.Text.UTF8Encoding $false))
            Write-Host "Saved key to auth.json."
        }
    }
}

Write-Host ""
Write-Host "Done. Next: run 'pi', then /model to pick a pi-zen model."
Write-Host ""