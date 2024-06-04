# Monitoring-server-logs

## Doc link

[Google Docs - Monitoring-server-logs](https://docs.google.com/document/d/1T0n6JKiqTzHQF0XRhYtGUSu7N7u_jsYoyGxU6Pbu9r8/)

## Problem Statement

The objective is to monitor the logs of the server and trigger an alert if an error occurs in the logs.

## Language

Shell

## Reasoning

Although Python is more familiar, a shell script might be better suited for this task. Shell scripting offers simplicity and built-in features conducive to log monitoring tasks. However, a Python script could achieve the same outcome.

## Idea

1. Maintain a list of servers as an array.
2. Iterate through the servers, logging in via SSH using PEM files.
3. Check the logs for errors within the last 15 minutes using the `grep` command.
4. If errors are found, send email and Slack alerts. Additionally, gather system performance metrics at that time using `top`, `free`, and `df -h` commands.
5. Run this script every 10 minutes using a cron job (`crontab -e`). Cron expression: `*/10 * * * *`.

## Deep Idea

1. **Extra Feature**: Extend the script to trigger an alert if CPU, memory, or disk usage exceeds 85%, even in the absence of errors in the logs.
2. **False Alarm Handling**: Implement a counter flag to mitigate excessive alerts. Upon the first alert, suppress further alerts for the next 30 minutes (`SUPPRESS_ALERTS`).

## Next Version of Script

Consider implementing a temporary fix, such as restarting the affected service, once the root cause of the error is identified. This can be integrated into the existing script.


## Usage of ChatGPT

1. Created a base script (`base_script.sh`).
2. Utilized ChatGPT to enhance the base script by providing input.
3. ChatGPT suggested going with a text file that will have the list of servers instead of having it as an array.
4. Utilized ChatGPT to identify limitations of the script, aiding in understanding edge conditions.
