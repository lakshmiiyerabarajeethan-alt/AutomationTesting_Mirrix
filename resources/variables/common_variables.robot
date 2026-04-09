*** Variables ***
# Browser settings
${BROWSER}              chromium
${HEADLESS}             False
${TIMEOUT}              30s

# Application URLs — override via .env or CLI: --variable APP_URL:https://...
${APP_URL}              https://your-mirrix-instance.example.com
${LOGIN_URL}            ${APP_URL}/login
${HOMEPAGE_URL}         ${APP_URL}/home

# Credentials — override via CLI: --variable USERNAME:xx --variable PASSWORD:xx
${USERNAME}             your_username
${PASSWORD}             your_password
