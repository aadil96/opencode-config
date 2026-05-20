# Deployment Workflow

**Owner:** DevOps
**Participants:** QA, Security

## Entry Conditions
- Code reviewed, approved, and merged to target branch
- All CI checks passing
- Release candidate tagged or identified

## Exit Conditions
- Deployment completed successfully
- Post-deployment health checks pass
- Rollback procedure verified and ready

## Flow

1. **QA** — Validate release readiness, sign off on quality gates
2. **DevOps** — Plan deployment sequence, prepare rollback strategy
3. **Security** — Sign off (required for infrastructure changes, permission changes, or network config)
4. **Deploy** — Execute the deployment per plan
5. **Monitor** — Observe metrics, logs, and alerts for anomalies
6. **Verify** — Confirm service health and feature functionality post-deploy

## Gate Checklist

- [ ] Release readiness confirmed (QA)
- [ ] Rollback plan documented and tested (DevOps)
- [ ] Security reviewed if applicable (Security)
- [ ] Deployment executed (DevOps)
- [ ] Post-deployment monitoring shows healthy (DevOps)
- [ ] Stakeholders notified of deployment status (DevOps)
