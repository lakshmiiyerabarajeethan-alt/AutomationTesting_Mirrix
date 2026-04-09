*** Settings ***
Library     Browser
Library     OperatingSystem
Resource    ../resources/keywords/common_keywords.robot
Resource    ../resources/variables/common_variables.robot

*** Keywords ***
Navigate To Upload Page
    [Documentation]    Navigates directly to the Assets Upload page.
    Go To    ${UPLOAD_URL}
    Focus Page
    Wait For Elements State    text=Drag your file(s) to start uploading    visible    timeout=${TIMEOUT}
    Log    Upload page loaded

Open Batch File Upload Dialog
    [Documentation]
    ...    Triggers the Batch File Upload dialog.
    ...    The dialog appears when files are dropped OR via an upload button/link.
    ...    Update the trigger selector if Mirrix uses a specific button to open it.
    Wait For Elements State    text=Batch File Upload    visible    timeout=${TIMEOUT}
    Log    Batch File Upload dialog is open

Select Upload Profile
    [Documentation]    Selects the desired Upload Profile from the dropdown in the Batch dialog.
    [Arguments]    ${profile}=Default
    Select Options By    css=select[name="uploadProfile"], css=[aria-label="Upload Profile"]
    ...    label    ${profile}
    Log    Upload Profile set to: ${profile}

Fill Upload Batch Description
    [Documentation]    Fills in the Upload Batch Description field.
    [Arguments]    ${description}
    Fill Text    css=input[placeholder*="description"], css=textarea[placeholder*="description"]
    ...    ${description}
    Log    Batch description filled: ${description}

Add Upload Batch Tag
    [Documentation]    Clicks the + button and adds a tag in the Upload Batch Tags section.
    [Arguments]    ${tag}
    Click    css=button[aria-label="Add tag"], css=button:has-text("+")
    Fill Text    css=input[aria-label="Tag input"], css=input[placeholder*="tag"]    ${tag}
    Log    Tag added: ${tag}

Upload File Via Dialog
    [Documentation]
    ...    Uploads a single file through the Batch File Upload dialog.
    ...    Provide full path to the asset file.
    [Arguments]    ${file_path}    ${profile}=Default    ${description}=${EMPTY}
    Navigate To Upload Page
    # Trigger the upload using the file input
    ${upload_input}=    Get Element    css=input[type="file"]
    Upload File By Selector    css=input[type="file"]    ${file_path}
    # The dialog should appear after file selection
    Open Batch File Upload Dialog
    Select Upload Profile    ${profile}
    IF    '${description}' != '${EMPTY}'
        Fill Upload Batch Description    ${description}
    END
    Click    css=button:has-text("Upload"), role=button[name="Upload"]
    # Wait for upload to complete
    Wait For Elements State    text=Complete    visible    timeout=60s
    Log    File uploaded successfully: ${file_path}

Cancel Upload Dialog
    [Documentation]    Closes the Batch File Upload dialog by clicking Cancel.
    Click    css=button:has-text("Cancel"), role=button[name="Cancel"]
    Wait For Elements State    text=Batch File Upload    hidden    timeout=${TIMEOUT}
    Log    Upload dialog cancelled

Verify Asset In Upload List
    [Documentation]
    ...    Checks that an asset appears in the upload list table.
    ...    Verifies file name and Expected Status columns.
    [Arguments]    ${file_name}    ${expected_status}=Complete
    Wait For Elements State    text=${file_name}    visible    timeout=${TIMEOUT}
    ${row}=    Get Element    css=tr:has-text("${file_name}")
    Get Text    ${row} >> css=td:last-child    ==    ${expected_status}
    Log    Asset verified in list: ${file_name} | Status: ${expected_status}
