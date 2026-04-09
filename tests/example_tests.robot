*** Settings ***
Library         Browser
Resource        ../resources/keywords/common_keywords.robot
Resource        ../resources/variables/common_variables.robot
Resource        ../pages/login_page.robot
Suite Setup     Open Browser Session
Suite Teardown  Close All Browsers
Test Teardown   Take Screenshot On Failure

*** Test Cases ***
Example Login Test
    [Documentation]    Smoke test — verifies login to Mirrix succeeds and main nav loads.
    [Tags]    smoke    login
    Login To Mirrix
    Wait For Elements State    text=Upload        visible    timeout=${TIMEOUT}
    Wait For Elements State    text=Collections   visible    timeout=${TIMEOUT}
    Wait For Elements State    text=Folders       visible    timeout=${TIMEOUT}
    Log    Smoke test passed — Mirrix navigation bar is visible
