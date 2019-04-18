# frozen_string_literal: true

class RRD
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def exists?
    File.exist?(filename)
  end

  def create
    command = %(
      rrdtool create #{filename} --step 60 \
      DS:delivered:GAUGE:120:U:U \
      DS:returned:GAUGE:120:U:U \
      RRA:AVERAGE:0.5:1:240 \
      RRA:AVERAGE:0.5:3:960 \
      RRA:AVERAGE:0.5:5:1152 \
      RRA:AVERAGE:0.5:10:1440 \
      RRA:AVERAGE:0.5:20:2232
    )

    system(command)
  end

  def update(time, delivered, returned)
    command = %(rrdtool update #{filename} #{time.to_i}:#{delivered}:#{returned})

    system(command)
  end
end
