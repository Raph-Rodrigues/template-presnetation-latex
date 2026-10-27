-- =====================================================================
--  instalar.lua
--  Registra um buscador de modulos para a pasta ./lua e carrega o
--  modulo principal. E executado por \directlua{dofile(...)} em
--  fisica.sty -- assim nenhum codigo Lua com barras invertidas
--  precisa aparecer dentro do .tex.
-- =====================================================================

local function buscar(nome)
  local base = nome:gsub("%.", "/")
  local candidatos = {
    "./lua/" .. base .. ".lua",
    "./lua/" .. base .. "/init.lua",
  }

  for _, caminho in ipairs(candidatos) do
    local arquivo = io.open(caminho, "r")
    if arquivo then
      arquivo:close()
      local chunk, erro = loadfile(caminho)
      if chunk then
        return chunk, caminho
      end
      error(erro)
    end
  end

  return " (modulo Lua nao encontrado em ./lua: " .. nome .. ")"
end

table.insert(package.searchers, 2, buscar)
fisica = require("fisica")
