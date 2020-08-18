local mod_name = "consumablesx"

--v.5.x translation
local S
if minetest.get_translator ~= nil then
	S = minetest.get_translator(mod_name)
else
	S = function(s)
		return s
	end
end

minetest.override_item("vessels:drinking_glass", {
	liquids_pointable = true,
	--modified bucket_empty.on_use from https://github.com/minetest/minetest_game/blob/master/mods/bucket/init.lua
	on_use = function (itemstack, user, pointed_thing)
		if pointed_thing.type == "object" then
			pointed_thing.ref:punch(user, 1.0, { full_punch_interval=1.0 }, nil)
			return user:get_wielded_item()
		elseif pointed_thing.type ~= "node" then
			-- do nothing if it's neither object nor node
			return
		end
		
		local node = minetest.get_node(pointed_thing.under)
		local item_count = user:get_wielded_item():get_count()
		
		if node.name == "default:river_water_source" then
			-- default set to return filled glass
			local giving_back = mod_name .. ":cup_of_water"
			
			if item_count > 1 then
				-- if space in inventory add filled glass, otherwise drop as item
				local inv = user:get_inventory()
				
				if inv:room_for_item("main", { name = giving_back }) then
					inv:add_item("main", giving_back)
				else
					local pos = user:get_pos()
					pos.y = math.floor(pos.y + 0.5)
					minetest.add_item(pos, giving_back)
				end
				
				-- set to return empty glasses minus 1
				giving_back = "vessels:drinking_glass " .. tostring(item_count - 1)
			end
			
			return ItemStack(giving_back)
		else
			-- non-liquid nodes will have their on_punch triggered
			local node_def = minetest.registered_nodes[node.name]
			if node_def then
				node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
			end
			return user:get_wielded_item()
		end
	end
})

local juice_types = {
	{ name = "cup_of_water",	desc = "Cup of Water",		hp = 0 },
	{ name = "cactus_juice",	desc = "Cactus Juice",		hp = 2,	crafted_from = "default:cactus" },
	{ name = "orange_juice",	desc = "Orange Juice",		hp = 2,	crafted_from = "default:orange" },
	{ name = "apple_juice",		desc = "Apple Juice",		hp = 2,	crafted_from = "default:apple" },
	{ name = "blueberry_juice",	desc = "Blueberry Juice",	hp = 2,	crafted_from = "farming:blueberries" },
	{ name = "raspberry_juice",	desc = "Raspberry Juice",	hp = 2,	crafted_from = "farming:raspberries" },
	{ name = "melon_juice",		desc = "Melon Juice",		hp = 2,	crafted_from = "farming:melon" },
	{ name = "pine_needle_tea",	desc = "Pine Needle Tea",	hp = 2,	crafted_from = "default:pine_needles" },
	{ name = "hot_chocolate",	desc = "Hot Chocolate",		hp = 5 }
}

for _, v in pairs(juice_types) do
	minetest.register_craftitem(mod_name .. ":" .. v.name, {
		description = S(v.desc),
		groups = { cup = 1 },
		inventory_image = mod_name .. "_" .. v.name .. ".png",
		stack_max = 1,
		on_use = minetest.item_eat(v.hp, "vessels:drinking_glass")
	})
	
	if v.crafted_from ~= nil then
		minetest.register_craft({
			output = mod_name .. ":" .. v.name,
			recipe = {
				{ v.crafted_from, v.crafted_from, v.crafted_from },
				{ v.crafted_from, v.crafted_from, v.crafted_from },
				{"", mod_name .. ":cup_of_water", ""}
			}
		})
	end
end

minetest.register_craftitem(mod_name .. ":bucket_hot_chocolate", {
	description = S("Bucket of Hot Chocolate"),
	inventory_image = mod_name .. "_bucket_hot_chocolate.png",
	stack_max = 1
})

