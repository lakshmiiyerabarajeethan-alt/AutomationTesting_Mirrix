============================================================
  Mirrix Test Automation — Upload Test Assets
============================================================

Place your real asset files in the correct subfolder below
before running upload tests. Binary files are gitignored
(see .gitignore) — they must be added manually per machine.

FOLDER STRUCTURE:
  test_assets/
  ├── images/         → .jpg  .jpeg  .png  .gif  .bmp  .tiff  .webp
  ├── documents/      → .pdf  .docx  .doc  .txt  .pptx
  ├── videos/         → .mp4  .mov  .avi  .mkv  .webm
  ├── spreadsheets/   → .xlsx  .xls  .csv
  └── other/          → anything that doesn't fit above

HOW TO REFERENCE IN TESTS:
  Variables in common_variables.robot:
    ${ASSETS_DIR}              → test_assets/          (root)
    ${ASSETS_IMAGES_DIR}       → test_assets/images/
    ${ASSETS_DOCUMENTS_DIR}    → test_assets/documents/
    ${ASSETS_VIDEOS_DIR}       → test_assets/videos/
    ${ASSETS_SPREADSHEETS_DIR} → test_assets/spreadsheets/
    ${ASSETS_OTHER_DIR}        → test_assets/other/

  Example in a test:
    ${file}=    Set Variable    ${ASSETS_IMAGES_DIR}${/}product_photo.jpg
    Upload File Via Dialog      ${file}

FILES REFERENCED IN upload_test_data.xlsx:
  images/       sample_image.jpg
  images/       sample_image.png
  documents/    sample_document.pdf
  spreadsheets/ sample_spreadsheet.xlsx
  videos/       sample_video.mp4

TIPS:
  - Keep file sizes small for faster CI runs (< 5 MB each)
  - Use descriptive names: product_hero.jpg not img001.jpg
  - When adding a new asset, also add a row in:
    test_data/upload_test_data.xlsx  (Upload Tests sheet)
============================================================
