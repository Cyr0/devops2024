locals { 
  helm_repo = "${var.jenkins_helm_repo}" 
}

locals { 
  helm_repo_name = "${var.jenkins_helm_repo_name}" 
}

locals {
  helm_chart = "${var.jenkins_helm_chart}"
}
locals {
  namespace = "${var.jenkins_namespace}"
}
