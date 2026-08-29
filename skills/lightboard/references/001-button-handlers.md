# Button Handlers

If you add `risu-trigger="abc"` to a button, clicking it will call the global function `abc`:

```html
<button risu-trigger="abc">ABC</button>
```

```lua
function abc(triggerId)
  print('called!')
end
```

To pass parameters, use `risu-btn` with `onButtonClick` instead:

```html
<button risu-btn="abc;0;1">ABC0</button> <button risu-btn="abc;1;1">ABC1</button>
```

```lua
-- code = abc;0;1 or abc;1;1
onButtonClick = function(triggerId, code)
  local prefix = 'abc'
  local _, prefixEnd = string.find(code, prefix)

  if not prefixEnd then
    return
  end

  local a, b = table.unpack(utils.split(code, ';'))
  setChatVar(triggerId, 'abc-a', a)
  setChatVar(triggerId, 'abc-b', b)
  -- ...
end
```

Insert these buttons with regexes or the Lua `listenEdit('editDisplay', ...)` API.
