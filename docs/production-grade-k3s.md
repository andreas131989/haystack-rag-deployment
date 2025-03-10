# Improvements

## External Datastore
By default, k3s uses SQLite, which isn’t ideal for HA. We can configure an external datastore (MySQL, PostgreSQL, etc.) to improve data durability and consistency.

## RBAC & Network Policies
Use Role-Based Access Control to enforce least privilege access. Implement network policies to restrict pod-to-pod communication based on security requirements.

## TLS & Certificate Management
Configure the ingress controller with TLS termination. Automate certificate issuance and renewal using cert-manager to secure external communications.

## CI/CD Integration
Automate linting, testing, and deployment of the Helm charts using CI/CD pipelines. This ensures consistency and quick rollbacks in case of issues.
