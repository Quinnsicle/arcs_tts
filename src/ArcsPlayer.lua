require("src/GUIDs")
local Log = require("src/LOG")
local Resource = require("src/Resource")

local power_count = 0

local player_pieces = {
    ["White"] = {
        components = {
            board = "999dbd",
            score_board = "41c240",
            ships = "6883e6",
            mini_ships = "93dca4",
            starports = "b96445",
            agents = "c863eb",
            mini_agents = "57ca23",
            cities = {"822a9c", "00ee1b", "a50d56", "06f4a8", "81c3a7"},
            power = "38ef71",
            objective = "59d36b",
            trophy_wall1 = "657831",
            trophy_wall2 = "95db55",
            trophy_wall3 = "550c9f",
            trophy_captive_wall = "4cb9ae",
            captive_wall1 = "0ada6b",
            captive_wall2 = "cb98ce",
            captive_wall3 = "17a428"
        },
        initiative_zone = "2e1cd3",
        trophies_zone = "275a50",
        captives_zone = "0c07a0",
        area_zone = "a952c1",
        hand_zone = "c832bf"
    },
    ["Yellow"] = {
        components = {
            board = "5aa44c",
            score_board = "9ef1b2",
            ships = "a75924",
            mini_ships = "1ae879",
            starports = "b9ebd3",
            agents = "7b3749",
            mini_agents = "8018da",
            cities = {"dbf4de", "799077", "acfa72", "ac28fb", "b41592"},
            power = "e1edd4",
            objective = "c5bc19",
            trophy_wall1 = "b3a49f",
            trophy_wall2 = "3898be",
            trophy_wall3 = "c59e2f",
            trophy_captive_wall = "a404b9",
            captive_wall1 = "68b2a5",
            captive_wall2 = "d1564b",
            captive_wall3 = "d54de0"
        },
        initiative_zone = "3fc6fd",
        trophies_zone = "7f5014",
        captives_zone = "31a56f",
        area_zone = "238a92",
        hand_zone = "856b9d"
    },
    ["Teal"] = {
        components = {
            board = "ae512a",
            score_board = "5f8f5b",
            ships = "2da385",
            mini_ships = "94823f",
            starports = "7e625d",
            agents = "791097",
            mini_agents = "bb9a25",
            cities = {"f3da7f", "5e753e", "79b799", "fad0f1", "45c804"},
            power = "40f97a",
            objective = "3c2ffc",
            trophy_wall1 = "2ffd2c",
            trophy_wall2 = "187183",
            trophy_wall3 = "924ecc",
            trophy_captive_wall = "2ff29e",
            captive_wall1 = "be7e33",
            captive_wall2 = "685f39",
            captive_wall3 = "041961"
        },
        initiative_zone = "cdc545",
        trophies_zone = "3085c9",
        captives_zone = "fe0b0d",
        area_zone = "ee4b6e",
        hand_zone = "c9dd8d"
    },
    ["Red"] = {
        components = {
            board = "c0c8a1",
            score_board = "a51833",
            ships = "7e0fe2",
            mini_ships = "8c2ffb",
            starports = "51a8f5",
            agents = "bbb3aa",
            mini_agents = "bb9a25",
            cities = {"33577c", "cf5b95", "0ac3c2", "6e36ca", "282f37"},
            power = "4c96ac",
            objective = "8d76b7",
            trophy_wall1 = "dbe667",
            trophy_wall2 = "fd6687",
            trophy_wall3 = "b054a0",
            trophy_captive_wall = "843c9c",
            captive_wall1 = "a95354",
            captive_wall2 = "214a7b",
            captive_wall3 = "a018a0"
        },
        initiative_zone = "32f290",
        trophies_zone = "48b6fb",
        captives_zone = "7b011e",
        area_zone = "c2bf05",
        hand_zone = "54730a"
    }
}

ArcsPlayer = {
    color = "",
    has_initiative = false,
    hand_size = 0,
    power = 0,
    tycoon = 0,
    tyrant = 0,
    warlord = 0,
    keeper = 0,
    empath = 0,
    player_instance = nil,
    last_action_card = nil,
    last_seize_card = nil,
    resource_slot_pos = {
        {
            x = 0.863,
            y = 0.209,
            z = -0.741
        }, {
            x = 0.614,
            y = 0.209,
            z = -0.742
        }, {
            x = 0.365,
            y = 0.209,
            z = -0.742
        }, {
            x = 0.116,
            y = 0.209,
            z = -0.742
        }, {
            x = -0.132,
            y = 0.209,
            z = -0.742
        }, {
            x = -0.381,
            y = 0.209,
            z = -0.743
        }
    }
}

