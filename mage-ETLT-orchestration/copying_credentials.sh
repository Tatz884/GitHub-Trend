# Fetch the credentials from Google Secret Manager
echo "Fetching credentials from Google Secret Manager..."
echo "{$GOOGLE_APPLICATION_CREDENTIALS_JSON}" > "${MAGE_CODE_PATH}/secrets/creds.json"

# Verify the credentials file
echo "Verifying credentials file..."
if [ ! -f ${MAGE_CODE_PATH}/secrets/creds.json ]; then
    echo "Credentials file not found, exiting."
    exit 1
fi

echo "Credentials fetched successfully."

# Export the GOOGLE_APPLICATION_CREDENTIALS environment variable
export GOOGLE_APPLICATION_CREDENTIALS=${MAGE_CODE_PATH}/secrets/creds.json

# Proceed with the original command
exec "$@"