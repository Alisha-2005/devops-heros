# Session 12: Kubernetes Ingress, ConfigMaps & Secrets

**Author:** Alisha Patel  
**Course:** SST DevOps & Cloud [SWE]  
**Session:** 12 - Kubernetes Ingress, ConfigMaps & Secrets  
**Repository:** devops-heros / session12-k8s

---

# Task 1: ConfigMaps — Environment Variables

## Description

Create a ConfigMap and use it to provide non-sensitive configuration values to a Pod through environment variables.

## Commands

    kubectl create configmap app-config \
      --from-literal=APP_ENV=development \
      --from-literal=APP_VERSION=v1

Verify the ConfigMap:

    kubectl get configmap app-config

    kubectl describe configmap app-config

Create the Pod:

    kubectl apply -f configmap-env.yaml

Check the Pod:

    kubectl get pods

Verify the environment variables:

    kubectl exec configmap-demo -- env | grep APP_

## Expected Output

    APP_ENV=development
    APP_VERSION=v1

## Screenshot

![ConfigMap Environment Variables](./screenshots/01-configmap-environment.png)

---

# Task 2: ConfigMaps — Environment Variables from File

## Description

Create a ConfigMap from a configuration file and inject the values into a Pod.

## Commands

Create the configuration file:

    cat > app.properties <<EOF
    APP_NAME=KubernetesApp
    APP_ENV=development
    LOG_LEVEL=info
    EOF

Create the ConfigMap:

    kubectl create configmap app-properties --from-env-file=app.properties

Verify:

    kubectl get configmap app-properties

    kubectl describe configmap app-properties

Deploy the Pod:

    kubectl apply -f configmap-file.yaml

Check environment variables:

    kubectl exec configmap-file-demo -- env | grep -E 'APP_NAME|APP_ENV|LOG_LEVEL'

## Expected Output

    APP_NAME=KubernetesApp
    APP_ENV=development
    LOG_LEVEL=info

## Screenshot

![ConfigMap From File](./screenshots/02-configmap-file.png)

---

# Task 3: ConfigMaps — Mount as Volume

## Description

Mount a ConfigMap as a volume so that its keys are exposed as files inside the container.

## Commands

    kubectl create configmap nginx-config \
      --from-literal=index.html='Hello from Kubernetes ConfigMap'

Verify:

    kubectl get configmap nginx-config

Deploy:

    kubectl apply -f configmap-volume.yaml

Check the mounted files:

    kubectl exec nginx-config-volume -- ls -la /usr/share/nginx/html

Read the mounted file:

    kubectl exec nginx-config-volume -- cat /usr/share/nginx/html/index.html

## Expected Result

The ConfigMap key should appear as a file inside the mounted directory.

## Screenshot

![ConfigMap Volume](./screenshots/03-configmap-volume.png)

---

# Task 4: Secrets — Create and Use a Secret

## Description

Create a Kubernetes Secret and inject the values into a Pod as environment variables.

Secrets are intended for sensitive configuration such as usernames, passwords, API keys, and tokens.

## Commands

Create the Secret:

    kubectl create secret generic app-secret \
      --from-literal=DB_USER=admin \
      --from-literal=DB_PASSWORD='change-me'

Verify:

    kubectl get secret app-secret

Describe metadata:

    kubectl describe secret app-secret

Deploy the Pod:

    kubectl apply -f secret-env.yaml

Check that the variables exist:

    kubectl exec secret-demo -- env | grep DB_USER

    kubectl exec secret-demo -- sh -c 'test -n "$DB_PASSWORD" && echo "DB_PASSWORD is set"'

Do not print the actual password in the terminal output.

## Expected Result

    DB_USER=admin
    DB_PASSWORD is set

## Screenshot

![Kubernetes Secret](./screenshots/04-secret-environment.png)

---

# Task 5: Secrets — Decode Secret Values

## Description

Inspect the Base64-encoded data stored in a Kubernetes Secret and decode it.

Base64 encoding is an encoding mechanism and should not be treated as encryption.

## Commands

Inspect the Secret:

    kubectl get secret app-secret -o yaml

Decode the username:

    kubectl get secret app-secret -o jsonpath='{.data.DB_USER}' | base64 --decode

Decode the password only for local verification if required:

    kubectl get secret app-secret -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode

## Important Note

Do not commit real passwords, API keys, tokens, or other credentials to GitHub.

For this assignment, use demonstration credentials only.

## Screenshot

![Secret Base64 Data](./screenshots/05-secret-base64.png)

---

# Task 6: ConfigMap vs Secret

## Description

Compare ConfigMaps and Secrets and understand when each should be used.

| Feature | ConfigMap | Secret |
|---|---|---|
| Purpose | Non-sensitive configuration | Sensitive configuration |
| Example | Application mode | Database password |
| Environment Variables | Supported | Supported |
| Volume Mount | Supported | Supported |
| Base64 Data | Not required | Kubernetes Secret data is commonly represented as Base64 |
| Security | Not intended for confidential data | Intended for sensitive configuration |
| Git Storage | Safe only when data is non-sensitive | Do not commit real credentials |

