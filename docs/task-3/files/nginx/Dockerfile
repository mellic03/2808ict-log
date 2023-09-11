# Use the nginx docker image as a base
FROM nginx

# Copy the nginx.conf we just wrote to the required location
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the SSL cert + key to the required location
COPY ssl/localhost.crt /etc/ssl/certs/localhost.crt
COPY ssl/localhost.key /etc/ssl/private/localhost.key