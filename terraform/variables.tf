variable "project_id" {
  description = "Nirvana Labs project ID."
  type        = string
}

variable "region" {
  description = "Nirvana Labs region."
  type        = string
  default     = "us-sva-2"
}

variable "cluster_name" {
  description = "NKS cluster name."
  type        = string
  default     = "mongodb-nks-demo"
}

variable "node_count" {
  description = "Worker node count (single pool). Defaulted to 3 so soft pod anti-affinity can spread replica-set members across nodes."
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Worker instance type."
  type        = string
  default     = "n1-highcpu-2"
}

variable "fetch_kubeconfig" {
  description = "Whether to fetch the cluster kubeconfig and install the MCK operator + replica set. Set to true on the second apply, after the control plane is reachable (~10 min after first apply)."
  type        = bool
  default     = false
}

variable "replica_set_members" {
  description = "Replica-set member count. 3 is the vendor-recommended minimum for a production-shaped deployment."
  type        = number
  default     = 3
}

variable "storage_size" {
  description = "Per-member data PVC size; total cluster storage = size × members."
  type        = string
  default     = "20Gi"
}
