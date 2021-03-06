#!/bin/bash

sudo mkdir -p /var/log/aws_uc_feature
sudo mkdir -p /opt/emr
sudo mkdir -p /opt/shared
sudo mkdir -p /var/ci
sudo chown hadoop:hadoop /var/log/aws_uc_feature
sudo chown hadoop:hadoop /opt/emr
sudo chown hadoop:hadoop /opt/shared
sudo chown hadoop:hadoop /var/ci
export aws_uc_feature_LOG_LEVEL="${aws_uc_feature_LOG_LEVEL}"

echo "${VERSION}" > /opt/emr/version
echo "${aws_uc_feature_LOG_LEVEL}" > /opt/emr/log_level
echo "${ENVIRONMENT_NAME}" > /opt/emr/environment

# Download the logging scripts
$(which aws) s3 cp "${S3_COMMON_LOGGING_SHELL}"  /opt/shared/common_logging.sh
$(which aws) s3 cp "${S3_LOGGING_SHELL}"         /opt/emr/logging.sh

# Set permissions
chmod u+x /opt/shared/common_logging.sh
chmod u+x /opt/emr/logging.sh

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_aws_uc_feature_message "$${1}" "download_scripts.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    log_wrapper_message "Downloading & install latest bootstrap and steps scripts"
    $(which aws) s3 cp --recursive "${scripts_location}/" /var/ci/ --include "*.sh"

    log_wrapper_message "Apply recursive execute permissions to the folder"
    sudo chmod --recursive a+rx /var/ci

    log_wrapper_message "Script downloads completed"

)  >> /var/log/aws_uc_feature/download_scripts.log 2>&1
