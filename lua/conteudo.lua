-- =====================================================================
--  conteudo.lua
--  Dados que alimentam os slides: roteiro, comparacao, niveis e
--  exercicios. Edite aqui e recompile -- nenhum .tex precisa mudar.
-- =====================================================================

local M = {}

-- Arquivo lido por fisica.plotOscilador()
M.arquivoDados = "dados/oscilador.csv"

-- ---------------------------------------------------------------------
--  Roteiro da apresentacao (gera os itens do slide "Roteiro")
-- ---------------------------------------------------------------------
M.roteiro = {
  {
    titulo    = "Motivação",
    descricao = "Por que o oscilador harmônico aparece em toda a física.",
  },
  {
    titulo    = "Formulação quântica",
    descricao = "A equação de Schrödinger e a quantização da energia.",
  },
  {
    titulo    = "Espectro e funções de onda",
    descricao = "Níveis, paridade, nós e densidade de probabilidade.",
  },
  {
    titulo    = "Aplicações e ferramentas",
    descricao = "Do infravermelho aos qubits; constantes e dados via Lua.",
  },
}

-- ---------------------------------------------------------------------
--  Tabela classico x quantico
-- ---------------------------------------------------------------------
M.comparacao = {
  {
    aspecto   = "Energia",
    classico  = [[contínua, $E \ge 0$]],
    quantico  = [[discreta, $E_n=(n+\tfrac12)\hbar\omega$]],
  },
  {
    aspecto   = "Estado de menor energia",
    classico  = [[repouso no fundo do poço, $E=0$]],
    quantico  = [[energia de ponto zero, $E_0=\tfrac12\hbar\omega$]],
  },
  {
    aspecto   = "Posição",
    classico  = [[trajetória $x(t)$ bem definida]],
    quantico  = [[distribuição de probabilidade $|\psi_n|^2$]],
  },
  {
    aspecto   = "Amplitude",
    classico  = [[qualquer valor permitido por $E$]],
    quantico  = [[probabilidade não nula fora da região clássica]],
  },
  {
    aspecto   = "Radiação emitida",
    classico  = [[qualquer frequência]],
    quantico  = [[saltos discretos $\Delta E=\hbar\omega$]],
  },
}

-- ---------------------------------------------------------------------
--  Niveis de energia. A energia e calculada em meV supondo
--  hbar*omega = 250 meV (regiao do infravermelho medio).
-- ---------------------------------------------------------------------
M.hbarOmegaMeV = 250

M.niveis = {}
for n = 0, 5 do
  M.niveis[#M.niveis + 1] = {
    n        = n,
    energia  = (n + 0.5) * M.hbarOmegaMeV,
    paridade = (n % 2 == 0) and "+1" or "-1",
    nos      = n,
  }
end

-- ---------------------------------------------------------------------
--  Exercicios (o campo nivel aparece alinhado a direita)
-- ---------------------------------------------------------------------
M.exercicios = {
  {
    texto = [[Partindo de $[\hat x,\hat p]=i\hbar$, mostre que $[\hat H,\hat a^\dagger]=\hbar\omega\,\hat a^\dagger$.]],
    nivel = "nível 1",
  },
  {
    texto = [[Calcule $\langle x\rangle$ e $\langle x^2\rangle$ no estado fundamental e verifique o princípio da incerteza.]],
    nivel = "nível 2",
  },
  {
    texto = [[Determine a probabilidade de encontrar a partícula fora da região classicamente permitida para $n=0$.]],
    nivel = "nível 3",
  },
  {
    texto = [[Estime $E_0$ por análise dimensional e compare com $\tfrac12\hbar\omega$.]],
    nivel = "nível 1",
  },
  {
    texto = [[Esboce $\psi_3(\xi)$ e identifique seus nós e sua paridade.]],
    nivel = "nível 1",
  },
}

return M
