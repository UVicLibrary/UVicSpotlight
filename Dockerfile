FROM ruby:2.7.4
RUN apt-get update -qq && \
    apt-get install -y \
        graphicsmagick \
        poppler-utils \
        libvips \
        ffmpeg \
        mysql-server \
        libmariadb-dev \
        libmysqlclient-dev \
        nodejs

# Install mysql
RUN cd ~ && wget https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb
RUN sudo dpkg -i mysql-apt-config_0.8.15-1_all.deb
RUN sudo apt install -f mysql-client=8.0* mysql-server=8.0*
RUN sudo service mysql start
# Run which mysql and chown that directory so your user can run mysql

# Create a database in mysql
CREATE DATABASE spotlight DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
# In terminal, run
rails db:migrate
# If there are issues, run rails db:migrate:redo to drop (delete) and recreate tables

# Set up Solr
# Copy solr/spotlight_conf into Vault solr folder
# Change config/settings.yml
configset: spotlight
configset_source_path: <%= File.join(Rails.root, 'solr', 'spotlight_conf') %>

# Run docker-compose up on Vault
# Then in Spotlight, run rails s -b 0.0.0.0 -p 3001