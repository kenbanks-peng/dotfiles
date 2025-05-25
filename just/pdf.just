set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/pdf.just" --list | zsh -c "$JUSTGREP"

############  PDF UTILS  ############

# pdf attach
pdf-attach *args:
  pdfattach {{args}}

# pdf detach
pdf-detach *args:
  pdfdetach {{args}}

# pdf fonts
pdf-fonts *args:
  pdffonts {{args}}

# pdf images
pdf-images *args:
  pdfimages {{args}}

# pdf info
pdf-info *args:
  pdfinfo {{args}}

# pdf separate
pdf-separate *args:
  pdfseparate {{args}}

# pdf sig
pdf-sig *args:
  pdfsig {{args}}

# pdf to cairo
pdf-cairo *args:
  pdftocairo {{args}}

# pdf to html
pdf-html *args:
  pdftohtml {{args}}
             
# pdf to ppm
pdf-ppm *args:
  pdftoppm {{args}}

# pdf to ps
pdf-ps *args:
  pdftops {{args}}

#pdf to text
pdf-text *args:
  pdftotext {{args}}

# pdf unite
pdf-unite *args:
  pdfunite {{args}}

