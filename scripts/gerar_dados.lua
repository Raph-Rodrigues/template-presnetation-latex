-- =====================================================================
--  gerar_dados.lua
--  Gera dados/oscilador.csv com o potencial e as funcoes de onda do
--  oscilador harmonico quantico, em unidades de hbar = m = omega = 1.
--
--  Uso (na raiz do projeto):
--      lua scripts/gerar_dados.lua
--
--  Colunas: x, V(x), psi0, psi1, psi2
--  As funcoes de onda sao deslocadas por (n + 1/2) e escaladas por
--  0.30 apenas para visualizacao no grafico.
-- =====================================================================

local function fatorial(n)
  local f = 1
  for i = 2, n do
    f = f * i
  end
  return f
end

-- Formata com ponto decimal, independente do locale do sistema.
local function fmt(valor, padrao)
  return (string.format(padrao, valor):gsub(",", "."))
end

-- Polinomio de Hermite H_n(x) por recorrencia.
local function hermite(n, x)
  if n == 0 then return 1.0 end
  if n == 1 then return 2.0 * x end

  local h0, h1 = 1.0, 2.0 * x
  for k = 2, n do
    local h2 = 2.0 * x * h1 - 2.0 * (k - 1) * h0
    h0, h1 = h1, h2
  end
  return h1
end

-- Funcao de onda normalizada psi_n(xi).
local function psi(n, xi)
  local norma = 1.0 / math.sqrt(2.0^n * fatorial(n) * math.sqrt(math.pi))
  return norma * hermite(n, xi) * math.exp(-xi * xi / 2.0)
end

local arquivo = assert(io.open("dados/oscilador.csv", "w"))
arquivo:write("# Oscilador harmonico quantico: hbar = m = omega = 1\n")
arquivo:write("# psi_n deslocadas por (n + 1/2) e escaladas por 0.30\n")
arquivo:write("x,V,psi0,psi1,psi2\n")

local passos = 100
local xmin, xmax = -4.0, 4.0

for i = 0, passos do
  local x = xmin + (xmax - xmin) * i / passos
  local V = 0.5 * x * x
  local p0 = 0.5 + 0.30 * psi(0, x)
  local p1 = 1.5 + 0.30 * psi(1, x)
  local p2 = 2.5 + 0.30 * psi(2, x)

  arquivo:write(fmt(x, "%.4f") .. "," .. fmt(V, "%.4f") .. "," ..
                fmt(p0, "%.4f") .. "," .. fmt(p1, "%.4f") .. "," ..
                fmt(p2, "%.4f") .. "\n")
end

arquivo:close()
print("gerado: dados/oscilador.csv")
