# eks cluster
resource "aws_eks_cluster" "eks_cluster" {
    name = "${var.project_name}-eks-cluster"
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
      subnet_ids = aws_subnet.eks_subnets[*].id
    }

    depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy, 
    aws_iam_role_policy_attachment.eks_vpc_resource_controller ]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }
  tags = {
    Name = "${var.project_name}-eks-node-group-worker"
  }
    depends_on = [ 
        aws_eks_cluster.eks_cluster 
        ]
}
#TODO:
#aws eks --region eu-west-1 update-kubeconfig --name projeks2024-eks-cluster
#kubectl get namespaces
#kubectl get pods
# change kubectl version
      #change:
      #apiVersion: client.authentication.k8s.io/v1alpha1
      #to:
      #apiVersion: client.authentication.k8s.io/v1beta1


resource "null_resource" "update_kubeconfig" {
  triggers = {
    cluster_name = aws_eks_cluster.eks_cluster.name
    cluster_endpoint = aws_eks_cluster.eks_cluster.endpoint
  }
  provisioner "local-exec" {
    #          aws eks --region eu-west-1 update-kubeconfig --name projeks2024-eks-cluster
    command = "aws eks --region ${var.region} update-kubeconfig --name ${self.triggers.cluster_name}"
    
  }
    depends_on = [
        aws_eks_cluster.eks_cluster, aws_eks_node_group.node_group 
        ]
}


# resource "kubernetes_storage_class" "gp2" {
#   metadata {
#     name = "gp2"
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" = "false" 
#     }
#     }
#     storage_provisioner = "kubernetes.io/aws-ebs"
#     parameters = {
#         type = "gp2"
#     }

#   reclaim_policy = "Retain"
#   allow_volume_expansion = true
# }

resource "kubernetes_storage_class" "default" {
  metadata {
    name = "default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "kubernetes.io/aws-ebs"
  parameters = {
    type = "gp2"
  }

  reclaim_policy = "Retain"
  allow_volume_expansion = true

      depends_on = [ 
        aws_eks_cluster.eks_cluster, 
        aws_eks_node_group.node_group, null_resource.update_kubeconfig 
        ]
}