function ArcsPlayer.components_visibility(color, is_visible, is_campaign)
    local visibility = is_visible and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}
    for key, id in pairs(player_pieces[color]["components"]) do
        if (key == "cities") then
            ArcsPlayer._show_cities(color, is_visible)
        elseif (key == "objective" and is_visible and not is_campaign) then
            local obj = getObjectFromGUID(id)
            if (obj) then
                obj.destroy()
            end
        else
            local obj = getObjectFromGUID(id)
            if (obj) then
                obj.setInvisibleTo(visibility)
            end
        end
    end
end

function ArcsPlayer._show_cities(color, is_visible)
    local visibility = is_visible and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}

    for _, id in pairs(player_pieces[color].components.cities) do
        local obj = getObjectFromGUID(id)
        obj.setInvisibleTo(visibility)
        -- local y_pos = is_visible and 1 or -2
        -- local pos = obj.getPosition()
        -- pos.y = y_pos
        -- obj.setPosition(pos)
        -- if (obj.hasTag("Lock")) then
        --     obj.locked = true
        -- else
        --     obj.locked = not is_visible
        -- end
    end
end

function ArcsPlayer:new(o)
    o = o or ArcsPlayer -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o:create_score()
    return o
end

function ArcsPlayer:setup(is_campaign)
    -- move power
    local y_pos
    local x_pos
    if (self.color == "Red") then
        y_pos = 3
        x_pos = -13.92
    elseif (self.color == "White") then
        y_pos = 3
        x_pos = -13.26
    elseif (self.color == "Teal") then
        y_pos = 2
        x_pos = -13.92
    elseif (self.color == "Yellow") then
        y_pos = 2
        x_pos = -13.26
    end
    local power = getObjectFromGUID(player_pieces[self.color].components.power)
    power.setPosition({x_pos, y_pos, -9.36})

    ArcsPlayer.components_visibility(self.color, true, is_campaign)
end

function ArcsPlayer:set_last_played_action_card(action_card_description)
    self.last_action_card = {
        type = string.sub(action_card_description, 1, -3),
        number = tonumber(string.sub(action_card_description, -1, -1))
    }

    if (Global.getVar("is_face_up_discard_active")) then
        local gold_color = {1, 0.7, 0.4}
        broadcastToAll(self.color .. " played " .. action_card_description,
            gold_color)
    end
end

function ArcsPlayer:set_last_played_seize_card(action_card_description)
    self.last_seize_card = {
        type = string.sub(action_card_description, 1, -3),
        number = tonumber(string.sub(action_card_description, -1, -1))
    }
end

function ArcsPlayer.has_secret_order(player_color)
    local area = getObjectFromGUID(player_pieces[player_color]["area_zone"])
    for _, obj in pairs(area.getObjects()) do
        if (obj.getName() == "SECRET ORDER") then
            return true
        end
    end

    return false
end

function ArcsPlayer:take_resource(name, slot_num)
    self.board = getObjectFromGUID(
        player_pieces[self.color]["components"]["board"])
    local board_pos = self.board.getPosition()
    local slot_pos = self.resource_slot_pos[slot_num]

    Resource:take(name, self.board.positionToWorld(slot_pos))
end

function ArcsPlayer:power_score(power_cube)
    -- Calculate base power from cube position
    local power_pos_x = power_cube and power_cube.getPosition().x or 0
    local base_power = math.floor((power_pos_x + 13.26) / 0.655)
    if base_power < 0 then base_power = 0 end

    -- Get bonus from zones
    local bonus = self:power_bonus()

    -- Calculate total and apply negative modifier if needed
    local total = base_power + bonus
    return self:is_power_negative() and -total or total
end

function ArcsPlayer:power_bonus()
    local bonus = 0
    local color_tag = self.color .. "Piece"

    -- Define zones and their bonus values
    local zones = {
        {guid = plus_fifty_power_zone_GUID, value = 50},
        {guid = plus_one_hundred_power_zone_GUID, value = 100}
    }

    for _, zone_info in ipairs(zones) do
        local zone = getObjectFromGUID(zone_info.guid)
        if not zone then
            Log.warning("Power bonus zone not found: " .. zone_info.guid)
        else
            -- Check objects in this zone
            for _, obj in ipairs(zone.getObjects()) do
                if obj.hasTag("power") and obj.hasTag(color_tag) then
                    bonus = bonus + zone_info.value
                end
            end
        end
    end

    return bonus
end

