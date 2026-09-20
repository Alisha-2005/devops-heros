# Session 10: Kubernetes Pods, ReplicaSets & Deployments

**Author:** Alisha Patel  
**Course:** SST DevOps & Cloud [SWE]  
**Session:** 10 - Kubernetes Core Objects

---

# Task 1: Cluster Health Verification & Baseline Environment Checks

## Description

Verify that the local Kubernetes cluster control plane, DNS components, and worker nodes are operational before deploying workloads.

## Commands

    kubectl version --output=yaml
    kubectl cluster-info
    kubectl get nodes -o wide

## Output

    [Paste your actual terminal output here]

## Screenshot

![Cluster Health](./screenshots/01-cluster-health.png)

---

# Task 2: Standard Nginx Pod Deployment, Inspection & Teardown

## Description

Create and deploy an individual Nginx Pod. Verify that the Pod is running, inspect its IP address and node placement, view its logs, and then delete it.

## Commands

    kubectl apply -f pod.yml

    kubectl get pods
    kubectl get pods -o wide
    kubectl logs nginx-pod

    kubectl delete -f pod.yml
    kubectl get pods

## Output

    [Paste your actual terminal output here]

## Screenshot

![Nginx Pod Operations](./screenshots/02-nginx-pod-operations.png)

---

# Task 3: ErrImagePull & ImagePullBackOff

## Description

Demonstrate Kubernetes error handling when a Pod references a non-existent container image.

The Pod object can be created, but the container runtime cannot pull the invalid image. Kubernetes reports failure states such as `ErrImagePull` and `ImagePullBackOff`.

## Commands

    kubectl apply -f pod-lifecycle/06-imagepullbackoff.yaml

    kubectl get pods lifecycle-image-error

    kubectl describe pod lifecycle-image-error | grep -A 10 Events:

    kubectl delete -f pod-lifecycle/06-imagepullbackoff.yaml

## Output

    [Paste your actual terminal output here]

## Screenshot

![Image Pull Error](./screenshots/03-imagepullbackoff-error.png)

---

# Task 4: Capturing Transient Pod Lifecycle Stages

## Description

Deploy a short-lived BusyBox container using `restartPolicy: Never` and observe the Pod lifecycle.

The required progression is:

    ContainerCreating → Running → Completed

## Commands

### Terminal 1

    kubectl get pods -w

### Terminal 2

    kubectl apply -f hello.yml

    kubectl get pods hello-pod

    kubectl logs hello-pod

    kubectl delete -f hello.yml

## Output

    [Paste your actual terminal output here]

## Screenshot

![Pod Lifecycle Stages](./screenshots/04-pod-lifecycle-stages.png)

---

# Task 5: Exhaustive Pod Lifecycle States & Probes

## Description

Explore Kubernetes Pod lifecycle states, health probes, initialization containers, multi-container Pods, and graceful termination.

## Lifecycle Manifests

The lab covers:

1. `01-running.yaml` — Running state
2. `02-pending.yaml` — Pending / unschedulable state
3. `03-succeeded.yaml` — Succeeded state
4. `04-failed.yaml` — Failed state
5. `05-crashloopbackoff.yaml` — CrashLoopBackOff
6. `06-imagepullbackoff.yaml` — ImagePullBackOff
7. `07-readiness.yaml` — Readiness Probe
8. `08-liveness.yaml` — Liveness Probe
9. `09-startup.yaml` — Startup Probe
10. `10-init-container.yaml` — Init Container
11. `11-multi-container.yaml` — Multi-container Pod
12. `12-termination.yaml` — Graceful Termination

## Commands

    cd session10-k8s-core-objects/pod-lifecycle/

### Pending State

    kubectl apply -f 02-pending.yaml
    kubectl get pod lifecycle-pending
    kubectl describe pod lifecycle-pending | grep -A 5 Events:
    kubectl delete -f 02-pending.yaml

### CrashLoopBackOff

    kubectl apply -f 05-crashloopbackoff.yaml
    kubectl get pod lifecycle-crashloop -w
    kubectl logs lifecycle-crashloop --previous
    kubectl delete -f 05-crashloopbackoff.yaml

### Readiness Probe

    kubectl apply -f 07-readiness.yaml
    kubectl get pod lifecycle-readiness
    kubectl delete -f 07-readiness.yaml

### Liveness Probe

    kubectl apply -f 08-liveness.yaml
    kubectl get pod lifecycle-liveness -w
    kubectl delete -f 08-liveness.yaml

