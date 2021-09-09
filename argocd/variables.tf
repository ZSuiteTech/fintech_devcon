variable "cluster_id" {
  description = "cluster id, this blocks until cluster is ready"
  type        = string
}

variable "apps_repo" {
  description = "apps repo for argocd app of apps"
  type = string
  default = "https://github.com/ZSuiteTech/fintech_devcon_charts.git"
}