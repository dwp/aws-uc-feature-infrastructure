#!/usr/bin/env bash
set -Eeuo pipefail

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_aws_uc_feature_message "$${1}" "mandatory_reconsideration.sh" "Running as: $USER"
    }

    UC_FEATURE_LOCATION="${uc_feature_scripts_location}" 

    chmod u+x "$UC_FEATURE_LOCATION"/mandatory_reconsideration/mandatory_reconsideration.sh
    chmod u+x "$UC_FEATURE_LOCATION"/mandatory_reconsideration/nationality.sh

    S3_PREFIX_FILE=/opt/emr/s3_prefix.txt
    S3_PREFIX=$(cat $S3_PREFIX_FILE)

    PUBLISHED_BUCKET="${published_bucket}"
    TARGET_DB=${target_db}
    SERDE="${serde}"
    LAZY_SERDE="${lazy_serde}"
    MANDATORY_DIR="$UC_FEATURE_LOCATION"/mandatory_reconsideration
    NATIONALITY_DIR="$UC_FEATURE_LOCATION"/nationality
    RETRY_SCRIPT=/var/ci/with_retry.sh
    PROCESSES="${processes}"
    

    log_wrapper_message "Set the following. published_bucket: $PUBLISHED_BUCKET, target_db: $TARGET_DB, serde: $SERDE, lazy_serde: $LAZY_SERDE, sql_dir: $SQL_DIR, uc_feature_dir: $UC_FEATURE_LOCATION"

    log_wrapper_message "Starting build_uc_feature job"

    declare -a SCRIPT_DIRS=( "$MANDATORY_DIR" "$NATIONALITY_DIR" ) 

    #shellcheck disable=SC2038
# here we are finding SQL files and don't have any non-alphanumeric filenames
if ! find "$SCRIPT_DIRS" -name '*.sql' \
    | xargs -n1 -P"$PROCESSES" "$RETRY_SCRIPT" hive \
            --hivevar target_db="$TARGET_DB" \
            --hivevar serde="$SERDE" \
            --hivevar data_path="$S3_PREFIX" -f; then
    echo build model stage failed >&2
    exit 1
fi



    "$MANDATORY_DIR"/mandatory_reconsideration.sh "$TARGET_DB" "$S3_PREFIX" "$SERDE" "$LAZY_SERDE" "$MANDATORY_DIR"

    log_wrapper_message "Finished build_uc_feature job"

) >> /var/log/aws_uc_feature/build_uc_feature.log 2>&1
