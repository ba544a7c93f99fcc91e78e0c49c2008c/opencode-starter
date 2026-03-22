---
name: openshift
description: OpenShift/Kubernetes patterns: Helm, routes, deployments, namespaces
---

## Namespaces — Naming Convention

```
[team]-[project]-[env]
e.g. platform-myproject-dev
     platform-myproject-prod
```

## Deployment — Recommended Patterns

**Always define resource limits:**
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

**Mandatory liveness and readiness probes:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

**Always specify `securityContext`:**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
```

## OpenShift Routes

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-service
spec:
  to:
    kind: Service
    name: my-service
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

Always enforce TLS (`insecureEdgeTerminationPolicy: Redirect`).

## Helm — Best Practices

- One chart per microservice
- `values.yaml` contains default values (dev)
- `values-prod.yaml` overrides only what differs
- Use `helm diff` before any `helm upgrade`
- Version charts with semver

## ConfigMaps and Secrets

- ConfigMaps for non-sensitive configuration
- Secrets for anything sensitive (use External Secrets Operator if available)
- Never commit plain Secrets to git

## Deployment Checklist

- [ ] Resource limits defined
- [ ] Probes configured
- [ ] Non-root securityContext
- [ ] TLS route enabled
- [ ] Secrets externalized
- [ ] Namespace correctly named
