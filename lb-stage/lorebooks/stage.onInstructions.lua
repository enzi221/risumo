local function main(triggerId, instructions, meta)
  local regeneration = meta and meta.type ~= 'generation'
  local sampling = getGlobalVar(triggerId, 'toggle_lb-stage.sampling') == '1'
  if regeneration or sampling then
    instructions.format = instructions.format:gsub('<lb%-stage%-patch>.-</lb%-stage%-patch>%s*', '')
  end
  if regeneration then
    instructions.guideline = instructions.guideline .. '\n\nFor this reroll or regeneration request, return complete <lb-stage> TOON output instead of a patch.'
  end
  return instructions
end

return main
