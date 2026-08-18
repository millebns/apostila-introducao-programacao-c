-- Converte os ambientes tcolorbox customizados da apostila em Markdown legível no GitHub.
-- Caixas de aviso viram blockquote (>) com emoji + rótulo em negrito, preservando
-- negrito/código internos. objetivos/resumo/níveis de exercício viram cabeçalhos.

local blockquote_boxes = {
  atencao    = "⚠️ Atenção",
  dica       = "💡 Dica",
  importante = "📌 Importante",
  destacado  = "📝 Situação",
}

local header_boxes = {
  objetivos = "🎯 Objetivos do Capítulo",
  resumo    = "📋 Resumo do Capítulo",
  exfacil   = "🟢 Nível Fácil",
  exmedio   = "🟡 Nível Médio",
  exdificil = "🔴 Nível Difícil",
}

function Div(el)
  local class = el.classes[1]

  -- Remove wrapper "center" (usado em volta de tabelas), mantém só o conteúdo
  if class == "center" then
    return el.content
  end

  if blockquote_boxes[class] then
    local label_para = pandoc.Para({ pandoc.Strong(pandoc.Str(blockquote_boxes[class])) })
    local content = { label_para }
    for _, block in ipairs(el.content) do
      table.insert(content, block)
    end
    return { pandoc.BlockQuote(content) }
  end

  if header_boxes[class] then
    local blocks = { pandoc.Header(2, header_boxes[class]) }
    for _, block in ipairs(el.content) do
      table.insert(blocks, block)
    end
    return blocks
  end

  -- Classe desconhecida: apenas remove o wrapper, mantém conteúdo
  return el.content
end

-- Remove spans de cor (usados nos cabeçalhos brancos das tabelas coloridas)
function Span(el)
  return el.content
end

-- Os blocos \begin{lstlisting}[style=codigoC] chegam como CodeBlock com
-- atributo style="codigoC". Marcamos como linguagem "c" para o GitHub
-- aplicar o highlight de sintaxe corretamente.
function CodeBlock(el)
  if el.attributes["style"] == "codigoC" then
    el.classes = { "c" }
    el.attributes["style"] = nil
  end
  return el
end