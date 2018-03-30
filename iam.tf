/* ELK-LogStreamerRole */
resource "aws_iam_role" "ELK-LogStreamerRole" {
  name = "ELK-LogStreamerRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ELK-LogStreamer" {
  name   = "ELK-LogStreamer"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ELK-LogStreamerRole-Attach-LogStreamer" {
    role       = "${aws_iam_role.ELK-LogStreamerRole.name}"
    policy_arn = "${aws_iam_policy.ELK-LogStreamer.arn}"
}

resource "aws_iam_role" "ELK-SolutionHelperRole" {
  name = "ELK-SolutionHelperRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ELK-LambdaLoader" {
  name   = "ELK-LambdaLoader"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
        },
        {
            "Effect":   "Allow",
            "Action":   "ec2:DescribeImages",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ELK-SolutionHelperRole-Attach-ELK-LambdaLoader" {
    role       = "${aws_iam_role.ELK-SolutionHelperRole.name}"
    policy_arn = "${aws_iam_policy.ELK-LambdaLoader.arn}"
}

resource "aws_iam_role" "ELK-LoggingMasterRole" {
  name = "ELK-LoggingMasterRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_caller_identity.current.account_id}",
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ELK-LoggingMasterPolicies" {
  name   = "ELK-LoggingMasterPolicies"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "es:ESHttpPost"
            ],
            "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:domain/*"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ELK-LoggingMasterRole-Attach-ELK-LoggingMasterPolicies" {
    role       = "${aws_iam_role.ELK-LoggingMasterRole.name}"
    policy_arn = "${aws_iam_policy.ELK-LoggingMasterPolicies.arn}"
}

