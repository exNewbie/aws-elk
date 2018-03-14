############################################################
# Cloud Init template

/*
data "template_file" "NginxDefault" {
  template = "${file("scripts/nginx_default.conf")}"
}
*/

data "template_cloudinit_config" "InstanceConfig" {
  gzip          = false
  base64_encode = false
/*
  part {
    filename     = "init.cfg"
    content_type = "text/part-handler"
    content      = "${data.template_file.script.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "baz"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "ffbaz"
  }
*/
  part {
    content = "#cloud-config\n---\npackages:\n - nginx"
  }
}

