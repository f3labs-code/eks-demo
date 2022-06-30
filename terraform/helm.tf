provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    #cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
      command     = "aws"
    }
  }
}

resource "helm_release" "nginx" {
  name       = "ingress-nginx"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  namespace  = "nginx-ingress"
  create_namespace = true
}