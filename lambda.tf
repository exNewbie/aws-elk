resource "aws_lambda_function" "SSM-Automation-CheckSnapshots" {
  filename         = "SSM-Automation-CheckSnapshots.zip"
  function_name    = "SSM-Automation-CheckSnapshots"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-CheckSnapshots.lambda_handler"
  source_code_hash = "${base64sha256(file("SSM-Automation-CheckSnapshots.zip"))}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_function" "SSM-Automation-CreateSnapshots" {
  filename         = "SSM-Automation-CreateSnapshots.zip"
  function_name    = "SSM-Automation-CreateSnapshots"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-CreateSnapshots.lambda_handler"
  source_code_hash = "${base64sha256(file("SSM-Automation-CreateSnapshots.zip"))}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_function" "SSM-Automation-RemoveSnapshotsWithRules" {
  filename         = "SSM-Automation-RemoveSnapshotsWithRules.zip"
  function_name    = "SSM-Automation-RemoveSnapshotsWithRules"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-RemoveSnapshotsWithRules.lambda_handler"
  source_code_hash = "${base64sha256(file("SSM-Automation-RemoveSnapshotsWithRules.zip"))}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_function" "SSM-Automation-ExecuteEBSBackup" {
  filename         = "SSM-Automation-ExecuteEBSBackup.zip"
  function_name    = "SSM-Automation-ExecuteEBSBackup"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-ExecuteEBSBackup.lambda_handler"
  source_code_hash = "${base64sha256(file("SSM-Automation-ExecuteEBSBackup.zip"))}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_permission" "SSM-Automation-ExecuteEBSBackup-Schedule" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.SSM-Automation-ExecuteEBSBackup.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.DailyEBSBackup.arn}"
}
