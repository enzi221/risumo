local test = require('test')
local describe = test.describe
local it = test.it

local function read(path)
  local file = assert(io.open(path))
  local content = file:read('*a')
  file:close()
  return content
end

prelude = require('prelude')

local options = {
  escapeText = function(value)
    return prelude.escEntities(value):gsub('{', '&#123;'):gsub('}', '&#125;')
  end,
}
local calendar = require('lb-minitalk-stdblocks/lorebooks/calendar')
local graph = require('lb-minitalk-stdblocks/lorebooks/opengraph')
local poll = require('lb-minitalk-stdblocks/lorebooks/poll')

describe('Standard OpenBlocks', function()
  it('inherits the MiniTalk message palette', function()
    local css = read('lb-minitalk-stdblocks/style.html')
    for _, property in ipairs({ 'accent', 'bg', 'bg-2', 'border', 'fg' }) do
      test.assertTrue(css:find('var(--lb-minitalk-' .. property .. ')', 1, true),
        'Consume MiniTalk color: ' .. property)
    end
    test.assertTrue(not css:find('#%x%x%x'), 'No hardcoded palette colors')
  end)

  it('validates and renders calendar events', function()
    for _, content in ipairs({
      '저녁 식사 § 오늘 19:00',
      '프로젝트 워크숍 § 9월 14일(월) 14:00–16:00 § 3층 회의실 § 노트북 지참',
      '출장 § 월–수 종일 §  § 일정 변경 가능',
    }) do
      test.assertTrue(calendar.validate('test', content), 'Accept calendar event: ' .. content)
      local html = calendar.render('test', content, options)
      test.assertTrue(html:find('캘린더', 1, true), 'Render calendar label')
    end
    for _, content in ipairs({ '', '제목만', ' § 19:00', '약속 § ' }) do
      test.assertTrue(not calendar.validate('test', content), 'Reject calendar event: ' .. content)
    end
    local detailed = calendar.render(
      'test', '밋 § 9월 14일 19:00 § 식당 § 생일 축하', options)
    for _, value in ipairs({ '밋', '9월 14일 19:00', '식당', '생일 축하' }) do
      test.assertTrue(detailed:find(value, 1, true), 'Render calendar field: ' .. value)
    end
    local noLocation = calendar.render('test', '출장 § 월–수 §  § 일정 변경 가능', options)
    test.assertTrue(noLocation:find('일정 변경 가능', 1, true), 'Render description without location')
    local escaped = calendar.render(
      'test', '<script> § {{bad}} § <img src=x> § <a href=x>link</a>', options)
    test.assertTrue(not escaped:find('<script>', 1, true) and not escaped:find('<img', 1, true), 'Escape HTML')
    test.assertTrue(not escaped:find('{{', 1, true) and not escaped:find('<a ', 1, true), 'Escape CBS and links')
  end)

  it('validates and renders polls', function()
    for _, content in ipairs({
      '야식? § 치킨 :: 0 § 피자 :: 0',
      '야식? § 치킨 :: 1 § 피자 :: 0',
      '야식? § 치킨 :: 2 § 피자 :: 1 § ',
      '야식? § 치킨 § 피자 :: ',
    }) do
      test.assertTrue(poll.validate('test', content), 'Accept poll: ' .. content)
      local html = poll.render('test', content, options)
      test.assertTrue(html:find('치킨', 1, true) and html:find('피자', 1, true), 'Render poll options')
    end
    for _, content in ipairs({
      '질문', '질문 § 하나 :: 0', '질문 § 하나 :: -1 § 둘 :: 0',
      '질문 § 하나 :: 1.5 § 둘 :: 0', '질문 § 하나 :: inf § 둘 :: 0', '질문 §  :: 1 § 둘 :: 0',
    }) do
      test.assertTrue(not poll.validate('test', content), 'Reject poll: ' .. content)
    end
    local empty = poll.render('test', '질문 § 하나 :: 0 § 둘 :: 0', options)
    test.assertTrue(empty:find('아직 참여한 사람이 없어요', 1, true), 'Render empty poll')
    test.assertTrue(empty:find('width:0%;', 1, true), 'Render empty poll width')
    local voted = poll.render('test', '질문 § 하나 :: 2 § 둘 :: 1', options)
    test.assertTrue(voted:find('67%%') and voted:find('총 3표', 1, true), 'Render poll totals')
  end)

  it('validates and escapes OpenGraph cards', function()
    for _, content in ipairs({
      '사이트 § example.com § 제목',
      '사이트 § https://example.com § 제목 § 설명',
    }) do
      test.assertTrue(graph.validate('test', content), 'Accept OpenGraph card: ' .. content)
      test.assertTrue(graph.render('test', content, options):find('제목', 1, true), 'Render OpenGraph title')
    end
    test.assertTrue(not graph.validate('test', '사이트 § 주소'), 'Reject incomplete OpenGraph card')
    for block, content in pairs({
      [graph] = '<script> § https://example.com § {{bad}} § <img src=x>',
      [poll] = '<script> § {{bad}} :: 0 § <img src=x> :: 1',
    }) do
      local html = block.render('test', content, options)
      test.assertTrue(not html:find('<script>', 1, true) and not html:find('<img', 1, true), 'Escape HTML')
      test.assertTrue(not html:find('{{', 1, true) and not html:find('href=', 1, true), 'Escape CBS and links')
    end
  end)
end)

test.printSummary()
