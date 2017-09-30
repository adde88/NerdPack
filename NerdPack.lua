local n_name, NeP = ...
NeP.Version = {
	major = 1,
	minor = 0010,
	branch = "RELEASE"
}
NeP.Media = 'Interface\\AddOns\\' .. n_name .. '\\Media\\'
NeP.Color = 'FFFFFF'
NeP.Paypal = 'http://goo.gl/yrctPO'
NeP.Patreon = 'https://www.patreon.com/mrthesoulz'
NeP.Author = 'MrTheSoulz'

-- This exports stuff into global space
NeP.Globals = {}
_G.NeP = NeP.Globals

NeP.Cache = {
	Conditions = {},
	Spells = {},
	Targets = {}
}

function NeP.Wipe_Cache()
	for _, v in pairs(NeP.Cache) do
		_G.wipe(v)
	end
end
