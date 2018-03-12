resource "aws_lambda_function" "ELK-AMIInfoFunction" {
  function_name    = "ELK-AMIInfoFunction"
  description      = "This function is CloudFormation custom lambda resource that looks up the latest AMI ID."
  role             = "${aws_iam_role.ELK-SolutionHelperRole.arn}"
  handler          = "amilookup.handler"
  runtime          = "nodejs4.3"
  timeout          = "300"
  s3_bucket        = "${join("-", list( lookup(var.SourceCode["General"], "S3Bucket"), var.region )) }"
  s3_key           = "${join("/", list( lookup(var.SourceCode["General"], "KeyPrefix"), "clog-ami-lookup.zip" )) }"
}

resource "aws_lambda_function" "ELK-LogStreamer" {
  function_name    = "ELK-LogStreamer"
  description      = "Centralized Logging - Lambda function to stream logs on ES Domain"
  role             = "${aws_iam_role.ELK-LogStreamerRole.arn}"
  handler          = "index.handler"

  s3_bucket        = "${join("-", list( lookup(var.SourceCode["General"], "S3Bucket"), var.region )) }"
  s3_key           = "${join("/", list( lookup(var.SourceCode["General"], "KeyPrefix"), "clog-indexing-service.zip" )) }"

  runtime          = "nodejs6.10"
  timeout          = "300"
}

resource "aws_lambda_function" "ELK-SolutionHelper" {
  function_name    = "ELK-SolutionHelper"
  description      = "EFS Backup - This function is a CloudFormation custom lambda resource that generates UUID for each deployment."
  role             = "${aws_iam_role.ELK-SolutionHelperRole.arn}"
  handler          = "solution-helper.lambda_handler"
  runtime          = "python2.7"
  timeout          = "300"

  s3_bucket        = "${join("-", list( "solutions", var.region )) }"
  s3_key           = "library/solution-helper/v3/solution-helper.zip"
}
