#!/bin/bash

# Function to retrieve instance metadata
get_instance_metadata() {
  local metadata_url="http://169.254.169.254/metadata/instance?api-version=2021-02-01"
  local metadata_json=$(curl -s -H Metadata:true --noproxy "*" --retry 3 "$metadata_url")
  if [ $? -eq 0 ]; then
    echo "$metadata_json"
  else
    echo "Failed to retrieve instance metadata."
  fi
}

# Call the function and save the result
instance_metadata=$(get_instance_metadata)

# Check if the metadata is not empty
if [ -n "$instance_metadata" ]; then
  # Format the JSON output for better readability (optional)
  formatted_metadata=$(echo "$instance_metadata" | jq .)

  # Print the formatted metadata
  echo "Azure Instance Metadata:"
  echo "$formatted_metadata"
else
  echo "No metadata available."
fi


