variable region {
  default     = "ap-southeast-2"
  description = "The AWS region where we want create the resources"
}

provider "aws" {
 region     = "${var.region}"
 profile    = "default"
}

data "aws_caller_identity" "current" {}

variable ESDomain {
  type        = "string"
  description = "Elasticsearch Domain Endpoint for centralized logging"
  default     = "elk"
}

variable ClusterSize {
  type        = "string"
  description = "Amazon ES cluster size (Tiny, Small, Medium or Large), as deployed in primary account"
  default     = "tiny"
}

/*
variable MasterRole {
  type        = "string"
  description = "IAM Role Arn for cross account log indexing"
}
*/
