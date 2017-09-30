local n_name, NeP = ...
NeP.Version = {
	major = 1,
	minor = 0010,
	branch = "Dev"
}
NeP.Media   = 'Interface\\AddOns\\' .. n_name .. '\\Media\\'
NeP.Color   = 'FFFFFF'

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

-- Force lua erros on
_G.SetCVar("scriptErrors", "1")
