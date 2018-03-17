data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

#############################################################################
# General vars

variable region {
  default     = "ap-southeast-2"
  description = "The AWS region where we want create the resources"
}

provider "aws" {
 region     = "${var.region}"
 profile    = "default"
}

#############################################################################
# Component vars

variable DOMAINNAME {
  type        = "string"
  description = "Name for the Amazon ES domain that this template will create. Domain names must start with a lowercase letter and must be between 3 and 28 characters. Valid characters are a-z (lowercase only), 0-9, and - (hyphen)"
  default     = "elk"
}

variable ClusterSize {
  type        = "string"
  description = "Amazon ES cluster size - tiny (1 data node), small (2 data nodes), medium (4 data nodes), large (10 data nodes)"
  default     = "tiny"
#  default     = [ "tiny", "small", "medium", "large" ]
}

variable ProxyUsername {
  type        = "string"
  description = "User name for kibana proxy servers"
  default     = "admin"
}

variable ProxyPass {
  type        = "string"
  description = "Password for dashboard access via the proxy server. Must be six characters or longer, and must contain one uppercase letter, one lower case letter, and a special character (!@#$%^&+)"
  default     = "MyPassWord"
}

variable SpokeAccounts {
  type        = "list"
  description = "Account IDs which you want to allow for centralized logging (comma separated list eg. 11111111,22222222)"
  default     = [ "914347413456", "823686041507" ]
}

variable KeyName {
  type        = "string"
  description = "Existing Amazon EC2 key pair for SSH access to the proxy and web servers"
  default     = "aws-workstation"
}

variable TrustedLocation {
  type        = "list"
  description = "IP address range that can SSH into Nginx proxy servers"
  default     = [ "49.255.176.150/32", "52.62.119.220/32" ]
}

variable SSHLocation {
  type        = "string"
  description = "IP address range that can SSH into Nginx proxy servers"
  default     = "122.108.210.113/32"
}

variable VPCCidrP {
  type        = "string"
  description = "CIDR block for VPC"
  default     = "10.249.0.0/16"
}

variable Subnet1 {
  type        = "string"
  description = "IP address range for subnet created in AZ1"
  default     = "10.249.250.0/24"
}

variable Subnet2 {
  type        = "string"
  description = "IP address range for subnet created in AZ2"
  default     = "10.249.249.0/24"
}

variable AmiLinux {
  default     = "ami-942dd1f6"
}

#############################################################################
# Mappings

variable InstanceMap {
  type        = "map"
  default = {
#    "t2.micro"        = "{\"Arch\":\"HVM64\"}"
#    "ap-southeast-2"  = "{\"instancetype\":\"t2.micro\"}"
    "ap-southeast-2"  = {
      "InstanceType"  = "t2.micro",
      "AMI"           = "ami-43874721"
    }
  }
}

variable InstanceSizing {
  type        = "map"
  default = {
    "elasticsearch" = {
      "tiny"    = "t2.small.elasticsearch"
      "small"   = "r4.large.elasticsearch"
      "medium"  = "r4.2xlarge.elasticsearch"
      "large"   = "r4.4xlarge.elasticsearch"
    }
  }
}

variable MasterSizing {
  type        = "map"
  default = {
    "elasticsearch" = {
      "tiny"    = "t2.small.elasticsearch",
      "small"   = "r4.large.elasticsearch",
      "medium"  = "r4.2xlarge.elasticsearch",
      "large"   = "r4.4xlarge.elasticsearch"
    }
  }
}

variable NodeCount {
  type        = "map"
  default = {
    "elasticsearch" = {
      "tiny"    = "1",
      "small"   = "2",
      "medium"  = "4",
      "large"   = "10"
    }
  }
}

variable SourceCode {
  type        = "map"
  default = {
    "General" = {
      "S3Bucket"    = "solutions",
      "KeyPrefix"   = "centralized-logging/latest"
    }
  }
}


#############################################################################
# Outputs

output KibanaURL {
  # Kibana dashboard URL
  value = "http://${aws_lb.ApplicationLoadBalancer.dns_name}/_plugin/kibana/"
}

/*
output DomainEndpoint {
  # ES domain endpoint URL
  value = !Sub ${ElasticsearchAWSLogs.DomainEndpoint}
}

output AmiId {
  # Ami Id vended in template
  value = "${lookup(var.InstanceMap[var.region], "AMI")}"
}

output MasterRole {
  # IAM role for ES cross account access
  value: !Sub ${LoggingMasterRole.Arn}
}

output SpokeAccountIds {
  # Accounts that are allowed to index on ES
  value: !Join [ ',', !Ref SpokeAccounts]
}

output LambdaArn {
  # Lambda function to index logs on ES Domain
  value: !Sub ${LogStreamer.Arn}
}

output ClusterSize {
  # Cluster size for the deployed ES Domain
  value: !Sub ${ClusterSize}
}

output instance_type {
  value = "${lookup(var.InstanceSizing["elasticsearch"], var.ClusterSize)}"
}
*/
