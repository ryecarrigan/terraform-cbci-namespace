terraform {
  required_version = ">= 0.12.0"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.master_namespace_name
  }
}

resource "helm_release" "master" {
  depends_on = [kubernetes_namespace.namespace]

  chart      = "cloudbees/cloudbees-core"
  name       = var.release_name
  namespace  = var.master_namespace_name
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
    agent_namespace_enabled = local.agent_namespace_enabled
    agent_namespace_name    = local.agent_namespace_name
    create_agent_namespace  = var.create_agent_namespace
    host_name               = var.host_name
    oc_namespace            = var.oc_namespace_name
  }
}

locals {
  agent_namespace_enabled = var.agent_namespace_name == "" ? false  : true
  agent_namespace_name    = var.agent_namespace_name == "" ? "null" : var.agent_namespace_name
}
