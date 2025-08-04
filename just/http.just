set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/http.just" --list | zsh -c "$JUSTGREP"

#############  HTTP  ##############

# hurl - curl test framework
[no-exit-message]
@h *args:
  print "{{BrightMagenta}}hurl {{args}}{{BrightBlue}}"
  hurl {{args}}

# hurl test
[no-exit-message]
@ht *args:
  print "{{BrightMagenta}}hurl --test {{args}}{{BrightBlue}}"
  hurl --test {{args}}

# new httpie
# http GET 'https://api.open-meteo.com/v1/forecast' latitude==42.9849 longitude==-81.2453 current_weather==true
[no-exit-message]
http *args:
  xh {{args}}

# new curl
[no-exit-message]
@curl *args:
  print "{{BrightMagenta}}curlie:{{BrightBlue}} $(curlie --curl {{args}})"
  print
  curlie {{args}}

# posting tui
[no-exit-message]
httptui *args:
  posting {{args}}

# curl/http/xh example1
[no-exit-message]
@c1:
  print "{{BrightMagenta}}xh https://dummyjson.com/products | jq '.products[0]'{{BrightBlue}}"
  xh https://dummyjson.com/products | jq '.products[0]'
  # curl -s https://dummyjson.com/products | jq '.products[0]'

# curl/http/xh example2
[no-exit-message]
@c2:
  print "{{BrightMagenta}}xh https://dummyjson.com/products/1 | jq{{BrightBlue}}"
  xh https://dummyjson.com/products/1 | jq
  # curl -s https://dummyjson.com/products/1 | jq

# curl/http/xh example3
[no-exit-message]
@c3:
  print "{{BrightMagenta}}xh https://dummyjson.com/products | jq '.products[0] | keys'{{BrightBlue}}"
  xh https://dummyjson.com/products | jq '.products[0] | keys'
  # curl -s https://dummyjson.com/products | jq '.products[0] | keys'

# curl/http/xh example4
[no-exit-message]
@c4:
  print "{{BrightMagenta}}xh https://dummyjson.com/products | jq '.products[0].price'{{BrightBlue}}"
  xh https://dummyjson.com/products | jq '.products[0].price'

# curl/http/xh example5
[no-exit-message]
@c5:
  print "{{BrightMagenta}}curl -s https://dummyjson.com/products/categories | jq '.[0] | keys'{{BrightBlue}}"
  xh https://dummyjson.com/products/categories | jq '.[0] | keys'
  # curl -s https://dummyjson.com/products/categories | jq '.[0] | keys'

# curl example6
[no-exit-message]
@c6:
  print "{{BrightMagenta}}curl -sSO "$(curl https://dummyjson.com/products | jq -r '.products[0].meta.qrCode')"{{BrightBlue}}"
  curl -sSO "$(curl https://dummyjson.com/products | jq -r '.products[0].meta.qrCode')"

# curl + htmlq example7
[no-exit-message]
@c7:
  curl https://clincalc.com/DrugStats/Top300Drugs.aspx | htmlq '#tableTopDrugs td a' -t
