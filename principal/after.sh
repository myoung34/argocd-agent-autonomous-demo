#!/bin/bash
principal_context="do-atl1-k8s-1-33-1-principal"
argocd-agentctl pki init \
  --principal-context  ${principal_context} \
  --principal-namespace argocd

# get lb ip for agent
agent_ip=$(kubectl --context ${principal_context} -n argocd get svc/argocd-agent-principal -ojson | jq -r '.status.loadBalancer.ingress[0].ip')
argocd-agentctl pki issue principal \
  --principal-context ${principal_context} \
  --principal-namespace argocd \
  --ip 127.0.0.1,${agent_ip} \
  --dns localhost \
  --upsert

argocd-agentctl pki issue resource-proxy \
  --principal-context ${principal_context} \
  --principal-namespace argocd \
  --ip 127.0.0.1 \
  --dns localhost \
  --upsert

argocd-agentctl jwt create-key \
  --principal-context ${principal_context} \
  --principal-namespace argocd \
  --upsert

kubectl rollout restart deployment argocd-agent-principal -n argocd --context ${principal_context}
