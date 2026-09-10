package.path = table.concat({
  './?.lua',
  './lb--be/lorebooks/?.lua',
  './lb--be/triggers/?.lua',
  package.path,
}, ';')

-- Module filenames can contain literal dots, such as toon.decode.lua.
table.insert(package.searchers, 2, function(name)
  local path, reason = package.searchpath(name, package.path, '/')
  if not path then
    return reason
  end
  return assert(loadfile(path)), path
end)
