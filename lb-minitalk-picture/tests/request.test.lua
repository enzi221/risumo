local test = require('test')
local describe = test.describe
local it = test.it

local callbacks = {}
local toggles = {}

async = function(callback)
  return callback
end
getGlobalVar = function(_, name)
  return toggles[name] or '0'
end
listenEdit = function(event, callback)
  callbacks[event] = callback
end
prelude = require('prelude')

dofile('lb-minitalk-picture/triggers/picture.lua')

describe('MiniTalk picture request filtering', function()
  it('removes markers only inside MiniTalk blocks from main requests', function()
    local request = callbacks.editRequest('test', {
      {
        content = 'ou%%tside\n<lb-minitalk>1b%%oy\nsel%%fie</lb-minitalk>\n<other>ke%%ep</other>',
        role = 'assistant',
      },
    })
    test.assertEquals(request[1].content,
      'ou%%tside\n<lb-minitalk>1boy\nselfie</lb-minitalk>\n<other>ke%%ep</other>',
      'Keep markers outside MiniTalk blocks')
  end)
end)

test.printSummary()
