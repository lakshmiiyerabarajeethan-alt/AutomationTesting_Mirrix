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

# ── Map test names → suite files ──────────────────────────────────────────────
$testFileMap = @{
    # Smoke
    "Example Login Test"                               = "example_tests.robot"
    "Verify Upload Page Loads"                         = "upload_tests.robot"
    "Verify Upload Table Columns Are Visible"          = "upload_tests.robot"
    "Verify Search Bar Is Visible"                     = "search_tests.robot"
    # Upload
    "Cancel Upload Dialog"                             = "upload_single_file_tests.robot"
    "Upload Single Image File"                         = "upload_single_file_tests.robot"
    "Upload JPEG Image File"                           = "upload_tests.robot"
    "Upload PDF Document File"                         = "upload_tests.robot"
    "Upload PNG Image File"                            = "upload_tests.robot"
    "Verify Batch File Upload Dialog Opens And Cancels" = "upload_tests.robot"
    # Search
    "Search By Product Keyword"                        = "search_tests.robot"
    "Search By Exact STEP ID"                          = "search_tests.robot"
    "Search By Partial File Name"                      = "search_tests.robot"
    "Search By Multi Word Phrase"                      = "search_tests.robot"
    "Search With No Results"                           = "search_tests.robot"
    "Search From List Button Opens Dialog"             = "search_tests.robot"
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

# ── Banner ────────────────────────────────────────────────────────────────────
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
foreach ($t in $selectedTests) { Ok "  [x] $t" }

$skippedTests = Read-SkippedTests
foreach ($t in $skippedTests) { Info "  [ ] $t  -- skipped" }

Info ""
$confirm = Read-Host "  Run these tests? [Y/n]"
if ($confirm -eq "n" -or $confirm -eq "N") {
    Info "Cancelled. Edit suite_selection.yaml to change selection."
    exit 0
}

# ── Build and run robot command ───────────────────────────────────────────────
$suiteFiles = $selectedTests | ForEach-Object { $testFileMap[$_] } | Select-Object -Unique

$robotArgs = [System.Collections.Generic.List[string]]::new()
$robotArgs.Add("--outputdir"); $robotArgs.Add($OUT)
foreach ($t in $selectedTests) { $robotArgs.Add("--test"); $robotArgs.Add($t) }
foreach ($f in $suiteFiles)    { $robotArgs.Add("$TESTS\$f") }

Info ""
Info "Command: robot --outputdir `"$OUT`" ..."
Info ""

& $ROBOT @robotArgs
$exitCode = $LASTEXITCODE

# ── Result ────────────────────────────────────────────────────────────────────
Info ""
if ($exitCode -eq 0) { Ok "All selected tests PASSED" }
else { Warn "Some tests FAILED (exit code: $exitCode)" }

Info ""
Info "Report : $OUT\report.html"
Info "Log    : $OUT\log.html"
Info ""

$open = Read-Host "  Open report in browser? [Y/n]"
if ($open -ne "n" -and $open -ne "N") { Start-Process "$OUT\report.html" }
