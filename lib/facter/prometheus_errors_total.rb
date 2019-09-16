# frozen_string_literal: true

require 'yaml'

# This will read the Prometheus node exporter's log and look for errors.
# The result seen by puppet is nothing more than an integer which it can
# pass to a file that Prometheus will scrape.
#
# We're not interested in details in this case, since it's just a
# metric. If you want more info than error count, then that's what logs
# are for.
Facter.add(:prometheus_errors_total) do
  setcode do
    log_path = '/var/log/prometheus-node-exporter.log'
    error_count = %r{(?<=error gathering metrics: )\d*(?= error)}

    if File.size? log_path
      [1, File.read(log_path)[error_count].to_i].max
    else
      0
    end
  end
end
