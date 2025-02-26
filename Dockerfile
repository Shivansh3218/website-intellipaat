FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache and required packages
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache to listen on port 82 for master branch deployments
RUN echo "Listen 82" >> /etc/apache2/ports.conf
RUN sed -i 's/Listen 80/Listen 80\nListen 82/g' /etc/apache2/ports.conf

# Create a new virtual host for port 82
RUN cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/master-site.conf
RUN sed -i 's/*:80/*:82/g' /etc/apache2/sites-available/master-site.conf
RUN a2ensite master-site.conf

# Ensure the Apache service starts properly
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set the work directory
WORKDIR /var/www/html

# Expose ports
EXPOSE 80 82

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]