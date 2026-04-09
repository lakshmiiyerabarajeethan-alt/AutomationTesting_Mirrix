*** Settings ***
Library     Browser

*** Keywords ***
Open Browser Session
    [Documentation]    Launches the browser with configured settings.
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Set Browser Timeout    ${TIMEOUT}

Close All Browsers
    Close Browser

Focus Page
    [Documentation]
    ...    Brings focus to the browser page so all elements become interactive.
    ...    Call this after every Go To / navigation to avoid "elements not visible" issues.
    Focus    css=body

Take Screenshot On Failure
    Take Screenshot    fullPage=True
