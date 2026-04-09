*** Settings ***
Library     Browser
Resource    ../resources/keywords/common_keywords.robot
Resource    ../resources/variables/common_variables.robot

*** Keywords ***
Login To Mirrix
    [Documentation]
    ...    Opens the Mirrix login page at ${LOGIN_URL} and performs login.
    ...    Waits until the main navigation is visible before continuing.
    [Arguments]    ${username}=${USERNAME}    ${password}=${PASSWORD}
    New Page    ${LOGIN_URL}
    Focus Page
    # Wait for email / username input field
    Wait For Elements State    css=input[type="email"], css=input[name="email"], css=input[type="text"]
    ...    visible    timeout=${TIMEOUT}
    Fill Text    css=input[type="email"], css=input[name="email"], css=input[type="text"]    ${username}
    Fill Text    css=input[type="password"]    ${password}
    Click    css=button[type="submit"]
    # Wait for main nav to appear — confirms successful login
    Wait For Elements State    text=Upload    visible    timeout=${TIMEOUT}
    Log    Login successful — Mirrix application loaded

Logout From Mirrix
    [Documentation]    Logs out from the Mirrix application.
    # Update selector to match the actual logout button/menu in Mirrix
    Click    css=[aria-label="Logout"], css=button:has-text("Logout")
    Wait For Elements State    css=input[type="email"], css=input[type="text"]
    ...    visible    timeout=${TIMEOUT}
    Log    Logout successful
