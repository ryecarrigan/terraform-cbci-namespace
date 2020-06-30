variable "chart_version" {
  default = ""
}

variable "host_name" {}
variable "master_namespace" {}
variable "oc_namespace" {}
variable "release_name" {}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.master_namespace
  }
}

resource "helm_release" "master" {
  depends_on = [kubernetes_namespace.namespace]

  chart      = "cloudbees/cloudbees-core"
  name       = var.release_name
  namespace  = var.master_namespace
  repository = data.helm_repository.cloudbees.metadata[0].name
  values     = [data.template_file.namespace.rendered]
  version    = var.chart_version
}

data "helm_repository" "cloudbees" {
  name = "cloudbees"
  url  = "https://charts.cloudbees.com/public/cloudbees"
}

data "template_file" "namespace" {
  template = file("${path.module}/namespace.yaml")
  vars = {
    host_name    = var.host_name
    oc_namespace = var.oc_namespace
  }
}
