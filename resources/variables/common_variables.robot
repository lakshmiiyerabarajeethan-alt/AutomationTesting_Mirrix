*** Variables ***
# Browser settings
${BROWSER}                  chromium
${HEADLESS}                 False
${TIMEOUT}                  30s

# Application URLs
${APP_URL}                  https://dev.mirrix.app
${LOGIN_URL}                ${APP_URL}/login
${UPLOAD_URL}               ${APP_URL}/assets/upload
${COLLECTIONS_URL}          ${APP_URL}/collections
${FOLDERS_URL}              ${APP_URL}/folders

# Credentials — override via CLI: --variable USERNAME:xx --variable PASSWORD:xx
${USERNAME}                 lakshmi@unitofmeasure.com
${PASSWORD}                 Welcome@123

# Test data
${TEST_DATA_DIR}            ${CURDIR}/../../test_data
${EXCEL_FILE}               ${TEST_DATA_DIR}/upload_test_data.xlsx

# Test assets root and subfolders
${ASSETS_DIR}               ${CURDIR}/../../test_assets
${ASSETS_IMAGES_DIR}        ${ASSETS_DIR}/images
${ASSETS_DOCUMENTS_DIR}     ${ASSETS_DIR}/documents
${ASSETS_VIDEOS_DIR}        ${ASSETS_DIR}/videos
${ASSETS_SPREADSHEETS_DIR}  ${ASSETS_DIR}/spreadsheets
${ASSETS_OTHER_DIR}         ${ASSETS_DIR}/other
