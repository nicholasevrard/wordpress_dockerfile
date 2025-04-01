FROM ubuntu:20.04

# Set environment variables to avoid interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV DB_NAME=wordpress
ENV DB_USER=wp_user
ENV DB_PASSWORD=your_password

# Update the package lists, upgrade the system, and install necessary packages
RUN apt update && apt upgrade -y && \
    apt install apache2 mariadb-server php libapache2-mod-php php-mysql unzip git -y && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Remove default index.html and clone WordPress repository
RUN rm -f index.html && \
    git clone https://github.com/nicholasevrard/dentist_wordpress.git && \
    mv wordpress/* . && \
    rm -rf wordpress latest.zip && \
    unzip dentist_wordpress.zip && \
    mv dentist_wordpress/* . && \
    rm -rf dentist_wordpress dentist_wordpress.zip

# Set proper file permissions for WordPress
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy Apache configuration
COPY wordpress.conf /etc/apache2/sites-available/wordpress.conf

# Enable the site and necessary Apache modules
RUN a2ensite wordpress.conf && \
    a2enmod rewrite

# Modify wp-config.php with the required database settings
RUN mv wp-config-sample.php wp-config.php && \
    sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '${DB_NAME}' );/" wp-config.php && \
    sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '${DB_USER}' );/" wp-config.php && \
    sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${DB_PASSWORD}' );/" wp-config.php && \
    sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'localhost' );/" wp-config.php && \
    sed -i "s/define( 'DB_CHARSET', 'utf8' );/define( 'DB_CHARSET', 'utf8' );/" wp-config.php && \
    sed -i "s/define( 'DB_COLLATE', '' );/define( 'DB_COLLATE', '' );/" wp-config.php

# Expose Apache's default port
EXPOSE 80

# Set the command to run Apache in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]