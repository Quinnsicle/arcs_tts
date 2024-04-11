require("src/GUIDs")
local Log = require("src/LOG")
local Resource = require("src/Resource")

local player_pieces = {
    ["White"] = {
        board = "999dbd",
        score_board = "41c240",
        resource = {"822a9c", "00ee1b"},
        ships = "6883e6",
        starports = "b96445",
        agents = "c863eb",
        cities = {"822a9c", "00ee1b", "a50d56", "06f4a8", "81c3a7"},
        initiative_zone = "2e1cd3",
        trophies_zone = "275a50",
        captives_zone = "0c07a0",
        area_zone = "a952c1",
        hand_zone = "c832bf",
        power = "38ef71"
    },
    ["Yellow"] = {
        board = "5aa44c",
        score_board = "9ef1b2",
        resource = {"dbf4de", "799077"},
        ships = "a75924",
        starports = "b9ebd3",
        agents = "7b3749",
        cities = {"dbf4de", "799077", "acfa72", "ac28fb", "b41592"},
        initiative_zone = "3fc6fd",
        trophies_zone = "7f5014",
        captives_zone = "31a56f",
        area_zone = "238a92",
        hand_zone = "856b9d",
        power = "e1edd4"
    },
    ["Teal"] = {
        board = "ae512a",
        score_board = "5f8f5b",
        resource = {"f3da7f", "f3da7f"},
        ships = "2da385",
        starports = "7e625d",
        agents = "791097",
        cities = {"f3da7f", "5e753e", "79b799", "fad0f1", "45c804"},
        initiative_zone = "cdc545",
        trophies_zone = "3085c9",
        captives_zone = "fe0b0d",
        area_zone = "ee4b6e",
        hand_zone = "c9dd8d",
        power = "40f97a"
    },
    ["Red"] = {
        board = "c0c8a1",
        score_board = "a51833",
        resource = {"33577c", "cf5b95"},
        ships = "7e0fe2",
        starports = "51a8f5",
        agents = "bbb3aa",
        cities = {"33577c", "cf5b95", "0ac3c2", "6e36ca", "282f37"},
        initiative_zone = "32f290",
        trophies_zone = "48b6fb",
        captives_zone = "7b011e",
        area_zone = "c2bf05",
        hand_zone = "54730a",
        power = "4c96ac"
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
    resource_slot_pos = {{
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
        x = -0.381,
        y = 0.209,
        z = -0.743
    }, {
        x = 0.116,
        y = 0.209,
        z = -0.742
    }, {
        x = -0.132,
        y = 0.209,
        z = -0.742
    }}
}

function ArcsPlayer:new(o)
    o = o or ArcsPlayer -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    -- print("test 1")
    -- for _, player in ipairs(Player.getPlayers()) do
    --     print("test 2")
    --     if (player.color == o.color) then
    --         print("test 3")
    --         print(player.color)
    --         o.player_instance = player
    --     end
    -- end

    o:create_score()

    return o

end

function ArcsPlayer:take_resource(name, slot_num)
    self.board = getObjectFromGUID(player_pieces[self.color]["board"])
    local board_pos = self.board.getPosition()
    local slot_pos = self.resource_slot_pos[slot_num]

    Resource:take(name, self.board.positionToWorld(slot_pos))
end

function ArcsPlayer:update_score()
    self.score_board = getObjectFromGUID(
        player_pieces[self.color]["score_board"])

    -- Power
    local power_cube = getObjectFromGUID(
        player_pieces[self.color].power)
    local power_pos_x = power_cube.getPosition().x
    local power = math.floor((power_pos_x + 13.26) / 0.655)
    self.power = (power > 0) and power or 0
    self.score_board.editButton({
        index = 0,
        label = self.power
    })
    self.score_board.editButton({
        index = 1,
        label = self.power
    })

    -- Hand
    -- self.hand_size = self.player_instance.getHandCount()
    self.hand_size = #getObjectFromGUID(
                         player_pieces[self.color]["hand_zone"]).getObjects()
    self.score_board.editButton({
        index = 2,
        label = self.hand_size
    })
    self.score_board.editButton({
        index = 3,
        label = self.hand_size
    })

    -- Tycoon
    self.tycoon = self:count("Fuel") + self:count("Material")
    self.score_board.editButton({
        index = 4,
        label = self.tycoon
    })
    self.score_board.editButton({
        index = 5,
        label = self.tycoon
    })

    -- Warlord
    self.trophies = #getObjectFromGUID(
                        player_pieces[self.color]["trophies_zone"]).getObjects()
    self.score_board.editButton({
        index = 6,
        label = self.trophies
    })
    self.score_board.editButton({
        index = 7,
        label = self.trophies
    })

    -- Tyrant
    self.captives = #getObjectFromGUID(
                        player_pieces[self.color]["captives_zone"]).getObjects()
    self.score_board.editButton({
        index = 8,
        label = self.captives
    })
    self.score_board.editButton({
        index = 9,
        label = self.captives
    })

    -- Keeper
    self.keeper = self:count("Relic")
    self.score_board.editButton({
        index = 10,
        label = self.keeper
    })
    self.score_board.editButton({
        index = 11,
        label = self.keeper
    })

    -- Empath
    self.empath = self:count("Psionic")
    self.score_board.editButton({
        index = 12,
        label = self.empath
    })
    self.score_board.editButton({
        index = 13,
        label = self.empath
    })
