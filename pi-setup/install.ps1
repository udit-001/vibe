# Vibe Pi setup for Windows.
# A short wizard: Pi core, Vibe packages, Playwright Agent CLI, Exa MCP, an optional Zen API key, then Vibe skills.
# Only asks for input when a human step is truly needed; skips everything else.
# Idempotent — every step skips what's already done, so re-running is safe.

$ErrorActionPreference = "Stop"
$MinNode = [version]"22.19.0"
$OfficialInstaller = "https://pi.dev/install.ps1"
$ZenUrl = "https://opencode.ai/zen"
$ExaUrl = "https://mcp.exa.ai/mcp?tools=web_search_exa,web_fetch_exa,web_search_advanced_exa"
$TotalSteps = 6
$agentDir = if ($env:PI_CODING_AGENT_DIR) { $env:PI_CODING_AGENT_DIR } else { Join-Path $HOME ".pi\agent" }
$Step = 0

function Step([string]$title) {
    $script:Step += 1
    Write-Host ""
    Write-Host ("[" + $script:Step + "/" + $script:TotalSteps + "] " + $title)
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
    "git:github.com/udit-001/pi-powerline-footer",
    "npm:pi-mcp-adapter",
    "npm:pi-subagents"
)
$installed = @((((pi list) -join "`n") -split "`n") | ForEach-Object { $_.Trim() })
foreach ($pkg in $packages) {
    if ($installed -contains $pkg) {
        Write-Host ("  -> " + $pkg + " (already installed)")
    } else {
        Write-Host ("  -> " + $pkg)
        pi install $pkg
        if ($LASTEXITCODE -ne 0) { Write-Host ("  !! failed: " + $pkg) }
    }
}

# Step 3 — Playwright Agent CLI + skills. Skills go to Pi's global skills
# folder (~/.agents/skills), not Claude Code's — see the --skills=agents flag.
Step "Install Playwright Agent CLI + skills"

$pwSkillsPath = Join-Path $HOME ".agents\skills\playwright-cli"

if (Get-Command playwright-cli -ErrorAction SilentlyContinue) {
    Write-Host "Playwright CLI already installed. Skipped npm install."
} else {
    Write-Host "Installing @playwright/cli globally."
    npm install -g @playwright/cli
    if ($LASTEXITCODE -ne 0) { Write-Host "  !! npm install -g @playwright/cli failed." }
}

if (-not (Get-Command playwright-cli -ErrorAction SilentlyContinue)) {
    Write-Host "  !! playwright-cli is not on PATH in this window."
    Write-Host "     Open a new terminal and re-run the script."
} elseif (Test-Path $pwSkillsPath) {
    Write-Host "Playwright skills already installed. Skipped."
} else {
    # --skills=agents targets the .agents/skills folder; --global makes it
    # user-global (~/.agents/skills), which Pi reads. The default (claude) is wrong here.
    Write-Host "Installing Playwright skills to the global agents folder (Pi)."
    playwright-cli install --skills=agents --global
    if ($LASTEXITCODE -ne 0) { Write-Host "  !! playwright-cli install --skills=agents --global failed." }
}

# Step 4 — Exa MCP. Same endpoint and tool selection as the opencode config.
Step "Configure Exa MCP server"

$mcpPath = Join-Path $agentDir "mcp.json"
$mcpObj = $null
if (Test-Path $mcpPath) {
    try {
        $raw = [System.IO.File]::ReadAllText($mcpPath)
        if (-not [string]::IsNullOrWhiteSpace($raw)) {
            $mcpObj = ($raw -replace "^\uFEFF", "") | ConvertFrom-Json
        }
    } catch {
        Write-Host "  !! Could not read mcp.json; a fresh file will be written."
        $mcpObj = $null
    }
}
if (-not $mcpObj) { $mcpObj = New-Object PSObject }

if (($mcpObj.PSObject.Properties.Name -contains "mcpServers") -and $null -ne $mcpObj.mcpServers -and ($mcpObj.mcpServers.PSObject.Properties.Name -contains "exa")) {
    Write-Host "Exa MCP is already configured. Skipped."
} else {
    if (-not ($mcpObj.PSObject.Properties.Name -contains "mcpServers") -or $null -eq $mcpObj.mcpServers) {
        $mcpObj | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value (New-Object PSObject) -Force
    }
    $exa = New-Object PSObject
    $exa | Add-Member -MemberType NoteProperty -Name "url" -Value $ExaUrl
    $exa | Add-Member -MemberType NoteProperty -Name "directTools" -Value $true
    $mcpObj.mcpServers | Add-Member -MemberType NoteProperty -Name "exa" -Value $exa -Force

    New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
    [System.IO.File]::WriteAllText($mcpPath, ($mcpObj | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding $false))
    Write-Host ("Configured Exa MCP in " + $mcpPath)
}

# Step 5 — Zen API key. Optional; press Enter to skip and do it later in pi.
Step "Zen API key (optional)"

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

# Step 6 — Vibe skills (global). Installed into the tool-agnostic ~/.agents/skills
# folder that Pi reads. Repo skills: docs-seeker, search.
Step "Install Vibe skills (global)"

$skillsDir = Join-Path $HOME ".agents\skills"
if ((Test-Path (Join-Path $skillsDir "docs-seeker")) -and (Test-Path (Join-Path $skillsDir "search"))) {
    Write-Host "Vibe skills (docs-seeker, search) already installed. Skipped."
} else {
    # -g = user-global; -a universal = the .agents/skills folder; -y = non-interactive.
    npx --yes skills add udit-001/vibe -s docs-seeker -s search -g -a universal -y
    if ($LASTEXITCODE -ne 0) { Write-Host "  !! npx skills add failed." }
}

Write-Host ""
Write-Host "Done. Next: run 'pi', then /model to pick a pi-zen model."
Write-Host ""