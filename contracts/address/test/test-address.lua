local filepath, filename, fileext = string.match(arg[0], "(.-)([^\\]-([^\\%.]+))$")
package.path = filepath .. '../../../libs/?.lua;' .. filepath .. '../?.lua;'.. package.path

require "athena-343-local"
require "address"

local suite = TestSuite('test suite for address.lua')

suite:add(TestCase('test valid address', function()
    assertTrue(address.isValidAddress("AmhUthrLULUMee46RDcfmBfajd3CK7Lpbgds7xRsAQoLpY32BcFK"))
    assertTrue(address.isValidAddress("AmgR34MnJ1XgvVTtL2FudQBp8wQvfP9voHCyYjWcTKcJUEU5FGGu"))
    assertTrue(address.isValidAddress("AmgJ9GSiMZmLtqn1VxwK7huzCWdafQYcDYxFrzdNCr8EpmXckCdS"))
end))

suite:add(TestCase('test invalid address', function()
    assertFalse(address.isValidAddress("Am hUthrLULUMee46RDcfmBfajd3CK7Lpbgds7xRsAQoLpY32BcF"))
    assertFalse(address.isValidAddress("AmgR34MnJ1XgvVTtL2FudQBp8wQvfP9voHCyYjWcTKcJUEU5FGG="))
    assertFalse(address.isValidAddress("ThisWillNotWork"))
end))

suite:add(TestCase('check nil address', function()
    assertTrue(address.isValidAddress(address.nilAddress()))
end))

suite:run()