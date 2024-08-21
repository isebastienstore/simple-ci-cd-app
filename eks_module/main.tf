resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "MainVPC"
    }
}

resource "aws_subnet" "private_subnet_a" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 0)
    availability_zone = "eu-west-3a"

    tags = {
        Name = "MainVPC-private-a"
    }
}

resource "aws_subnet" "private_subnet_b" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 1)
    availability_zone = "eu-west-3b"

    tags = {
        Name = "MainVPC-private-b"
    }
}

resource "aws_subnet" "public_subnet_a" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 100)
    availability_zone = "eu-west-3a"

    tags = {
        Name = "MainVPC-public-a"
    }
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 101)
    availability_zone = "eu-west-3b"

    tags = {
        Name = "MainVPC-public-b"
    }
}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "MainVPC-InternetGateway"
    }
}

resource "aws_eip" "nat_eip_a" {
    vpc = true
}

resource "aws_eip" "nat_eip_b" {
    vpc = true
}

resource "aws_nat_gateway" "nat_gateway_a" {
    allocation_id = aws_eip.nat_eip_a.id
    subnet_id     = aws_subnet.public_subnet_a.id

    tags = {
        Name = "MainVPC-nat-a"
    }
}

resource "aws_nat_gateway" "nat_gateway_b" {
    allocation_id = aws_eip.nat_eip_b.id
    subnet_id     = aws_subnet.public_subnet_b.id

    tags = {
        Name = "MainVPC-nat-b"
    }
}

resource "aws_route_table" "public_route_table_a" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "MainVPC-route-public-a"
    }
}

resource "aws_route" "public_route_a" {
    route_table_id         = aws_route_table.public_route_table_a.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "public_rt_association_a" {
    subnet_id      = aws_subnet.public_subnet_a.id
    route_table_id = aws_route_table.public_route_table_a.id
}

resource "aws_route_table" "public_route_table_b" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "MainVPC-route-public-b"
    }
}

resource "aws_route" "public_route_b" {
    route_table_id         = aws_route_table.public_route_table_b.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "public_rt_association_b" {
    subnet_id      = aws_subnet.public_subnet_b.id
    route_table_id = aws_route_table.public_route_table_b.id
}

resource "aws_route_table" "private_route_table_a" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "MainVPC-route-private-a"
    }
}

resource "aws_route" "private_route_a" {
    route_table_id         = aws_route_table.private_route_table_a.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gateway_a.id
}

resource "aws_route_table_association" "private_rt_association_a" {
    subnet_id      = aws_subnet.private_subnet_a.id
    route_table_id = aws_route_table.private_route_table_a.id
}

resource "aws_route_table" "private_route_table_b" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "MainVPC-route-private-b"
    }
}

resource "aws_route" "private_route_b" {
    route_table_id         = aws_route_table.private_route_table_b.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gateway_b.id
}

resource "aws_route_table_association" "private_rt_association_b" {
    subnet_id      = aws_subnet.private_subnet_b.id
    route_table_id = aws_route_table.private_route_table_b.id
}

/* ===============================EKS SECTION==========================*/

resource "aws_eks_cluster" "main" {
    name     = "my-eks-cluster"
    role_arn  = aws_iam_role.eks_cluster_role.arn
    version   = "1.21"

    vpc_config {
        subnet_ids = [
            aws_subnet.subnet_public.id
        ]
    }

    tags = {
        Name = "my-eks-cluster"
    }
}

resource "aws_eks_node_group" "main" {
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = "my-node-group"
    node_role_arn   = aws_iam_role.eks_node_role.arn
    subnet_ids      = [
        aws_subnet.subnet_public.id
    ]
    scaling_config {
        desired_size = 2
        max_size     = 3
        min_size     = 1
    }

    tags = {
        Name = "my-node-group"
    }
}


/* ===============================IAM ROLES SECTION==========================*/


resource "aws_iam_role" "eks_cluster_role" {
    name = "eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role       = aws_iam_role.eks_cluster_role.name
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
    name = "eks-node-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
    role       = aws_iam_role.eks_node_role.name
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry" {
    role       = aws_iam_role.eks_node_role.name
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
