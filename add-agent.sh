#!/bin/bash
principal_context="do-atl1-k8s-1-34-1-do-2-atl1-principal"
worker_context="do-atl1-do-atl1-k8s-1-33-1-cluster-1"
principal_cname="principal.markyoung.us"
namespace="argocd"
agent_name="cluster-1"


# get lb ip for agent from principal cluster
argocd-agentctl agent create ${agent_name} \
  --principal-context ${principal_context} \
  --principal-namespace ${namespace} \
  --resource-proxy-server ${principal_cname}:9090 \
  --resource-proxy-username ${agent_name} \
  --resource-proxy-password "$(openssl rand -base64 32)"

kubectl --context ${principal_context} create namespace ${agent_name}

argocd-agentctl pki issue agent ${agent_name} \
  --principal-context ${principal_context} \
  --agent-context ${worker_context} \
  --agent-namespace ${namespace} \
  --upsert

argocd-agentctl pki propagate \
  --principal-context ${principal_context} \
  --principal-namespace ${namespace} \
  --agent-context ${worker_context} \
  --agent-namespace ${namespace}

kubectl patch configmap argocd-agent-params -n ${namespace} --context ${worker_context} \
  --patch "{\"data\":{
    \"agent.server.address\":\"${principal_cname}\"
  }}"

kubectl rollout restart deployment argocd-agent-agent -n ${namespace} --context ${worker_context}
