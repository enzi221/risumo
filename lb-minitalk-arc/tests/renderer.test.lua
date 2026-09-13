local test = require('test')
prelude = require('prelude')
local render = assert(loadfile('lb-minitalk-arc/lorebooks/renderer.lua'))()
local toggles = {}
getGlobalVar = function(_, name)
  return toggles[name] or '0'
end
local calls = {}
local function escape(value)
  return prelude.escEntities(value):gsub('{', '&#123;'):gsub('}', '&#125;')
end
local options = {
  chatIndex = 0,
  escapeText = escape,
  id = 'arc-test-0',
  renderContent = function(message)
    table.insert(calls, message.type)
    return '<span>' .. escape(message.content) .. '</span>'
  end,
}
local data = {
  messages = {
    { content = '<hello>{{user}}', sender = 'a', time = '10:00', type = 'text' },
    { content = 'sticker', sender = 'a', time = '10:01', type = 'con' },
    { content = '<later>{{user}}', sender = '-', time = '-', type = 'pause' },
    { content = 'card', sender = 'a', time = '10:02', type = 'openblock:calendar' },
    { content = '-', sender = '-', time = '-', type = 'skip' },
    { content = 'a', sender = '-', time = '10:03', type = 'exit' },
    { content = 'a', sender = '-', time = '10:04', type = 'invited' },
    { content = 'reply', sender = 'b', time = '10:05', type = 'text' },
  },
  name = '<room>{{user}}',
  participants = { { id = 'a', name = '상대' }, { id = 'b', name = '사용자' } },
  pov = 'b',
}
local html = render('test', data, options)
test.assertDeepEquals(calls, { 'text', 'con', 'openblock:calendar', 'exit', 'invited', 'text' }, 'Content helper receives every supported content kind except separators')
test.assertTrue(html:find('&lt;later&gt;&#123;&#123;user&#125;&#125;', 1, true), 'Pause content uses the supplied escaping helper')
test.assertTrue(html:find('&lt;room&gt;&#123;&#123;user&#125;&#125;', 1, true), 'Room title prevents HTML and CBS evaluation')
test.assertTrue(html:find('class="lb-minitalk-arc-media"', 1, true), 'MiniCon uses a media wrapper')
test.assertTrue(html:find('class="lb-minitalk-arc-openblock"', 1, true), 'OpenBlock content uses its own wrapper')
local _, starts = html:gsub('data%-group%-start="true"', '')
test.assertEquals(starts, 3, 'Consecutive senders group together and pause restarts a group')
test.assertTrue(html:find('data-self="true"', 1, true), 'POV message uses outgoing palette')
test.assertTrue(html:find('lb-minitalk-arc-avatar lb-minitalk-gradient', 1, true), 'Arc avatar reuses the shared gradient')
test.assertTrue(html:find('%-%-lb%-minitalk%-gradient%-seed:%d+'), 'Avatar receives a stable nickname seed')
for _, action in ipairs({ 'lb-reroll__lb-minitalk', 'lb-interaction__lb-minitalk__ChangeRoom', 'lb-interaction__lb-minitalk__SendMessage', 'lb-interaction__lb-minitalk__immediate#PassTime' }) do
  test.assertTrue(html:find('risu-btn="' .. action .. '"', 1, true), 'Control dispatches ' .. action)
end
test.assertTrue(html:find('popovertarget="arc-test-0"', 1, true), 'Room controls target the supplied unique popover')
for index, color in ipairs({ 'pink', 'blue', 'yellow', 'green' }) do
  toggles['toggle_lb-minitalk.theme'] = tostring(index - 1)
  toggles['toggle_lb-minitalk.darkness'] = '1'
  local themed = render('test', data, options)
  test.assertTrue(themed:find('data-color="' .. color .. '"', 1, true), 'Existing theme selects ' .. color)
  test.assertTrue(themed:find('data-theme="dark"', 1, true), 'Existing brightness selects dark mode')
end
data.messages = {}
test.assertTrue(render('test', data, options):find('메시지 없음', 1, true), 'Empty room remains usable')
test.assertTrue(html:find('class="lb-module-opener-root"', 1, true), 'Opener wrapper has no renderer layout class')
test.assertTrue(html:find('class="lb-dialog lb-minitalk-arc-root lb-minitalk-arc-dialog"', 1, true), 'Popover combines shared dialog positioning with Arc styling')
test.assertTrue(html:find('popovertargetaction="hide"', 1, true), 'Close control hides the popover')
test.printSummary()
