corefile: |
  .:53 {
    errors
    health
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
      pods insecure
      fallthrough in-addr.arpa ip6.arpa
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
  }
  oidc.eks.us-east-1.amazonaws.com:53 {
    errors
    cache 30
    forward . ${public_dns_servers}
    reload
  }