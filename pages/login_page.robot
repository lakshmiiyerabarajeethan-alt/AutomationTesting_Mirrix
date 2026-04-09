*** Settings ***
Library     Browser
Resource    ../resources/keywords/common_keywords.robot
Resource    ../resources/variables/common_variables.robot

*** Keywords ***
Login To Mirrix
    [Documentation]
    ...    Opens the Mirrix application URL and performs login.
    ...    Waits until the homepage is visible before continuing.
    [Arguments]    ${username}=${USERNAME}    ${password}=${PASSWORD}
    New Page    ${LOGIN_URL}
    Focus Page
    # Wait for login form — update selectors to match the actual Mirrix login page
    Wait For Elements State    role=textbox[name="Username"]    visible    timeout=${TIMEOUT}
    Fill Text    role=textbox[name="Username"]    ${username}
    Fill Text    role=textbox[name="Password"]    ${password}
    Click    role=button[name="Login"]
    # Wait for homepage indicator after successful login
    Go To    ${HOMEPAGE_URL}
    Focus Page
    Log    Login successful — homepage loaded
