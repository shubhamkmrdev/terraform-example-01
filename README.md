#!/bin/bash

# Define the pattern to match within the script
PATTERN="example.com"

# Define the log file
LOG_FILE="/var/log/mail_queue_cleanup.log"

# Define email details
EMAIL_SUBJECT="Mail Queue Cleanup Job Completed"
EMAIL_TO="recipient@example.com"
EMAIL_BODY="/tmp/mail_queue_cleanup_body.txt"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Start logging
log_message "Starting mail queue cleanup for pattern: '$PATTERN'"

# List all deferred emails and filter by the defined pattern
POSTQUEUE_OUTPUT=$(postqueue -p 2>&1)
DEFERRED_EMAILS=$(echo "$POSTQUEUE_OUTPUT" | grep -E "$PATTERN" | awk '{print $1}')

# Check if any emails match the pattern
if [ -z "$DEFERRED_EMAILS" ]; then
    log_message "No deferred emails matching the pattern '$PATTERN' were found."
else
    # Loop through each matched email and delete it
    echo "$DEFERRED_EMAILS" | while read -r QUEUE_ID; do
        log_message "Deleting email with Queue ID: $QUEUE_ID"
        postsuper -d "$QUEUE_ID" 2>&1 | tee -a "$LOG_FILE"
    done
    log_message "Completed deletion of matching deferred emails."
fi

# Prepare the email body
echo "Mail queue cleanup for pattern '$PATTERN' has completed." > "$EMAIL_BODY"
echo "Log file: $LOG_FILE" >> "$EMAIL_BODY"

# Send the email notification
mailx -s "$EMAIL_SUBJECT" "$EMAIL_TO" < "$EMAIL_BODY"

# Clean up temporary email body file
rm "$EMAIL_BODY"
