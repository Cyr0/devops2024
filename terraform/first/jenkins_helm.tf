# resource "null_resource" "kubectl_wait" {
#   provisioner "local-exec" {
# #     command = "chmod +x ${path.module}/wait4nodes.sh && ${path.module}/wait4nodes.sh"
#     command = "sleep 600"
#   }
#     depends_on = [ aws_eks_cluster.eks_cluster, 
#                    aws_eks_node_group.node_group, 
#                    null_resource.update_kubeconfig ]
# }

resource "null_resource" "helm_add_repo"{
    triggers = {
        always_run = "${timestamp()}"
    }
    provisioner "local-exec" {
        command = "helm repo add ${local.helm_repo_name} ${local.helm_repo} && helm repo update"
    }
}

# resource "null_resource" "helm_add_repo_nginx"{
#     triggers = {
#         always_run = "${timestamp()}"
#     }
#     provisioner "local-exec" {
#         command = "helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update"
#     }
# }
#
#   resource "helm_release" "jenkins" {
#       name       = "jenkins"
#       repository = "https://charts.jenkins.io"
#       chart      = "jenkins"
#       version    = "3.11.3"
#       namespace = "cicd"
#       create_namespace = true
#       timeout = 300

resource "helm_release" "jenkins" {
    name        = "${var.project_name}-jenkins"
    repository  = "${local.helm_repo}"
    chart       = "${local.helm_chart}"
    namespace   = "${local.namespace}"
    version     = "${var.jenkins_version}"
#     namespace = "default"
    create_namespace = true
    timeout = 300 
    set {
        name    = "controller.admin.password"
        value   = "adminPassword"
    }
    set {
        name    = "controller.serviceType"
        value   = "LoadBalancer"
    }

    #depends_on = [ kubernetes_namespace.jenkins, null_resource.helm_add_repo, null_resource.update_kubeconfig ]
    depends_on = [ null_resource.helm_add_repo, null_resource.update_kubeconfig ]

}

# resource "helm_release" "nginx" {
#     name        = "${var.project_name}-nginx"
#     repository  = "https://charts.bitnami.com/bitnami"
#     chart       = "nginx"
#     version     = "15.12.2"
#     namespace   = "default"
#     depends_on  = [ null_resource.helm_add_repo_nginx, 
#                   null_resource.update_kubeconfig, 
#                   null_resource.kubectl_wait ]

# }

