require "rubygems"
require "bundler/setup"

require "dotenv"
require "logger"
require "resolv"
require 'uri'
require 'selenium-webdriver'

file = File.open('/home/ubuntu/letsencrypt-dns-ddnsnow/script.log', File::WRONLY | File::APPEND | File::CREAT)
logger = Logger.new(file, datetime_format: '%Y-%m-%d %H:%M:%S')

logger.info "**********create start**********"
logger.info ARGV

# CONFIG
Dotenv.load
sub_domain = ENV["DDNS_NOW_SUB_DOMAIN"]
password = ENV["DDNS_NOW_PASSWORD"]
login_url = "https://ddns.kuku.lu/index.php"

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

# Login
system("echo '' > nohup.out")
pid = `ps ax | grep chrome | grep 35512 | grep -v "grep"`.split(" ").first
port = "35512"
if pid
  system("DISPLAY=:1.0 nohup /opt/google/chrome/chrome --remote-debugging-port=35513 2>&1 &")
  pid = `ps ax | grep chrome | grep 35513 | grep -v "grep"`.split(" ").first
  port = "35513"
else
  system("DISPLAY=:1.0 nohup /opt/google/chrome/chrome --remote-debugging-port=35512 2>&1 &")
  pid = `ps ax | grep chrome | grep 35512 | grep -v "grep"`.split(" ").first
  port = "35512"
end

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--lang=ja-JP')
options.add_argument('--no-sandbox')
options.add_argument('--headless')
options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36')
options.add_option(:debugger_address, "127.0.0.1:#{port}")

driver = Selenium::WebDriver.for :chrome, options: options
driver.manage.timeouts.implicit_wait = 30
logger.info "ログイン画面へ移動"
driver.get(login_url)
sleep 10

login_domain_elem = driver.find_element(name: "login_domain")
login_domain_elem.send_keys sub_domain
login_password_elem = driver.find_element(name: "login_password")
login_password_elem.send_keys password
form = driver.find_element(css: "#area_login form")
sleep 2
logger.info "ログイン"
form.submit
sleep 10

logger.info "設定画面へ移動"
driver.get("https://ddns.kuku.lu/control.php")
sleep 10

# update
txt = driver.find_element(name: "update_data_txt")
old_value = txt.text
txt.clear
if old_value.size == 0
  txt.send_keys value
else
  txt.send_keys [old_value, value].compact.join("\n")
end
sleep 2
logger.info "レコード設定"
driver.execute_script("runUpdate()")
sleep 10
logger.info "レコード設定完了"

logger.info "設定画面へ移動"
driver.get("https://ddns.kuku.lu/control.php")
sleep 10

logger.info "waiting 120 sec."
sleep 120

# inputed_values = driver.find_element(name: "update_data_txt")
# if inputed_values.include?(value)
#   dns_updated = false
#   until dns_updated
#     logger.info "waiting 60 sec."
#     sleep 60

#     dns_results = [
#       Resolv::DNS.new(nameserver: '8.8.8.8').getresources(domain, Resolv::DNS::Resource::IN::TXT).flat_map(&:strings)
#     ].flatten.uniq
#     logger.info "txt records = #{dns_results}"
#     dns_updated = dns_results.include?(value)
#   end
#   sleep 10
#   logger.info "create succeess!"
# else
#   logger.error "create fail."
# end

# ログアウト
logger.info "トップページへ移動"
driver.get("https://ddns.kuku.lu/index.php")
sleep 10

logger.info "ログアウト"
btn2 = driver.find_element(xpath: "/html/body/div[2]/center/table/tbody/tr[2]/td/div[2]/div[1]/div/div/div/div[3]/a")
btn2
btn2.click

driver.quit
system("kill #{pid}") unless pid.nil?
logger.info "close"

logger.info "**********create end**********"
