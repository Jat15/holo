--[[
Holo ver 0.1 par Jat
Licence GPLv2 or later for code
Image by AndrOn
Licence WTFPL
--]]

--Fuction

local function holospwan(pos, itemname)
	local obj = minetest.add_entity(pos, "holo:item")
	obj:get_luaentity():set_item(itemname)
	return obj
end

--Support de l'hologramme

minetest.register_node("holo:socle", {
	description = "Socle holographique",
	drawtype = "signlike",
	tiles = {"holo_socle.png"},
	inventory_image = "holo_socle.png",
	wield_image = "holo_socle.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {dig_immediate=2},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_int("wear",0)
		minetest.get_meta(pos):set_string("item","")
		minetest.get_meta(pos):set_string("player","")
	end,
	after_place_node = function(pos, placer)
		minetest.get_meta(pos):set_string("player",placer:get_player_name())
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local item = itemstack:get_name()
		local mitem=minetest.get_meta(pos):get_string("item")
		local listobj=minetest.get_objects_inside_radius(pos, 0)
		local actif=""
		for i=1,table.getn(listobj) do
			if not(listobj[i]:is_player()) and listobj[i]:get_luaentity().itemname==mitem then
				actif=listobj[i]
			end
		end
		if mitem=="" and not(item=="") then
			minetest.get_meta(pos):set_int("wear",itemstack:get_wear())
			itemstack:take_item(1)
			holospwan({x=pos.x,y=pos.y,z=pos.z},item)
			minetest.get_meta(pos):set_string("item",item)
		elseif actif=="" and not(mitem=="") then
			holospwan({x=pos.x,y=pos.y,z=pos.z},mitem)
		elseif not(actif=="") then
			actif:remove()
		end
	end,
	can_dig = function(pos,player)
		local mplayer = minetest.get_meta(pos):get_string("player")
		return mplayer==player:get_player_name() or mplayer==""
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local old = oldmetadata.fields
		local mitem = old.item
		local mwear = old.wear
		local listobj=minetest.get_objects_inside_radius(pos, 0)
		local actif=""
		for i=1,table.getn(listobj) do
			if not(listobj[i]:is_player()) and listobj[i]:get_luaentity().itemname==mitem then
				actif=listobj[i]
			end
		end
		if not(mitem==nil) then
			digger:get_inventory():add_item('main',mitem.." 1 "..mwear )
			if not(actif=="") then
				actif:remove()
			end
		end
	end,

})

--Craft du support

minetest.register_craft({
	output = "holo:socle 10",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})

--Hologramme

minetest.register_entity("holo:item", {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collisionbox = {-0.17,-0.17,-0.17, 0.17,0.17,0.17},
		visual = "sprite",
		visual_size = {x=0.5, y=0.5},
		textures = {""},
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = false,
	},
	itemname = '',
	set_item = function(self, itemstring)
		self.itemname = itemstring
		local itemname = itemstring
		local item_texture = nil
		local item_type = ""
		if minetest.registered_items[itemname] then
			item_texture = minetest.registered_items[itemname].inventory_image
			item_type = minetest.registered_items[itemname].type
		end
		prop = {
			is_visible = true,
			visual = "sprite",
			textures = {"unknown_item.png"}
		}
		if item_texture and item_texture ~= "" then
			prop.visual = "sprite"
			prop.textures = {item_texture}
			prop.visual_size = {x=0.50, y=0.50}
		else
			prop.visual = "wielditem"
			prop.textures = {itemname}
			prop.visual_size = {x=0.25, y=0.25}
			prop.automatic_rotate = math.pi * 0.25
		end
		self.object:set_properties(prop)
	end,
	on_activate = function(self, staticdata)
		self.itemname = staticdata
		self.object:set_armor_groups({immortal=1})
		self:set_item(self.itemname)
	end,
	get_staticdata = function(self)
		return self.itemname
	end,
	on_punch = function(self, hitter)
		self.object:remove()
	end,
})


