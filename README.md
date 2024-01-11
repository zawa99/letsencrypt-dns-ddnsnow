# DDNS Now側で機能が増え、ツールが用意されたのでこれを使ってください。
https://ddns.kuku.lu/manual.php#certbot




# letsencrypt-dns-ddnsnow
個人的なツールなので他環境で動くか不明.

## usage
```
cp .env.sample .env
```

````
gem install bundler
bundle install --path vendor/bundle
```

## test run
```
sudo certbot certonly --dry-run --manual --manual-public-ip-logging-ok --agree-tos --preferred-challenges dns-01 -d example.com -d *.example.com --manual-auth-hook /home/ubuntu/letsencrypt-dns-ddnsnow/create.sh --manual-cleanup-hook /home/ubuntu/letsencrypt-dns-ddnsnow/cleanup.sh
```

## first run
```
sudo certbot certonly --manual --manual-public-ip-logging-ok --agree-tos --preferred-challenges dns-01 -d example.com -d *.example.com --manual-auth-hook /home/ubuntu/letsencrypt-dns-ddnsnow/create.sh --manual-cleanup-hook /home/ubuntu/letsencrypt-dns-ddnsnow/cleanup.sh
```

## update test
```
sudo certbot renew --dry-run
```

## update
```
sudo certbot renew

sudo systemctl restart certbot.service
```
