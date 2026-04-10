*** Settings ***
Library         Browser
Library         Collections
Library         OperatingSystem
Library         ../resources/helpers/test_data_reader.py
Resource        ../resources/keywords/common_keywords.robot
Resource        ../resources/variables/common_variables.robot
Resource        ../pages/login_page.robot
Resource        ../pages/upload_page.robot
Suite Setup     Run Keywords    Load Upload Test Data    AND    Open Browser Session    AND    Login To Mirrix
Suite Teardown  Close All Browsers
Test Teardown   Take Screenshot On Failure

*** Variables ***
${UPLOAD_SHEET}     Upload Tests
${UPLOAD_TC_ID}     TC_UP_001

*** Test Cases ***
Cancel Upload Dialog
    [Tags]    upload    dialog
    Go To Upload Page
    File Should Exist                  ${FILE_PATH}
    Wait For Elements State            role=button[name="Select files"]    visible    timeout=10s
    Select File For Upload          ${FILE_PATH}
    Set Upload Profile              ${UPLOAD_PROFILE}
    Fill Batch Description          ${BATCH_DESC}
    Add Batch Tag Via Tag Button    ${BATCH_TAG}
    Cancel Upload Dialog

Upload Single Image File
    [Tags]    upload    e2e
    Go To Upload Page
    File Should Exist                  ${FILE_PATH}
    Wait For Elements State            role=button[name="Select files"]    visible    timeout=10s
    Select File For Upload          ${FILE_PATH}
    Set Upload Profile              ${UPLOAD_PROFILE}
    Fill Batch Description          ${BATCH_DESC}
    Add Batch Tag Via Plus Icon     ${BATCH_TAG}
    Submit Upload
    Auto Refresh Upload Page        2s
    ${resolved_step_id}=    Resolve Step ID For Upload    ${STEP_ID}    ${FILE_NAME}
    Verify Asset Row In Table       ${resolved_step_id}
    Open Asset Preview
    Close Asset Preview
    Navigate To Asset Detail        ${resolved_step_id}
    Navigate Back Via Breadcrumb

*** Keywords ***
Load Upload Test Data
    ${rows}=    Read Excel Sheet    ${EXCEL_FILE}    ${UPLOAD_SHEET}
    ${row}=    Get Upload Test Data Row    ${rows}    ${UPLOAD_TC_ID}
    ${file_name}=    Get From Dictionary    ${row}    File Name
    ${upload_profile}=    Get From Dictionary    ${row}    Upload Profile
    ${batch_desc}=    Get From Dictionary    ${row}    Upload Batch Description
    ${batch_tag}=    Get From Dictionary    ${row}    Upload Batch Tags
    ${file_path}=    Set Variable    ${ASSETS_DIR}${/}${file_name}
    ${step_status}    ${step_id}=    Run Keyword And Ignore Error    Get From Dictionary    ${row}    Step ID
    IF    '${step_status}' != 'PASS'
        ${step_id}=    Set Variable    ${EMPTY}
    END
    Set Suite Variable    ${FILE_NAME}    ${file_name}
    Set Suite Variable    ${FILE_PATH}    ${file_path}
    Set Suite Variable    ${UPLOAD_PROFILE}    ${upload_profile}
    Set Suite Variable    ${BATCH_DESC}    ${batch_desc}
    Set Suite Variable    ${BATCH_TAG}    ${batch_tag}
    Set Suite Variable    ${STEP_ID}    ${step_id}

Get Upload Test Data Row
    [Arguments]    ${rows}    ${test_case_id}
    FOR    ${row}    IN    @{rows}
        ${candidate_id}=    Get From Dictionary    ${row}    Test Case ID
        IF    '${candidate_id}' == '${test_case_id}'
            RETURN    ${row}
        END
    END
    Fail    No data row found in "${UPLOAD_SHEET}" for Test Case ID "${test_case_id}".

Resolve Step ID For Upload
    [Arguments]    ${excel_step_id}    ${file_name}
    IF    '${excel_step_id}' != ''
        RETURN    ${excel_step_id}
    END
    ${resolved_step_id}=    Get Step ID By File Name    ${file_name}
    RETURN    ${resolved_step_id}
