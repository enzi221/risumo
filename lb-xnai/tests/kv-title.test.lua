local test = require('test')
local describe = test.describe
local it = test.it

prelude = require('prelude')

local gen = require('lb-xnai/lorebooks/xnai.gen')

describe('Key visual title prompt', function()
  local globalVars = {}
  getGlobalVar = function(_, key)
    return globalVars[key]
  end

  local dummyImage = {
    applyImagePreset = function(_, source, options)
      local pos = source.setup
      if options and options.positiveNote and options.positiveNote ~= '' then
        pos = pos ~= '' and (pos .. ', ' .. options.positiveNote) or options.positiveNote
      end
      return {
        description = source.description,
        negative = options and options.negativeNote or '',
        positive = pos,
      }
    end,
  }

  prelude.import = function()
    return dummyImage
  end
  prelude.verbose = function() end

  it('appends movie title prompt with character name from getName() when toggle is on and slot is nil', function()
    globalVars['toggle_lb-xnai.kv.title'] = '1'
    getName = function() return 'Envy' end
    local prompts = gen.buildPresetPrompt('test', {
      cast = 'solo',
      characters = {},
      scene = 'night sky',
    })
    test.assertEquals(
      prompts.positive,
      'solo, night sky, A title "Envy" is written 0.75::in the very middle of the image, horizontally and vertically centered, like a movie or a book title. ::',
      'Keyvis gets title prompt with character name from getName()'
    )
    getName = nil
    globalVars['toggle_lb-xnai.kv.title'] = nil
  end)

  it('does not append title prompt when getName() returns empty string', function()
    globalVars['toggle_lb-xnai.kv.title'] = '1'
    getName = function() return '' end
    local prompts = gen.buildPresetPrompt('test', {
      cast = 'solo',
      characters = {},
      scene = 'night sky',
    })
    test.assertEquals(prompts.positive, 'solo, night sky', 'Empty name skips title prompt')
    getName = nil
    globalVars['toggle_lb-xnai.kv.title'] = nil
  end)

  it('does not append title prompt when toggle is disabled', function()
    globalVars['toggle_lb-xnai.kv.title'] = '0'
    getName = function() return 'Envy' end
    local prompts = gen.buildPresetPrompt('test', {
      cast = 'solo',
      characters = {},
      scene = 'night sky',
    })
    test.assertEquals(prompts.positive, 'solo, night sky', 'Disabled toggle skips title prompt')
    getName = nil
    globalVars['toggle_lb-xnai.kv.title'] = nil
  end)

  it('does not append title prompt for regular scenes with slot', function()
    globalVars['toggle_lb-xnai.kv.title'] = '1'
    getName = function() return 'Envy' end
    local prompts = gen.buildPresetPrompt('test', {
      cast = 'solo',
      characters = {},
      scene = 'night sky',
      slot = 1,
    })
    test.assertEquals(prompts.positive, 'solo, night sky', 'Regular scenes do not get keyvis title prompt')
    getName = nil
    globalVars['toggle_lb-xnai.kv.title'] = nil
  end)
end)

test.printSummary()
