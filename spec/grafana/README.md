# Grafana

This StatefulSet will create a Grafana instance with the following features:

- Google Auth
- Pre-configured datasources
- Pre-configured organisation
- Pre-configured user roles

Before deploying the YAML, be sure to update any cluster specific values and Grafana config:
```
kubectl apply -f grafana.yml
```
