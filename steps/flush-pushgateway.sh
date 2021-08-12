#!/bin/bash

# This script waits for a fixed period to give the metrics scraper enough
# time to collect Uc Features metrics. It then deletes all of Uc Features metrics so that
# the scraper doesn't continually gather stale metrics long past Uc Feature's termination.

(
    # Import the logging functions
    source /opt/emr/logging.sh

    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_adg_message "$${1}" "flush-pushgateway.sh" "Running as: ,$USER"
    }

    log_wrapper_message "Sleeping for 3m"

    sleep 180 # scrape interval is 60, scrape timeout is 10, 5 for the pot

    log_wrapper_message "Flushing the Uc Feature pushgateway"
    curl -X PUT "http://${uc_feature_pushgateway_hostname}:9091/api/v1/admin/wipe"
    log_wrapper_message "Done flushing the Uc Feature pushgateway"

) >> /var/log/aws_uc_feature/flush-pushgateway.log 2>&1
