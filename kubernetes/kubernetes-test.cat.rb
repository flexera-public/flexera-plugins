name 'kubernetes-test-cat'
rs_ca_ver 20161221
short_description "kubernetes test cat"
long_description "Version: 0.3"
import "kubernetes"
import "sys_log"
info "provider": "AWS", "service": "EC2"

permission "pft_general_permissions" do
  resources "rs_cm.tags", "rs_cm.instances", "rs_cm.audit_entries", "rs_cm.credentials", "rs_cm.clouds", "rs_cm.sessions", "rs_cm.accounts", "rs_cm.publications"
  actions   "rs_cm.*"
end

permission "pft_sensitive_views" do
  resources "rs_cm.credentials" # Currently these actions are not support for instance resources, "rs_cm.instances"
  actions "rs_cm.index_sensitive", "rs_cm.show_sensitive"
end

parameter "kubernetes_host" do
  like $kubernetes.kubernetes_host
end

parameter "kubernetes_key" do
  like $kubernetes.kubernetes_key
end

operation "launch" do
  definition "gen_launch"
end

define gen_launch($kubernetes_host,$kubernetes_key) return $kubernetes_host,$kubernetes_key do
end

output "output_pods" do
  label "Pods"
end

output "output_pod_names" do
  label "Pod Names"
end

output "output_containers" do
  label "Containers"
end

operation "get_pods" do
  definition "get_pods"
  output_mappings do {
    $output_pods => $pods,
    $output_pod_names => $podnames,
    $output_containers => $containers
  } end
end

define get_pods() return @pods,$pods,$podnames,$containers do
  call sys_log.summary("List Pods")
  call sys_log.detail("running get pods")
  call kubernetes.start_debugging()
  @pods = kubernetes.pods.empty()
  sub on_error: kubernetes.stop_debugging() do
    @pods = kubernetes.pods.list()
  end
  call sys_log.detail(to_s(@pods))
  call kubernetes.stop_debugging()
  $pods = to_s(@pods)
  $arr_pod_names = []
  $arr_container_names = []
  foreach @pod in @pods do
    $arr_pod_names << @pod.name
    foreach $container in @pod.containers do
      $arr_container_names << $container["name"]
    end
  end
  $podnames = to_s($arr_pod_names)
  $containers = to_s($arr_container_names)
end