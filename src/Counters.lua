require("src/GUIDs")
local LOG = require("src/LOG")

-- Create counters that can be attached to containers or zones to count the objects contained inside.

local ObjectCounters = {}

local has_counter = {}
local the_counters = {
    {
        container_GUID = player_pieces_GUIDs["White"]["ships"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["White"]["agents"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["White"]["starports"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Yellow"]["ships"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Yellow"]["agents"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Yellow"]["starports"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Red"]["ships"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Red"]["agents"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Red"]["starports"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Teal"]["ships"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Teal"]["agents"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = player_pieces_GUIDs["Teal"]["starports"],
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {1, 1, 1}
    }, {
        container_GUID = imperial_ships_GUID,
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {0.8, 0.58, 0.27}
    }, {
        container_GUID = blight_GUID,
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {0.7, 0.9, 0.7}
    }, {
        container_GUID = Global.getVar("free_cities_GUID"),
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0.06, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {0.7, 0.7, 0.7}
    }, {
        container_GUID = Global.getVar("free_starports_GUID"),
        position = {0.5, 0.06, 0.03},
        shadow = {0.03, 0.06, 0.02},
        scale = {1, 1, 1},
        font_size = 365,
        font_color = {0.7, 0.7, 0.7}
    }
}

function ObjectCounters.setup()
    for _, counter in pairs(the_counters) do
        ObjectCounters.add(getObjectFromGUID(counter.container_GUID), counter)
    end
end

function ObjectCounters.add(container, button)
    if (container.type == "Infinite") then
        container.createButton({
            function_owner = self,
            click_function = "doNothing",
            label = "∞",
            position = Vector(button.shadow) + Vector(button.position),
            rotation = button.rotation and button.rotation or {0, 0, 0},
            width = 0,
            height = 0,
            scale = button.scale,
            font_size = button.font_size,
            font_color = {0, 0, 0}
        })
        container.createButton({
            function_owner = self,
            click_function = "doNothing",
            label = "∞",
            position = button.position,
            rotation = button.rotation and button.rotation or {0, 0, 0},
            width = 0,
            height = 0,
            scale = button.scale,
            font_size = button.font_size,
            font_color = button.font_color
        })
        return
    end

    has_counter[container.getGUID()] = true
    container.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "" .. #container.getObjects(),
        position = Vector(button.shadow) + Vector(button.position),
        rotation = button.rotation and button.rotation or {0, 0, 0},
        width = 0,
        height = 0,
        scale = button.scale,
        font_size = button.font_size,
        font_color = {0, 0, 0}
    })
    container.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "" .. #container.getObjects(),
        position = button.position,
        rotation = button.rotation and button.rotation or {0, 0, 0},
        width = 0,
        height = 0,
        scale = button.scale,
        font_size = button.font_size,
        font_color = button.font_color
    })
    -- log("Attached counter to: "..container.getName())
end

function ObjectCounters.update(container)
    if has_counter[container.getGUID()] then
        container.editButton({
            index = 0,
            label = "" .. #container.getObjects()
        })
        container.editButton({
            index = 1,
            label = "" .. #container.getObjects()
        })
    end
end

return ObjectCounters
