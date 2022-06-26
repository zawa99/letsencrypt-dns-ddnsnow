CNH_DNS_DOMAIN=${CERTBOT_DOMAIN}'.'
CNH_DNS_NAME='_acme-challenge.'${CNH_DNS_DOMAIN}
CNH_DNS_DATA=${CERTBOT_VALIDATION}

curl -X POST -H "Authorization: Bearer ${LINE_TOKEN}" 'https://notify-api.line.me/api/notify' -F "message=LetsEncrypt Update Cert. CERTBOT_DOMAIN=${CERTBOT_DOMAIN}, CERTBOT_VALIDATION=${CERTBOT_VALIDATION}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR

. ./.env
$BUNDLER_PATH exec ruby create.rb $CNH_DNS_NAME $CNH_DNS_DATA
