-- Format: number to readable text helpers shared by the HUD and the server.

local Format = {}

function Format.group(value)
	local sign = value < 0 and "-" or ""
	local whole = math.floor(math.abs(value) + 0.5)
	local reversed = string.reverse(tostring(whole))
	local grouped = reversed:gsub("(%d%d%d)", "%1,")
	grouped = grouped:reverse()
	grouped = grouped:gsub("^,", "")
	return sign .. grouped
end

function Format.money(value)
	return "$" .. Format.group(value)
end

function Format.compact(value)
	if value >= 1e9 then
		return string.format("%.2fB", value / 1e9)
	end
	if value >= 1e6 then
		return string.format("%.2fM", value / 1e6)
	end
	if value >= 1e4 then
		return string.format("%.1fK", value / 1e3)
	end
	return Format.money(value)
end

function Format.rate(value)
	return "$" .. Format.compact(value) .. "/s"
end

return Format
