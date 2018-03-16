resource "aws_elasticsearch_domain" "ELK-ElasticsearchAWSLogs" {
  domain_name           = "${var.DOMAINNAME}"
  elasticsearch_version = "6.2"

  cluster_config {
    dedicated_master_enabled  = "false"
    instance_count            = "${lookup(var.NodeCount["elasticsearch"], var.ClusterSize)}"
    zone_awareness_enabled    = "false"
    instance_type             = "${lookup(var.InstanceSizing["elasticsearch"], var.ClusterSize)}"
    dedicated_master_type     = "${lookup(var.MasterSizing["elasticsearch"], var.ClusterSize)}"
    dedicated_master_count    = 1
  }

  ebs_options {
    ebs_enabled = "true"
    iops        = 0
    volume_size = 10 # min = 10Gb
    volume_type = "standard" # "gp2"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": { 
              "AWS": "${aws_iam_role.ELK-LoggingMasterRole.arn}"
            },
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/*"
        },
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "IpAddress": {
                  "aws:SourceIp": [ "${aws_eip.ProxyAEIP.public_ip}/32", "${aws_eip.ProxyBEIP.public_ip}/32" ]
                }
            }
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 11
  }

  tags {
    Domain = "ELK"
  }
}
