#!/bin/bash
set -e

stack_names="${STACK_NAMES}"
active="${ACTIVE}"
region="${AWS_REGION}"

function parse_params {
  python3 <<-EOF
import sys, json
try:
  res=json.loads('''$@''')
  print(' '.join([
    'ParameterKey={},UsePreviousValue=true'.format(x['ParameterKey'])
    for x in res['Stacks'][0].get('Parameters', [])
    if x['ParameterKey'] != 'Active'
  ]))
except Exception as e:
  pass
EOF
}

function get_current_status {
  python3 <<-EOF
import sys, json
try:
  res=json.loads('''$@''')
  print([x['ParameterValue'] for x in res['Stacks'][0].get('Parameters', []) if x['ParameterKey'] == 'Active'][0])
except Exception as e:
  pass
EOF
}

function get_stack_id {
  echo "$1" | jq -r '.Stacks[0].StackId'
}

while read -r stack_name; do
  echo "Processing stack: $stack_name [$(date +'%Y-%m-%d %H:%M:%S')]"
  describe_res=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region "$region")
  current_status=$(get_current_status "$describe_res")
  new_params=$(parse_params "$describe_res")
  stack_id=$(get_stack_id "$describe_res")

  echo "StackId: $stack_id"

  if [ -n "$current_status" ]; then
    if [ "$current_status" = "$active" ]; then
      echo "✔️ Stack '$stack_name' is already in state Active=$active. Skipping..."
    else
      echo "Updating stack '$stack_name' to Active=$active..."
      aws cloudformation update-stack \
        --region "$region" \
        --stack-name "$stack_name" \
        --use-previous-template \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=Active,ParameterValue=$active $new_params
      echo "✅ Stack '$stack_name' updated to Active=$active"
    fi
  else
    echo "⚠️ Stack '$stack_name' does not have parameter 'Active'."
  fi

  echo "------------------------------------------------------------"
done <<< "$stack_names"
