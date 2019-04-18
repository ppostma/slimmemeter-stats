# frozen_string_literal: true

require 'serialport'

require_relative 'telegram'

class P1Reader
  class << self
    def read(options = {})
      serial = SerialPort.new('/dev/ttyUSB0', 115_200)

      start_telegram, end_telegram = false
      buffer = []
      last = 0
      count = 0

      loop do
        string = serial.gets
        next if string.nil?

        case string[0]
        when '/'
          # first line of telegram
          start_telegram = true
          end_telegram = false

          buffer = []
        when '!'
          # last line of telegram
          end_telegram = true
        end

        buffer << string

        if start_telegram && end_telegram
          start_telegram, end_telegram = false

          now = Time.now
          next if options[:wait] && (now.to_i - last) < options[:wait]

          last = now.to_i
          count += 1

          telegram = Telegram.new(buffer)
          yield telegram if block_given?
        end

        break if options[:count] && count >= options[:count]
      end

      serial.close
    end
  end
end
