# frozen_string_literal: true

require 'bigdecimal'
require 'time'

class Telegram
  CODES = {
    '1-0:1.8.1' => :delivered_low,        # Example: 1-0:1.8.1(001645.208*kWh)\r\n
    '1-0:1.8.2' => :delivered_normal,     # Example: 1-0:1.8.2(001774.312*kWh)\r\n
    '1-0:2.8.1' => :returned_low,         # Example: 1-0:2.8.1(000044.517*kWh)\r\n
    '1-0:2.8.2' => :returned_normal,      # Example: 1-0:2.8.2(000095.936*kWh)\r\n
    '1-0:1.7.0' => :delivered_currently,  # Example: 1-0:1.7.0(00.295*kW)\r\n
    '1-0:2.7.0' => :returned_currently    # Example: 1-0:2.7.0(00.000*kW)\r\n
  }.freeze

  attr_reader :raw, :time

  def initialize(raw)
    @raw = raw
    @time = Time.now
  end

  def data
    @data ||= parse_data(raw)
  end

  def delivered_low
    data[:delivered_low]
  end

  def delivered_normal
    data[:delivered_normal]
  end

  def returned_low
    data[:returned_low]
  end

  def returned_normal
    data[:returned_normal]
  end

  def delivered_currently
    data[:delivered_currently]
  end

  def returned_currently
    data[:returned_currently]
  end

  def to_s
    output = []
    output << "Telegram received on #{time}"
    output << "Electricity delivered (low tariff): #{delivered_low.to_s('f')} kWh"
    output << "Electricity delivered (normal tariff): #{delivered_normal.to_s('f')} kWh"
    output << "Electricity returned (low tariff): #{returned_low.to_s('f')} kWh"
    output << "Electricity returned (normal tariff): #{returned_normal.to_s('f')} kWh"
    output << "Electricity delivered currently: #{delivered_currently.to_s('f')} kW"
    output << "Electricity returned currently: #{returned_currently.to_s('f')} kW"

    output.join("\n")
  end

  private

  def parse_data(data)
    results = {}

    data.each do |line|
      matches = line.match(/(.+)\(([0-9\.]+).*\)/)
      next if matches.nil?

      code = matches[1]
      next unless CODES.key?(code)

      key = CODES[code]
      value = BigDecimal(matches[2])

      results[key] = value
    end

    results
  end
end
