local test = require('test')

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

test.printSummary()
