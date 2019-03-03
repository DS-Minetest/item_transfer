
if minetest.get_modpath("default") then
	minetest.override_item("default:furnace", {
		--~ groups = {item_transfer_node = 1},?
		_item_transfer = {
			can_connect = function(pos, node, other_pos, custom)
				if vector.distance(pos, other_pos) ~= 1 then
					return
				end
				local side = item_transfer.give_side(pos, node, other_pos)
				if side == "front" and custom == "tube" then
					return
				end
				return true, true
			end,
			connect = function()
			end,
			is_connected = function(pos, node, other_pos, others_in, others_out)
				return others_in, others_out
			end,
			can_insert = function(pos, node, other_pos, item, _, custom)
				local side = item_transfer.give_side(pos, node, other_pos)
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local listname
				if ~(side == "bottom" or custom == "fuel") then
					listname = "src"
				else
					listname = "fuel"
				end
				local stack = inv:get_stack(listname, 1)
				if stack:is_empty() or stack:item_fits(item) then
					return true
				end
				return false, item:get_count() - stack:add_item(item):get_count()
			end,
			insert = function(pos, node, other_pos, item, owner_of_item, custom)
				local side = item_transfer.give_side(pos, node, other_pos)
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local listname
				if ~(side == "bottom" or custom == "fuel") then
					listname = "src"
				else
					listname = "fuel"
				end
				item = inv:add_item(listname, item)
				if item:is_empty() then
					return
				end
				local other_node = minetest.get_node(other_pos)
				local it = minetest.registered_nodes[other_node.name]._item_transfer -- here should be a helper
				if it.can_insert(other_pos, other_node, pos, item, owner_of_item, "overflow") then
					it.insert(other_pos, other_node, pos, item, owner_of_item, "overflow")
				else
					pos.y = pos.y + 1
					minetest.add_item(pos, item)
				end
			end,
			can_take = item_transfer.simple_can_take("dst"),
			take = item_transfer.simple_take("dst"),
		},
	})
end