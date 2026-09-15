local function main(triggerId, input)
  if getGlobalVar(triggerId, 'toggle_lb-xnai.forcedinsertion') == '1' then
    return input
  end

  return input:gsub('%%%%', '')
end

return main
