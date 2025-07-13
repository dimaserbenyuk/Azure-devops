# Azure-devops
Azure-devops

aws cloudformation create-stack \
  --stack-name ecs-toggle-test \
  --template-body file://ecs-toggle-stack.yaml \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=Active,ParameterValue=true \
  --region us-east-1

aws cloudformation describe-stacks \
  --stack-name ecs-toggle-test \
  --region us-east-1 \
  --query "Stacks[0].StackStatus" | jq .

"CREATE_COMPLETE"

aws ecs describe-services \
  --cluster ecs-toggle-test-cluster \
  --services ecs-toggle-test-svc \
  --region us-east-1 \
  --query "services[0].status" | jq .

"ACTIVE"

aws cloudformation describe-stacks \
  --stack-name ecs-toggle-test \
  --region us-east-1 \
  --query "Stacks[0].Parameters" | jq .

[
  {
    "ParameterKey": "Active",
    "ParameterValue": "true"
  }
]

aws ecs run-task \
  --cluster test-ecs-cluster \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxxxxx],securityGroups=[sg-xxxxxxxx],assignPublicIp=ENABLED}" \
  --task-definition ecs-task-test


export AWS_PAGER=""

export STACK_NAMES="ecs-toggle-test"
export ACTIVE=true
export AWS_REGION=us-east-1

./ecs_toggle.sh

 docker run --rm \
  -e AWS_REGION=us-east-1 \
  -e ACTIVE=false \
  -e STACK_NAMES="ecs-toggle-test" \
  -v ~/.aws:/root/.aws:ro \
  ecs_toggle


  aws cloudformation delete-stack \
  --stack-name ecs-toggle-test \
  --region us-east-1
