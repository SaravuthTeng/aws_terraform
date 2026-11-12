# ==========================================
# 1. VPC & INTERNET GATEWAY
# ==========================================
resource "aws_vpc" "vpc_three_tier" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc-three-tier"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_three_tier.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# ==========================================
# 2. SUBNETS (2 AZs x 3 Tiers = 6 Subnets)
# ==========================================

# Public Subnets (Load Balancer / NAT Gateways)
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc_three_tier.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# Private Subnets (WordPress Application Tier)
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc_three_tier.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 11)
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# Isolated Subnets (RDS / Aurora Database Tier)
resource "aws_subnet" "isolated_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc_three_tier.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 21)
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.environment}-isolated-subnet-${count.index + 1}"
  }
}

# ==========================================
# 3. NAT GATEWAYS & ROUTE TABLES
# ==========================================

# Public Route Table -> Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_three_tier.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IPs & NAT Gateways (1 for UAT, 2 for Prod)
resource "aws_eip" "nat" {
  count  = var.single_nat_gateway ? 1 : 2
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.single_nat_gateway ? 1 : 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }
}

# Private Route Tables -> NAT Gateway
resource "aws_route_table" "private_rt" {
  count  = var.single_nat_gateway ? 1 : 2
  vpc_id = aws_vpc.vpc_three_tier.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.environment}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private_rt[0].id : aws_route_table.private_rt[count.index].id
}

# Isolated Route Table (No Internet or NAT access)
resource "aws_route_table" "isolated_rt" {
  vpc_id = aws_vpc.vpc_three_tier.id

  tags = {
    Name = "${var.environment}-isolated-rt"
  }
}

resource "aws_route_table_association" "isolated_assoc" {
  count          = 2
  subnet_id      = aws_subnet.isolated_subnet[count.index].id
  route_table_id = aws_route_table.isolated_rt.id
}

# ==========================================
# 4. THREE-TIER SECURITY GROUPS
# ==========================================

### Tier 1: Public Load Balancer SG
resource "aws_security_group" "public_sg" {
  name        = "${var.environment}-first-tier-sg"
  vpc_id      = aws_vpc.vpc_three_tier.id
  description = "Allow HTTP and HTTPS traffic from the internet"

  tags = {
    Name = "${var.environment}-public-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "public_https" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "public_to_private" {
  security_group_id            = aws_security_group.public_sg.id
  referenced_security_group_id = aws_security_group.private_sg.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

### Tier 2: Private WordPress App SG
resource "aws_security_group" "private_sg" {
  name        = "${var.environment}-second-tier-sg"
  vpc_id      = aws_vpc.vpc_three_tier.id
  description = "Allow traffic only from public_sg"

  tags = {
    Name = "${var.environment}-private-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_from_public" {
  security_group_id            = aws_security_group.private_sg.id
  referenced_security_group_id = aws_security_group.public_sg.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "private_outbound" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

### Tier 3: Isolated Database SG (RDS / Aurora)
resource "aws_security_group" "isolate_sg" {
  name        = "${var.environment}-third-tier-sg"
  vpc_id      = aws_vpc.vpc_three_tier.id
  description = "Allow MySQL traffic only from private_sg"

  tags = {
    Name = "${var.environment}-isolate-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "isolate_from_private" {
  security_group_id            = aws_security_group.isolate_sg.id
  referenced_security_group_id = aws_security_group.private_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

