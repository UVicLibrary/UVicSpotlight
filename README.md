# Spotlight 2024

This is a heavily customized instance of [Spotlight v.3](https://github.com/projectblacklight/spotlight), which the [University of Victoria Libraries](https://www.uvic.ca/library/) uses in production for its [digital exhibits](https://exhibits.library.uvic.ca/).

We use a combination of Ubuntu on WSL 2 and Docker for our development environments. Although we don't distribute a Docker image ourselves, you can create docker containers for the backend components and connect the Spotlight app to them.

## Dependencies

#### Backend Components
* MySQL/MariaDB (tested with v. 15)
* Solr (tested with v. 9.4)

#### Apps Components
* **ImageMagick or GraphicsMagick** - For the IIIF server (powered by the [RIIIF gem](https://github.com/sul-dlss/riiif)). In future, we hope to create a version of RIIIF that uses VIPS instead.
* **ffmpeg** - audio/video processing library for audio/video thumbnail generation.
* **Redis (production only)** - used to run batch uploads/reindex in the background.
* **Poppler (utils)** - PDF processing library (used by libvips below)
* **[libvips](https://www.libvips.org/)** - Image processing library used for PDF thumbnail generation

## Getting Started (Dev)

If you're working on Windows, we recommend installing [Windows Terminal](https://apps.microsoft.com/detail/9N0DX20HK701?hl=en-US&gl=US), [Ubuntu on WSL2](https://canonical-ubuntu-wsl.readthedocs-hosted.com/en/latest/guides/install-ubuntu-wsl2/), and [Docker Desktop](https://www.docker.com/products/docker-desktop/).

**Note:** these instructions are for a dev environment in Ubuntu. Instructions may vary based on your operating system.

### Database

If using a locally-installed MariaDB:

```bash
# See https://devopscube.com/install-mariadb-on-ubuntu/
sudo apt update
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
sudo apt-get install mariadb-server mariadb-client -y
sudo service start mariadb # or sudo service mariadb start
sudo mysql_secure_installation
# Follow instructions to set password for root user

# Verify installation
mysql -V
```

You can also use Docker. See Docker images and instructions for [mariaDB](https://hub.docker.com/r/bitnami/mariadb) or [MySQL](https://hub.docker.com/_/mysql). Note that if you run a Docker image, you'll still need to install MariaDB/MySQL locally in order to connect to it from your app.

Set up the database by opening the mysql console with `mysql -u root -p`. Then create a new user with the credentials in `config/database.yml`.

```sql
CREATE DATABASE spotlight_dev;
GRANT ALL ON spotlight_dev.* to 'spotlight'@'localhost' IDENTIFIED BY 'spotlight';
```

### Troubleshooting first-time DB migration

In some cases, trying to run the migrations may fail with an error message about the Translations table not existing (even though you may be trying to create the table by running `rails db:migrate` in the first place). To work around this error, comment everything within the `configure_blacklight` line:

```ruby
# configure_blacklight do |config|
   # ...
   # everything in here should be commented out too...
   # ...
# end
```

Then run `rails db:migrate`. Once all the migrations have succeeded, you can uncomment the catalog controller.

### Solr

You have a few choices:
1. Run a Docker container (recommended). See the instructions below for starting one up.
2. Install Solr locally (you'll need to install Java as well).
3. Use the solr_wrapper gem. Open a new tab in Windows Terminal (or other Terminal program), `cd` into the Spotlight directory, and run `solr_wrapper`. In our experience, this approach can break when Apache releases a new version of Solr.

#### Create a Solr Docker container

Install Docker Desktop and make sure the Docker engine is running. Then, in the Spotlight directory, run:

```
# Without this, Solr will fail with an error like Cannot write to /var/solr as 8983:8983
chown 8983:8983 solr/data -R

# Download the container and create a test core called gettingstarted
docker run -d -v "$PWD/solr/data:/var/solr/data" -p 8983:8983 --name spotlight_solr solr:9.4 solr-precreate gettingstarted
```

Solr should now be running at `localhost:8983`. See the official [Solr documentation](https://solr.apache.org/guide/solr/latest/deployment-guide/solr-in-docker.html) for more about using Solr Docker.

#### Create a Solr core

Our custom Solr configuration files are stored in `solr/conf`. To create the core configured in `config/blacklight.yml`, go to the **Solr Dashboard (localhost:8983) > Core Admin > Add Core**. Fill out the pop-up form like so:

```
name: blacklight-core
instanceDir: /var/solr/data/blacklight-core
dataDir: /var/solr/data/blacklight-core/data
config: conf/solrconfig.xml
schema: conf/schema.xml
```

### Installing Dependencies

1. In Ubuntu, this is straightforward (mileage may vary on other OS's):

```bash
sudo apt update
sudo apt install -y \
    imagemagick \
    poppler-utils \
    libvips \
    ffmpeg
```

2. Install RVM and Ruby according to [the instructions](https://rvm.io/rvm/install).

3. Then `cd` into the Spotlight directory and run:

```
bundle install
rails db:migrate RAILS_ENV=development
```

### Review Settings
* In `app/uploaders/spotlight/featured_image_uploader`, configure the `store_dir` and the `cache_dir`
* Verify the Solr/Blacklight URL is correct in `config/blacklight.yml`
* Verify the database configuration in `config/database.yml` is correct

### Edit Credentials

Since Rails 6, the recommended way to store/access credentials is with `Rails.application.credentials`. First, make sure nano is installed (`apt install nano`), then run:

`RAILS_ENV=production EDITOR="nano" rails credentials:edit`

This will open a menu for setting variables such as database credentials (in production) and the Google Maps API key. When you're done editing credentials, simply close the file/menu. This will generate two files, `config/credentials.yml.enc` (encrypted credentials) and a `master.key`.

**Never publish your master.key when pushing to a remote git branch.** In fact, running `rails credentials:edit` for the first time should automatically add `master.key` to your `.gitignore`.

For more info on Rails credentials, see [this tutorial](https://webcrunch.com/posts/the-complete-guide-to-ruby-on-rails-encrypted-credentials).

### Create an Admin User

Run `rails spotlight:admin` and follow the prompts.

### Start the Server

Run `rails s -b 0.0.0.0`. The app should now be running at `localhost:3000`.

If you restart your computer, remember to also restart the database (`sudo service start mariadb`) and Solr.
