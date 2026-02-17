local function main(_, output)
  local node = prelude.queryNodes('lb-stage', output)
  if #node == 0 then
    return
  end

  local success, content = pcall(prelude.toon.decode, node[1].content)
  if not success then
    error('InvalidOutput: Invalid TOON format. ' .. tostring(content))
  end

  -- Check for unknown keys (known keys: objective, phase, episodes, divergence, comment, history, foreshadowing)
  local knownKeys = {
    objective = true,
    phase = true,
    episodes = true,
    divergence = true,
    comment = true,
    history = true
  }

  for key, _ in pairs(content) do
    if not knownKeys[key] then
      error('InvalidOutput: Unknown key "' .. key .. '".')
    end
  end
end

return main
