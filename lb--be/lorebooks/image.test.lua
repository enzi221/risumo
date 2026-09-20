local test = require('test')

local books = {}

getLoreBooks = function(_, name)
  return books[name] or {}
end

prelude = require('prelude')

local result
generateImage = function()
  return {
    await = function()
      return result
    end,
  }
end

local image = require('lb--be/lorebooks/image')

test.describe('Image generation result', function()
  test.it('returns image inlays', function()
    result = '{{inlay::picture-id}}'
    test.assertEquals(image.generateImageFromPrompts('test', { positive = 'portrait' }), result,
      'Return a generated image inlay')
  end)

  test.it('uses the configured failure message for a non-inlay API result', function()
    result = 'Error: Image generation failed'
    local success, reason = pcall(image.generateImageFromPrompts, 'test', { positive = 'portrait' }, {
      requestFailed = '이미지 API 호출 실패',
    })
    test.assertTrue(not success, 'Reject a non-inlay API result')
    test.assertTrue(tostring(reason):find('이미지 API 호출 실패', 1, true) ~= nil,
      'Use the caller-defined failure message')
  end)
end)

test.describe('Image preset weights', function()
  test.it('strips explicit and bracket weights from positive and negative prompts', function()
    books.preset = { {
      content = '[Positive]\n{prompt}\n[Negative]\n{prompt}',
    } }

    local prompts = assert(image.applyImagePreset('test', {
      characters = { {
        negative = '[bad anatomy]',
        positive = '{girl}',
      } },
      description = '',
      setup = '{{masterpiece}}, [soft light], 1.2::red dress::',
    }, {
      comfy = true,
      negativeNote = '0.5::blurry::',
      presetBookName = 'preset',
      weightMode = 'strip',
    }))

    test.assertEquals(prompts.positive, 'masterpiece, soft light, red dress,\n\ngirl',
      'Strip positive weights')
    test.assertEquals(prompts.negative, 'blurry\n\nbad anatomy', 'Strip negative weights')
  end)

  test.it('converts explicit weights and strips bracket weights', function()
    books.preset = { {
      content = '[Positive]\n{prompt}\n[Negative]\n{prompt}',
    } }

    local prompts = assert(image.applyImagePreset('test', {
      characters = { {
        negative = '[bad anatomy]',
        positive = '{girl}',
      } },
      description = '',
      setup = '{{masterpiece}}, [soft light], 1.2::red dress::',
    }, {
      comfy = true,
      negativeNote = '0.5::blurry::',
      presetBookName = 'preset',
      weightMode = 'convert',
    }))

    test.assertEquals(prompts.positive, 'masterpiece, soft light, (red dress:1.2),\n\ngirl',
      'Convert explicit positive weights and strip bracket weights')
    test.assertEquals(prompts.negative, '(blurry:0.5)\n\nbad anatomy',
      'Convert explicit negative weights and strip bracket weights')
  end)
end)

test.printSummary()
