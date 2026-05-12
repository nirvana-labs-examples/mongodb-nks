output "kubeconfig_path" {
  description = "Path to the kubeconfig written for the cluster. Null until fetch_kubeconfig is true."
  value       = module.nks.kubeconfig_path
}

output "mongo_connection_string_cmd" {
  description = "Shell command that prints the operator-generated MongoDB connection-string URI."
  value       = "kubectl get secret mongo-admin-admin -n mongo -o jsonpath='{.data.connectionString\\.standard}' | base64 -d"
}

output "mongo_test_cmd" {
  description = "Shell command that spins up an ephemeral mongosh pod and runs db.runCommand({hello: 1}) against the replica set. eval \"$(terraform output -raw mongo_test_cmd)\" to run."
  value       = <<-EOT
    URI=$(kubectl get secret mongo-admin-admin -n mongo -o jsonpath='{.data.connectionString\.standard}' | base64 -d) && kubectl run -it --rm mongosh --image=mongo:8.0 --restart=Never -- mongosh "$URI" --eval 'db.runCommand({hello: 1})'
  EOT
}
