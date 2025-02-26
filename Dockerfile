FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install Apache
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable required Apache modules
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Expose ports
EXPOSE 80

# Start Apache in foreground`
CMD ["apache2ctl", "-D", "FOREGROUND"]