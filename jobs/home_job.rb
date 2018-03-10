require 'net/http'
require 'uri'
require 'json'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '15s', :first_in => 0 do |job|
  uri = URI.parse('https://api.nature.global/1/devices')
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Get.new(uri.request_uri)
  req['Accept'] = 'application/json'
  req['Authorization'] = 'Bearer ' + ENV['REMO_TOKEN']

  res = https.request(req)

  if res.code == '200'
    parsed = JSON.parse(res.body)
  else
    puts "Error on getting data from remo, #{code} #{message}"
  end

  temperature = parsed[0]['newest_events']['te']['val']
  humidity = parsed[0]['newest_events']['hu']['val']

  send_event('temperature', { current: temperature })
  send_event('humidity', { value: humidity })
end
