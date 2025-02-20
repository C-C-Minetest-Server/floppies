local S = minetest.get_translator("floppy")

local colours = {
	red = S('Red'),
	green = S('Green'),
	blue = S('Blue')
}

local throw = function(itemstack, user, pointed_thing)
	local name = itemstack:get_name()
	local pos = user:get_pos()
	local dir = user:get_look_dir()

	if pos and dir then
		pos.y = pos.y + 1.5
		local obj = minetest.add_entity(pos, name)
		if obj then
			obj:set_velocity(vector.multiply(dir, 25))
			obj:set_acceleration({x=dir.x * -3, y=-25, z=dir.z * -3})
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item()
			end
		end
	end
	return itemstack
end

local function get_param2_from_acc(acc)
	if acc.z < acc.x then
		if acc.z < 0 then
			return 0
		elseif acc.z > 0 then
			return 3
		end
	elseif acc.z > acc.x then
		if acc.z < 0 then
			return 1
		elseif acc.z > 0 then
			return 2
		end
	end
	return 0
end

for colour, colourdesc in pairs(colours) do
	minetest.register_craftitem("floppy:floppy_"..colour, {
		description = S("@1 Floppy",colourdesc),
		inventory_image = "floppy_"..colour..".png",
		on_place = throw,
		on_secondary_use = throw
	})

	minetest.register_entity("floppy:floppy_"..colour, {
		visual = "item",
		visual_size = {x=1, y=1, z=1.5},
		textures = {'floppy:floppy_'..colour},
		physical = true,
		on_step = function(self, dtime, collision)
			if collision.touching_ground then
				for _,coll in pairs(collision.collisions) do
					if coll.type == "node" and coll.axis == "y" then
						local acc = self.object:get_acceleration()
						local pos = coll.node_pos
						pos.y = pos.y + 1
						minetest.set_node(pos, {name="floppy:floppy_"..colour.."_lying",param2=get_param2_from_acc(acc)})
						self.object:remove()
						break
					end
				end
			end

			local rot = self.object:get_rotation()
			if rot then
				rot.x = rot.x + 0.2
				rot.y = rot.y + 0.2
				self.object:set_rotation(rot)
			end
		end
	})

	minetest.register_node("floppy:floppy_"..colour.."_lying", {
		description = S("@1 Floppy (Lying)",colourdesc),
		tiles = { "floppy_"..colour..".png", "floppy_"..colour..".png", "floppy_side.png" },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5, -0.4375, 0.3125, -0.375, 0.3125},
				{0.375, -0.5, -0.4375, 0.4375, -0.375, 0.1875},
				{0.3125, -0.5, -0.4375, 0.375, -0.375, 0.25},
				{-0.4375, -0.5, 0.375, 0.1875, -0.375, 0.4375},
				{-0.4375, -0.5, 0.3125, 0.25, -0.375, 0.375},
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5, -0.4375, 0.4375, -0.375, 0.4375}
			}
		},
		drop = "floppy:floppy_"..colour,
		groups = { snappy=3, cracky=3, oddly_breakable_by_hand=3, crumbly=3, not_in_creative_inventory=1 }
	})

	if minetest.get_modpath("default") and minetest.get_modpath("wool") then
		local wool = "wool:"..colour
		minetest.register_craft({
			output = "floppy:floppy_"..colour,
			recipe = {
				{wool, "default:steel_ingot", wool},
				{wool, wool, wool},
				{wool, "default:paper", wool},
			}
		})
	end
end
