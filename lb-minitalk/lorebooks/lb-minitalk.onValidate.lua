local function main(triggerId, output)
  local runtime = prelude.import(triggerId, 'lb-minitalk.runtime')
  if runtime.patch(output) then
    return
  end
  runtime.decode(triggerId, runtime.extract(output).content, true)
end

return main