function ArcsPlayer:is_power_negative()
    local negative_zone = getObjectFromGUID(negative_power_zone_GUID)

    if not negative_zone then
        Log.warning("Negative power zone not found")
        return false
    end

    local color_tag = self.color .. "Piece"
    local objects = negative_zone.getObjects()

    for i = 1, #objects do
        local obj = objects[i]
        if obj.hasTag("power") and obj.hasTag(color_tag) then
            return true
        end
    end

    return false
end

function ArcsPlayer:update_score()
    self.score_board = getObjectFromGUID(
        player_pieces[self.color]["components"]["score_board"])
    if (self.score_board == nil) then
        return
    end

    local ambitions = Global.getVar("active_ambitions")
    local white_color = Color.fromString("White")
    local gold_color = {0.8, 0.58, 0.27}

    local tycoon_active = false
    local tyrant_active = false
    local warlord_active = false
    local keeper_active = false
    local empath_active = false
    if (ambitions) then
        for k, v in pairs(ambitions) do
            if (v == "Tycoon") then
                tycoon_active = true
            elseif (v == "Tyrant") then
                tyrant_active = true
            elseif (v == "Warlord") then
                warlord_active = true
            elseif (v == "Keeper") then
                keeper_active = true
            elseif (v == "Empath") then
                empath_active = true
            end
        end
    end

    local power_cube = getObjectFromGUID(
        player_pieces[self.color]["components"].power)
    self.power = self:power_score(power_cube)
    local hand_zone = getObjectFromGUID(player_pieces[self.color]["hand_zone"])
    self.hand_size = hand_zone and #hand_zone.getObjects() or 0
    self.tycoon = self:count("Fuel") + self:count("Material")
    local captive_zone = getObjectFromGUID(
        player_pieces[self.color]["captives_zone"])
    self.captives = captive_zone and #captive_zone.getObjects() or 0
    local trophies_zone = getObjectFromGUID(
        player_pieces[self.color]["trophies_zone"])
    self.trophies = trophies_zone and #trophies_zone.getObjects() or 0
    self.keeper = self:count("Relic")
    self.empath = self:count("Psionic")

    self.score_board.editButton({
        index = 0,
        label = self.power
    })
    self.score_board.editButton({
        index = 1,
        label = self.power
    })
    self.score_board.editButton({
        index = 2,
        label = self.hand_size
    })
    self.score_board.editButton({
        index = 3,
        label = self.hand_size
    })
    self.score_board.editButton({
        index = 4,
        label = self.tycoon
    })
    self.score_board.editButton({
        index = 5,
        label = self.tycoon,
        font_color = (tycoon_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 6,
        label = self.captives
    })
    self.score_board.editButton({
        index = 7,
        label = self.captives,
        font_color = (tyrant_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 8,
        label = self.trophies
    })
    self.score_board.editButton({
        index = 9,
        label = self.trophies,
        font_color = (warlord_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 10,
        label = self.keeper
    })
    self.score_board.editButton({
        index = 11,
        label = self.keeper,
        font_color = (keeper_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 12,
        label = self.empath
    })
    self.score_board.editButton({
        index = 13,
        label = self.empath,
        font_color = (empath_active and gold_color or white_color)
    })
end

function ArcsPlayer:count(resource)
    local area = getObjectFromGUID(player_pieces[self.color]["area_zone"])
    local count = 0

    if (area == nil) then
        return count
    end

    for _, obj in pairs(area.getObjects()) do
        if (obj.getDescription() == resource) then
            if (obj.name == "Custom_Tile_Stack") then
                count = count + obj.getQuantity()
            else
                count = count + 1
            end
        end
    end

    return count
end

function ArcsPlayer:create_score()
    self.score_board = getObjectFromGUID(
        player_pieces[self.color]["components"]["score_board"])

    local shadow = Vector({0.01, 0, 0.04})
    -- local text_color = Color.fromString(self.color)
    local text_color = Color.fromString("White")
    local score_row = -0.2

    -- Power
    local power_pos = Vector({-6.65, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = power_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = power_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = {0.8, 0.58, 0.27}
    })

    -- Hand Size
    local hand_pos = Vector({-4.65, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = hand_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = hand_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 2. Tycoon
    local tycoon_pos = Vector({-1.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tycoon_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tycoon_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 3. Tyrant
    local tyrant_pos = Vector({0.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tyrant_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tyrant_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 4. Warlord
    local warlord_pos = Vector({2.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = warlord_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = warlord_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 5. Keeper
    local keeper_pos = Vector({4.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = keeper_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = keeper_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 6. Empath
    local empath_pos = Vector({6.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = empath_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = empath_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    self:update_score()
end

return ArcsPlayer
