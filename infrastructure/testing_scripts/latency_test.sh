#!/bin/bash

# Define the URL to test
url=$1

# Number of requests to make
num_requests=10

# Perform latency test
echo "Testing latency for $url..."

total_time=0
successful_requests=0
for ((i=1; i<=$num_requests; i++))
do
    # Perform the request and extract the HTTP status code and time taken
    result=$(curl -s -o /dev/null -w "%{http_code} %{time_total}\n" $url)
    http_code=$(echo $result | cut -d' ' -f1)
    latency=$(echo $result | cut -d' ' -f2)

    if [ $http_code -eq 200 ]; then
        total_time=$(echo $total_time + $latency | bc)
        successful_requests=$((successful_requests + 1))
        echo "Request $i: $latency seconds"
    else
        echo "Request $i: Failed (HTTP $http_code)"
    fi
done

# Calculate average latency
if [ $successful_requests -gt 0 ]; then
    average_latency=$(echo "scale=3; $total_time / $successful_requests" | bc)
    echo "Average latency: $average_latency seconds"
else
    echo "No successful requests, cannot calculate average latency."
fi