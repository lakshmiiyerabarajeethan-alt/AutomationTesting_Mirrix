*** Variables ***
# Browser settings
${BROWSER}              chromium
${HEADLESS}             False
${TIMEOUT}              30s

# Application URLs
${APP_URL}              https://dev.mirrix.app
${LOGIN_URL}            ${APP_URL}/login
${UPLOAD_URL}           ${APP_URL}/assets/upload
${COLLECTIONS_URL}      ${APP_URL}/collections
${FOLDERS_URL}          ${APP_URL}/folders

# Credentials — override via CLI: --variable USERNAME:xx --variable PASSWORD:xx
# or set via .env file (loaded at runtime by the pipeline)
${USERNAME}             lakshmi@unitofmeasure.com
${PASSWORD}             Welcome@123

# Test data paths
${TEST_DATA_DIR}        ${CURDIR}/../../test_data
${ASSETS_DIR}           ${TEST_DATA_DIR}/assets
${EXCEL_FILE}           ${TEST_DATA_DIR}/upload_test_data.xlsx
