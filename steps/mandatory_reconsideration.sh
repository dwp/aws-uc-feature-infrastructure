#!/usr/bin/env bash
set -Eeuo pipefail

(
    # Import the logging functions
    source /opt/emr/logging.sh

    source /var/ci/resume_step.sh

    function log_wrapper_message() {
        log_aws_uc_feature_message "$${1}" "mandatory_reconsideration.sh" "Running as: ,$USER"
    }

    UC_FEATURE_LOCATION="${uc_feature_scripts_location}" 

    chmod u+x "$UC_FEATURE_LOCATION"/mandatory_reconsideration/mandatory_reconsideration.sh

    S3_PREFIX_FILE=/opt/emr/s3_prefix.txt
    S3_PREFIX=$(cat $S3_PREFIX_FILE)

    PUBLISHED_BUCKET="${published_bucket}"
    TARGET_DB=${target_db}
    SERDE="${serde}"
    LAZY_SERDE="${lazy_serde}"
    SQL_DIR="$UC_FEATURE_LOCATION"/mandatory_reconsideration

    log_wrapper_message "Set the following. published_bucket: $PUBLISHED_BUCKET, target_db: $TARGET_DB, serde: $SERDE, lazy_serde: $LAZY_SERDE, sql_dir: $SQL_DIR, uc_feature_dir: $UC_FEATURE_LOCATION"

    log_wrapper_message "Starting mandatory_reconsideration job"

    "$UC_FEATURE_LOCATION"/mandatory_reconsideration/mandatory_reconsideration.sh "$TARGET_DB" "$S3_PREFIX" "$SERDE" "$LAZY_SERDE" "$SQL_DIR"

    log_wrapper_message "Finished mandatory_reconsideration job"

) >> /var/log/aws_uc_feature/mandatory_reconsideration.log 2>&1
