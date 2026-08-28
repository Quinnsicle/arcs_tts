require("src/GUIDs")
local LOG = require("src/LOG")

-- Create counters that can be attached to containers or zones to count the objects contained inside.

local ObjectCounters = {}
local the_counters
local player_pieces_guids
local has_counter = {}

local function initializeCounters()
    player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    return {
        {
            container_GUID = player_pieces_guids["White"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["White"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["White"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Pink"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Pink"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Pink"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = Global.getVar("imperial_ships_GUID"),
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
end

function ObjectCounters.setup()
    the_counters = initializeCounters()
    for _, counter in pairs(the_counters) do
        local container = nil
        if counter and counter.container_GUID then
            container = getObjectFromGUID(counter.container_GUID)
        end
        if not container then
            LOG.WARNING("ObjectCounters.setup: missing container for GUID " .. tostring(counter and counter.container_GUID))
        else
            ObjectCounters.add(container, counter)
        end
    end
end

function ObjectCounters.add(container, button)
    if not container then
        LOG.WARNING("ObjectCounters.add called with nil container")
        return
    end
    local ok, guid = pcall(function() return container.getGUID() end)
    if not ok or not guid then
        LOG.WARNING("ObjectCounters.add: could not get GUID from container")
        return
    end
    local existing = container.getButtons() or {}

    if (container.type == "Infinite") then
        -- If buttons already exist, edit them instead of creating duplicates
        if #existing >= 2 then
            has_counter[guid] = true
            container.editButton({index = 0, label = "∞"})
            container.editButton({index = 1, label = "∞"})
            return
        end

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
        has_counter[guid] = true
        return
    end

    local label = "" .. #container.getObjects()
    if #existing >= 2 then
        has_counter[guid] = true
        container.editButton({index = 0, label = label})
        container.editButton({index = 1, label = label})
        return
    end

    has_counter[guid] = true
    container.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = label,
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
        label = label,
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
