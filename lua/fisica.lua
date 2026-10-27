-- =====================================================================
--  fisica.lua
--  Ponte entre os modulos Lua e o LaTeX. Todas as funcoes publicas
--  escrevem diretamente no fluxo do documento com tex.sprint().
--
--  Importante: nao incluimos "\n" nas strings entregues ao TeX. O
--  LuaTeX trataria o caractere de nova linha como um glifo, gerando
--  avisos de "Missing character" e problemas de alinhamento.
-- =====================================================================

local constantes = require("constantes")
local conteudo   = require("conteudo")

local M = {}

-- ---------------------------------------------------------------------
--  Utilitarios
-- ---------------------------------------------------------------------
local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function exigirTabela(t, nome)
  if type(t) ~= "table" then
    error("fisica.lua: '" .. nome .. "' deveria ser uma tabela")
  end
end

-- Formata numeros sempre com ponto decimal (independente do locale).
local function fmt(valor, padrao)
  return (string.format(padrao, valor):gsub(",", "."))
end

-- ---------------------------------------------------------------------
--  Constantes fisicas
-- ---------------------------------------------------------------------
-- $c = \qty{299792458}{\metre\per\second}$
function M.constante(chave)
  local c = constantes.obter(chave)
  tex.sprint(string.format("$%s = \\qty{%s}{%s}$",
    c.simbolo, c.valor, c.unidade))
end

-- \qty{valor}{unidade}
function M.valor(chave)
  local c = constantes.obter(chave)
  tex.sprint(string.format("\\qty{%s}{%s}", c.valor, c.unidade))
end

-- \unit{unidade}
function M.unidade(chave)
  local c = constantes.obter(chave)
  tex.sprint(string.format("\\unit{%s}", c.unidade))
end

-- $simbolo$
function M.simbolo(chave)
  local c = constantes.obter(chave)
  tex.sprint(string.format("$%s$", c.simbolo))
end

-- Linhas prontas para um tabular: simbolo & valor & grandeza \\
function M.tabelaConstantes(lista)
  for chave in lista:gmatch("[^,]+") do
    chave = trim(chave)
    if chave ~= "" then
      local c = constantes.obter(chave)
      tex.sprint(string.format("$%s$ & \\qty{%s}{%s} & %s \\\\",
        c.simbolo, c.valor, c.unidade, c.nome))
    end
  end
end

-- ---------------------------------------------------------------------
--  Conteudo estruturado (lua/conteudo.lua)
-- ---------------------------------------------------------------------
function M.roteiro()
  exigirTabela(conteudo.roteiro, "roteiro")
  for _, item in ipairs(conteudo.roteiro) do
    tex.sprint(string.format("\\item \\textbf{%s} --- %s ",
      item.titulo, item.descricao))
  end
end

function M.comparacao()
  exigirTabela(conteudo.comparacao, "comparacao")
  for _, linha in ipairs(conteudo.comparacao) do
    tex.sprint(string.format("%s & %s & %s \\\\",
      linha.aspecto, linha.classico, linha.quantico))
  end
end

function M.niveisTabela()
  exigirTabela(conteudo.niveis, "niveis")
  for _, nivel in ipairs(conteudo.niveis) do
    tex.sprint(string.format(
      "%d & \\qty{%s}{\\milli\\electronvolt} & $%s$ & %d \\\\",
      nivel.n, fmt(nivel.energia, "%g"), nivel.paridade, nivel.nos))
  end
end

function M.exercicios()
  exigirTabela(conteudo.exercicios, "exercicios")
  for _, ex in ipairs(conteudo.exercicios) do
    tex.sprint(string.format(
      "\\item %s\\hfill{\\scriptsize\\color{fisicamuted}%s} ",
      ex.texto, ex.nivel))
  end
end

-- Energia do nivel n para um dado hbar*omega (em meV).
function M.energia(n, meV)
  if type(n) ~= "number" or type(meV) ~= "number" then
    error("fisica.lua: \\energia espera dois numeros")
  end
  tex.sprint(string.format("\\qty{%s}{\\milli\\electronvolt}",
    fmt((n + 0.5) * meV, "%g")))
end

-- ---------------------------------------------------------------------
--  Leitura de CSV e geracao de \addplot
-- ---------------------------------------------------------------------
local function lerCSV(caminho)
  local arq, erro = io.open(caminho, "r")
  if not arq then
    error("fisica.lua: nao foi possivel abrir '" .. caminho ..
          "': " .. tostring(erro) ..
          ". Rode 'lua scripts/gerar_dados.lua' na raiz do projeto.")
  end

  local linhas = {}
  for linha in arq:lines() do
    linha = trim(linha)
    if linha ~= "" and linha:sub(1, 1) ~= "#" then
      local campos = {}
      for campo in linha:gmatch("[^,;]+") do
        campo = trim(campo)
        campos[#campos + 1] = tonumber(campo) or campo
      end
      if #campos > 0 then
        linhas[#linhas + 1] = campos
      end
    end
  end
  arq:close()

  -- Remove o cabecalho, se houver.
  if #linhas > 0 and type(linhas[1][1]) ~= "number" then
    table.remove(linhas, 1)
  end
  return linhas
end

local function plotarColuna(dados, colX, colY, estilo, legenda)
  local pontos = {}
  for _, linha in ipairs(dados) do
    local x, y = linha[colX], linha[colY]
    if type(x) == "number" and type(y) == "number" then
      pontos[#pontos + 1] = "(" .. fmt(x, "%.4f") .. "," ..
                                  fmt(y, "%.4f") .. ")"
    end
  end
  if #pontos == 0 then
    error("fisica.lua: nenhum ponto valido na coluna " .. tostring(colY))
  end

  tex.sprint(string.format("\\addplot[%s] coordinates {%s}; ",
    estilo, table.concat(pontos, " ")))

  if legenda and legenda ~= "" then
    tex.sprint(string.format("\\addlegendentry{%s} ", legenda))
  end
end

-- Expoe os utilitarios para uso direto em \directlua
M.lerCSV = lerCSV
M.plotarColuna = plotarColuna

-- Le dados/oscilador.csv e emite o potencial + psi_0, psi_1, psi_2.
function M.plotOscilador()
  local dados = lerCSV(conteudo.arquivoDados)
  if #dados == 0 then
    error("fisica.lua: '" .. conteudo.arquivoDados .. "' esta vazio")
  end

  -- Colunas: 1=x, 2=V(x), 3=psi0, 4=psi1, 5=psi2
  plotarColuna(dados, 1, 2,
    "draw=fisicamuted, dashed, line width=0.7pt, smooth", nil)
  plotarColuna(dados, 1, 3,
    "draw=fisicacyan, line width=1.5pt, smooth", "$n=0$")
  plotarColuna(dados, 1, 4,
    "draw=fisicaamber, line width=1.5pt, smooth", "$n=1$")
  plotarColuna(dados, 1, 5,
    "draw=fisicaviolet, line width=1.5pt, smooth", "$n=2$")
end

return M
