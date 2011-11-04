Tire.configure do |c|
  c.url("#{Cloudsdale.config['tire']['host']}:#{Cloudsdale.config['tire']['port']}")
end