## Examples

### ConfigMap

    APP_ENV=production
    LOG_LEVEL=info
    APP_PORT=8080

### Secret

    DB_USERNAME=admin
    DB_PASSWORD=<sensitive-value>

---

# Task 7: Ingress Controller Installation

## Description

Enable the NGINX Ingress Controller in Minikube and verify that the controller is running.

## Commands

Enable the addon:

    minikube addons enable ingress

Check the Ingress Controller:

    kubectl get pods -n ingress-nginx

Check the Service:

    kubectl get svc -n ingress-nginx

Check the IngressClass:

    kubectl get ingressclass

## Expected Result

The NGINX Ingress Controller Pod should reach the `Running` state.

## Screenshot

![Ingress Controller](./screenshots/07-ingress-controller.png)

---

# Task 8: Ingress — Host-Based Routing

## Description

Create multiple backend Services and use one Ingress resource to route traffic based on the HTTP Host header.

Example:

    app1.local
    app2.local

## Architecture

    Client
      |
      v
    NGINX Ingress Controller
      |
      +----------------+
      |                |
      v                v
    app1 Service    app2 Service
      |                |
      v                v
    app1 Pods        app2 Pods

## Commands

Deploy the applications:

    kubectl apply -f app1-deployment.yaml
    kubectl apply -f app1-service.yaml

    kubectl apply -f app2-deployment.yaml
    kubectl apply -f app2-service.yaml

Apply the Ingress:

    kubectl apply -f host-ingress.yaml

Verify:

    kubectl get ingress

    kubectl describe ingress app-ingress

Get Minikube IP:

    minikube ip

Test using the Host header:

    curl -H "Host: app1.local" http://$(minikube ip)

    curl -H "Host: app2.local" http://$(minikube ip)

## Expected Result

Requests with:

    Host: app1.local

should reach the first application.

Requests with:

    Host: app2.local

should reach the second application.

## Screenshot

![Ingress Host Routing](./screenshots/08-ingress-host-routing.png)

---

# Task 9: Ingress — Path-Based Routing

## Description

Use one host with different URL paths to route requests to different Services.

Example:

    /app1
    /app2

## Architecture

    Client
      |
      v
    example.local
      |
      +-------------------+
      |                   |
    /app1               /app2
      |                   |
      v                   v
    app1 Service       app2 Service

## Commands

Apply the Ingress:

    kubectl apply -f path-ingress.yaml

Verify:

    kubectl get ingress

    kubectl describe ingress path-ingress

Test:

    curl -H "Host: example.local" http://$(minikube ip)/app1

    curl -H "Host: example.local" http://$(minikube ip)/app2

## Expected Result

    /app1 → app1 Service
    /app2 → app2 Service

## Screenshot

![Ingress Path Routing](./screenshots/09-ingress-path-routing.png)

---

# Task 10: Ingress TLS

## Description

Configure HTTPS access through the NGINX Ingress Controller using a TLS Secret.

For this lab, create a self-signed certificate for demonstration purposes.

## Commands

Create a private key and certificate:

    openssl req -x509 -nodes -days 365 \
      -newkey rsa:2048 \
      -keyout tls.key \
      -out tls.crt \
      -subj "/CN=secure.local/O=secure.local"

Create the TLS Secret:

    kubectl create secret tls secure-tls \
      --key tls.key \
      --cert tls.crt

Verify:

    kubectl get secret secure-tls

Apply the TLS Ingress:

    kubectl apply -f tls-ingress.yaml

Verify:

    kubectl get ingress

    kubectl describe ingress secure-ingress

Test HTTPS:

    curl -k -H "Host: secure.local" https://$(minikube ip)

## Expected Result

HTTPS traffic should reach the configured backend through the Ingress Controller.

The `-k` option is used because the certificate is self-signed.

## Screenshot

![Ingress TLS](./screenshots/10-ingress-tls.png)

---

# Task 11: Ingress Troubleshooting

## Description

Troubleshoot common Ingress problems including:

- Ingress Controller not running
- Incorrect Service name
- Incorrect Service port
- Missing IngressClass
- Incorrect hostname
- Incorrect path
- Missing TLS Secret

## Diagnostic Commands

Check Ingress:

    kubectl get ingress

    kubectl describe ingress

Check Services:

    kubectl get svc

Check Endpoints:

    kubectl get endpoints

Check Pods:

    kubectl get pods -o wide

Check Ingress Controller:

    kubectl get pods -n ingress-nginx

View controller logs:

    kubectl logs -n ingress-nginx \
      -l app.kubernetes.io/component=controller

Check IngressClass:

    kubectl get ingressclass

Check DNS / Host routing:

    curl -v -H "Host: example.local" http://$(minikube ip)

## Troubleshooting Checklist

### 1. Controller

Is the NGINX Ingress Controller running?

### 2. Ingress

Does the Ingress resource exist?

### 3. IngressClass

Does the Ingress use the correct controller class?

### 4. Service

Does the backend Service exist?

### 5. Endpoints

Does the Service have healthy endpoints?

### 6. Pods

