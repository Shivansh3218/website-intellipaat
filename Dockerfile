FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache and required packages
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ensure the Apache service starts properly
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Remove default index.html
RUN rm -f /var/www/html/index.html

# Set the work directory
WORKDIR /var/www/html

# Expose ports
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]