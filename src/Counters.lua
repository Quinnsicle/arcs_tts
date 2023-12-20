-- Create counters that can be attached to containers or zones to count the objects contained inside.

local ObjectCounters = {}

local Has_Counter = {}

function ObjectCounters.setup()
  local Counters = {
    {
      GUID = Global.getVar("player_pieces_GUIDs")["White"]["ships"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["White"]["agents"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["White"]["starports"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Yellow"]["ships"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Yellow"]["agents"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Yellow"]["starports"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Red"]["ships"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Red"]["agents"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Red"]["starports"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Teal"]["ships"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Teal"]["agents"],
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
      GUID = Global.getVar("player_pieces_GUIDs")["Teal"]["starports"],
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
      GUID = Global.getVar("imperial_ships_GUID"),
      position = {0.5, 0.06, 0.03},
      shadow = {0.53, 0.06, 0.05}, -- drop shadow bottom right
      -- shadow = {0.48, 0.06, 0.04}, --drop shadow bottom left
      width = 1,
      height = 1,
      scale = {1, 1, 1},
      font_size = 365,
      font_color = {0.8, 0.58, 0.27}
    }
  }

  -- Begin implementing buttons
  for _, counter in ipairs(Counters) do
    Has_Counter[counter.GUID] = true
    local container = getObjectFromGUID(counter.GUID)
    container.createButton({
      function_owner  = self,
      click_function  = "doNothing",
      label           = ""..#container.getObjects(),
      position        = counter.shadow,
      rotation        = counter.rotation and counter.rotation or {0,0,0},
      width           = counter.width,
      height          = counter.height,
      scale           = counter.scale,
      font_size       = counter.font_size,
      font_color      = {0, 0, 0}
    })
    container.createButton({
      function_owner  = self,
      click_function  = "doNothing",
      label           = ""..#container.getObjects(),
      position        = counter.position,
      rotation        = counter.rotation and counter.rotation or {0,0,0},
      width           = counter.width,
      height          = counter.height,
      scale           = counter.scale,
      font_size       = counter.font_size,
      font_color      = counter.font_color
    })
    --log("Attached counter to: "..getObjectFromGUID(counter.GUID).getName())
  end

end

function onObjectEnterContainer(container, object) ObjectCounters.Update(container) end
function onObjectLeaveContainer(container, object) ObjectCounters.Update(container) end
function onObjectEnterZone(zone, object) ObjectCounters.Update(zone) end
function onObjectLeaveZone(zone, object) ObjectCounters.Update(zone) end
function ObjectCounters.Update(container)
  if Has_Counter[container.getGUID()] then
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