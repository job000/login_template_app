# First stage: build the application
FROM cirrusci/flutter:stable AS build-env

# Set the working directory
WORKDIR /app/

# Copy the app files to the container
COPY . .

# Get Flutter dependencies and build the web app
RUN flutter pub get
RUN flutter build web

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Second stage: Create the runtime image
FROM nginx:alpine

# Copy the build artifacts from the build stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
