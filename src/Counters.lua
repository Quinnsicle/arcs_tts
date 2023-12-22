-- Create counters that can be attached to containers or zones to count the objects contained inside.

local ObjectCounters = {}

local has_counter = {}
local the_counters = {
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["White"]["ships"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["White"]["agents"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["White"]["starports"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Yellow"]["ships"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Yellow"]["agents"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Yellow"]["starports"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Red"]["ships"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Red"]["agents"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Red"]["starports"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Teal"]["ships"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Teal"]["agents"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("player_pieces_GUIDs")["Teal"]["starports"],
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {1, 1, 1}
  },
  {
    container_GUID = Global.getVar("imperial_ships_GUID"),
    position = {0.5, 0.06, 0.03},
    shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
    -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
    width = 1,
    height = 1,
    scale = {1, 1, 1},
    font_size = 365,
    font_color = {0.8, 0.58, 0.27}
  } --]]
}

function ObjectCounters.setup()
  for _, counter in pairs(the_counters) do
    ObjectCounters.add(getObjectFromGUID(counter.container_GUID), counter)
  end
end

function ObjectCounters.add(container, button)
  has_counter[container.getGUID()] = true
  container.createButton({
    function_owner  = self,
    click_function  = "doNothing",
    label           = ""..#container.getObjects(),
    position        = button.shadow,
    rotation        = button.rotation and button.rotation or {0,0,0},
    width           = button.width,
    height          = button.height,
    scale           = button.scale,
    font_size       = button.font_size,
    font_color      = {0, 0, 0}
  })
  container.createButton({
    function_owner  = self,
    click_function  = "doNothing",
    label           = ""..#container.getObjects(),
    position        = button.position,
    rotation        = button.rotation and button.rotation or {0,0,0},
    width           = button.width,
    height          = button.height,
    scale           = button.scale,
    font_size       = button.font_size,
    font_color      = button.font_color
  })
  --log("Attached counter to: "..container.getName())
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