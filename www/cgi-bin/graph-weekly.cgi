#!/bin/sh

echo "Content-type: image/svg+xml\n"

rrdtool graph - \
  --title 'Verbruik en teruglevering (afgelopen week)' \
  --vertical-label 'watt' \
  --width '500' \
  --height '200' \
  --start -1w \
  --imgformat SVG \
  --slope-mode \
  --units-exponent 0 \
  "DEF:delivered=${POWER_RRD}:delivered:AVERAGE" \
  "DEF:returned=${POWER_RRD}:returned:AVERAGE" \
  "LINE1:delivered#dc3545:Verbruik" \
  "GPRINT:delivered:LAST:      Huidig\: %7.0lf"  \
  "GPRINT:delivered:AVERAGE:Gemiddeld\: %7.0lf"  \
  "GPRINT:delivered:MAX:Maximum\: %7.0lf\n"  \
  "LINE1:returned#28a745:Teruglevering" \
  "GPRINT:returned:LAST: Huidig\: %7.0lf"  \
  "GPRINT:returned:AVERAGE:Gemiddeld\: %7.0lf"  \
  "GPRINT:returned:MAX:Maximum\: %7.0lf\n"
