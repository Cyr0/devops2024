output "eks-clsuter" {
    value = aws_eks_cluster.eks_cluster
}

output "eks-clsuter-name" {
    value = aws_eks_cluster.eks_cluster.name
}

output "eks-clsuter-endpoint" {
    value = aws_eks_cluster.eks_cluster.endpoint
}
