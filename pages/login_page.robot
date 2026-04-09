*** Settings ***
Library     Browser
Resource    ../resources/keywords/common_keywords.robot
Resource    ../resources/variables/common_variables.robot

*** Keywords ***
Login To Mirrix
    [Arguments]    ${username}=${USERNAME}    ${password}=${PASSWORD}
    New Page        ${LOGIN_URL}
    Click           role=textbox[name="Email"]
    Fill Text       role=textbox[name="Email"]      ${username}
    Click           role=textbox[name="Password"]
    Fill Text       role=textbox[name="Password"]   ${password}
    Click           css=svg
    Click           role=button[name="Login"]
    Wait For Elements State    role=link[name="Upload"]    visible    timeout=${TIMEOUT}
