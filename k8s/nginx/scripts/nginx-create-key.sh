openssl genrsa -out https.key 2048
openssl req -new -x509 -key https.key -out https.cert -days 365 -subj /CN=www.my-website.com
