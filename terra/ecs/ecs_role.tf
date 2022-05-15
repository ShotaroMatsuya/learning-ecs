# when creating task definition using terraform, we have the option to provide either a task role or an execution roll or both depending on your needs

# former one is  for the IAM role that allows ECS container to make calls to other aws services

# latter one is for the role that the ecs contianer agent & the docker daemon can assume

# we're going to create the latter with a policy tha gives permissions to S3 because that's where the actual docker image layers are stored

# permision to ECR to pull the images, and lastly  permission to push logs to cloudWatch
resource "aws_iam_role" "task_role" {
  name               = "ecs_tasks-${var.name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# the policy that will actually be attached to this particular role
# giving permissions to S3 and ECR to be able to authorize & in additino to be able to actually pull the relevant images, and lastly to be able to have logs being pushed through to cloud watch 
resource "aws_iam_role" "main_ecs_tasks" {
  name               = "main_ecs_tasks-${var.name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "main_ecs_tasks" {
  name = "main_ecs_tasks-${var.name}-policy"
  role = aws_iam_role.main_ecs_tasks.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Resource": [
              "*"
            ],
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:DescribeLogStreams"
            ]
        }
    ]

}
EOF
}
