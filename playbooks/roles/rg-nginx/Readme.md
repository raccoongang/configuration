example: skip edx nginx config and use custom domain/port/proxy_pass_port
```
---  
nginx_edx_config: False
NGINX_ADDITIONAL_SERVICES_CONFIG:
  - name: xxx
    server_name: xxx.raccoongang.com
    nginx_port: 443
    nging_proxy_pass_port: 8080
    nginx_ssl_certificate_path: /etc/nginx/ssl/rg.crt
    nginx_ssl_certificate_key_path: /etc/nginx/ssl/rg.key
  - name: yyy
    server_name: yyy.raccoongang.com
    nginx_port: 80
    nging_proxy_pass_port: 8181
    nginx_ssl_certificate_path: /etc/nginx/ssl/rg.crt
    nginx_ssl_certificate_key_path: /etc/nginx/ssl/rg.key
```