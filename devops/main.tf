### Call module create three tier network for deployment

module "network" {
  source             = "../modules/three-tier-network"
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = true
  app_port           = 80
}

# Example: Plugging module outputs into an Application Load Balancer
resource "aws_lb" "wordpress_alb" {
  name               = "${var.environment}-wordpress-alb"
  load_balancer_type = "application"
  subnets            = module.network.public_subnet_ids
  security_groups    = [module.network.public_sg_id]
}

