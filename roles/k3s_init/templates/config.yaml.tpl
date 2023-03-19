node-ip: $(jq --raw-output '.[].privateIp' /tmp/instanceMetadata.vnics.*.json)
node-ekxternal-ip: $(curl -s ifconfig.co)
token: "${k3s_cluster_token}"
node-label:
  - "kubernetes.io/arch=$(uname -m)"
  - "kubernetes.io/hostname=$(hostname -a)"
  - "topology.kubernetes.io/region=$(jq --raw-output '.region' /tmp/instanceMetadata.instance.*.json)"
  - "topology.kubernetes.io/zone=$(jq --raw-output '.ociAdName' /tmp/instanceMetadata.instance.*.json)"
  - "failure-domain.beta.kubernetes.io/zone=$(jq --raw-output '.faultDomain | ascii_downcase' /tmp/instanceMetadata.instance.*.json)"
  - "cloud.oracle.com/availability-domain=$(jq --raw-output '.ociAdName' /tmp/instanceMetadata.instance.*.json)"
  - "cloud.oracle.com/fault-domain=$(jq --raw-output '.faultDomain | ascii_downcase' /tmp/instanceMetadata.instance.*.json)"
  - "cloud.oracle.com/oci-instance-shape=$(jq --raw-output '.shape' /tmp/instanceMetadata.instance.*.json)"
  - "cloud.oracle.com/oci-instancepool-id=$(jq --raw-output '.instancePoolId | split(".") | .[4]' /tmp/instanceMetadata.instance.*.json)"
  # - "node-role.kubernetes.io/$(jq --raw-output '.definedTags["K3s-NodeInfo"] | .NodeRole' /tmp/instanceMetadata.instance.*.json)=true"
%{ if k3s_node_role == "master" }
# etcd-disable-snapshots: true
# TODO: enable etcd s3 backups
etcd-snapshot-schedule-cron: '0 0 * * *'
etcd-snapshot-retention: 14
etcd-expose-metrics: true
flannel-backend: "none"
disable-cloud-controller: true
kubelet-arg:
- "cloud-provider=external"
- "provider-id=$(jq --raw-output '.id' /tmp/instanceMetadata.instance.*.json)"
write-kubeconfig-mode: "0644"
cluster-cidr: "192.168.0.0/16"
disable-network-policy: true
no-deploy:
  - traefik
  - servicelb
tls-san:
  - "${apiserver_lb_hostname}"
%{ endif }