# Deployable secured Nginx web-server
Deployable nginx configured to obtain [Let's Encrypt](https://letsencrypt.org/) certificates

# Requirements
- Docker
- Docker-compose
- Cloudflare account
- Your own domain name

# Installation
#### Step 1
Clone this repository  
```
git clone https://github.com/Woofka/nginx.git
```  

#### Step 2
Put your Cloudflare API key in `cloudflare.ini`. This API key should have permissions
to change DNS zones to complete Let's Encrypt DNS challenges.  
> TODO: It will be better to use docker secret

#### Step 3
Create a new docker network that will be used by these and future containers  
```
docker network create nginx-network
```  
and make sure that it referenced in `docker-compose.yml`
```
networks:
  default:
    external:
      name: nginx-network
```

#### Step 4
Replace e-mail address and domain names with your ones in certbot command in `docker-compose.yml`
and also replace domain names in `nginx-conf/nginx.conf`

#### Step 5
Make sure that certbot command in `docker-compose.yml` use `--staging` flag.
That will prevent reaching the limit of certificates.
Now you can run a test:
```
docker-compose up -d
```
Open certbot logs and make sure that you successfully obtain certificates:
```
docker logs -f certbot
```

#### Step 6
If previous step is done successfully you can replace `--staging` flag with `--force-renewal`
in certbot command in `docker-compose.yml` and recreate certbot to obtain real certificates:
```
docker-compose up --force-recreate --no-deps certbot
```
You should see output telling you about successful obtaining of certificate.

#### Step 7
Generate a Diffie-Hellman key (it may take some time):
```
sudo openssl dhparam -out ./dhparam/dhparam-2048.pem 2048
```
> TODO: It will be better to use docker secret

#### Step 8
Edit `nginx-ssl.conf` file replacing domain names with your ones and then
replace nginx configuration:
```
cp ./nginx-conf/nginx.conf ./nginx-nossl.conf
cp ./nginx-ssl.conf ./nginx-conf/nginx.conf
```

#### Step 9
Recreate nginx container to use SSL certificates:
```
docker-compose up -d --force-recreate --no-deps nginx
```

#### Step 10
Replace `PATH_TO_PROJECT_DIR` in `ssl-renew.sh` and make it executable:
```
chmod +x ssl-renew.sh
```
Then create a test cron task for renewing certificates:
```
sudo crontab -e
```
Choose editor and put a string in the end with proper path to script file:
```
*/5 * * * * PATH_TO_PROJECT_DIR/ssl-renew.sh >> /var/log/cron.log 2>&1
```
 Then open log file:
```
tail -f /var/log/cron.log
```
 After some time you should see a message about successful renewal and killing nginx container
 Note that container is not truly killed, it's a way to send a signal to update configurations.  
 
 #### Step 11
If previous step is done successfully you can remove `--dry-run` flag from `ssl-renew.sh`
and change cron task timing to `0 12 * * *` to renew certificates every 12 hours.

# What's next?
Congratulations! Now you have secured web server and can configure it as you want.  
For example you can setup a proxy to another docker container.
Just use `--network nginx-network` parameter when running a new container
and add a new server to nginx configuration. You can use a name of container as a domain name.
After everything is configured just recreate a nginx container:
```
docker-compose up -d --force-recreate --no-deps nginx
``` 