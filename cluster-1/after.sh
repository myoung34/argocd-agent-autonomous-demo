#!/bin/bash
principal_context="do-atl1-k8s-1-33-1-principal"
worker_context="do-atl1-k8s-1-33-1-cluster-1"

# get lb ip for agent from principal cluster
agent_ip=$(kubectl --context ${principal_context} -n argocd get svc/argocd-agent-principal -ojson | jq -r '.status.loadBalancer.ingress[0].ip')
argocd-agentctl agent create cluster-1 \
  --principal-context ${principal_context} \
  --principal-namespace argocd \
  --resource-proxy-server ${agent_ip}:9090 \
  --resource-proxy-username cluster-1 \
  --resource-proxy-password "$(openssl rand -base64 32)"

kubectl --context ${principal_context} create namespace cluster-1

argocd-agentctl pki issue agent cluster-1 \
  --principal-context ${principal_context} \
  --agent-context ${worker_context} \
  --agent-namespace argocd \
  --upsert

argocd-agentctl pki propagate \
  --principal-context ${principal_context} \
  --principal-namespace argocd \
  --agent-context ${worker_context} \
  --agent-namespace argocd

kubectl patch configmap argocd-agent-params -n argocd --context ${worker_context} \
  --patch "{\"data\":{
    \"agent.server.address\":\"${agent_ip}\"
  }}"

kubectl rollout restart deployment argocd-agent-agent -n argocd --context ${worker_context}
