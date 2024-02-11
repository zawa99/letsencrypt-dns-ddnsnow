CNH_DNS_DOMAIN=${CERTBOT_DOMAIN}'.'
CNH_DNS_NAME='_acme-challenge.'${CNH_DNS_DOMAIN}
CNH_DNS_DATA=${CERTBOT_VALIDATION}

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR

. ./.env
sudo -u ubuntu $BUNDLER_PATH exec ruby cleanup.rb $CNH_DNS_NAME $CNH_DNS_DATA

exit 0
