/*
  Proxy EC2 resources
  [ALBSecurityGroup, ALBListener, ApplicationLoadBalancer, ALBTargetGroup, ProxyServerSecurityGroup,
  ProxyAHost, ProxyBHost, ProxyAlarm, ProxyBAlarm, ProxyAEIP, ProxyAEIPAssoc, ProxyBEIP, ProxyBEIPAssoc]
*/

############################################################
# Security Groups

resource "aws_security_group" "ALBSecurityGroup" {
  name        = "ALBSecurityGroup"
  description = "ALB - Port 80 access"
  vpc_id      = "${aws_vpc.PrimerVPC.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "ELK-ALBSecurityGroup"
  }
}

resource "aws_security_group" "ProxyServerSecurityGroup" {
  name        = "ProxyServerSecurityGroup"
  description = "Enable HTTP/80 and SSH/22 access"
  vpc_id      = "${aws_vpc.PrimerVPC.id}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "ELK-ProxyServerSecurityGroup"
  }

}
resource "aws_security_group_rule" "ProxyServerSecurityGroup80" {
  description               = "Enable HTTP/80 access"
  type                      = "ingress"
  from_port                 = 80
  to_port                   = 80
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.ALBSecurityGroup.id}"
  security_group_id  = "${aws_security_group.ProxyServerSecurityGroup.id}"
}

resource "aws_security_group_rule" "ProxyServerSecurityGroup22" {
  description               = "Enable SSH/22 access"
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  cidr_blocks               = [ "${var.SSHLocation}", "${var.TrustedLocation}" ]
  security_group_id  = "${aws_security_group.ProxyServerSecurityGroup.id}"
}

############################################################
# ALB

resource "aws_lb" "ApplicationLoadBalancer" {
  name               = "ApplicationLoadBalancer"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60
  security_groups    = [ "${aws_security_group.ALBSecurityGroup.id}" ]
  subnets            = [ "${aws_subnet.PublicSubnetA.id}", "${aws_subnet.PublicSubnetB.id}" ]

  tags {
    Name = "ELK-ApplicationLoadBalancer"
  }
}

resource "aws_lb_listener" "ALBListener" {
  load_balancer_arn = "${aws_lb.ApplicationLoadBalancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.ALBTargetGroup.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ALBTargetGroup" {
  name                  = "ELK-ALBTargetGroup"
  port                  = 80
  protocol              = "HTTP"
  vpc_id                = "${aws_vpc.PrimerVPC.id}"
  target_type           = "instance"

  health_check          = {
    interval              = 30
    path                  = "/"
    timeout               = 5
    unhealthy_threshold   = 5
    matcher               = "200-499"
  }

  tags                  = {
    Name = "ELK-ALBTargetGroup"
  }
}

/*
Targets :
      - Id: !Sub ${ProxyAHost}
        Port: 80
      - Id: !Sub ${ProxyBHost}
        Port: 80
*/

############################################################
# EC2 instance

resource "aws_instance" "ProxyAHost" {
  ami                           = "${lookup(var.InstanceMap[var.region], "AMI")}"
  instance_type                 = "${lookup(var.InstanceMap[var.region], "InstanceType")}"
  key_name                      = "${var.KeyName}"
  vpc_security_group_ids        = ["${aws_security_group.ProxyServerSecurityGroup.id}"]
  associate_public_ip_address   = "true"
  subnet_id                     = "${aws_subnet.PublicSubnetA.id}"

#  network_interface {
#    device_index          = 0
#    delete_on_termination = "true"
#  }

  tags {
        Name = "ELK-ProxyAHost"
  }

  user_data = "${data.template_cloudinit_config.InstanceConfig.rendered}"
/*
  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y httpd24 php56 php56-mysqlnd
  service httpd start
  chkconfig httpd on
  echo "<?php" >> /var/www/html/calldb.php
  echo "\$conn = new mysqli('mydatabase.linuxacademy.internal', 'root', 'secret', 'test');" >> /var/www/html/calldb.php
  echo "\$sql = 'SELECT * FROM mytable'; " >> /var/www/html/calldb.php
  echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/calldb.php
  echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['mycol'] ;} " >> /var/www/html/calldb.php
  echo "\$conn->close(); " >> /var/www/html/calldb.php
  echo "?>" >> /var/www/html/calldb.php
HEREDOC
*/
}