### Startup Probe

    kubectl apply -f 09-startup.yaml
    kubectl get pod lifecycle-startup
    kubectl delete -f 09-startup.yaml

### Init Container

    kubectl apply -f 10-init-container.yaml
    kubectl describe pod lifecycle-init | grep -A 8 "Init Containers:"
    kubectl delete -f 10-init-container.yaml

### Multi-Container Pod

    kubectl apply -f 11-multi-container.yaml
    kubectl get pod lifecycle-multi-container
    kubectl logs lifecycle-multi-container -c sidecar
    kubectl delete -f 11-multi-container.yaml

### Graceful Termination

    kubectl apply -f 12-termination.yaml
    kubectl delete -f 12-termination.yaml

## Output

    [Paste your actual terminal output here]

## Screenshots

![Lifecycle Probes and CrashLoop](./screenshots/05-lifecycle-probes-crashloop.png)

![Init Container and Multi Container](./screenshots/05-lifecycle-init-multicontainer.png)

---

# Task 6: ReplicaSet & StatefulSet

## Description

Explore Kubernetes controller objects.

A ReplicaSet maintains the desired number of Pod replicas and replaces a Pod when it is deleted.

A StatefulSet provides stable identities and predictable ordinal Pod names.

## ReplicaSet Commands

    kubectl apply -f session10-k8s-core-objects/replicaset.yml

    kubectl get rs nginx-rs
    kubectl get pods -l app=nginx

    POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')

    kubectl delete pod $POD_NAME

    kubectl get pods -l app=nginx

    kubectl delete -f session10-k8s-core-objects/replicaset.yml

## StatefulSet Commands

    kubectl apply -f session10-k8s-core-objects/k8s-core-objects/statefulset.yml

    kubectl get statefulset mysql
    kubectl get pods -l app=mysql

    kubectl delete -f session10-k8s-core-objects/k8s-core-objects/statefulset.yml

## Output

    [Paste your actual terminal output here]

## Screenshot

![ReplicaSet and StatefulSet](./screenshots/06-controllers-rs-statefulset.png)

---

# Task 7: DaemonSet Architecture & Host Agent Deployment

## Description

Deploy a DaemonSet and verify that one Pod instance runs on each eligible worker node.

## Commands

    kubectl apply -f session10-k8s-core-objects/k8s-core-objects/deamonset.yml

    kubectl get ds node-exporter

    kubectl get pods -l app=node-exporter -o wide

    kubectl delete -f session10-k8s-core-objects/k8s-core-objects/deamonset.yml

## Output

    [Paste your actual terminal output here]

## Screenshot

![DaemonSet Verification](./screenshots/07-daemonset-verification.png)

---

# Task 8: Deployment Upgrades, Rolling Updates & Rollbacks

## Description

Demonstrate a rolling update using `maxSurge: 1` and `maxUnavailable: 0`, monitor the rollout, inspect revision history, and perform a rollback.

## Commands

    cd session10-k8s-core-objects/01-rolling-update/

    kubectl apply -f deployment-v1.yaml
    kubectl apply -f service.yaml

    kubectl rollout status deployment/app-rolling

    kubectl apply -f deployment-v2.yaml

    kubectl rollout status deployment/app-rolling

    kubectl get pods -l app=app-rolling --show-labels

    kubectl rollout history deployment/app-rolling

    kubectl rollout undo deployment/app-rolling

    kubectl rollout status deployment/app-rolling

    kubectl delete -f service.yaml -f deployment-v1.yaml

## Output

    [Paste your actual terminal output here]

## Screenshot

![Rolling Update and Rollback](./screenshots/08-rolling-update-and-rollback.png)

---

# Task 9: Real-World Troubleshooting Scenarios

## Description

Troubleshoot two Kubernetes deployment problems:

1. A rollout failure caused by an invalid image.
2. An API server rejection caused by an immutable selector mismatch.

## Drill 1: Broken Image Rollout

    cd session10-k8s-core-objects/troubleshooting/

    kubectl apply -f broken-image.yaml

    kubectl rollout status deployment/yatri-backend --timeout=30s

    kubectl get pods -l app=yatri-backend

    kubectl rollout undo deployment/yatri-backend

    kubectl delete -f broken-image.yaml

## Drill 2: Selector Mismatch

    kubectl apply -f selector-mismatch.yaml

The Deployment should be rejected because the Pod template labels do not match the Deployment selector.

