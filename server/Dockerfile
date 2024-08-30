# Use an official Node.js runtime as a parent image
FROM node:22-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install all dependencies, including 'devDependencies'
RUN npm install

# Copy the application code to the working directory
COPY . .

# Expose the application port and the debugging port
EXPOSE 3000 9229

# Define the command to run your application, enable debugging
CMD ["node", "--inspect=0.0.0.0:9229", "index.js"]
