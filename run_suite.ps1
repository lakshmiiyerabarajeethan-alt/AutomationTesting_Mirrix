# ============================================================================
# run_suite.ps1  —  Test Suite Runner
# Reads suite_selection.yaml to decide which tests to run.
# Usage: .\run_suite.ps1
# ============================================================================

$ROOT   = $PSScriptRoot
$ROBOT  = "$ROOT\venv\Scripts\robot.exe"
$TESTS  = "$ROOT\tests"
$OUT    = "$ROOT\results"
$CONFIG = "$ROOT\suite_selection.yaml"

function Header($msg) { Write-Host "`n$msg" -ForegroundColor Cyan }
function Ok($msg)     { Write-Host "  $msg" -ForegroundColor Green }
function Warn($msg)   { Write-Host "  $msg" -ForegroundColor Yellow }
function Info($msg)   { Write-Host "  $msg" -ForegroundColor White }

# ── Map test names to their suite files ───────────────────────────────────────
$testFileMap = @{
    "Full E2E Workflow"   = "full_e2e_tests.robot"
    "Example Login Test"  = "example_tests.robot"
}

# ── Parse suite_selection.yaml ────────────────────────────────────────────────
function Read-SuiteSelection {
    $selected = [System.Collections.Generic.List[string]]::new()
    foreach ($line in Get-Content $CONFIG) {
        $line = $line.Trim()
        if ($line -match '^(.+?):\s*(true|false)\s*$') {
            $testName = $Matches[1].Trim()
            $enabled  = $Matches[2] -eq "true"
            if ($enabled -and $testFileMap.ContainsKey($testName)) {
                $selected.Add($testName)
            }
        }
    }
    return $selected
}

function Read-SkippedTests {
    $skipped = [System.Collections.Generic.List[string]]::new()
    foreach ($line in Get-Content $CONFIG) {
        $line = $line.Trim()
        if ($line -match '^(.+?):\s*false\s*$') {
            $testName = $Matches[1].Trim()
            if ($testFileMap.ContainsKey($testName)) {
                $skipped.Add($testName)
            }
        }
    }
    return $skipped
}

# ── Show current selection ────────────────────────────────────────────────────
Clear-Host
Header "============================================="
Header "   Mirrix Automation -- Test Suite Runner    "
Header "============================================="
Info ""
Info "Reading selection from: suite_selection.yaml"
Info ""

$selectedTests = Read-SuiteSelection

if ($selectedTests.Count -eq 0) {
    Warn "No tests are set to 'true' in suite_selection.yaml."
    Warn "Edit the file and set at least one test to true, then re-run."
    exit 1
}

Info "Tests selected to run:"
foreach ($t in $selectedTests) {
    Ok "  [x] $t"
}

$skippedTests = Read-SkippedTests
foreach ($t in $skippedTests) {
    Info "  [ ] $t  -- skipped"
}

Info ""
$confirm = Read-Host "  Run these tests? [Y/n]"
if ($confirm -eq "n" -or $confirm -eq "N") {
    Info "Cancelled. Edit suite_selection.yaml to change selection."
    exit 0
}

# ── Build robot command ───────────────────────────────────────────────────────
$testArgs   = $selectedTests | ForEach-Object { "--test `"$_`"" }
$suiteFiles = $selectedTests | ForEach-Object { $testFileMap[$_] } | Select-Object -Unique
$suiteArgs  = $suiteFiles    | ForEach-Object { "`"$TESTS\$_`"" }

$fullCmd = ($testArgs + $suiteArgs) -join ' '

Info ""
Info "Command: robot --outputdir `"$OUT`" $fullCmd"
Info ""

# ── Run ───────────────────────────────────────────────────────────────────────
$robotArgs = [System.Collections.Generic.List[string]]::new()
$robotArgs.Add("--outputdir")
$robotArgs.Add($OUT)
foreach ($t in $selectedTests) {
    $robotArgs.Add("--test")
    $robotArgs.Add($t)
}
foreach ($f in $suiteFiles) {
    $robotArgs.Add("$TESTS\$f")
}
& $ROBOT @robotArgs
$exitCode = $LASTEXITCODE

# ── Result ────────────────────────────────────────────────────────────────────
Info ""
if ($exitCode -eq 0) {
    Ok "All selected tests PASSED"
} else {
    Warn "Some tests FAILED (exit code: $exitCode)"
}

Info ""
Info "Report : $OUT\report.html"
Info "Log    : $OUT\log.html"
Info ""

$open = Read-Host "  Open report in browser? [Y/n]"
if ($open -ne "n" -and $open -ne "N") {
    Start-Process "$OUT\report.html"
}
