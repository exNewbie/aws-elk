############################################################
# Cloud Init template

data "template_file" "ProxySetting" {
  template = "${file("scripts/proxy.cfinit")}"
  vars {
    ElasticsearchAWSLogsDomainEndpoint = "${aws_elasticsearch_domain.ELK-ElasticsearchAWSLogs.endpoint}"
  }
}

data "template_file" "Kibana" {
  template = "${file("scripts/kibana.sh")}"
  vars {
    ProxyUsername = "${var.ProxyUsername}"
    ProxyPass     = "${var.ProxyPass}"
  }
}

data "template_cloudinit_config" "InstanceConfig" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.ProxySetting.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.Kibana.rendered}"
  }
/*
  part {
    content_type = "text/x-shellscript"
    content      = "ffbaz"
  }
  part {
    content = "#cloud-config\n---\npackages:\n - nginx"
  }
*/
}

