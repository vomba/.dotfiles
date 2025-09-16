# capo-ssh
capo-ssh() {
  local clusterName nodeName
  if [[ "${#}" -lt 2 ]]; then
    echo "Usage: capo-ssh <Openstackcluster name> <Node name>" >&2
    echo "  The Openstackcluster object must be in the 'capi-cluster' namespace" >&2
    return 1
  fi
  clusterName="${1}"
  nodeName="${2}"
  shift 2
  bastionFIP=$(kubectl get openstackcluster -n capi-cluster "${clusterName}" -ojsonpath='{.status.bastion.floatingIP}')
  if [[ -z "${bastionFIP}" ]]; then
    echo "Openstackcluster ${clusterName} doesn't have a bastion with a floation IP" >&2
    return 1
  fi
  nodeIP="$(kubectl get machines.cluster.x-k8s.io -n capi-cluster -ojsonpath='{.items[?(@.status.nodeRef.name=="'"${nodeName}"'")].status.addresses[?(@.type=="InternalIP")].address}')"
  if [[ -z "${nodeIP}" ]]; then
    echo "Node ${nodeName} doesn't have an Internal IP" >&2
    return 1
  fi
  ssh -J "ubuntu@${bastionFIP}" "ubuntu@${nodeIP}" "${@}"
}
_capo-ssh_complete() {
  if [[ "${COMP_CWORD}" -eq 1 ]]; then
    clusters="$(kubectl get openstackcluster.infrastructure.cluster.x-k8s.io -n capi-cluster -ojsonpath='{.items[*].metadata.name}')"
    mapfile -t COMPREPLY < <(compgen -W "${clusters}" -- "$2")
  elif [[ "${COMP_CWORD}" -eq 2 ]]; then
    clusterName="${COMP_WORDS[COMP_CWORD - 1]}"
    nodes="$(kubectl get machines.cluster.x-k8s.io -n capi-cluster -ojsonpath='{.items[?(@.spec.clusterName=="'"${clusterName}"'")].status.nodeRef.name}')"
    mapfile -t COMPREPLY < <(compgen -W "${nodes}" -- "$2")
  fi
}
complete -F _capo-ssh_complete capo-ssh
# vim: ft=sh