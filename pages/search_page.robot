*** Settings ***
Library     Browser
Resource    ../resources/keywords/common_keywords.robot
Resource    ../resources/variables/common_variables.robot

*** Keywords ***
Search For Asset
    [Documentation]
    ...    Types a search term into the Search bar and submits via the teal Search button.
    ...    Works from any page that has the Search bar visible (e.g. Upload, Collections).
    [Arguments]    ${search_term}
    Wait For Elements State    css=input[placeholder="Search"]    visible    timeout=${TIMEOUT}
    Clear Text    css=input[placeholder="Search"]
    Fill Text     css=input[placeholder="Search"]    ${search_term}
    Click         css=button[aria-label="Search"], css=button:has-text("🔍"),
    ...           css=button[type="submit"]
    Focus Page
    Log    Search executed for: ${search_term}

Search From List
    [Documentation]
    ...    Clicks the "Search from List" button to open the list-based search dialog,
    ...    then searches within that dialog.
    [Arguments]    ${search_term}
    Wait For Elements State    css=button:has-text("Search from List")
    ...    visible    timeout=${TIMEOUT}
    Click    css=button:has-text("Search from List")
    Wait For Elements State    css=input[placeholder="Search"]    visible    timeout=${TIMEOUT}
    Fill Text    css=input[placeholder="Search"]    ${search_term}
    Click        css=button[aria-label="Search"], css=button[type="submit"]
    Focus Page
    Log    Search from List executed for: ${search_term}

Verify Search Result Count
    [Documentation]    Asserts the number of search result rows matches expected count.
    [Arguments]    ${expected_count}
    ${count}=    Get Element Count    css=table tbody tr
    Should Be Equal As Integers    ${count}    ${expected_count}
    Log    Search result count verified: ${count}

Verify Asset In Search Results
    [Documentation]    Confirms a specific asset file name appears in the search results table.
    [Arguments]    ${file_name}
    Wait For Elements State    css=table tbody    visible    timeout=${TIMEOUT}
    Wait For Elements State    text=${file_name}    visible    timeout=${TIMEOUT}
    Log    Asset found in search results: ${file_name}

Verify Step ID In Search Results
    [Documentation]    Confirms a specific STEP ID link appears in the search results table.
    [Arguments]    ${step_id}
    Wait For Elements State    css=a:has-text("${step_id}")    visible    timeout=${TIMEOUT}
    Log    STEP ID found in search results: ${step_id}

Verify No Search Results
    [Documentation]    Confirms that the search returned no results (empty table).
    ${count}=    Get Element Count    css=table tbody tr
    Should Be Equal As Integers    ${count}    0
    Log    Confirmed: no search results returned

Clear Search
    [Documentation]    Clears the search input field.
    Clear Text    css=input[placeholder="Search"]
    Log    Search field cleared
