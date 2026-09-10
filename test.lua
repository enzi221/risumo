local framework = {}

local totalTests = 0
local passedTests = 0
local failedTests = 0

function framework.assertEquals(actual, expected, message)
  totalTests = totalTests + 1
  if actual == expected then
    passedTests = passedTests + 1
    print("✓ " .. message)
  else
    failedTests = failedTests + 1
    print("✗ " .. message)
    print("  Expected: " .. tostring(expected))
    print("  Actual:   " .. tostring(actual))
  end
end

function framework.assertTrue(condition, message)
  framework.assertEquals(not not condition, true, message)
end

function framework.deepEqual(left, right)
  if type(left) ~= type(right) then
    return false
  end
  if type(left) ~= 'table' then
    return left == right
  end

  local leftCount = 0
  local rightCount = 0
  for key, value in pairs(left) do
    leftCount = leftCount + 1
    if not framework.deepEqual(value, right[key]) then
      return false
    end
  end
  for _ in pairs(right) do
    rightCount = rightCount + 1
  end
  return leftCount == rightCount
end

function framework.assertDeepEquals(actual, expected, message)
  framework.incrementTotal()
  if framework.deepEqual(actual, expected) then
    framework.incrementPassed()
    print('✓ ' .. message)
  else
    framework.incrementFailed()
    print('✗ ' .. message)
    print('  Expected: ' .. framework.tableToString(expected))
    print('  Actual:   ' .. framework.tableToString(actual))
  end
end

function framework.assertFails(callback, expected, message)
  framework.incrementTotal()
  local success, result = pcall(callback)
  if not success and tostring(result):find(expected, 1, true) then
    framework.incrementPassed()
    print('✓ ' .. message)
  else
    framework.incrementFailed()
    print('✗ ' .. message)
    print('  Expected error containing: ' .. expected)
    print('  Actual: ' .. tostring(result))
  end
end

function framework.describe(name, fn)
  print("\n" .. name)
  fn()
end

function framework.it(name, fn)
  fn()
end

function framework.printSummary()
  print("\n" .. string.rep("=", 50))
  print("Test Summary")
  print(string.rep("=", 50))
  print(string.format("Total:  %d", totalTests))
  print(string.format("Passed: %d", passedTests))
  print(string.format("Failed: %d", failedTests))
  print(string.rep("=", 50))

  if failedTests == 0 then
    print("✓ All tests passed!")
    os.exit(0)
  else
    print("✗ Some tests failed")
    os.exit(1)
  end
end

function framework.getStats()
  return {
    total = totalTests,
    passed = passedTests,
    failed = failedTests
  }
end

function framework.incrementTotal()
  totalTests = totalTests + 1
end

function framework.incrementPassed()
  passedTests = passedTests + 1
end

function framework.incrementFailed()
  failedTests = failedTests + 1
end

function framework.tableToString(t, indent)
  indent = indent or 0
  if type(t) ~= "table" then
    return tostring(t)
  end

  local str = "{\n"
  local first = true
  local indentStr = string.rep("  ", indent + 1)

  for k, v in pairs(t) do
    if not first then str = str .. ",\n" end
    first = false
    str = str .. indentStr .. "[" .. tostring(k) .. "] = "
    if type(v) == "table" then
      str = str .. framework.tableToString(v, indent + 1)
    else
      str = str .. tostring(v)
    end
  end

  str = str .. "\n" .. string.rep("  ", indent) .. "}"
  return str
end

return framework
