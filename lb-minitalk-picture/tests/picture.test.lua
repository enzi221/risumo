local test = require('test')
local describe = test.describe
local it = test.it

prelude = require('prelude')

local picture = require('lb-minitalk-picture/lorebooks/picture.lib')
prelude.import = function(_, name)
  if name == 'lb-minitalk-picture.lib' then
    return picture
  end
end
local generated = require('lb-minitalk-picture/lorebooks/picture-generated')

describe('MiniTalk picture OpenBlock', function()
  it('parses setup and character sections', function()
    local data = assert(picture.parse('1girl, selfie, upper body § girl, black hair. waving.'))
    test.assertEquals(data.setup, '1girl, selfie, upper body', 'Keep setup and perspective together')
    test.assertEquals(#data.characters, 1, 'Parse one character prompt')
    test.assertEquals(data.characters[1].positive, 'girl, black hair. waving.', 'Keep character prompt')
  end)

  it('accepts a picture without featured characters', function()
    local data = assert(picture.parse('no people, pov, exterior, rainy street'))
    test.assertEquals(#data.characters, 0, 'Allow a setup-only picture')
  end)

  it('rejects multiline and empty content', function()
    test.assertTrue(not picture.parse(''), 'Reject empty content')
    test.assertTrue(not picture.parse('no people\nexterior'), 'Reject multiline content')
  end)

  it('keeps generated inlays and their original prompts', function()
    local content = '{{inlay::picture-id}} § selfie § girl, black hair § boy, blond hair'
    local stored = assert(picture.parseGenerated(content))
    test.assertEquals(stored.original, 'selfie § girl, black hair § boy, blond hair',
      'Keep every original picture section')
    test.assertTrue(generated.validate('test', content), 'Accept an inlay followed by its original content')
  end)

  it('renders a non-inlay result without losing regeneration', function()
    local content = 'image result unavailable § selfie § girl, black hair'
    local stored = assert(picture.parseGenerated(content))
    test.assertEquals(stored.original, 'selfie § girl, black hair', 'Retain the original prompt for regeneration')
    test.assertEquals(stored.inlay, nil, 'Do not treat a non-inlay result as an image')
    test.assertTrue(generated.validate('test', content), 'Accept stored results without an inlay')
    local html = generated.render('test', content, {
      chatIndex = 0,
      id = 'picture-test',
      messageIndex = 1,
    })
    test.assertTrue(html:find('첨부사진을 표시할 수 없습니다', 1, true) ~= nil,
      'Show a fallback for a non-inlay result')
    test.assertTrue(html:find('lb-minitalk-picture-generate/0_1', 1, true) ~= nil,
      'Offer regeneration from the original prompt')
  end)

end)

test.printSummary()
