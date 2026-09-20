# Session 11: Kubernetes Networking & Services

**Author:** Alisha Patel  
**Course:** SST DevOps & Cloud [SWE]  
**Session:** 11 - Kubernetes Networking & Services  
**Repository:** devops-heros / session11-k8s

---

# Task 1: Kubernetes Port Architecture & Clarification Drill

## Description

Understand the four important Kubernetes port definitions:

- `containerPort`
- `targetPort`
- `port`
- `nodePort`

These ports describe different points in the traffic flow from an external client to the application container.

## Commands

    kubectl explain pod.spec.containers.ports.containerPort
    kubectl explain service.spec.ports

## Architecture Flow

    Client Browser
          |
          v
    nodePort: 30080
    Host / Node IP
          |
          v
    port: 8080
    Kubernetes Service
          |
          v
    targetPort: 80
    Pod Network
          |
          v
    containerPort: 80
    Nginx Container

## Port Definitions

### containerPort

`containerPort` represents the port on which the application inside the container is expected to listen.

It is primarily declarative/informational in the Pod specification and does not by itself expose the application outside the Pod.

### targetPort

`targetPort` identifies the port on the backend Pod where the Service sends traffic.

### port

`port` is the port exposed by the Kubernetes Service inside the cluster.

### nodePort

`nodePort` exposes a Service on a static high port on each eligible worker node.

The standard Kubernetes NodePort range is:

    30000–32767

## Screenshot

![Kubernetes Port Architecture](./screenshots/01-kubernetes-port-architecture.png)

---

# Task 2: Type 1 Service — ClusterIP

## Description

Deploy a three-replica Nginx backend and expose it internally using a `ClusterIP` Service.

Verify the Service, Endpoints, and internal DNS resolution using both the short Service name and the full Kubernetes FQDN.

## Working Directory

    session-11-kubernetes-services/01-clusterip/

## Commands

    kubectl apply -f 01-clusterip/app-deployment.yaml
    kubectl apply -f 01-clusterip/service.yaml

    kubectl get pods -l app=web-clusterip -o wide
    kubectl get svc web-service-clusterip
    kubectl get endpoints web-service-clusterip

    kubectl apply -f 01-clusterip/client-pod.yaml
    kubectl wait --for=condition=ready pod/curl-client --timeout=60s

    kubectl exec -it curl-client -- curl -s http://web-service-clusterip:8080 | grep -i "<title>"

    kubectl exec -it curl-client -- curl -s http://web-service-clusterip.default.svc.cluster.local:8080 | grep -i "<title>"

## Expected Result

The Service should receive a ClusterIP and automatically discover the three backend Pod IP addresses.

The client Pod should successfully access the Nginx application using:

    web-service-clusterip:8080

and:

    web-service-clusterip.default.svc.cluster.local:8080

## Screenshot 2.1

![ClusterIP Service](./screenshots/02-clusterip-service.png)

## Screenshot 2.2

![ClusterIP DNS Resolution](./screenshots/02-clusterip-dns.png)

---

# Task 3: Type 2 Service — NodePort

## Description

Deploy a two-replica Nginx application and expose it externally using a NodePort Service.

The Service uses port `30080` on the cluster nodes.

## Working Directory

    session-11-kubernetes-services/02-nodeport/

## Commands

    kubectl apply -f 02-nodeport/app-deployment.yaml
    kubectl apply -f 02-nodeport/service.yaml

    kubectl get svc web-service-nodeport

    MINIKUBE_IP=$(minikube ip)

    curl -I http://${MINIKUBE_IP}:30080

    minikube service web-service-nodeport --url

## Expected Result

The Service should display a mapping similar to:

    80:30080/TCP

The application should respond successfully through the NodePort.

## Screenshot 3.1

![NodePort Service](./screenshots/03-nodeport-service.png)

## Screenshot 3.2

![NodePort HTTP Response](./screenshots/03-nodeport-http.png)

