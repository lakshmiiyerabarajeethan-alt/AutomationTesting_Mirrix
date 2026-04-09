*** Settings ***
Library         Browser
Resource        ../resources/keywords/common_keywords.robot
Resource        ../resources/variables/common_variables.robot
Resource        ../pages/login_page.robot
Resource        ../pages/upload_page.robot
Suite Setup     Run Keywords    Open Browser Session    AND    Login To Mirrix
Suite Teardown  Close All Browsers
Test Teardown   Take Screenshot On Failure

*** Variables ***
${FILE_NAME}        61tmTIwEdnL._AC_UF1000,1000_QL80_.jpg
${FILE_PATH}        ${ASSETS_DIR}${/}${FILE_NAME}
${UPLOAD_PROFILE}   Images
${BATCH_DESC}       Test_image_0904
${BATCH_TAG}        doll
${STEP_ID}          IMG_146303

*** Test Cases ***
Cancel Upload Dialog
    [Tags]    upload    dialog
    Go To Upload Page
    Select File For Upload          ${FILE_PATH}
    Set Upload Profile              ${UPLOAD_PROFILE}
    Fill Batch Description          Test_image
    Add Batch Tag Via Tag Button    ${BATCH_TAG}
    Cancel Upload Dialog

Upload Single Image File
    [Tags]    upload    e2e
    Go To Upload Page
    Select File For Upload          ${FILE_PATH}
    Set Upload Profile              ${UPLOAD_PROFILE}
    Fill Batch Description          ${BATCH_DESC}
    Add Batch Tag Via Plus Icon     ${BATCH_TAG}
    Submit Upload
    Verify Asset Row In Table       ${STEP_ID}
    Open Asset Preview
    Close Asset Preview
    Navigate To Asset Detail        ${STEP_ID}
    Navigate Back Via Breadcrumb