end

function ArcsPlayer:count(resource)
    local area = getObjectFromGUID(
        player_pieces[self.color]["area_zone"])
    local count = 0

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
        player_pieces[self.color]["score_board"])

    local shadow = Vector({0.007, 0, 0.032})
    local text_color = Color.fromString(self.color)

    -- Power
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.power,
        position = Vector({-1.5, 0.11, 0}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.power,
        position = {-1.5, 0.11, 0},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 500,
        font_color = {0.8, 0.58, 0.27}
    })

    -- Hand Size
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.hand_size,
        position = Vector({-0.7, 0.11, 0}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.hand_size,
        position = {-0.7, 0.11, 0},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 500,
        font_color = text_color
    })

    -- 2. Tycoon
    local tycoon = self:count("Fuel") + self:count("Material")
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.tycoon,
        position = Vector({0, 0.11, 0}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.tycoon,
        position = {0, 0.11, 0},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 500,
        font_color = text_color
    })

    -- 3. Tyrant
    local captives = #getObjectFromGUID(
                         player_pieces[self.color]["captives_zone"]).getObjects()
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.captives,
        position = Vector({0.4, 0.11, 0}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.captives,
        position = {0.4, 0.11, 0},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 500,
        font_color = text_color
    })

    -- 4. Warlord
    local trophies = #getObjectFromGUID(
                         player_pieces[self.color]["trophies_zone"]).getObjects()
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.trophies,
        position = Vector({0.8, 0.11, 0}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.trophies,
        position = {0.8, 0.11, 0},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 500,
        font_color = text_color
    })

    -- 5. Keeper
    local keeper = self:count("Relic")
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.keeper,
        position = Vector({1.2, 0.11, 0}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.keeper,
        position = {1.2, 0.11, 0},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 500,
        font_color = text_color
    })

    -- 6. Empath
    local empath = self:count("Psionic")
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.empath,
        position = Vector({1.6, 0.11, 0}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = self.empath,
        position = {1.6, 0.11, 0},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 500,
        font_color = text_color
    })

    -- labels
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Power",
        position = Vector({-1.5, 0.11, 0.7}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Power",
        position = {-1.5, 0.11, 0.7},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0.8, 0.58, 0.27}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Hand",
        position = Vector({-0.7, 0.11, 0.7}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Hand",
        position = {-0.7, 0.11, 0.7},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = text_color
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Tycoon",
        position = Vector({0, 0.11, 0.7}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Tycoon",
        position = {0, 0.11, 0.7},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = text_color
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Tyrant",
        position = Vector({0.4, 0.11, 0.7}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Tyrant",
        position = {0.4, 0.11, 0.7},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = text_color
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Warlord",
        position = Vector({0.8, 0.11, 0.7}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Warlord",
        position = {0.8, 0.11, 0.7},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = text_color
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Keeper",
        position = Vector({1.2, 0.11, 0.7}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Keeper",
        position = {1.2, 0.11, 0.7},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = text_color
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Empath",
        position = Vector({1.6, 0.11, 0.7}) + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "Empath",
        position = {1.6, 0.11, 0.7},
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        scale = {0.2, 1, 1},
        font_size = 200,
        font_color = text_color
    })
end

return ArcsPlayer
