FROM hshar/webapp

WORKDIR /var/www/html

COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 80

# Use Apache instead of nginx (common in webapp images)
CMD ["apache2ctl", "-D", "FOREGROUND"]
