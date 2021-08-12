#!/usr/bin/env bash
set -Eeuo pipefail

(

    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_aws_uc_feature_message "$${1}" "create-uc-features-dbs.sh" "Running as: ,$USER"
    }

    log_wrapper_message "Creating UC Feature Databases"

    hive -e "CREATE DATABASE IF NOT EXISTS ${uc_feature_db} LOCATION '${published_bucket}/${hive_metastore_location}';"

    log_wrapper_message "Finished creating UC Feature Databases"

) >> /var/log/aws_uc_feature/create_uc_feature_dbs.log 2>&1
