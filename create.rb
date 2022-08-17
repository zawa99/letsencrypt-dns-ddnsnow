require "rubygems"
require "bundler/setup"

require "mechanize"
require "dotenv"
require "logger"
require "resolv"

file = File.open('script.log', File::WRONLY | File::APPEND | File::CREAT)
logger = Logger.new(file, datetime_format: '%Y-%m-%d %H:%M:%S')

logger.info "create start"
logger.info ARGV

Dotenv.load
sub_domain = ENV["DDNS_NOW_SUB_DOMAIN"]
password = ENV["DDNS_NOW_PASSWORD"]
if sub_domain.nil? || password.nil?
  logger.error "need .env file. DDNS_NOW_SUB_DOMAIN, DDNS_NOW_PASSWORD."
  return
end

# LETS_ENCRYPT
if ARGV.size == 2
  domain = ARGV[0] # CERTBOT_DOMAIN
  value = ARGV[1] # CERTBOT_VALIDATION
else
  logger.error "need ARGV domain, value"
  return
end

# CONFIG
login_url = "https://ddns.kuku.lu/index.php"

# Login
agent = Mechanize.new
agent.user_agent_alias = "Windows Mozilla"
html = agent.get(login_url)

login_form = html.form_with(action: "index.php")
login_form.field_with(name: 'login_domain').value = sub_domain
login_form.field_with(name: 'login_password').value = password

logged_in_page_html = agent.submit(login_form)

unless logged_in_page_html.title.include?("詳細設定")
  logger.error "login fail."
  return
end

dns_form = logged_in_page_html.form_with(name: "uform")
dns_form.field_with(name: "update_data_txt").value =
  if dns_form.field_with(name: "update_data_txt").value != ""
    [dns_form.field_with(name: "update_data_txt").value, value].join("\n")
  else
    value
  end
updated_page_html = agent.submit(dns_form)

dns_form = updated_page_html.form_with(name: "uform")
inputed_values = dns_form.field_with(name: "update_data_txt").value.split("\n")

if inputed_values.include?(value)
  dns_updated = false
  until dns_updated
    sleep 120
    dns_results = [
      Resolv::DNS.new(nameserver: '8.8.8.8').getresources(domain, Resolv::DNS::Resource::IN::TXT).flat_map(&:strings)
    ].flatten.uniq
    logger.info "txt records = #{dns_results}"
    dns_updated = dns_results.include?(value)
  end
  sleep 120
  logger.info "create succeess!"
else
  logger.error "create fail."
end
