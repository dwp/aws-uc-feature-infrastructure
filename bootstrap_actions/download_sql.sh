#!/bin/bash
(
    # Import the logging functions
    source /opt/emr/logging.sh

    SCRIPT_DIR="${aws_uc_feature_scripts_location}" 
    DOWNLOAD_DIR=/opt/emr/downloads

    echo "Creating directories"
    sudo mkdir -p "$DOWNLOAD_DIR"
    sudo mkdir -p "$SCRIPT_DIR"
    sudo chown hadoop:hadoop "$DOWNLOAD_DIR"
    sudo chown hadoop:hadoop "$SCRIPT_DIR"

    function log_wrapper_message() {
        log_aws_aws_uc_feature_message "$${1}" "download_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "Download & install latest aws_uc_feature scripts"
    log_wrapper_message "Downloading & install latest aws_uc_feature scripts"

    VERSION="${version}"
    URL="s3://${s3_artefact_bucket_id}/aws_uc_feature/aws_uc_feature-$VERSION.zip"
    "$(which aws)" s3 cp "$URL" "$DOWNLOAD_DIR"

    echo "aws_uc_feature_VERSION: $VERSION"
    log_wrapper_message "aws_uc_feature_version: $VERSION"

    echo "SCRIPT_DOWNLOAD_URL: $URL"
    log_wrapper_message "script_download_url: $URL"

    echo "Unzipping location: $SCRIPT_DIR"
    log_wrapper_message "script unzip location: $SCRIPT_DIR"

    echo "$version" > /opt/emr/version
    echo "${aws_aws_uc_feature_log_level}" > /opt/emr/log_level
    echo "${environment_name}" > /opt/emr/environment

    echo "START_UNZIPPING ......................"
    log_wrapper_message "start unzipping ......................."

    unzip "$DOWNLOAD_DIR"/aws_uc_feature-"$VERSION".zip -d "$SCRIPT_DIR"  >> /var/log/aws-aws_uc_feature/download_unzip_sql.log 2>&1

    echo "FINISHED UNZIPPING ......................"
    log_wrapper_message "finished unzipping ......................."

)  >> /var/log/aws_uc_feature/download_sql.log 2>&1
