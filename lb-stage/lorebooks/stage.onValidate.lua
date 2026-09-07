local function main(triggerId, output)
  local resolve = prelude.import(triggerId, 'lb-stage.state')
  resolve(triggerId, output)
end

return main
