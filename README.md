# Haystack RAG Deployment

This repository provides a **Kubernetes-based**, **cloud-agnostic**, **on-premise** deployment solution for the Haystack Retrieval-Augmented Generation (RAG) application. It is designed for production-like environments, deploying all components (Frontend, Backend and OpenSearch) as Kubernetes workloads using manifests and a Helm chart.

---

## Table of Contents

- [Overview](#overview)
- [Assumptions and decisions](#assumptions-and-decisions)
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Verification Steps](#verification-steps)
- [Additional Considerations](#additional-considerations)

---

## Overview

This deployment solution packages the Haystack RAG application into a production-grade Kubernetes environment. It leverages Kubernetes to deploy components (Frontend, Backend, OpenSearch, etc.) as workloads (Deployments, Services, ConfigMaps, Secrets, and Ingress). A Helm chart packages Kubernetes manifests with configurable `values.yaml`. Networking and ingress are configured via **Traefik** to expose frontend and API endpoints accessible via a custom hostname (`rag.local`). Note that the chosen kubernetes distribution (k3s) has built-in a traefik ingress class. If you deploy in another distribution, you would need to ensure it exists.

Next to the helm chart, there are deployable release kubernetes manifests in the `release` directory templated from the helm charts. 

Finally, the `kubernetes-static-routing` folder contains the initial deployment manifests which were used to generate the helm charts. Note that certificates, rbac, ingress and network policies were not used in that minimal setup as the goal was to get the stack up and running.

---

## Assumptions and decisions
- In a production environment, we would use a load balancer to expose traefik to the outside. Since this is supposed to run locally, we are using nodePort services, which is deemed ok for the purpose of this exercise. 
- The helm release is the one being automatically deployed on k3s. There is a second script (`deploy_k8s.sh`) which can be used once the cluster is setup to deploy the release scripts.
- It was chosen to containerize the whole exercise to ensure minimal dependencies with host systems.
- K3s was chosen as a production grade but still minimal kubernetes distro.
- Self signed certificates are used for TLS via cert-manager.
- Network policies and rbac ensure a production like environment in k3s.

---

## Prerequisites

You will need to have the following prerequisites completed. Optionally, you can use either `prerequisites-unix.sh` or `prerequisites-windows.ps1` depending on your operating system to verify or complete the setup.

- Docker installed and running.
- `make` installed (for building source images).
- Ability to modify the local hosts file.

---

## Deployment Steps

### Create your .env file

You will need to create a `.env` file in the `/config` directory following the provided example `.env.example` that includes the opensearch username, password and your openAI key.

### Adjust Hosts File (if you used either of the prerequisites scripts skip this step)

Edit your hosts file:
- Linux/Mac: `/etc/hosts`
- Windows: `C:\Windows\System32\drivers\etc\hosts`

Add the following line:

```bash
127.0.0.1 rag.local
```

### Build Source Images

Execute:

```bash
make build
```

### Build Docker Image

Execute:

```bash
docker build -t haystack-deployment .
```

### Run the Deployment Container

Execute:

```bash
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/config:/app/config" \
  haystack-deployment
```

### Access the Application

Open your browser at:

```
https://rag.local:32090/
```

You will be able to upload a document and use the query functionality. 

## Verification Steps

- **Check Docker container status:**

```bash
docker ps
```

- **Access frontend in browser:**

```bash
https://rag.local:32090/
```

- **Test Traefik Gateway health endpoint:**

In order to test the health endpoint of Traefik, you can port forward the corresponding port and perform a curl command.

```bash
kubectl port-forward svc/haystack-rag-api-gw 8081:8081 -n <namespace_name> & PF_PID=$!; sleep 1; curl http://localhost:8081/ping; kill $PF_PID
```

*Expect a 'OK' response.*

- **Review deployment logs for errors:**

```bash
docker logs <container-id>
```

*Replace `<container-id>` with your actual container ID.*

### Verifying the deployment functionality in k3s cluster ###
Once the deployment inside the container is finished, you will be able to interact with the k3s cluster. Look for this log line:
```bash
[2025-03-09 19:33:36] Deployment complete! You can now interact with your cluster.
```

You can check then the logs for the backend, frontend, traefix and opensearch pods to ensure they are healthy.

Firstly, you can run `kubectl get pods` which, if all works as expected, should show you all pods running:
```bash
$ kubectl get pods -w
NAME                                             READY   STATUS    RESTARTS   AGE
haystack-rag-backend-indexing-586d5b7877-gmqzb   1/1     Running   0          2m14s
haystack-rag-backend-query-59d5ddbbf7-ch8bv      1/1     Running   0          2m14s
haystack-rag-frontend-6f6c6d7cd9-8nffc           1/1     Running   0          2m14s
haystack-rag-gateway-api-gw-dbbb66f96-w7rt9      1/1     Running   0          2m14s
haystack-rag-search-opensearch-0                 1/1     Running   0          2m14s
```

Then, you can check the logs of each pod and look for HTTP 200 OK status:
```bash
kubectl logs <pod-name>
```

If you exit the container and want to enter again, just run:
```bash
docker exec -it <container-id> bash
```

---

## Additional Considerations

For Airgapped Deployment, Integration with Alternative Password Stores and Monitoring and Logging Integration feel free to consult the [Bonus Points Overview](docs/bonus-points-overview.md) doc.

To further improve the k3s cluster setup to mimic a production grade cluster, we can implement a couple more improvements that are documented in the same document.

---
