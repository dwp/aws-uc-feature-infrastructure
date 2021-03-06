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
    chmod u+x "$UC_FEATURE_LOCATION"/nationality/nationality.sh

    S3_PREFIX_FILE=/opt/emr/s3_prefix.txt
    S3_PREFIX=$(cat $S3_PREFIX_FILE)

    PUBLISHED_BUCKET="${published_bucket}"
    S3_PATH="$PUBLISHED_BUCKET"/"$S3_PREFIX"
    TARGET_DB=${target_db}
    SERDE="${serde}"
    MANDATORY_DIR="$UC_FEATURE_LOCATION"/mandatory_reconsideration/mandatory_reconsideration.sql
    NATIONALITY_DIR="$UC_FEATURE_LOCATION"/nationality/nationality.sql
    COMMON_SQL="$UC_FEATURE_LOCATION"/common/common.sql
    RETRY_SCRIPT=/var/ci/with_retry.sh
    PROCESSES="${processes}"
    PDM="uc"


    log_wrapper_message "Set the following. published_bucket: $PUBLISHED_BUCKET, target_db: $TARGET_DB, serde: $SERDE, uc_feature_dir: $UC_FEATURE_LOCATION"

    log_wrapper_message "Starting build_uc_feature job"

    #shellcheck disable=SC2034
    declare -a SCRIPT_DIRS=( "$MANDATORY_DIR" "$NATIONALITY_DIR" )

    "$RETRY_SCRIPT" hive    --hivevar DB="$TARGET_DB" \
                            --hivevar SERDE="$SERDE" \
                            --hivevar S3_PREFIX="$S3_PATH" -f "$COMMON_SQL";

    #shellcheck disable=SC2038
    if ! printf '%s\n' "$${SCRIPT_DIRS[@]}" | xargs -n1 -P"$PROCESSES" "$RETRY_SCRIPT" hive \
                --hivevar DB="$TARGET_DB" \
                --hivevar SERDE="$SERDE" \
                --hivevar PDM="$PDM" \
                --hivevar S3_PREFIX="$S3_PATH" -f; then
        echo build_uc_feature failed >&2
        exit 1
    fi

    log_wrapper_message "Finished build_uc_feature job"

) >> /var/log/aws_uc_feature/build_uc_feature.log 2>&1
