#!/usr/bin/env lua
-- =====================================================================
--  gerar-fallback-xetex.lua
--  Gera fisica-estatico.tex, usado quando o template e compilado com
--  XeLaTeX (por exemplo, no UaiTeX, que nao oferece LuaLaTeX).
--
--  O fallback reproduz os valores e textos de lua/constantes.lua e
--  lua/conteudo.lua, alem do grafico de dados/oscilador.csv.
--
--  Rode na raiz do projeto:
--      lua tools/gerar-fallback-xetex.lua
-- =====================================================================

package.path = "./lua/?.lua;" .. package.path

local saida = {}

local function emit(...)
  for _, linha in ipairs({ ... }) do
    saida[#saida + 1] = linha
  end
end

-- O modulo fisica.lua usa tex.sprint(); simulamos a saida para capturar
-- exatamente o LaTeX que o LuaLaTeX produziria.
tex = { sprint = function() end }

local constantes = require("constantes")
local conteudo   = require("conteudo")
local fisica     = require("fisica")

local function capturar(fn)
  local partes = {}
  local anterior = tex.sprint
  tex.sprint = function(s)
    partes[#partes + 1] = s
  end
  fn()
  tex.sprint = anterior
  return table.concat(partes)
end

emit(
  "% =====================================================================",
  "%  fisica-estatico.tex",
  "%  Fallback para XeLaTeX (UaiTeX, Overleaf com XeLaTeX etc.).",
  "%  GERADO por tools/gerar-fallback-xetex.lua -- nao edite a mao.",
  "%",
  "%  Para atualizar depois de mexer em lua/ ou dados/:",
  "%      lua tools/gerar-fallback-xetex.lua",
  "% =====================================================================",
  "\\makeatletter",
  ""
)

-- ---------------------------------------------------------------------
--  Constantes
-- ---------------------------------------------------------------------
local chaves = {}
for chave in pairs(constantes.dados) do
  chaves[#chaves + 1] = chave
end
table.sort(chaves)

for _, chave in ipairs(chaves) do
  local c = constantes.dados[chave]
  -- Nomes de macro via \csname: chaves como "eps0" tem digito, que nao
  -- pode aparecer em \newcommand{\fisica@cte@eps0}.
  local function definir(nome, corpo)
    emit(string.format(
      "\\expandafter\\newcommand\\csname fisica@%s@%s\\endcsname{%s}",
      nome, chave, corpo))
  end
  definir("cte", capturar(function() fisica.constante(chave) end))
  definir("valor", capturar(function() fisica.valor(chave) end))
  definir("unidade", capturar(function() fisica.unidade(chave) end))
  definir("simbolo", capturar(function() fisica.simbolo(chave) end))
  definir("nome", c.nome)
end

emit(
  "",
  "\\newcommand{\\cte}[1]{\\csname fisica@cte@#1\\endcsname}",
  "\\newcommand{\\ctevalor}[1]{\\csname fisica@valor@#1\\endcsname}",
  "\\newcommand{\\cteunidade}[1]{\\csname fisica@unidade@#1\\endcsname}",
  "\\newcommand{\\ctesimbolo}[1]{\\csname fisica@simbolo@#1\\endcsname}",
  "\\newcommand{\\tabelaconstantes}[1]{%",
  "  \\def\\fisica@linhas{}%",
  "  \\@for\\fisica@chave:=#1\\do{%",
  "    \\edef\\fisica@linhas{%",
  "      \\unexpanded\\expandafter{\\fisica@linhas}%",
  "      \\expandafter\\noexpand\\csname fisica@simbolo@\\fisica@chave\\endcsname &",
  "      \\expandafter\\noexpand\\csname fisica@valor@\\fisica@chave\\endcsname &",
  "      \\expandafter\\noexpand\\csname fisica@nome@\\fisica@chave\\endcsname",
  "      \\noexpand\\\\%",
  "    }%",
  "  }%",
  "  \\fisica@linhas",
  "}",
  ""
)

-- ---------------------------------------------------------------------
--  Conteudo estruturado
-- ---------------------------------------------------------------------
emit("\\newcommand{\\roteiro}{" .. capturar(fisica.roteiro) .. "}")
emit("\\newcommand{\\comparacao}{" .. capturar(fisica.comparacao) .. "}")
emit("\\newcommand{\\niveisTabela}{" .. capturar(fisica.niveisTabela) .. "}")
emit("\\newcommand{\\exercicios}{" .. capturar(fisica.exercicios) .. "}")
emit("")

-- ---------------------------------------------------------------------
--  Grafico (mesmas coordenadas que o modo Lua)
-- ---------------------------------------------------------------------
emit("\\newcommand{\\plotOscilador}{" .. capturar(fisica.plotOscilador) .. "}")
emit("")

-- ---------------------------------------------------------------------
--  Energia de um nivel, sem Lua
-- ---------------------------------------------------------------------
emit(
  "\\newcommand{\\energia}[2]{%",
  "  \\qty[drop-zero-decimal]{\\fpeval{round((#1+0.5)*(#2),3)}}{\\milli\\electronvolt}%",
  "}",
  "",
  "\\makeatother",
  ""
)

local arquivo = "fisica-estatico.tex"
local fh, erro = io.open(arquivo, "w")
if not fh then
  error("nao foi possivel escrever '" .. arquivo .. "': " .. tostring(erro))
end
fh:write(table.concat(saida, "\n"))
fh:close()
print("gerado: " .. arquivo .. " (" .. #saida .. " linhas)")
