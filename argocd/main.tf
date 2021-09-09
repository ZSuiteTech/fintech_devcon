terraform {
  required_version = ">= 0.12.6"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.3"
    }
  }
}

data "kubectl_file_documents" "namespace" {
    content = file("${path.module}/manifests/namespace.yaml")
} 

data "kubectl_file_documents" "argocd" {
    content = file("${path.module}/manifests/install.yaml")
}

resource "kubectl_manifest" "namespace" {
    count     = length(data.kubectl_file_documents.namespace.documents)
    yaml_body = element(data.kubectl_file_documents.namespace.documents, count.index)
    override_namespace = "argocd"
}

resource "kubectl_manifest" "argocd" {
    depends_on = [
      kubectl_manifest.namespace,
    ]
    count     = length(data.kubectl_file_documents.argocd.documents)
    yaml_body = element(data.kubectl_file_documents.argocd.documents, count.index)
    override_namespace = "argocd"
}

data "kubectl_file_documents" "apps" {
    content = file("${path.module}/manifests/apps.yaml")
}

resource "kubectl_manifest" "apps" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.apps.documents)
    yaml_body = element(data.kubectl_file_documents.apps.documents, count.index)
    override_namespace = "argocd"
}

