package.path = package.path..';../?.lua'
local notifitable = require('notifitable')
require 'lunity'
module( 'TEST_NOTIFITABLE', lunity )

function test1_basics()
	assertType(notifitable,'function')
	local dm = notifitable()
	assertType(dm,'table')
	local updates = {}
	local hits = 0
	local result = dm:registerForChange('foo',function(key,newval,oldval)
		assertEqual(key,'foo')
		assertEqual(oldval,updates[key])
		updates[key] = newval
		hits = hits+1
	end)
	assertTrue(result)
	local function bump() hits = hits+1 end
	local result = dm:registerForChange('foo',bump)
	assertTrue(result)
	assertNil(updates.foo)
	dm.foo = 17
	assertEqual(updates.foo,17)
	assertEqual(hits,2)
	dm.foo = 42
	assertEqual(updates.foo,42)
	assertEqual(hits,4)
	dm:unregisterForChange('foo',bump)
	dm.foo = 9
	assertEqual(hits,5)
	dm.foo = nil
	assertNil(updates.foo)
end

function test2_nestedkeys()
	local dm = notifitable()
	dm.t1 = {bar=17}
	local ping
	local function pingbump(k,v) ping=v end
	dm:registerForChange('t1','foo',pingbump)
	dm.t1.foo = 42
	assertEqual(ping,42)
	assertEqual(dm.t1.bar,17)
	dm:unregisterForChange('t1','foo',pingbump)
	dm.t1.foo = 9
	assertEqual(ping,42)
end

function test3_autovivification()
	local dm = notifitable()
	local ping
	dm:registerForChange('t1','foo','bar',function(k,v)
		ping = v
	end)
	dm.t1.foo.jim = 17
	dm.t1.foo.bar = 42
	assertEqual(ping,42)
end

function test4_wrapping()
	local t = {foo=17}
	local dm = notifitable(t)
	local ping
	assertEqual(dm.foo,17)
	dm:registerForChange('foo',function(k,v)
		ping = v
	end)
	dm.foo = 42
	assertEqual(t.foo,42)
	assertEqual(dm.foo,42)
	assertEqual(ping,42)
end

function test5_failure()
	local t4 = notifitable{ settings='rainbows' }
	local r = t4:registerForChange('settings','editor','usetabs',function() end)
	assertTrue(not r)
end

runTests{useANSI=false}