local chocolate_eggs = { "easter_eggs:chocolate_egg", "easter_eggs:chocolate_egg_dark" }
for _, v in pairs(chocolate_eggs) do
	minetest.register_craft({
		output = mod_name .. ":bucket_hot_chocolate",
		recipe = {
			{ v },
			{ "bucket:bucket_lava" }
		}
	})
end

minetest.register_craft({
	output = mod_name .. ":hot_chocolate",
	recipe = {
		{ "vessels:drinking_glass", "vessels:drinking_glass", "vessels:drinking_glass" },
		{ "vessels:drinking_glass", mod_name .. ":bucket_hot_chocolate", "vessels:drinking_glass" },
		{ "vessels:drinking_glass", "vessels:drinking_glass", "vessels:drinking_glass" }
	},
	replacements = {
		{ "vessels:drinking_glass", mod_name .. ":hot_chocolate" },
		{ "vessels:drinking_glass", mod_name .. ":hot_chocolate" },
		{ "vessels:drinking_glass", mod_name .. ":hot_chocolate" },
		{ mod_name .. ":bucket_hot_chocolate", "bucket:bucket_empty" },
		{ "vessels:drinking_glass", mod_name .. ":hot_chocolate" },
		{ "vessels:drinking_glass", mod_name .. ":hot_chocolate" },
		{ "vessels:drinking_glass", mod_name .. ":hot_chocolate" },
		{ "vessels:drinking_glass", mod_name .. ":hot_chocolate" }
	}
})

local icecream_flavors = {
	["default:cactus"] = "cactus",
	["default:orange"] = "orange",
	["default:apple"] = "apple",
	["farming:blueberries"] = "blueberry",
	["farming:raspberries"] = "raspberry",
	["farming:melon"] = "melon",
	["easter_eggs:chocolate_egg"] = "chocolate",
	["easter_eggs:chocolate_egg_dark"] = "chocolate"
}

--adding appropriate items to the flavors group
for i, _ in pairs(icecream_flavors) do
	local v = minetest.registered_items[i]
	if v ~= nil then
		local groups = v.groups
		groups.icecream_flavor = 1
		
		minetest.override_item(i, {
			groups = groups
		})
	end
end

minetest.register_craftitem(mod_name .. ":ice_cream", {
	description = S("Ice Cream"),
	inventory_image = mod_name .. "_icecream_cup.png",
	stack_max = 1
})

minetest.register_craft({
	output = mod_name .. ":ice_cream",
	recipe = {
		{ "group:icecream_flavor", "group:icecream_flavor", "group:icecream_flavor" },
		{ "", "vessels:drinking_glass", "" }
	}
})

--registering all the different kinds of ice cream
for _, v in pairs(icecream_flavors) do
	for _, w in pairs(icecream_flavors) do
		for _, x in pairs(icecream_flavors) do
			if w ~= v and x ~= v then
				minetest.register_craftitem(mod_name .. ":ice_cream_" .. v .. "_" .. w .. "_" .. x, {
					description = S(v .. ", " .. w .. " and " .. x .. " Ice Cream"),
					inventory_image = mod_name .. "_icecream_" .. v .. "_left_ball.png^" ..
						mod_name .. "_icecream_" .. w .. "_top_ball.png^" ..
						mod_name .. "_icecream_" .. x .. "_right_ball.png^" ..
						mod_name .. "_icecream_cup.png",
					groups = { not_in_creative_inventory = 1 },
					stack_max = 1
				})
			end
		end
	end
end

--selecting flavors in the crafting grid output
local select_flavors = function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() == mod_name .. ":ice_cream" then
		local v = icecream_flavors[old_craft_grid[1]:get_name()]
		local w = icecream_flavors[old_craft_grid[2]:get_name()]
		local x = icecream_flavors[old_craft_grid[3]:get_name()]
		if w == v or x == v or x == w then
			--effectively disables crafting
			itemstack:clear()
		else
			itemstack:set_name(mod_name .. ":ice_cream_" .. v .. "_" .. w .. "_" .. x)
		end
	end
end

minetest.register_craft_predict(select_flavors)
minetest.register_on_craft(select_flavors)
