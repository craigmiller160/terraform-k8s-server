# Setup Port Forwarding

It is critically important that the home internet be setup to forward the following ports. This explains how the ports will be forwarded from the production machine to the public internet.

For this to work the Ubuntu prod machine needs to have a permanent LAN IP assigned by the router.

## Port Table

| Application             | Server Port | Public Port |
|-------------------------|-------------|-------------|
| Cluster Ingress (HTTP)  | 31101       | 80          |
| Cluster Ingress (HTTPS) | 31100       | 443         |
| MongoDB                 | 30002       | 30002       |
 | Nexus                   | 30003       | 30003       |
| Nexus (Docker)          | 30004       | 30004       |
| Postgres                | 30001       | 30001       |
| SSH                     | 22          | 8000        | 