# Use the specified pre-built container
FROM hshar/webapp

# Set maintainer
LABEL maintainer="devops@abodesoftware.com"

# Set working directory where code should reside
WORKDIR /var/www/html

# Copy application files to the container
COPY . /var/www/html/

# Ensure proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
