#! /bin/bash
# Initialising Carelink Automation
# Proof of concept ONLY - 640g csv to NightScout
# *****************************************************************************$
# USER SPECIFIC Variables - Please enter your values here
# *****************************************************************************$
api_secret_hash='6a7437850f23a1bafeb7d22c29353a7e608107a3' # This is the SHA-1 $
your_nightscout='https://t1djlg.herokuapp.com' #'https://something.azurewebsite$
gap_seconds=240 # between polling pump
cron_ok=1 # change to 0 if you don't want to run as cron (set to run at boot ti$
cron_delay=20 # seconds to test if cron started
