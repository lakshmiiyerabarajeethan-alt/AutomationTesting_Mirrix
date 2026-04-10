*** Settings ***
Library     Browser
Resource    ../resources/keywords/common_keywords.robot
Resource    ../resources/variables/common_variables.robot

*** Keywords ***
Go To Upload Page
    Click                       role=link[name="Upload"]
    Wait For Elements State     role=button[name="Select files"]    visible    timeout=${TIMEOUT}

Select File For Upload
    [Arguments]    ${file_path}
    Upload File By Selector     css=input[type="file"]    ${file_path}
    Wait For Elements State     text=Batch File Upload              visible    timeout=${TIMEOUT}

Set Upload Profile
    [Arguments]    ${profile}
    ${profile_selector}=    Set Variable    css=.ant-modal-content .ant-select-selector
    ${open_dropdown}=       Set Variable    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)
    Wait For Elements State     ${profile_selector}    visible    timeout=${TIMEOUT}
    Click                       ${profile_selector}
    Press Keys                  ${profile_selector}    ArrowDown
    Wait For Elements State     ${open_dropdown}    visible    timeout=${TIMEOUT}
    Click                       ${open_dropdown} >> text=${profile}

Fill Batch Description
    [Arguments]    ${description}
    Click           role=textbox[name="Upload Batch Description:"]
    Fill Text       role=textbox[name="Upload Batch Description:"]    ${description}

Add Batch Tag Via Plus Icon
    [Arguments]    ${tag}
    Click           css=.anticon.anticon-plus > svg
    Fill Text       role=textbox >> nth=1    ${tag}
    Press Keys      role=textbox >> nth=1    Enter

Add Batch Tag Via Tag Button
    [Arguments]    ${tag}
    Click           css=.ant-tag
    Fill Text       role=textbox >> nth=1    ${tag}
    Press Keys      role=textbox >> nth=1    Enter

Submit Upload
    Click                       role=button[name="Upload"]
    Wait For Elements State     text=Uploading... 100%    visible    timeout=60s

Auto Refresh Upload Page
    [Arguments]    ${delay}=2s
    Sleep                      ${delay}
    Reload
    Wait For Elements State    role=button[name="Select files"]    visible    timeout=${TIMEOUT}

Cancel Upload Dialog
    Click                       role=button[name="Cancel"]
    Wait For Elements State     text=Batch File Upload    hidden    timeout=${TIMEOUT}

Verify Asset Row In Table
    [Arguments]    ${step_id}
    Wait For Elements State     role=cell[name="${step_id}"]         visible    timeout=${TIMEOUT}
    Wait For Elements State     role=cell[name="Completed"] >> nth=0    visible    timeout=${TIMEOUT}

Open Asset Preview
    Click                       role=cell[name="eye Preview"] >> nth=0
    Wait For Elements State     css=.ant-image-preview-img           visible    timeout=${TIMEOUT}

Close Asset Preview
    Click                       role=button[name="close"]

Navigate To Asset Detail
    [Arguments]    ${step_id}
    Click                       role=link[name="${step_id}"]

Navigate Back Via Breadcrumb
    Click                       role=list >> role=link >> nth=0

Get Step ID By File Name
    [Arguments]    ${file_name}
    ${row_selector}=    Set Variable    css=table tbody tr:has-text("${file_name}")
    Wait For Elements State     ${row_selector}    visible    timeout=${TIMEOUT}
    ${step_id}=    Get Text     ${row_selector} >> td >> nth=1
    RETURN    ${step_id}
