-- Signpost icons

data:extend{
	{
		type = "item-group",
		name = "signpost-icons",
		order = "fb",
		icon = "__attach-notes__/graphics/signpost-icon.png",
		icon_size = 32,
        icon_mipmaps = 1,
	}
}

local subgroups = 0
local order = 0

local function generateIcon(name, subgroup, file, wrappedEntity, size)
	local subgroup = subgroup.."-signpost-icons"
	if not data.raw["item-subgroup"][subgroup] then
	
		subgroups = subgroups + 1
		order = 0
		
		data:extend{{
			type = "item-subgroup",
			name = subgroup,
			group = "signpost-icons",
			order = string.rep("a", subgroups)
		}}
	end

	order = order + 1
	data:extend{
		{
			type = "virtual-signal",
			name = "signpost-icon-"..name,
			localised_name = wrappedEntity and {"entity-name."..name} or nil,
			icon = file or ("__attach-notes__/graphics/signpost-icons/"..name.."-icon.png"),
			icon_size = size or 32,
            icon_mipmaps = 1,
			subgroup = subgroup,
			order = string.rep("a", order),
		}
	}
end

generateIcon("danger", "signs-red", nil, nil, 64)
generateIcon("destroyed", "signs-red", nil, nil, 64)
generateIcon("electricity", "signs-red", nil, nil, 64)
generateIcon("recharge", "signs-red", nil, nil, 64)
generateIcon("fuel-red", "signs-red", nil, nil, 64)
generateIcon("fluid", "signs-red", nil, nil, 64)
generateIcon("ammo", "signs-red", nil, nil, 64)

generateIcon("warning", "signs-warning", nil, nil, 64)
generateIcon("nuclear", "signs-warning", nil, nil, 64)
generateIcon("plug", "signs-warning", nil, nil, 64)
generateIcon("port", "signs-warning", nil, nil, 64)
generateIcon("wrench", "signs-warning", nil, nil, 64)
generateIcon("gear", "signs-warning", nil, nil, 64)
generateIcon("warning-biters", "signs-warning", nil, nil, 64)

generateIcon("bot-blue", "signs-special", nil, nil, 64)
generateIcon("bot", "signs-special", nil, nil, 64)
generateIcon("storage", "signs-special", nil, nil, 64)
generateIcon("misaligned", "signs-special", nil, nil, 64)

generateIcon("stop", "symbols")
generateIcon("factorio", "symbols", "__core__/graphics/factorio.png", nil, 128)
generateIcon("electric", "symbols")
generateIcon("fire", "symbols")
generateIcon("fuel", "symbols")
generateIcon("trash", "symbols")

generateIcon("tree", "nature")
generateIcon("bush", "nature")
generateIcon("biter", "nature", nil, nil, 64)

generateIcon("small-biter", "biters", "__base__/graphics/icons/small-biter.png", true)
generateIcon("medium-biter", "biters", "__base__/graphics/icons/medium-biter.png", true)
generateIcon("big-biter", "biters", "__base__/graphics/icons/big-biter.png", true)
generateIcon("behemoth-biter", "biters", "__base__/graphics/icons/behemoth-biter.png", true)

generateIcon("small-spitter", "spitters", "__base__/graphics/icons/small-spitter.png", true)
generateIcon("medium-spitter", "spitters", "__base__/graphics/icons/medium-spitter.png", true)
generateIcon("big-spitter", "spitters", "__base__/graphics/icons/big-spitter.png", true)
generateIcon("behemoth-spitter", "spitters", "__base__/graphics/icons/behemoth-spitter.png", true)

-- generateIcon("player", "other", "__base__/graphics/icons/player.png")
-- generateIcon("coin", "other", "__base__/graphics/icons/coin.png")
-- generateIcon("computer", "other", "__base__/graphics/icons/computer.png")
-- generateIcon("rocket-part", "other", "__base__/graphics/icons/rocket-part.png")