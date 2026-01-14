agent:
* argocd-agent-client-tls is the output from the cert-manager for the -agent from the principal
* argocd-agent-ca is just the crt from the cert-manager for the argocd-agent-ca on the principle

principal:
* `cluster-agentname`: `config` is the cert ca/key/crt from the argocd-agent-principal-tls on the principal, ?agentname is the agentname, name is agent name only. use 'https://argocd-agent-resource-proxy.argocd.svc.cluster.local:9090?agentName=cluster-1'. labels make this show up as an agent to the CLI
* create a cert ca/key/crt for the agent  (-agent) from cert-manager, give that to the agent as agents `argocd-agent-client-tls`
* pass ca.crt only from principal argocd-agent-ca to argocd-agent-ca (as opaque)
