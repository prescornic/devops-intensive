#!/bin/bash

apt-get update -y
apt-get install -y nginx

systemctl start nginx
systemctl enable nginx

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>VVD Web Server</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 50px; background-color: #f4f4f4; }
        .container { border: 2px solid #333; display: inline-block; padding: 20px; background: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello from Vasile's Server!</h1>
        <p>This page was deployed via Terraform User Data.</p>
        <p><b>Status:</b> Nginx is running on Ubuntu 24.04</p>
    </div>
</body>
</html>
EOF