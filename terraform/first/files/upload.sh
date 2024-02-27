#!/bin/bash

# Read from environment variables
BUCKET_NAME=${BUCKET_NAME}
OBJECT_KEY=${OBJECT_KEY}
EFS_PATH=${EFS_PATH}
EFS_FILE=${EFS_FILE}
LOG_DIR=${LOG_DIR}
LOG_FILE=${LOG_FILE}

# Upload EFS_FILE
echo "Uploading EFS file to S3..."
aws s3 cp "${EFS_PATH}/${EFS_FILE}" "s3://${BUCKET_NAME}/${OBJECT_KEY}"
echo "EFS file uploaded."

# Upload LOG_FILE
echo "Uploading log file to S3..."
aws s3 cp "${LOG_FILE}" "s3://${BUCKET_NAME}/${OBJECT_KEY}"
echo "Log file uploaded."

