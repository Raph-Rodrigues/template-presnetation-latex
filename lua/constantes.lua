-- =====================================================================
--  constantes.lua
--  Constantes fisicas recomendadas pelo CODATA 2022.
--  Cada entrada guarda: simbolo (LaTeX), valor (sintaxe siunitx),
--  unidade (LaTeX) e nome em portugues.
--
--  Os valores com incerteza usam a notacao do siunitx:
--      9.1093837139(28)e-31  ==  (9.1093837139 +/- 0.0000000028)e-31
-- =====================================================================

local M = {}

M.dados = {
  c = {
    simbolo = "c",
    valor   = "299792458",
    unidade = [[\metre\per\second]],
    nome    = "velocidade da luz no vácuo",
    exata   = true,
  },
  h = {
    simbolo = "h",
    valor   = "6.62607015e-34",
    unidade = [[\joule\second]],
    nome    = "constante de Planck",
    exata   = true,
  },
  hbar = {
    simbolo = [[\hbar]],
    valor   = "1.054571817e-34",
    unidade = [[\joule\second]],
    nome    = "constante de Planck reduzida",
    exata   = false,
  },
  e = {
    simbolo = "e",
    valor   = "1.602176634e-19",
    unidade = [[\coulomb]],
    nome    = "carga elementar",
    exata   = true,
  },
  me = {
    simbolo = "m_e",
    valor   = "9.1093837139(28)e-31",
    unidade = [[\kilogram]],
    nome    = "massa do elétron",
    exata   = false,
  },
  mp = {
    simbolo = "m_p",
    valor   = "1.67262192595(52)e-27",
    unidade = [[\kilogram]],
    nome    = "massa do próton",
    exata   = false,
  },
  kB = {
    simbolo = "k_B",
    valor   = "1.380649e-23",
    unidade = [[\joule\per\kelvin]],
    nome    = "constante de Boltzmann",
    exata   = true,
  },
  eps0 = {
    simbolo = [[\varepsilon_0]],
    valor   = "8.8541878188(14)e-12",
    unidade = [[\farad\per\metre]],
    nome    = "permissividade elétrica do vácuo",
    exata   = false,
  },
  NA = {
    simbolo = "N_A",
    valor   = "6.02214076e23",
    unidade = [[\per\mole]],
    nome    = "constante de Avogadro",
    exata   = true,
  },
  G = {
    simbolo = "G",
    valor   = "6.67430(15)e-11",
    unidade = [[\cubic\metre\per\kilogram\per\square\second]],
    nome    = "constante gravitacional",
    exata   = false,
  },
  muB = {
    simbolo = [[\mu_B]],
    valor   = "9.2740100657(29)e-24",
    unidade = [[\joule\per\tesla]],
    nome    = "magnéton de Bohr",
    exata   = false,
  },
}

-- Retorna a entrada pedida ou lanca um erro legivel no log do LaTeX.
function M.obter(chave)
  local c = M.dados[chave]
  if not c then
    error("constante desconhecida: '" .. tostring(chave) ..
          "'. Chaves disponiveis: " .. table.concat(M.chaves(), ", "))
  end
  return c
end

-- Lista de chaves em ordem alfabetica (util para mensagens de erro).
function M.chaves()
  local lista = {}
  for k in pairs(M.dados) do
    lista[#lista + 1] = k
  end
  table.sort(lista)
  return lista
end

return M
