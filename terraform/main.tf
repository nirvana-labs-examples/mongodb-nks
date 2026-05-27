module "nks" {
  source  = "nirvana-labs/nks/nirvana"
  version = "~> 0.2.0"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  project_id         = var.project_id
  region             = var.region

  node_pools = {
    default = {
      node_count    = var.node_count
      instance_type = var.instance_type
    }
  }

  fetch_kubeconfig = var.fetch_kubeconfig
}

locals {
  mongo_chart_path = "${path.module}/../mongo"
}

# Pre-create the namespace so cluster RBAC grants access to it before
# helm_release runs its preflight. Helm reads existing release secrets
# from the target namespace first, which fails when secret access is
# namespace-scoped.
resource "kubernetes_namespace" "mongo" {
  metadata {
    name = "mongo"
  }
}

# Generated admin password. Terraform owns it via state; the chart picks
# it up by reference (auth.existingSecret), so the chart never templates
# the password into a manifest.
resource "random_password" "mongo_admin" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "mongo_admin" {
  metadata {
    name      = "mongo-admin"
    namespace = kubernetes_namespace.mongo.metadata[0].name
  }
  data = {
    password = random_password.mongo_admin.result
  }
}

resource "helm_release" "mongo" {
  name      = "mongo"
  namespace = kubernetes_namespace.mongo.metadata[0].name
  chart     = local.mongo_chart_path

  values = [file("${local.mongo_chart_path}/values.yaml")]

  set {
    name  = "auth.existingSecret"
    value = kubernetes_secret.mongo_admin.metadata[0].name
  }

  set {
    name  = "replicaSet.members"
    value = var.replica_set_members
  }

  set {
    name  = "persistence.size"
    value = var.storage_size
  }

  # After the initial install, the values.yaml in your fork is the source
  # of truth — edits propagate via your GitOps tooling or `helm upgrade`.
  # Ignoring values/set here prevents Terraform from fighting subsequent
  # changes. The release itself stays in state so `terraform destroy`
  # cleans up.
  lifecycle {
    ignore_changes = [values, set, version]
  }
}

# Read back the operator-generated connection-string Secret. The name
# follows MCK's convention `<crname>-<authdb>-<username>`. The operator
# emits this Secret after the replica set reaches `Phase: Running`;
# expect a 2–3 minute delay after helm_release returns. If the data
# source resolves before the Secret exists, re-run `terraform apply`.
data "kubernetes_secret" "mongo_connection" {
  depends_on = [helm_release.mongo]
  metadata {
    name      = "mongo-admin-admin"
    namespace = kubernetes_namespace.mongo.metadata[0].name
  }
}
