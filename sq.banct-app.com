bitnami@ip-172-31-36-53:/etc/nginx/sites-enabled$ ls
sq.banct-app.com
bitnami@ip-172-31-36-53:/etc/nginx/sites-enabled$ cat sq.banct-app.com 
server {
  server_name  _;
  add_header X-XSS-Protection "1; mode=block";
  root         /usr/share/nginx/html;

  index index.html index.htm index.nginx-debian.html;
  server_name sq.banct-app.com www.sq.banct-app.com;



 ## ssl_certificate     /etc/letsencrypt/live/sq.banct-app.com/fullchain.pem;
 ## ssl_certificate_key /etc/letsencrypt/live/sq.banct-app.com/privkey.pem;

    proxy_set_header X-Forwarded-For $proxy_protocol_addr; # To forward the original client's IP address 
    proxy_set_header X-Forwarded-Proto $scheme; # to forward the  original protocol (HTTP or HTTPS)
    proxy_set_header Host $host; # to forward the original host requested by the client



  location / { 
    proxy_pass http://127.0.0.1:9000;

   }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/sq.banct-app.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/sq.banct-app.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
    if ($host = sq.banct-app.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen       80;
  listen       [::]:80;
  server_name  _;
  server_name sq.banct-app.com www.sq.banct-app.com;
    return 404; # managed by Certbot


}
