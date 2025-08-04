set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/pdf.just" --list | zsh -c "$JUSTGREP"

############  PDF UTILS  ############

# pdf attach
[no-exit-message]
pdf-attach *args:
  pdfattach {{args}}

# pdf detach
[no-exit-message]
pdf-detach *args:
  pdfdetach {{args}}

# pdf fonts
[no-exit-message]
pdf-fonts *args:
  pdffonts {{args}}

# pdf images
[no-exit-message]
pdf-images *args:
  pdfimages {{args}}

# pdf info
[no-exit-message]
pdf-info *args:
  pdfinfo {{args}}

# pdf separate
[no-exit-message]
pdf-separate *args:
  pdfseparate {{args}}

# pdf sig
[no-exit-message]
pdf-sig *args:
  pdfsig {{args}}

# pdf to cairo
[no-exit-message]
pdf-cairo *args:
  pdftocairo {{args}}

# pdf to html
[no-exit-message]
pdf-html *args:
  pdftohtml {{args}}
             
# pdf to ppm
[no-exit-message]
pdf-ppm *args:
  pdftoppm {{args}}

# pdf to ps
[no-exit-message]
pdf-ps *args:
  pdftops {{args}}

#pdf to text
[no-exit-message]
pdf-text *args:
  pdftotext {{args}}

# pdf unite
[no-exit-message]
pdf-unite *args:
  pdfunite {{args}}

