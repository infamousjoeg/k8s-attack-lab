
for i in {1..2}
do

MARS_NAMESPACE="mars$i"
NODEPORT="3000$i"
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $MARS_NAMESPACE
---
apiVersion: v1
kind: Secret
metadata:
  name: flag
  namespace: $MARS_NAMESPACE
type: Opaque
data:
  flag: eTB1X2FyM190aDNfZjFyc3RfbTRuXzBuX200cnMNCg==
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: frontend
  namespace: $MARS_NAMESPACE
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: redis
  namespace: $MARS_NAMESPACE
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: frontend-get-list-exec-pods-binding
  namespace: $MARS_NAMESPACE
subjects:
- kind: ServiceAccount
  name: frontend
  namespace: $MARS_NAMESPACE
  apiGroup: ""
roleRef:
  kind: Role
  name: get-list-exec-pods
  apiGroup: ""

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: redis-get-secrets-on-pods-binding
  namespace: $MARS_NAMESPACE
subjects:
- kind: ServiceAccount
  name: redis
  namespace: $MARS_NAMESPACE
  apiGroup: ""
roleRef:
  kind: Role
  name: get-secrets-on-pods-to-redis
  apiGroup: ""
---
apiVersion: apps/v1 # apps/v1beta2 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: frontend
  namespace: $MARS_NAMESPACE
  labels:
    app: guestbook
spec:
  selector:
    matchLabels:
      app: guestbook
      tier: frontend
  replicas: 1
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      serviceAccountName: frontend
      containers:
      - name: php-redis
        #image: jaybeale/guestbook-frontend-with-statusphp-vuln:5
        #image:  mydockerid4/vaas-cve-2014-6271
        image:  mydockerid4/ttyd-workshop
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
          # Using `GET_HOSTS_FROM=dns` requires your cluster to
          # provide a dns service. As of Kubernetes 1.3, DNS is a built-in
          # service launched automatically. However, if the cluster you are using
          # does not have a built-in DNS service, you can instead
          # access an environment variable to find the master
          # service's host. To do so, comment out the 'value: dns' line above, and
          # uncomment the line below:
          # value: env
        - name: NAMESPACE
          value: $MARS_NAMESPACE
        ports:
        - containerPort: 7681

---
apiVersion: apps/v1 # apps/v1beta2 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: redis-master
  namespace: $MARS_NAMESPACE
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
      role: master
      tier: backend
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
        role: master
        tier: backend
    spec:
      serviceAccountName: redis
      containers:
      - name: master
        image: k8s.gcr.io/redis:e2e
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379

---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: $MARS_NAMESPACE
  labels:
    app: guestbook
    tier: frontend
spec:
  # comment or delete the following line if you want to use a LoadBalancer
  type: NodePort 
  # if your cluster supports it, uncomment the following to automatically create
  # an external load-balanced IP for the frontend service.
  # type: LoadBalancer
  ports:
  - nodePort: $NODEPORT
    protocol: TCP
    targetPort: 7681
    port: 8018
  selector:
    app: guestbook
    tier: frontend

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: get-list-exec-pods
  namespace: $MARS_NAMESPACE
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["pods"]
  verbs: ["get", "list", "exec"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: get-secrets-on-pods-to-redis
  namespace: $MARS_NAMESPACE
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
  resourceNames: ["flag"]
EOF

done
