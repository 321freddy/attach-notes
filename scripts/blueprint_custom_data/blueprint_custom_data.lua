--------------------------------------------------------------------------------------------------------------------------------
-- Usage example:
-- local sample_data = { sample_key = sample_value, {a=1, b = 'c'}, d = true}
-- write_to_combinator(combinator, sample_data)
-- local loaded_data = read_from_combinator(combinator)
-- now loaded_data contains the same data as is same as sample_data
--------------------------------------------------------------------------------------------------------------------------------
-- Author: thelordodin
-- Special thanks to Mooncat - who guided me how to do this.
-- License: free to copy, change, and use in any projects. No warranty.
--------------------------------------------------------------------------------------------------------------------------------

local mp = require 'MessagePack'
local combinator_item_slot_count = 5000
local bcd = {}

--------------------------------------------------------------------------------------------------------------------------------
local function data_to_numbers(data)
	local mpac = mp.pack(data)
	local mpac_m = #mpac % 4
	local mpac_s = #mpac - mpac_m
	local r = {#mpac}
	local v

	for i = 1, mpac_s, 4 do			-- 4 bytes per value is max for lua number
		v =	string.byte(mpac, i+3)*0x1000000
		+	string.byte(mpac, i+2)*0x10000
		+	string.byte(mpac, i+1)*0x100
		+	string.byte(mpac, i+0)

		if v >= 0x80000000 then
			v = v-0x100000000
		end
		table.insert(r,v)
	end
		v =	((mpac_s+3 <= #mpac) and string.byte(mpac, mpac_s+3)*0x10000		or 0)
		+	((mpac_s+2 <= #mpac) and string.byte(mpac, mpac_s+2)*0x100			or 0)
		+	((mpac_s+1 <= #mpac) and string.byte(mpac, mpac_s+1) 				or 0)
		table.insert(r,v)
	return r
end
--------------------------------------------------------------------------------------------------------------------------------
local function numbers_to_data(numbers)
	local r = ""
	for i = 2, #numbers do
		local n = numbers[i]
		if n < 0 then
			n = n+0x100000000
		end
		
		local v4 = n % 0x100
		n = (n - v4) / 0x100
		local v3 = n % 0x100
		n = (n - v3) / 0x100
		local v2 = n % 0x100
		n = (n - v2) / 0x100
		local v1 = n % 0x100
		r = r..string.char(v4, v3, v2, v1)
	end
	r = string.sub(r,1,numbers[1])
	return mp.unpack(r)
end
--------------------------------------------------------------------------------------------------------------------------------
function bcd.write_to_combinator(combinator, data)
	local numbers = data_to_numbers(data)

	local params = {}
	for i, v in pairs(numbers) do
		table.insert(params,
			{
				signal =
				{
					type = "virtual",
					name = "signal-0"
				},
				count = v,
				index = i
			})
	end

	if #params > combinator_item_slot_count then
		return false
	end

	combinator.get_or_create_control_behavior().parameters = {parameters = params};
	return true
end
-------------------------------------------------------------------------------------------------------------------------------
function bcd.get_combinator_params(data)
	local numbers = data_to_numbers(data)

	local params = {}
	for i, v in pairs(numbers) do
		table.insert(params,
				{
					signal =
					{
						type = "virtual",
						name = "signal-0"
					},
					count = v,
					index = i
				})
	end

	if #params > combinator_item_slot_count then
		return false
	end

	return params
end
-------------------------------------------------------------------------------------------------------------------------------
function bcd.read_from_combinator(combinator)
	local params = combinator.get_or_create_control_behavior().parameters
	local numbers = {}

	for _, p in pairs(params) do
		table.insert(numbers, p.count)
	end
	return numbers_to_data(numbers)
end
--------------------------------------------------------------------------------------------------------------------------------

return bcd;