The manifest should then be corrected so:

    spec.template.metadata.labels.app

matches:

    spec.selector.matchLabels.app

After correction, apply the manifest again.

## Output

    [Paste your actual terminal output here]

## Screenshot

![Troubleshooting Drills](./screenshots/09-troubleshooting-drills.png)

---

# Task 10: Theoretical & Architectural Concepts

## 10.1 ContainerPort

`containerPort` represents the port exposed by the application container in the Pod specification.

It is primarily informational and does not itself expose the application outside the Pod.

## 10.2 TargetPort

`targetPort` is the port on the backend Pod to which a Kubernetes Service sends traffic.

## 10.3 Port

`port` is the port exposed by the Kubernetes Service inside the cluster.

## 10.4 NodePort

`nodePort` exposes a Service through a static port on each worker node.

The documented NodePort range is:

    30000–32767

---

## 10.5 Labels vs Selectors

### Labels

Labels are key-value pairs attached to Kubernetes objects.

Example:

    app: nginx
    env: production

### Selectors

Selectors are filters used by Kubernetes controllers and Services to identify objects with matching labels.

---

## 10.6 Deployment Strategies

### RollingUpdate

Gradually replaces old Pods with new Pods.

### Recreate

Terminates the old Pods before creating the new Pods, creating a downtime window.

### Blue-Green

Runs two complete environments and switches Service traffic between them.

### Canary

Runs a small number of new-version Pods alongside the stable version so that only part of the traffic reaches the new version.

---

## 10.7 maxSurge vs maxUnavailable

For:

    replicas: 4
    maxSurge: 1
    maxUnavailable: 0

Maximum Pods during the rollout:

    4 + 1 = 5 Pods

Minimum available Pods:

    4 - 0 = 4 Pods

---

## 10.8 Resource Requests vs Limits

### Requests

Resource requests represent the minimum CPU and memory resources requested for scheduling a Pod.

### Limits

Limits represent the maximum resource usage allowed for the container.

For memory, exceeding the limit can result in the container being terminated due to an out-of-memory condition.

### GB vs GiB

    1 GB  = 1,000,000,000 bytes
    1 GiB = 1,073,741,824 bytes

Kubernetes commonly uses units such as:

    Mi
    Gi

---

# Task 11: Blue-Green Deployment Execution & Instant Selector Cutover

## Description

Deploy Blue and Green environments side-by-side.

Initially route traffic to Blue, switch the Service selector to Green, verify the traffic change, and perform an instant rollback to Blue.

## Commands

    cd session10-k8s-core-objects/02-blue-green/

    kubectl apply -f deployment-blue.yaml
    kubectl apply -f deployment-green.yaml

    kubectl get pods -l app=myapp --show-labels

    kubectl apply -f service-blue.yaml

    kubectl describe svc myapp-service | grep Selector
    kubectl get endpoints myapp-service

    curl -s http://localhost:30020 | grep "ENVIRONMENT"

    kubectl apply -f service-green.yaml

    kubectl describe svc myapp-service | grep Selector
    kubectl get endpoints myapp-service

    curl -s http://localhost:30020 | grep "ENVIRONMENT"

    kubectl apply -f service-blue.yaml

    curl -s http://localhost:30020 | grep "ENVIRONMENT"

    kubectl delete -f service-blue.yaml -f deployment-blue.yaml -f deployment-green.yaml

For Minikube, use the Minikube IP with the configured NodePort if required.

## Expected Observation

Before the switch:

    Selector: app=myapp,slot=blue
    BLUE ENVIRONMENT

After the switch:

    Selector: app=myapp,slot=green
    GREEN ENVIRONMENT

## Output

    [Paste your actual terminal output here]

## Screenshot

![Blue Green Cutover](./screenshots/11-blue-green-cutover.png)

---

# Task 12: Canary Deployment Execution & Pod-Ratio Traffic Splitting

## Description

Deploy a 9-replica stable version and a 1-replica canary version under the same Service.

Observe the approximate traffic distribution, increase the canary percentage, and roll the canary back to zero replicas.

## Commands

    cd session10-k8s-core-objects/03-canary/

    kubectl apply -f deployment-stable.yaml
    kubectl apply -f service.yaml

    kubectl rollout status deployment/app-stable

    kubectl apply -f deployment-canary.yaml
    kubectl rollout status deployment/app-canary

    kubectl get pods -l app=myapp-canary --show-labels

    kubectl get endpoints myapp-canary-service

    for i in $(seq 1 20); do
      curl -s http://localhost:30030 | grep -o "STABLE v1\|CANARY v2"
    done

