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

