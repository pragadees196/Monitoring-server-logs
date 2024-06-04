# Monitoring-server-logs

Doc link : https://docs.google.com/document/d/1T0n6JKiqTzHQF0XRhYtGUSu7N7u_jsYoyGxU6Pbu9r8/


Problem statement:  
	Monitor the Logs of the server and find and alert, if an error occurs in the logs

Language: Shell 
Reason: Even though I'm more comfortable with Python, a shell script might better fit this task. Writing could be simpler and might already have the necessary features built-in. We can still write a Python script to achieve the same outcome.

Idea :
Keeping a list of servers as an array and logging with ssh and pem files into each of them through the loop 
Check the last 15 minutes' logs and look for the error in logs with the grep command 
If we find the error in the logs, we will send mail and Slack alerts and we will look for the system performance at that particular time using top, free, df -h  commands.
We can run this script every 10 minutes using the cron setup crontab -e
Cron expression : */10 * * * *

Deep idea : 
Extra feature - We can use the same script to trigger the alert if, anyone the parameters in CPU, memory, or disk have more than 85% even though we are not having errors in the logs. (Extra idea)
False alarm condition - We anticipate encountering errors for a while after launching this script. Since it runs every 10 minutes, this could lead to excessive alerts being triggered every 10 minutes. To address this, we can introduce a counter flag. If an alert is triggered for the first time, the script will hold off on creating new alerts for the next 30 minutes(SUPPRESS_ALERTS).

Next Verison of script : 
Let's consider, as of now, we do not know the root cause of the error, once the root is figured out, let me consider the temporary fix as restarting the particular service means, we can add the service restart step in the same script.

Where I have used ChatGPT :
1 . I have created a base script (base_script.sh), and I have used ChatGPT to enhance the base script by providing my inputs to it. 
2 . ChatGPT suggested going with a text file that will have having server instead of having it as an array
3 . Used ChatGPT to find the limitations of the script, so that we could figure out the edge conditions
