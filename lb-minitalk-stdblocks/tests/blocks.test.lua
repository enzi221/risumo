local test = require('test')
local describe = test.describe
local it = test.it

prelude = require('prelude')
local calendar = require('lb-minitalk-stdblocks/lorebooks/calendar')
local graph = require('lb-minitalk-stdblocks/lorebooks/opengraph')
local poll = require('lb-minitalk-stdblocks/lorebooks/poll')

describe('Standard OpenBlocks', function()
  it('validates calendar events', function()
    for _, content in ipairs({
      '저녁 식사 § 오늘 19:00',
      '프로젝트 워크숍 § 9월 14일(월) 14:00–16:00 § 3층 회의실 § 노트북 지참',
      '출장 § 월–수 종일 §  § 일정 변경 가능',
    }) do
      test.assertTrue(calendar.validate('test', content), 'Accept calendar event: ' .. content)
    end
    for _, content in ipairs({ '', '제목만', ' § 19:00', '약속 § ' }) do
      test.assertTrue(not calendar.validate('test', content), 'Reject calendar event: ' .. content)
    end
  end)

  it('validates polls', function()
    for _, content in ipairs({
      '야식? § 치킨 :: 0 § 피자 :: 0',
      '야식? § 치킨 :: 1 § 피자 :: 0',
      '야식? § 치킨 :: 2 § 피자 :: 1 § ',
      '야식? § 치킨 § 피자 :: ',
    }) do
      test.assertTrue(poll.validate('test', content), 'Accept poll: ' .. content)
    end
    for _, content in ipairs({
      '질문', '질문 § 하나 :: 0', '질문 § 하나 :: -1 § 둘 :: 0',
      '질문 § 하나 :: 1.5 § 둘 :: 0', '질문 § 하나 :: inf § 둘 :: 0', '질문 §  :: 1 § 둘 :: 0',
    }) do
      test.assertTrue(not poll.validate('test', content), 'Reject poll: ' .. content)
    end
  end)

  it('validates OpenGraph cards', function()
    for _, content in ipairs({
      '사이트 § example.com § 제목',
      '사이트 § https://example.com § 제목 § 설명',
    }) do
      test.assertTrue(graph.validate('test', content), 'Accept OpenGraph card: ' .. content)
    end
    test.assertTrue(not graph.validate('test', '사이트 § 주소'), 'Reject incomplete OpenGraph card')
  end)
end)

test.printSummary()
