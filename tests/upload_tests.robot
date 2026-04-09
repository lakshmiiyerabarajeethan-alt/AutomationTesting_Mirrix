*** Settings ***
Library         Browser
Library         OperatingSystem
Resource        ../resources/keywords/common_keywords.robot
Resource        ../resources/variables/common_variables.robot
Resource        ../pages/login_page.robot
Resource        ../pages/upload_page.robot
Suite Setup     Run Keywords    Open Browser Session    AND    Login To Mirrix
Suite Teardown  Close All Browsers
Test Teardown   Take Screenshot On Failure

*** Test Cases ***
Verify Upload Page Loads
    [Documentation]
    ...    Navigates to the Upload page and confirms the drag-and-drop area
    ...    and the existing uploaded assets table are visible.
    [Tags]    upload    smoke
    Navigate To Upload Page
    Wait For Elements State    text=Drag your file(s) to start uploading    visible    timeout=${TIMEOUT}
    Wait For Elements State    css=table    visible    timeout=${TIMEOUT}
    Log    Upload page verified — drag zone and assets table are visible

Verify Upload Table Columns Are Visible
    [Documentation]
    ...    Confirms the assets table has the expected column headers:
    ...    Thumbnail, STEP ID, File name, Upload Date, File size, Status.
    [Tags]    upload    smoke
    Navigate To Upload Page
    Wait For Elements State    text=Thumbnail     visible    timeout=${TIMEOUT}
    Wait For Elements State    text=STEP ID       visible    timeout=${TIMEOUT}
    Wait For Elements State    text=File name     visible    timeout=${TIMEOUT}
    Wait For Elements State    text=Upload Date   visible    timeout=${TIMEOUT}
    Wait For Elements State    text=File size     visible    timeout=${TIMEOUT}
    Wait For Elements State    text=Status        visible    timeout=${TIMEOUT}
    Log    All upload table column headers verified

Upload JPEG Image File
    [Documentation]
    ...    Uploads a JPEG image using the Batch File Upload dialog.
    ...    Prerequisites: place sample_image.jpg in test_data/assets/
    [Tags]    upload    e2e    jpeg
    ${file}=    Set Variable    ${ASSETS_DIR}/sample_image.jpg
    File Should Exist    ${file}
    Upload File Via Dialog
    ...    file_path=${file}
    ...    profile=Default
    ...    description=Batch upload of toy product image
    Verify Asset In Upload List    sample_image.jpg    Complete

Upload PDF Document File
    [Documentation]
    ...    Uploads a PDF document using the Batch File Upload dialog.
    ...    Prerequisites: place sample_document.pdf in test_data/assets/
    [Tags]    upload    e2e    pdf
    ${file}=    Set Variable    ${ASSETS_DIR}/sample_document.pdf
    File Should Exist    ${file}
    Upload File Via Dialog
    ...    file_path=${file}
    ...    profile=Default
    ...    description=PDF product specification upload
    Verify Asset In Upload List    sample_document.pdf    Complete

Upload PNG Image File
    [Documentation]
    ...    Uploads a PNG image using the Batch File Upload dialog.
    ...    Prerequisites: place sample_image.png in test_data/assets/
    [Tags]    upload    e2e    png
    ${file}=    Set Variable    ${ASSETS_DIR}/sample_image.png
    File Should Exist    ${file}
    Upload File Via Dialog
    ...    file_path=${file}
    ...    profile=Default
    ...    description=PNG format product image
    Verify Asset In Upload List    sample_image.png    Complete

Verify Batch File Upload Dialog Opens And Cancels
    [Documentation]
    ...    Confirms the Batch File Upload dialog appears correctly and
    ...    can be dismissed via the Cancel button without uploading.
    [Tags]    upload    dialog
    Navigate To Upload Page
    # Drop a file to trigger the dialog (or click the upload trigger)
    ${file}=    Set Variable    ${ASSETS_DIR}/sample_image.jpg
    File Should Exist    ${file}
    Upload File By Selector    css=input[type="file"]    ${file}
    Open Batch File Upload Dialog
    Wait For Elements State    text=Upload Profile             visible    timeout=${TIMEOUT}
    Wait For Elements State    text=Upload Batch Description   visible    timeout=${TIMEOUT}
    Wait For Elements State    text=Upload Batch Tags          visible    timeout=${TIMEOUT}
    Cancel Upload Dialog
    Log    Batch File Upload dialog opened and cancelled successfully