## Increase Canary Traffic

    kubectl scale deployment app-canary --replicas=3
    kubectl scale deployment app-stable --replicas=7

    kubectl get endpoints myapp-canary-service

## Rollback

    kubectl scale deployment app-canary --replicas=0
    kubectl scale deployment app-stable --replicas=9

    for i in $(seq 1 5); do
      curl -s http://localhost:30030 | grep -o "STABLE v1\|CANARY v2"
    done

## Cleanup

    kubectl delete -f service.yaml -f deployment-canary.yaml -f deployment-stable.yaml

## Output

    [Paste your actual terminal output here]

## Screenshot

![Canary Traffic Split](./screenshots/12-canary-traffic-split.png)

---

# Task 13: Recreate Deployment Execution & Downtime Demonstration

## Description

Deploy an application using:

    strategy.type: Recreate

During the update, the old Pods are terminated before the new Pods are created. This produces a deliberate downtime window.

## Commands

    cd session10-k8s-core-objects/04-recreate/

    kubectl apply -f deployment-v1.yaml
    kubectl apply -f service.yaml

    kubectl rollout status deployment/app-recreate

    kubectl get pods -l app=app-recreate

## Terminal 1 — Watch Pods

    kubectl get pods -l app=app-recreate -w

## Terminal 2 — Monitor Traffic

    while true; do
      curl -s --connect-timeout 1 http://localhost:30040 | grep -o 'VERSION: [^<]*' || echo "[OUTAGE] Connection refused / 0 pods alive"
      sleep 0.5
    done

## Terminal 3 — Trigger Update

    kubectl apply -f deployment-v2.yaml

Observe the transition:

    v1 → OUTAGE → v2

## Rollback

    kubectl rollout history deployment/app-recreate

    kubectl rollout undo deployment/app-recreate

    kubectl rollout status deployment/app-recreate

## Cleanup

    kubectl delete -f service.yaml -f deployment-v2.yaml

## Output

    [Paste your actual terminal output here]

## Screenshot

![Recreate Deployment Downtime](./screenshots/13-recreate-downtime.png)

---

# Key Kubernetes Concepts Learned

## Pod

A Pod is the smallest deployable unit in Kubernetes and can contain one or more containers.

## ReplicaSet

A ReplicaSet maintains the desired number of Pod replicas and replaces Pods when they fail or are deleted.

## StatefulSet

A StatefulSet provides stable Pod identities and predictable ordinal names for stateful workloads.

## DaemonSet

A DaemonSet ensures that a Pod runs on each eligible node.

## Deployment

A Deployment manages application replicas and application version updates.

## Rolling Update

A Rolling Update gradually replaces old Pods with new Pods while maintaining the configured availability.

## Rollback

A rollback allows a Deployment to return to a previous revision.

## Blue-Green Deployment

A Blue-Green deployment maintains two application environments and switches traffic between them using a Service selector.

## Canary Deployment

A Canary deployment introduces a new version gradually by controlling the number of new-version Pods.

## Recreate Strategy

The Recreate strategy terminates existing Pods before creating new Pods and can therefore introduce downtime.

---

# Conclusion

This session covered Kubernetes Pods, Pod lifecycle states, health probes, ReplicaSets, StatefulSets, DaemonSets, Deployments, rolling updates, rollbacks, troubleshooting, Kubernetes networking concepts, deployment strategies, Blue-Green deployments, Canary deployments, and Recreate deployments.

The practical tasks demonstrate how Kubernetes controllers maintain desired state, manage application versions, recover from failures, and control application rollout behavior.

---

# Screenshots

The following screenshots will be added to the `screenshots/` directory as the practical tasks are completed:

1. `01-cluster-health.png`
2. `02-nginx-pod-operations.png`
3. `03-imagepullbackoff-error.png`
4. `04-pod-lifecycle-stages.png`
5. `05-lifecycle-probes-crashloop.png`
6. `05-lifecycle-init-multicontainer.png`
7. `06-controllers-rs-statefulset.png`
8. `07-daemonset-verification.png`
9. `08-rolling-update-and-rollback.png`
10. `09-troubleshooting-drills.png`
11. `11-blue-green-cutover.png`
12. `12-canary-traffic-split.png`
13. `13-recreate-downtime.png`