Are the backend Pods running and ready?

### 7. Port

Does the Ingress point to the correct Service port?

### 8. Host

Is the HTTP Host header correct?

### 9. TLS

Does the referenced TLS Secret exist?

## Screenshot

![Ingress Troubleshooting](./screenshots/11-ingress-troubleshooting.png)

---

# Task 12: Complete Kubernetes Configuration Architecture

## Description

Combine ConfigMaps, Secrets, Services, Deployments, and Ingress into a single application architecture.

## Architecture

    User
      |
      | HTTP / HTTPS
      v
    NGINX Ingress Controller
      |
      v
    Kubernetes Service
      |
      v
    Deployment
      |
      +----------------------+
      |                      |
      v                      v
    Pod 1                  Pod 2
      |                      |
      +----------+-----------+
                 |
          +------+------+
          |             |
          v             v
      ConfigMap       Secret
          |             |
          v             v
      Non-sensitive   Sensitive
      Configuration  Configuration

## Configuration Examples

### ConfigMap

    APP_ENV=production
    LOG_LEVEL=info
    APP_PORT=8080

### Secret

    DB_USERNAME=admin
    DB_PASSWORD=<sensitive-value>

## Commands

Verify all resources:

    kubectl get configmaps

    kubectl get secrets

    kubectl get deployments

    kubectl get pods

    kubectl get svc

    kubectl get ingress

Check the complete application:

    kubectl get all

## Screenshot

![Complete Kubernetes Architecture](./screenshots/12-complete-kubernetes-architecture.png)

---

# Kubernetes Configuration Best Practices

## ConfigMaps

Use ConfigMaps for:

- Environment names
- Application configuration
- Feature flags
- Non-sensitive settings
- Configuration files

Do not use ConfigMaps for passwords or other confidential values.

## Secrets

Use Secrets for:

- Passwords
- API keys
- Tokens
- Database credentials
- TLS certificates

Never commit real Secret values to a public GitHub repository.

## Ingress

Use Ingress when HTTP/HTTPS traffic needs:

- Host-based routing
- Path-based routing
- TLS termination
- Centralized external access
- Routing to multiple internal Services

---

# Key Concepts Learned

## ConfigMap

A Kubernetes object used to store non-sensitive configuration data.

## Secret

A Kubernetes object used to store sensitive configuration data.

## Ingress

An API object that defines HTTP/HTTPS routing rules to Services.

## Ingress Controller

The component that implements the Ingress rules and actually handles incoming traffic.

## TLS

Transport Layer Security provides encrypted HTTPS communication.

## Host-Based Routing

Routes requests according to the HTTP Host header.

## Path-Based Routing

Routes requests according to the URL path.

## Service

Provides a stable networking endpoint for Pods.

## Deployment

Maintains the desired number of application Pods and manages application updates.

---

# Useful Verification Commands

## ConfigMaps

    kubectl get configmaps

    kubectl describe configmap <configmap-name>

## Secrets

    kubectl get secrets

    kubectl describe secret <secret-name>

## Deployments

    kubectl get deployments

    kubectl rollout status deployment/<deployment-name>

## Pods

    kubectl get pods -o wide

## Services

    kubectl get svc

    kubectl get endpoints

## Ingress

    kubectl get ingress

    kubectl describe ingress <ingress-name>

## Ingress Controller

    kubectl get pods -n ingress-nginx

    kubectl logs -n ingress-nginx \
      -l app.kubernetes.io/component=controller

---

# Cleanup

After completing the practical tasks, remove the demonstration resources.

    kubectl delete -f configmap-env.yaml
    kubectl delete -f configmap-file.yaml
    kubectl delete -f configmap-volume.yaml
    kubectl delete -f secret-env.yaml

Remove ConfigMaps and Secrets created through commands:

    kubectl delete configmap app-config
    kubectl delete configmap app-properties
    kubectl delete configmap nginx-config
    kubectl delete secret app-secret
    kubectl delete secret secure-tls

Remove application resources:

    kubectl delete deployments --all
    kubectl delete services --all
    kubectl delete ingress --all

---

# Conclusion

This session covered Kubernetes configuration management and HTTP/HTTPS application routing.

The practical work demonstrated how ConfigMaps provide non-sensitive configuration, how Secrets store sensitive configuration, and how these objects can be consumed by Pods.

The session also covered NGINX Ingress Controller installation, host-based routing, path-based routing, TLS configuration, Ingress troubleshooting, and the architecture connecting users, Ingress, Services, Deployments, Pods, ConfigMaps, and Secrets.

---

# Screenshots

The following screenshots will be added to the `screenshots/` directory as the practical tasks are completed:

1. `01-configmap-environment.png`
2. `02-configmap-file.png`
3. `03-configmap-volume.png`
4. `04-secret-environment.png`
5. `05-secret-base64.png`
6. `07-ingress-controller.png`
7. `08-ingress-host-routing.png`
8. `09-ingress-path-routing.png`
9. `10-ingress-tls.png`
10. `11-ingress-troubleshooting.png`
11. `12-complete-kubernetes-architecture.png`
