local SupplyManager = {}
-- TODO
-- stack management algorithm
-- remove from game GUID

city_row = {
  {0.10, 2.00, -2.00},
  {0.33, 2.00, -2.00},
  {0.56, 2.00, -2.00},
  {0.79, 2.00, -2.00},
  {1.02, 2.00, -2.00}
}

supplies = {

  -- Player Agents
  ["White Agent"]   = {bag = Global.getVar("player_pieces_GUIDs")["White"]["agents"]},
  ["Blue Agent"]    = {bag = Global.getVar("player_pieces_GUIDs")["Teal"]["agents"]},
  ["Yellow Agent"]  = {bag = Global.getVar("player_pieces_GUIDs")["Yellow"]["agents"]},
  ["Red Agent"]     = {bag = Global.getVar("player_pieces_GUIDs")["Red"]["agents"]},

  -- Player Fresh Ships
  ["White Ship (Fresh)"]    = {bag = Global.getVar("player_pieces_GUIDs")["White"]["ships"]},
  ["Blue Ship (Fresh)"]     = {bag = Global.getVar("player_pieces_GUIDs")["Teal"]["ships"]},
  ["Yellow Ship (Fresh)"]   = {bag = Global.getVar("player_pieces_GUIDs")["Yellow"]["ships"]},
  ["Red Ship (Fresh)"]      = {bag = Global.getVar("player_pieces_GUIDs")["Red"]["ships"]},

  -- Player Damaged Ships
  ["White Ship (Damaged)"]    = {bag = Global.getVar("player_pieces_GUIDs")["White"]["ships"], state = 1},
  ["Blue Ship (Damaged)"]     = {bag = Global.getVar("player_pieces_GUIDs")["Teal"]["ships"], state = 1},
  ["Yellow Ship (Damaged)"]   = {bag = Global.getVar("player_pieces_GUIDs")["Yellow"]["ships"], state = 1},
  ["Red Ship (Damaged)"]      = {bag = Global.getVar("player_pieces_GUIDs")["Red"]["ships"], state = 1},

  -- Player Damaged Ships
  ["White Starport"]    = {bag = Global.getVar("player_pieces_GUIDs")["White"]["starports"], face_up = true},
  ["Blue Starport"]     = {bag = Global.getVar("player_pieces_GUIDs")["Teal"]["starports"], face_up = true},
  ["Yellow Starport"]   = {bag = Global.getVar("player_pieces_GUIDs")["Yellow"]["starports"], face_up = true},
  ["Red Starport"]      = {bag = Global.getVar("player_pieces_GUIDs")["Red"]["starports"], face_up = true},

  -- Player Cities
  ["White City"] =  {
    origin = Global.getVar("player_pieces_GUIDs")["White"]["player_board"],
    face_up = true,
    set={
      ["822a9c"]=city_row[1],
      ["00ee1b"]=city_row[2],
      ["a50d56"]=city_row[3],
      ["06f4a8"]=city_row[4],
      ["81c3a7"]=city_row[5]
    }
  },
  ["Blue City"] =   {
    origin = Global.getVar("player_pieces_GUIDs")["Teal"]["player_board"],
    face_up = true,
    set={
      ["f3da7f"]=city_row[1],
      ["5e753e"]=city_row[2],
      ["79b799"]=city_row[3],
      ["fad0f1"]=city_row[4],
      ["45c804"]=city_row[5]
    }
  },
  ["Yellow City"] = {
    origin = Global.getVar("player_pieces_GUIDs")["Yellow"]["player_board"],
    face_up = true,
    set={
      ["dbf4de"]=city_row[1],
      ["799077"]=city_row[2],
      ["acfa72"]=city_row[3],
      ["ac28fb"]=city_row[4],
      ["b41592"]=city_row[5]
    }
  },
  ["Red City"] =    {
    origin = Global.getVar("player_pieces_GUIDs")["Red"]["player_board"],
    face_up = true,
    set={
      ["33577c"]=city_row[1],
      ["cf5b95"]=city_row[2],
      ["0ac3c2"]=city_row[3],
      ["6e36ca"]=city_row[4],
      ["282f37"]=city_row[5]
    }
  },

  -- Resources
  ["Psionic"]   = {pos = {0,2,0}, origin = Global.getVar("resources_markers_GUID")["psionics"]},
  ["Relic"]     = {pos = {0,2,0}, origin = Global.getVar("resources_markers_GUID")["relics"]},
  ["Weapon"]    = {pos = {0,2,0}, origin = Global.getVar("resources_markers_GUID")["weapons"]},
  ["Fuel"]      = {pos = {0,2,0}, origin = Global.getVar("resources_markers_GUID")["fuel"]},
  ["Material"]  = {pos = {0,2,0}, origin = Global.getVar("resources_markers_GUID")["materials"]},

  -- Miscallaneous
  [""]                          = {ignore = true},

  --["Blight"]                    = {bag = Global.getVar("")},
  ["Imperial Ship (Damaged)"]   = {bag = Global.getVar("imperial_ships_GUID"), state = 1},
  ["Imperial Ship (Fresh)"]     = {bag = Global.getVar("imperial_ships_GUID")},
  --["Free City"]                 = {bag = Global.getVar("")},
  --["Free Starport"]             = {bag = Global.getVar("")},
}

-- Main return
function SupplyManager.returnObject(object,is_bottom_deck)

  local deck_pos = is_bottom_deck and -1 or 1
  local supply = supplies[object.getName()]

  if not supply then
    print("Unable to return "..object.getName().." to a supply.")
    return
  end

  -- Check for additional changes that should be made when returning to supply
  if supply.state then
    object.setState(supply.state)
  elseif supply.face_up and object.is_face_down then
    object.flip()
  elseif supply.face_down and not object.is_face_down then
    object.flip()
  end

  -- Complete return based on type
  if supply.ignore then
    return
  elseif supply.bag then
    getObjectFromGUID(supply.bag).putObject(object)
  elseif supply.deck then
    object.setPosition(object.getPosition()+vector(0,5,0)*deck_pos)
    getObjectFromGUID(supply.GUID).putObject(object)
  elseif supply.set or supply.pos then
    local pos = supply.set and supply.set[object.getGUID()] or supply.pos
    if not pos then
      log("Return position for "..object.getName().." ("..object.getGUID()..") not found.")
      return
    end
    if supply.origin then
      local origin = getObjectFromGUID(supply.origin)
      pos = origin.positionToWorld(pos)
      local rot = origin.getRotation()
      object.setRotation({x=0,y=rot.y,z=0})
    end
    object.setPositionSmooth(pos,false,true)
  end

end

-- Expanded returns
function SupplyManager.returnEverything()
  for _,i in pairs(getObjects()) do 
    ReturnObject(i) 
  end
end

function SupplyManager.returnZone(zone) 
  for _,i in pairs(zone.getObjects()) do 
    ReturnObject(i) 
  end
end

-- Remove from game shortcut
function SupplyManager.removeFromGame(object)
  local bin = getObjectFromGUID(Global.getVar("TBD"))
  bin.putObject(object)
end

-- Context menu return implementation
function SupplyManager.addMenuToAllObjects()
  for _,object in pairs(getObjects()) do
    SupplyManager.addMenuToObject(object)
  end
end

function SupplyManager.addMenuToObject(object)
  --log("Adding return context menu option to "..object.getName())
  if object.getName() ~= "" and supplies[object.getName()] then
    object.addContextMenuItem("Return "..object.getName(), SupplyManager.returnFromMenu)
  end
end

function SupplyManager.returnFromMenu(player_color, position, object)
  SupplyManager.returnObject(object)
end

return SupplyManager