---

# Task 4: Type 3 Service — LoadBalancer

## Description

Deploy a three-replica workload using a `LoadBalancer` Service.

Use `minikube tunnel` to simulate cloud-provider LoadBalancer functionality and obtain an external IP.

## Working Directory

    session-11-kubernetes-services/03-loadbalancer/

## Commands

    kubectl apply -f 03-loadbalancer/app-deployment.yaml
    kubectl apply -f 03-loadbalancer/service.yaml

    kubectl get svc web-service-loadbalancer

Run the following in a separate terminal:

    minikube tunnel

Then check:

    kubectl get svc web-service-loadbalancer

Retrieve the external IP:

    EXTERNAL_IP=$(kubectl get svc web-service-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

Test the application:

    curl -s http://${EXTERNAL_IP}:80 | grep -i "<title>"

## Expected Result

Before the tunnel, the external IP may show:

    <pending>

After starting `minikube tunnel`, the Service should receive an external IP.

## Screenshot 4.1

![LoadBalancer External IP](./screenshots/04-loadbalancer-external-ip.png)

## Screenshot 4.2

![LoadBalancer Application](./screenshots/04-loadbalancer-application.png)

---

# Task 5: Type 4 Service — ExternalName

## Description

Create an `ExternalName` Service that acts as a DNS CNAME alias to an external domain.

An `ExternalName` Service does not create a ClusterIP or selector-based Endpoints.

## Working Directory

    session-11-kubernetes-services/04-externalname/

## Commands

    kubectl apply -f 04-externalname/service.yaml
    kubectl apply -f 04-externalname/client-pod.yaml

    kubectl wait --for=condition=ready pod/dns-test-client --timeout=60s

Inspect the Service:

    kubectl get svc external-database-service

Test DNS resolution:

    kubectl exec -it dns-test-client -- nslookup external-database-service

Test outbound access:

    kubectl exec -it dns-test-client -- curl -s -k https://external-database-service

## Expected Result

The Service should show:

    TYPE: ExternalName
    CLUSTER-IP: <none>

DNS should resolve the Kubernetes Service name to the configured external domain.

## Screenshot 5.1

![ExternalName Service](./screenshots/05-externalname-service.png)

## Screenshot 5.2

![ExternalName DNS](./screenshots/05-externalname-dns.png)

---

# Task 6: Type 5 Service — Headless Service

## Description

Deploy a three-replica StatefulSet with a Headless Service using:

    clusterIP: None

Unlike a normal ClusterIP Service, a Headless Service does not provide a single virtual IP.

Instead, DNS can return the individual Pod IP addresses.

## Working Directory

    session-11-kubernetes-services/05-headless/

## Commands

    kubectl apply -f 05-headless/service.yaml
    kubectl apply -f 05-headless/app-statefulset.yaml
    kubectl apply -f 05-headless/client-pod.yaml

Wait for the StatefulSet:

    kubectl rollout status statefulset/web-stateful --timeout=120s

Check Pods:

    kubectl get pods -l app=web-headless -o wide

Inspect the Service:

    kubectl get svc web-service-headless

DNS lookup:

    kubectl exec -it headless-dns-client -- nslookup web-service-headless

Lookup an individual StatefulSet Pod:

    kubectl exec -it headless-dns-client -- nslookup web-stateful-0.web-service-headless.default.svc.cluster.local

Test direct Pod access:

    kubectl exec -it headless-dns-client -- curl -s http://web-stateful-0.web-service-headless:80 | grep -i "<title>"

## Expected Result

The Headless Service should have:

    CLUSTER-IP: None

The DNS lookup should return multiple Pod IP addresses.

The StatefulSet Pod should be reachable through its predictable hostname.

## Screenshot 6.1

![Headless Service DNS](./screenshots/06-headless-dns.png)

## Screenshot 6.2

![Stateful Pod DNS](./screenshots/06-stateful-pod-dns.png)

---

# Task 7: Services Without Selectors

## Description

Create a Service without a selector and manually attach an external backend using an `Endpoints` object.

This demonstrates how Kubernetes Services can abstract external infrastructure.

## Step 1: Create Service

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Service
    metadata:
      name: external-legacy-db
    spec:
      ports:
        - protocol: TCP
          port: 3306
          targetPort: 3306
    EOF

## Step 2: Verify Empty Endpoints

    kubectl get endpoints external-legacy-db

Expected:

    <none>

## Step 3: Create Manual Endpoints

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Endpoints
    metadata:
      name: external-legacy-db
    subsets:
      - addresses:
          - ip: 192.168.1.150
        ports:
          - port: 3306
    EOF

## Step 4: Verify Endpoints

    kubectl get endpoints external-legacy-db

## Expected Result

The endpoint should show:

    192.168.1.150:3306

## Screenshot 7.1

![Empty Endpoints](./screenshots/07-empty-endpoints.png)

## Screenshot 7.2

![Manual Endpoints](./screenshots/07-manual-endpoints.png)

---

# Task 8: FQDN & CoreDNS Deep Dive

## Description

Investigate Kubernetes DNS resolution, the FQDN structure, `/etc/resolv.conf`, search domains, and the `ndots:5` configuration.

## Kubernetes FQDN Structure

The standard Kubernetes Service FQDN follows:

    <service>.<namespace>.svc.cluster.local

Example:

    web-service-clusterip.default.svc.cluster.local

## Commands

Check CoreDNS:

    kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide

Inspect DNS configuration inside a Pod:

    kubectl exec -it curl-client -- cat /etc/resolv.conf

Test short-name resolution:

    kubectl exec -it curl-client -- nslookup web-service-clusterip

Test external DNS:

    kubectl exec -it curl-client -- nslookup api.github.com

## Important `/etc/resolv.conf` Fields

### nameserver

Specifies the DNS server used by the Pod.

### search

Specifies domain suffixes that can automatically be appended to short names.

### ndots:5

Specifies that names containing fewer than five dots may first be searched using the configured search domains before being treated as absolute names.

This can result in additional DNS queries for external domains and can therefore add lookup latency.

## Screenshot 8.1

![resolv.conf](./screenshots/08-resolv-conf.png)

## Screenshot 8.2

![CoreDNS Resolution](./screenshots/08-coredns-resolution.png)

---

# Task 9: Pod Identity & Lifecycle — Deployment vs StatefulSet

## Description

Compare the identity behavior of a stateless Deployment and a StatefulSet.

Deployments use disposable Pod identities, while StatefulSets provide predictable ordinal identities.

## Commands

Apply the Deployment:

    kubectl apply -f session-11-kubernetes-services/01-clusterip/app-deployment.yaml

Apply the StatefulSet:

    kubectl apply -f session-11-kubernetes-services/05-headless/service.yaml

    kubectl apply -f session-11-kubernetes-services/05-headless/app-statefulset.yaml

Check Pods:

    kubectl get pods -l app=web-clusterip

    kubectl get pods -l app=web-headless

## Delete a Deployment Pod

    DEPLOY_POD=$(kubectl get pods -l app=web-clusterip -o jsonpath='{.items[0].metadata.name}')

    echo "Deleting Stateless Deployment Pod: ${DEPLOY_POD}"

    kubectl delete pod "${DEPLOY_POD}"

Check again:

    kubectl get pods -l app=web-clusterip

A replacement Pod should have a new generated identity.

## Delete StatefulSet Pod

    echo "Deleting StatefulSet Pod: web-stateful-0"

    kubectl delete pod web-stateful-0

Check again:

    kubectl get pods -l app=web-headless

The StatefulSet should recreate:

    web-stateful-0

## Behavioral Comparison

| Workload | Pod Identity |
|---|---|
| Deployment | New Pod receives a new generated identity |
| StatefulSet | Ordinal identity remains stable |
| Deployment example | `web-app-clusterip-xxxxx-yyyyy` |
| StatefulSet example | `web-stateful-0` |

## Screenshot 9.1

![Deployment vs StatefulSet](./screenshots/09-deployment-statefulset-identity.png)

## Screenshot 9.2

![Pod Recreation](./screenshots/09-pod-recreation.png)

---

# Task 10: Master Architectural Matrix

## Description

Compare Deployment, StatefulSet, and DaemonSet architecture.

## Commands

    kubectl explain deployment.spec

    kubectl explain statefulset.spec

    kubectl explain daemonset.spec

## Architectural Matrix

| Architectural Metric | Deployment | StatefulSet | DaemonSet |
|---|---|---|---|
| Primary Workload Type | Stateless microservices and Web APIs | Stateful databases and distributed systems | Node-level infrastructure agents |
| Pod Naming | Random generated identity | Deterministic ordinal identity | Node-associated identity |
| Pod Identity | Ephemeral | Persistent / stable | Bound to node |
| Startup / Shutdown | Generally parallel | Ordered | Across eligible nodes |
| Storage | Shared or ephemeral storage | Persistent storage per ordinal | HostPath or node-local storage |
| Associated Services | ClusterIP / NodePort / LoadBalancer | Headless Service commonly used for discovery | None or ClusterIP |
| Scaling | Arbitrary replicas | Ordinal scaling | Follows eligible nodes |
| Examples | Nginx, Flask, Node.js API | Kafka, MongoDB, PostgreSQL | Node Exporter, Fluentd, Falco |

## Screenshot

![Controller Architecture Matrix](./screenshots/10-controller-architecture-matrix.png)

---

# Task 11: Production Cost Optimization & Service Selection Decision Tree

## Description

Understand how Kubernetes Service types should be selected based on application requirements.

A common production architecture keeps application Services internal and uses an Ingress layer for HTTP/HTTPS traffic rather than exposing every microservice through an individual cloud LoadBalancer.

## Service Selection Decision Tree

    Need to expose service outside cluster?
                  |
          +-------+-------+
          |               |
         NO              YES
          |               |
          v               v
    Need direct       External third-party
    Pod discovery?       domain?
          |               |
      +---+---+       +---+---+
      |       |       |       |
     YES      NO     YES      NO
      |        |      |        |
      v        v      v        v
   HEADLESS  CLUSTERIP EXTERNALNAME
                              |
                              v
                       Public Cloud?
                              |
                       +------+------+
                       |             |
                      YES            NO
                       |             |
                       v             v
                  HTTP/HTTPS       NODEPORT
                       |
                       v
                    INGRESS
                       |
                       v
               Internal CLUSTERIP
                  Services

## Service Selection Summary

### ClusterIP

Use for normal internal application-to-application communication.

### Headless Service

Use when clients need direct Pod discovery and stable identities, commonly with StatefulSets.

### ExternalName

Use as a DNS alias for an external service/domain.

### NodePort

Useful for development, testing, or environments where direct node-level exposure is required.

### LoadBalancer

Used for external TCP/UDP or direct cloud load-balancing requirements.

### Ingress

Used for HTTP/HTTPS Layer 7 routing across multiple internal Services.

## Cost Optimization Concept

Using a separate cloud LoadBalancer for every microservice can increase infrastructure cost.

A common architecture instead uses:

    Internet
       |
       v
    One External Load Balancer
       |
       v
    Ingress Controller
       |
       +--------+--------+
       |        |        |
       v        v        v
    ClusterIP ClusterIP ClusterIP
       A        B        C

This allows multiple HTTP/HTTPS applications to share a common external entry point.

## Screenshot

![Service Selection Decision Tree](./screenshots/11-service-selection-decision-tree.png)

---

# Task 12: Minikube Docker Driver Port Binding & Tunnel Analysis

## Description

Understand why direct NodePort access can behave differently when Minikube uses the Docker driver.

With the Docker driver, the Minikube node runs inside a Docker container and its internal node network may not be directly reachable from the host in the same way as a bare-metal Kubernetes node.

## Verify NodePort

    kubectl get svc web-service-nodeport

## Retrieve Minikube IP

    NODE_IP=$(minikube ip)

    echo "Testing direct connection to ${NODE_IP}:30080"

    curl --connect-timeout 2 -s http://${NODE_IP}:30080 || echo "Connection Failed"

## Workaround 1: minikube service

Use:

    minikube service web-service-nodeport --url

This provides a host-accessible URL that forwards traffic to the Service.

Test the generated URL with:

    curl -I http://127.0.0.1:<generated-port>

## Workaround 2: minikube tunnel

Start the tunnel in another terminal:

    minikube tunnel

Then inspect Services:

    kubectl get svc

The tunnel provides routing support for Minikube LoadBalancer Services.

## Key Concept

The important distinction is:

    Host
      |
      v
    Docker Network
      |
      v
    Minikube Node Container
      |
      v
    Kubernetes Service
      |
      v
    Pod

The exact networking behavior depends on the operating system and Minikube driver.

## Screenshot 12.1

![Minikube NodePort Network](./screenshots/12-minikube-nodeport-network.png)

## Screenshot 12.2

![Minikube Service URL](./screenshots/12-minikube-service-url.png)

---

# Key Kubernetes Networking Concepts Learned

## ClusterIP

Provides internal cluster networking through a virtual Service IP.

## NodePort

Exposes a Service through a static port on cluster nodes.

## LoadBalancer

Provides an external load-balancing interface when supported by the environment or cloud provider.

## ExternalName

Provides a DNS CNAME-style alias to an external domain.

## Headless Service

Uses `clusterIP: None` and allows DNS to return individual Pod addresses.

## Services Without Selectors

Allow Services to manually reference external endpoints.

## CoreDNS

Provides DNS-based service discovery inside the Kubernetes cluster.

## FQDN

Kubernetes Services can be addressed using:

    <service>.<namespace>.svc.cluster.local

## Deployment Identity

Deployment Pods are replaceable and receive new identities when recreated.

## StatefulSet Identity

StatefulSet Pods have stable ordinal identities such as:

    web-stateful-0
    web-stateful-1
    web-stateful-2

## DaemonSet

A DaemonSet schedules a Pod on each eligible node.

---

# Conclusion

This session covered Kubernetes networking and Service architecture in depth.

The practical work demonstrated the differences between ClusterIP, NodePort, LoadBalancer, ExternalName, and Headless Services.

The session also covered Kubernetes DNS, FQDN resolution, CoreDNS, manual Endpoints, Pod identity behavior, Deployment versus StatefulSet architecture, DaemonSets, Service selection, production networking architecture, and Minikube networking behavior.

---

# Screenshots

The following screenshots will be added to the `screenshots/` directory as the practical tasks are completed:

1. `01-kubernetes-port-architecture.png`
2. `02-clusterip-service.png`
3. `02-clusterip-dns.png`
4. `03-nodeport-service.png`
5. `03-nodeport-http.png`
6. `04-loadbalancer-external-ip.png`
7. `04-loadbalancer-application.png`
8. `05-externalname-service.png`
9. `05-externalname-dns.png`
10. `06-headless-dns.png`
11. `06-stateful-pod-dns.png`
12. `07-empty-endpoints.png`
13. `07-manual-endpoints.png`
14. `08-resolv-conf.png`
15. `08-coredns-resolution.png`
16. `09-deployment-statefulset-identity.png`
17. `09-pod-recreation.png`
18. `10-controller-architecture-matrix.png`
19. `11-service-selection-decision-tree.png`
20. `12-minikube-nodeport-network.png`
21. `12-minikube-service-url.png`
