local func = require('func')
local map, forEach = func.map, func.forEach

local ANSI = {}
local mod = {}

local function init()
	local codes = {}
	local brights = {gray = 90, grey = 90}
	local basic = {
		black=30,
		red=31,
		green=32,
		yellow=33,
		blue=34,
		magenta=35,
		cyan=36,
		white=37,
	}

	forEach(basic, function(v, k)
		brights["bright_"..k] = v + 60
		codes[k] = v
	end)

	forEach(brights, function(v, k)
		codes[k.."_bg"] = v + 10
		codes[k] = v
	end)

	codes.reset = 0

	ANSI = codes
end

function mod.ansi(q)
	return string.format("\027[%dm", ANSI[q])
end


init()

return mod
