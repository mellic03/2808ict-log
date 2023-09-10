# Use the node docker image as a base for this image.
FROM node:latest

WORKDIR /usr/src/app
COPY package*.json ./

# Install node.js dependencies (found in package.json).
RUN npm install

# Copy all directory contents.
COPY . .

# The pizzeria app requires these environment variables to be set.
ENV MONGODB_URI="mongodb://mongo-service:27017/"
ENV PORT=4200
ENV SECRET="secret"

# Run the app on port 4200.
EXPOSE 4200

# Run the app with the command "node server.js".
CMD ["node", "server.js"]