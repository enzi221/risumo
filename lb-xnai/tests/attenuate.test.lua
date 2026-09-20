local test = require('test')
local describe = test.describe
local it = test.it

prelude = require('prelude')

local gen = require('lb-xnai/lorebooks/xnai.gen')

describe('NAI prompt weight attenuation', function()
  it('attenuates simple tags without weights', function()
    local result = gen.attenuatePrompt('masterpiece, 1girl, smiling')
    test.assertEquals(result, '0.75::masterpiece, 1girl, smiling ::', 'Wrap whole prompt in 0.75')
  end)

  it('attenuates tags containing existing weights and maintains 0.75 across boundaries', function()
    local result = gen.attenuatePrompt('abc, 2::def::, ghi')
    test.assertEquals(result, '0.75::abc, ::1.5::def ::0.75::, ghi ::', 'Preserve weight continuation across tags')
  end)

  it('handles existing weights that already have trailing spaces', function()
    local result = gen.attenuatePrompt('abc, 2::def ::, ghi')
    test.assertEquals(result, '0.75::abc, ::1.5::def ::0.75::, ghi ::', 'Normalize closing space')
  end)

  it('scales decimal weights properly', function()
    local result = gen.attenuatePrompt('0.4::cloud9 ::')
    test.assertEquals(result, '0.3::cloud9 ::', 'Scale decimal weight')
  end)

  it('handles multiple consecutive weighted blocks', function()
    local result = gen.attenuatePrompt('1::first::, 2::second::')
    test.assertEquals(result, '0.75::first ::, 1.5::second ::', 'Multiple consecutive weights')
  end)

  it('handles empty input gracefully', function()
    test.assertEquals(gen.attenuatePrompt(''), '', 'Empty string')
    test.assertEquals(gen.attenuatePrompt('   '), '   ', 'Whitespace string')
  end)
end)

describe('buildPresetPrompt attenuation integration', function()
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

  it('does not attenuate when toggle is disabled', function()
    globalVars['toggle_lb-xnai.compat.comfy'] = '0'
    globalVars['toggle_lb-xnai.preset.attenuate'] = '0'

    local prompts = gen.buildPresetPrompt('test', {
      camera = 'close-up',
      cast = 'solo',
      characters = {},
      scene = 'room',
    })
    test.assertEquals(prompts.positive, 'solo, close-up, room', 'Unattenuated when toggle is 0')
  end)

  it('attenuates model setup when toggle is enabled in NAI mode', function()
    globalVars['toggle_lb-xnai.compat.comfy'] = '0'
    globalVars['toggle_lb-xnai.preset.attenuate'] = '1'

    local prompts = gen.buildPresetPrompt('test', {
      camera = '',
      cast = '',
      characters = {},
      scene = 'abc, 2::def::, ghi',
    })
    test.assertEquals(prompts.positive, '0.75::abc, ::1.5::def ::0.75::, ghi ::', 'Attenuated in NAI mode')
  end)

  it('does not attenuate in ComfyUI mode even if toggle is enabled', function()
    globalVars['toggle_lb-xnai.compat.comfy'] = '1'
    globalVars['toggle_lb-xnai.preset.attenuate'] = '1'

    local prompts = gen.buildPresetPrompt('test', {
      camera = '',
      cast = '',
      characters = {},
      scene = 'abc, 2::def::, ghi',
    })
    test.assertEquals(prompts.positive, 'abc, 2::def::, ghi', 'Unattenuated in ComfyUI mode')
  end)
end)

test.printSummary()
