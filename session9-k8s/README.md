# Session 9: Kubernetes Fundamentals & Cluster Architecture

**Author:** Alisha Patel
**Course:** SST DevOps & Cloud [SWE]
**Session:** 09 - Kubernetes Fundamentals
**Repository:** devops-heros / session9-k8s

---

## Task 1: Minikube & CLI Installation Verification

### Description

Verify that Minikube and the Kubernetes CLI (`kubectl`) are successfully installed on the local system.

### Commands

```bash
minikube version
kubectl version --client
```

### Output

```text
minikube version: v1.39.0
commit: 7a9f6a841470a207de8cf4bafccc ee0969d8ba10
Client Version: v1.36.4
Kustomize Version: v5.8.1
```

### Screenshot

![Minikube and Kubectl Version](./screenshots/01-version-check.png)

---

## Task 2: Starting the Minikube Kubernetes Cluster

### Description

Initialize the local Kubernetes cluster using Minikube.

### Command

```bash
minikube start
```

### Output

```text
minikube start --driver=docker

😄  minikube v1.39.0 on Ubuntu 24.04
✨  Using the docker driver based on existing profile
👍  Starting "minikube" primary control-plane node in "minikube" cluster
📦  Preparing Kubernetes v1.37.0 on containerd 2.3.4 ...
🔎  Verifying Kubernetes components...
🔌  Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏁  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default```

### Screenshot

![Minikube Start](./screenshots/02-minikube-start.png)

---

## Task 3: Verifying Cluster Status & Node Health

### Description

Inspect the status of the Minikube control plane and verify that the Kubernetes node is in the `Ready` state.

### Commands

```bash
minikube status
kubectl get nodes -o wide
```

### Output

```text
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                  KERNEL-VERSION       CONTAINER-RUNTIME
minikube  Ready    control-plane   16d   v1.37.0   192.168.49.2   <none>        Debian GNU/Linux 12      7.0.0-31-generic     containerd://2.3.4```

### Screenshot

![Minikube Status and Nodes](./screenshots/03-minikube-status.png)

---

## Task 4: Stopping the Minikube Cluster

### Description

Gracefully stop the Minikube cluster to release system resources.

### Commands

```bash
minikube stop
minikube status
```

### Output

```text
Stopping node "minikube" ...
Powering off "minikube" via SSH ...
1 node stopped.

minikube
type: Control Plane
host: Stopped
kubelet: Stopped
apiserver: Stopped
kubeconfig: Stopped```

### Screenshot

![Minikube Stop](./screenshots/04-minikube-stop.png)

---

# Task 5: Kubernetes Cluster Architecture & Component Analysis

## 5.1 Control Plane

The Control Plane manages the Kubernetes cluster and maintains the desired state of the system.

### kube-apiserver

The `kube-apiserver` is the front door of the Kubernetes cluster. It exposes the Kubernetes API and handles requests from users, administrators, and other Kubernetes components.

### etcd

`etcd` is the distributed key-value store used by Kubernetes to store cluster state and configuration data.

### kube-scheduler

The `kube-scheduler` watches for newly created Pods that do not yet have an assigned worker node. It evaluates resource requirements and scheduling constraints and selects an appropriate node.

### kube-controller-manager

The `kube-controller-manager` runs controller processes that continuously compare the current cluster state with the desired state and take corrective actions when necessary.

---

## 5.2 Worker Node

Worker Nodes are responsible for running application workloads.

### kubelet

The `kubelet` is the primary agent running on each worker node. It receives Pod specifications and ensures that the required containers are running and healthy.

### kube-proxy

`kube-proxy` maintains network rules on each node and enables Kubernetes Services to route network traffic to Pods.

### Container Runtime

The Container Runtime is responsible for actually running containers. Modern Kubernetes environments commonly use runtimes such as `containerd` or `CRI-O`.

### Pod

A Pod is the smallest deployable unit in Kubernetes. It contains one or more containers that share networking and storage resources.

---

## 5.3 Kubernetes Architecture Flow

```text
                    CONTROL PLANE
        +--------------------------------------+
        |                                      |
        |  kube-apiserver <----> etcd          |
        |        |                             |
        |        +----> kube-scheduler         |
        |        |                             |
        |        +----> controller-manager     |
        |                                      |
        +------------------+-------------------+
                           |
                           |
                    Kubernetes API
                           |
             +-------------+-------------+
             |                           |
             v                           v
       WORKER NODE 1              WORKER NODE 2
    +------------------+       +------------------+
    | kubelet          |       | kubelet          |
    | kube-proxy       |       | kube-proxy       |
    | Container Runtime|       | Container Runtime|
    | Pods             |       | Pods             |
    +------------------+       +------------------+
```

---

## 5.4 How the Components Interact

1. A user or administrator sends a request to the `kube-apiserver`.
2. The API server validates and processes the request.
3. Cluster state is stored in `etcd`.
4. The `kube-scheduler` selects a suitable worker node for newly created Pods.
5. The `kubelet` on the selected worker node receives the Pod specification.
6. The Container Runtime starts the required containers.
7. `kube-proxy` provides the networking rules required for Kubernetes Services.
8. The controller manager continuously monitors the cluster and works to maintain the desired state.

---

## Conclusion

This session covered the basic Kubernetes environment using Minikube and kubectl. It also introduced the Kubernetes cluster architecture, including the Control Plane components and Worker Node components, and explained how these components work together to manage and run containerized workloads.

---

## Screenshots

The following screenshots will be stored in the `screenshots/` directory:

1. `01-version-check.png` — Minikube and kubectl version verification
2. `02-minikube-start.png` — Minikube cluster startup
3. `03-minikube-status.png` — Cluster status and node verification
4. `04-minikube-stop.png` — Minikube cluster shutdown
