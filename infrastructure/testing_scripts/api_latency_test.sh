#!/bin/bash

# Check if URL argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <Base URL>"
    exit 1
fi

# Base URL of the API to test
BASE_URL=$1

# Number of requests to send for testing
NUM_REQUESTS=10

# Initialize variables for total response time and average response time
TOTAL_RESPONSE_TIME=0
AVERAGE_RESPONSE_TIME=0

# Perform latency test
echo "Testing latency for $BASE_URL..."

# Function to send a request and measure latency
send_request() {
    local url=$1
    local index=$2
    local response=$(curl -s -o /dev/null -w "%{time_total}\n" $url)
    echo "Response time for request $index: $response seconds"
    TOTAL_RESPONSE_TIME=$(echo "$TOTAL_RESPONSE_TIME + $response" | bc)
}

# Loop for sending requests and measuring latency in parallel
for ((i=1; i<=$NUM_REQUESTS; i++)); do
    # Generate a random postfix
    RANDOM_POSTFIX=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5 ; echo '')
    # Construct URL with random postfix
    URL="$BASE_URL/$RANDOM_POSTFIX"
    echo "Sending request $i to URL: $URL..."
    # Send request in background
    send_request "$URL" "$i" &
done

# Wait for all background jobs to finish
wait

# Calculate average response time
AVERAGE_RESPONSE_TIME=$(echo "scale=3; $TOTAL_RESPONSE_TIME / $NUM_REQUESTS" | bc)

echo "Average response time: $AVERAGE_RESPONSE_TIME seconds"

echo "Latency test completed."
