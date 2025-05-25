set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/http.just" --list | zsh -c "$JUSTGREP"

#############  HTTP  ##############

# hurl - curl test framework
@h *args:
  print "{{BrightMagenta}}hurl {{args}}{{BrightBlue}}"
  hurl {{args}}

# hurl test
@ht *args:
  print "{{BrightMagenta}}hurl --test {{args}}{{BrightBlue}}"
  hurl --test {{args}}

# new httpie
# http GET 'https://api.open-meteo.com/v1/forecast' latitude==42.9849 longitude==-81.2453 current_weather==true
http *args:
  xh {{args}}

# new curl
@curl *args:
  print "{{BrightMagenta}}curlie:{{BrightBlue}} $(curlie --curl {{args}})"
  print
  curlie {{args}}

# posting tui
httptui *args:
  posting {{args}}

# curl/http/xh example1
@c1:
  print "{{BrightMagenta}}xh https://dummyjson.com/products | jq '.products[0]'{{BrightBlue}}"
  xh https://dummyjson.com/products | jq '.products[0]'
  # curl -s https://dummyjson.com/products | jq '.products[0]'

# curl/http/xh example2
@c2:
  print "{{BrightMagenta}}xh https://dummyjson.com/products/1 | jq{{BrightBlue}}"
  xh https://dummyjson.com/products/1 | jq
  # curl -s https://dummyjson.com/products/1 | jq

# curl/http/xh example3
@c3:
  print "{{BrightMagenta}}xh https://dummyjson.com/products | jq '.products[0] | keys'{{BrightBlue}}"
  xh https://dummyjson.com/products | jq '.products[0] | keys'
  # curl -s https://dummyjson.com/products | jq '.products[0] | keys'

# curl/http/xh example4
@c4:
  print "{{BrightMagenta}}xh https://dummyjson.com/products | jq '.products[0].price'{{BrightBlue}}"
  xh https://dummyjson.com/products | jq '.products[0].price'

# curl/http/xh example5
@c5:
  print "{{BrightMagenta}}curl -s https://dummyjson.com/products/categories | jq '.[0] | keys'{{BrightBlue}}"
  xh https://dummyjson.com/products/categories | jq '.[0] | keys'
  # curl -s https://dummyjson.com/products/categories | jq '.[0] | keys'

# curl example6
@c6:
  print "{{BrightMagenta}}curl -sSO "$(curl https://dummyjson.com/products | jq -r '.products[0].meta.qrCode')"{{BrightBlue}}"
  curl -sSO "$(curl https://dummyjson.com/products | jq -r '.products[0].meta.qrCode')"

# curl + htmlq example7
@c7:
  curl https://clincalc.com/DrugStats/Top300Drugs.aspx | htmlq '#tableTopDrugs td a' -t
