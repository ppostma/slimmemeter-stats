#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

require_relative 'lib/p1_reader'
require_relative 'lib/rrd'

options = { rrd: ENV['POWER_RRD'] }

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on '-d', '--daemon', 'Daemonize process' do
    options[:daemon] = true
  end

  opts.on '-r', '--rrd FILE', 'Set the RRD file' do |file|
    options[:rrd] = file
  end
end
parser.parse!

if options[:rrd].nil?
  puts 'Please supply the RRD file with -r or by setting the POWER_RRD environment variable.'
  exit 1
end

rrd = RRD.new(options[:rrd])
unless rrd.exists?
  puts "RRD file #{rrd.filename} does not exist, creating..."

  unless rrd.create
    puts "Failed to create #{rrd.filename} RRD file."
    exit 1
  end
end

Process.daemon(true) if options[:daemon]

P1Reader.read(wait: 60) do |telegram|
  delivered_currently = (telegram.delivered_currently * 1000).to_i
  returned_currently = (telegram.returned_currently * 1000).to_i

  rrd.update(telegram.time, delivered_currently, returned_currently)
end
