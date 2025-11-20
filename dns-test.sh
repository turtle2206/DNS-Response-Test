#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [--ip-address <DNS_SERVER>] [--multiple-tests <NUMBER>]"
    echo "    --ip-address <DNS_SERVER>  Specify the DNS server IP address."
    echo "    --multiple-tests <N>        Perform N tests and calculate average response time."
    exit 1
}

# Default values
DNS_SERVER="8.8.8.8"  # Default to Google's public DNS
MULTIPLE_TESTS=1       # Default to 1 test

# Parse command line arguments
while [[ "$1" != "" ]]; do
    case $1 in
        --ip-address )
            shift
            DNS_SERVER=$1
            ;;
        --multiple-tests )
            shift
            MULTIPLE_TESTS=$1
            if ! [[ $MULTIPLE_TESTS =~ ^[0-9]+$ ]]; then
                echo "Error: --multiple-tests value must be a positive integer."
                exit 1
            fi
            ;;
        * )
            usage
    esac
    shift
done

# List of common domains to test
DOMAINS=(
    "google.com" "facebook.com" "amazon.com" "twitter.com" "github.com"
    "linkedin.com" "youtube.com" "wikipedia.org" "stackoverflow.com"
    "reddit.com" "microsoft.com" "apple.com" "yahoo.com" "bing.com"
    "cloudflare.com" "paypal.com" "instagram.com" "netflix.com"
)

# Output header
echo "Testing DNS response times using $DNS_SERVER"
echo "--------------------------------------------------------------"
printf "%-25s %-20s\n" "Domain" "Response Time (ms)"
echo "--------------------------------------------------------------"

# Variables to calculate average response time
TOTAL_TIME=0
COUNT=0

# Perform multiple tests
for (( i=0; i<MULTIPLE_TESTS; i++ )); do
    echo "Test Run: $((i + 1))"
    
    # Loop through each domain and test response time
    for DOMAIN in "${DOMAINS[@]}"; do
        # Measure response time using dig
        RESPONSE_TIME=$(dig +stats @$DNS_SERVER $DOMAIN | grep "Query time:" | awk '{print $4}')

        # Print the response time in milliseconds
        printf "%-25s %-20s via %s\n" "$DOMAIN" "${RESPONSE_TIME} ms" "$DNS_SERVER"

        # Accumulate total response time and count
        TOTAL_TIME=$(( TOTAL_TIME + RESPONSE_TIME ))
        COUNT=$(( COUNT + 1 ))
    done

    echo "--------------------------------------------------------------"
done

# Calculate average response time
if [ $COUNT -ne 0 ]; then
    AVERAGE_TIME=$(( TOTAL_TIME / COUNT ))
else
    AVERAGE_TIME=0
fi

# Output average response time
echo "--------------------------------------------------------------"
printf "%-25s %-20s via %s\n" "Average Query Response Time:" "${AVERAGE_TIME} ms" "$DNS_SERVER"
echo "--------------------------------------------------------------"

# Get ping time to the DNS server
PING_TIME=$(ping -c 1 -W 1 $DNS_SERVER | grep 'time=' | awk -F'=' '{print $4}' | awk '{print $1}')
echo "Ping time to DNS server ($DNS_SERVER): ${PING_TIME} ms"
echo "--------------------------------------------------------------"
