--[=========================================================================[
   Notifitable v0.2 by Gavin Kistner
   See http://github.com/Phrogz/notifitable for usage documentation.
   Licensed under the MIT License.
--]=========================================================================]
local function notifitable(values)
	values = values or {}
	local table,calls = {},{}

	setmetatable(table,{
		__index=values,
		__newindex=function(_,key,val)
			if calls[key] and val~=values[key] then
				for func,_ in pairs(calls[key]) do
					func(key,val,values[key])
				end
			end
			rawset(values,key,val)
		end
	})

	function table:registerForChange(...)
		local key,callback = ...
		if select('#',...)==2 then
			calls[key] = calls[key] or {}
			calls[key][callback] = true
			return true
		else
			if values[key]==nil or (type(values[key])=='table' and not values[key].registerForChange) then
				values[key] = notifitable(values[key])
			end
			if type(values[key])=='table' then
				return values[key]:registerForChange(select(2,...))
			end
		end
	end

	function table:unregisterForChange(...)
		local key,callback = ...
		if select('#',...)>2 then
			if values[key] and values[key].unregisterForChange then
				return values[key]:unregisterForChange(select(2,...))
			end
		else
			if calls[key] then calls[key][callback] = nil end
			return true
		end
	end

	return table
end

return notifitable