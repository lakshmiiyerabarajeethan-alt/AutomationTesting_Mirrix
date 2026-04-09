*** Settings ***
Library         Browser
Resource        ../resources/keywords/common_keywords.robot
Resource        ../resources/variables/common_variables.robot
Resource        ../pages/login_page.robot
Resource        ../pages/search_page.robot
Suite Setup     Run Keywords    Open Browser Session    AND    Login To Mirrix    AND    Go To    ${UPLOAD_URL}
Suite Teardown  Close All Browsers
Test Setup      Go To    ${UPLOAD_URL}
Test Teardown   Take Screenshot On Failure

*** Test Cases ***
Verify Search Bar Is Visible
    [Documentation]    Confirms the Search input and both search buttons are visible on the Upload page.
    [Tags]    search    smoke
    Wait For Elements State    css=input[placeholder="Search"]     visible    timeout=${TIMEOUT}
    Wait For Elements State    css=button:has-text("Search from List")    visible    timeout=${TIMEOUT}
    Log    Search bar and Search from List button verified as visible

Search By Product Keyword
    [Documentation]
    ...    TC_SR_001 — Searches by keyword "Teddy" and verifies the asset appears in results.
    [Tags]    search    keyword
    Search For Asset    Teddy
    Verify Asset In Search Results    Teddy bubble shooter.png
    Log    TC_SR_001 passed — keyword search "Teddy" returned expected asset

Search By Exact STEP ID
    [Documentation]
    ...    TC_SR_002 — Searches by exact STEP ID "IMG_146146" and verifies the match.
    [Tags]    search    step-id
    Search For Asset    IMG_146146
    Verify Step ID In Search Results    IMG_146146
    Verify Asset In Search Results    61tmTlwEdnL._AC_UF1000,1000_QL80_.jpg
    Log    TC_SR_002 passed — STEP ID search returned correct asset

Search By Partial File Name
    [Documentation]
    ...    TC_SR_003 — Searches by partial keyword "marker" and confirms the match.
    [Tags]    search    keyword
    Search For Asset    marker
    Verify Asset In Search Results    Yello marker.jpg
    Log    TC_SR_003 passed — partial name search "marker" returned expected asset

Search By Multi Word Phrase
    [Documentation]
    ...    TC_SR_004 — Searches using a multi-word phrase "bubble shooter".
    [Tags]    search    keyword
    Search For Asset    bubble shooter
    Verify Asset In Search Results    Teddy bubble shooter.png
    Log    TC_SR_004 passed — multi-word search returned expected asset

Search With No Results
    [Documentation]
    ...    TC_SR_005 — Searches for a term that should return no results
    ...    and confirms the table is empty.
    [Tags]    search    negative
    Search For Asset    nonexistent_asset_xyz
    Verify No Search Results
    Log    TC_SR_005 passed — no results returned for nonexistent search term

Search From List Button Opens Dialog
    [Documentation]
    ...    Verifies the "Search from List" button is clickable and opens
    ...    a list-based search experience.
    [Tags]    search    smoke
    Search From List    Teddy
    Log    Search from List executed successfully
