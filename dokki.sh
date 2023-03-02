# Read your project master_key
MASTER_KEY=$(cat ./config/master.key)

# Start SSH session
# Change the ip for the one you get from DigitalOcean
ssh root@122.122.122.122 << EOF

# create dokku app
dokku apps:create name_of_my_app

# install dokku postgres plugin
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git

# create database (it should match the name in /config/database.yml) which by default is something like:
# 
# production:
#   <<: *default
#   database: name_of_my_app_production
dokku postgres:create name_of_my_app_production

# Link database to app
dokku postgres:link name_of_my_app_production name_of_my_app

# Configure your master_key
dokku config:set name_of_my_app RAILS_MASTER_KEY=$MASTER_KEY

# Install SSL plugin
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# Config letsencrypt
dokku config:set --global DOKKU_LETSENCRYPT_EMAIL=your@email.com
dokku letsencrypt:set name_of_my_app email your@email.com
dokku domains:set name_of_my_app yourdomain.com
dokku letsencrypt:enable name_of_my_app

EOF

# Going back to your local machine
# Remove the existing dokku remote (in case there is already one from before)
git remote remove dokku

# Add a new dokku remote with the IP address variable
git remote add dokku dokku@122.122.122.122:name_of_my_app

# Push the main branch to the dokku remote's master branch
git push dokku main:master
