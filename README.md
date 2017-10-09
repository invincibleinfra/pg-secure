# Purpose

The `pg-secure` image is intended to facilitate setup of a
secure postgres instance.

# Setup

Postgres expects the TLS secret files to be owned either by `root` or by the user that owns the database process.
In the case of the official Postgres docker images (upon which this image is based), that user is `postgres`. This ownership structure
creates some difficulties because `chown` does not work
well within Docker containers. As such, the TLS files must be mounted under the `/tls` directory, which our image will then copy to `/pg-secure/tls` prior to
starting the server.

For example, the following bind mount will work:

```
sudo docker run --rm -p 5432:5432 -v `pwd`/certs:/tls invincibleinfra/pg-secure
```

Note that the `postgresql.conf` used by this postgres instance
sepecifies the following TLS configuration files:

```
ssl_cert_file = '/pg-secure/tls/cert'
ssl_key_file = '/pg-secure/tls/key'
ssl_ca_file = '/pg-secure/tls/ca'
```

# Kubernetes Integration

The file `manifest/deployment.yaml` provides an example of a `pg-secure` Kubernetes deployment. Note the use of Kubernetes secrets to provide the TLS
configuration information:

```
volumes:
  - name: tls-secrets
    secret:
      secretName: pg-tls-secret
      items:
        - key: key
          path: key
          mode: 0600
        - key: cert
          path: cert
        - key: ca
          path: ca
```

The entire set of Kubernetes API objects required to expose this postgres
instance to internal clients may be instantiated as follows:

```
kubectl apply -f manifest/deployment.yaml
kubectl apply -f manifest/service.yaml
```
