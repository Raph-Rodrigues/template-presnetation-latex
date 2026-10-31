LATEXMK ?= latexmk
LUA     ?= lua
MAIN     = main

FONTES = $(MAIN).tex beamerthemefisica.sty fisica.sty fisica-video.sty \
         $(wildcard content/*.tex) \
         $(wildcard lua/*.lua) \
         $(wildcard videos/*) \
         dados/oscilador.csv

all: $(MAIN).pdf

$(MAIN).pdf: $(FONTES)
	$(LATEXMK) -lualatex -interaction=nonstopmode -halt-on-error $(MAIN).tex

dados: dados/oscilador.csv

dados/oscilador.csv: scripts/gerar_dados.lua
	$(LUA) scripts/gerar_dados.lua

clean:
	$(LATEXMK) -C $(MAIN).tex

.PHONY: all dados clean
