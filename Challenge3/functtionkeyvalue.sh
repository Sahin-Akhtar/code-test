#!/bin/bash

# Function to retrieve a nested value from a JSON object using a key
get_nested_value() {
  local json="$1"
  local key="$2"

  # Use jq to navigate the JSON object
  local result="$(echo "$json" | jq -r "$key")"

  echo "$result"
}

# Example JSON objects
object1='{"a":{"b":{"c":"d"}}}'
object2='{"x":{"y":{"z":"a"}}}'

# Example keys
key1="a/b/c"
key2="x/y/z"

# Retrieve values
value1=$(get_nested_value "$object1" ".${key1//\//.}")
value2=$(get_nested_value "$object2" ".${key2//\//.}")

# Print the values
echo "Value for key '$key1': $value1"
echo "Value for key '$key2': $value2"

