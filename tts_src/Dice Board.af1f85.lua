TAG = self.getName().." Spawned Die"

SCALE_COMBAT = {1.50,1.50,1.50}
SCALE_SPECIAL = {2.50,2.50,2.50}

MAX_COMBAT = 6
MAX_SPECIAL = 1

BOARD_AREA = {x=2.00, y=5.00, z=3.00}

GRID_COMBAT = {
  area    =   BOARD_AREA,
  rows    =   5,
  columns =   4
}

GRID_SPECIAL = {
  area    =   BOARD_AREA,
  rows    =   2,
  columns =   1
}

DICE = {
  ["skirmish"] = {
    custom = {image="https://dl.dropboxusercontent.com/s/3kr0xkvssrwuckb/bombard-die.png", type=1},
    scale = SCALE_COMBAT,
    max = MAX_COMBAT
  },
  ["assault"] = {
    custom = {image="https://dl.dropboxusercontent.com/s/6g633hq8t6ba403/asssault-die.png", type=1},
    scale = SCALE_COMBAT,
    max = MAX_COMBAT
  },
  ["raid"] = {
    custom = {image="https://dl.dropboxusercontent.com/s/m777tcc1unmox8w/raid-die.png", type=1},
    scale = SCALE_COMBAT,
    max = MAX_COMBAT
  },
  ["cluster"] = {
    custom = {image="https://dl.dropboxusercontent.com/s/n7e0c4gpdxyz3aw/number-die.png",type=1},
    scale = SCALE_SPECIAL,
    max = MAX_SPECIAL,
  },
  ["event"] = {
    custom = {image="https://dl.dropboxusercontent.com/s/nor7ic5s9r20pfv/icon-die.png",type=1},
    scale = SCALE_SPECIAL,
    max = MAX_SPECIAL,
  }
}

MESSAGE_COLOR = {
  ["skirmish"]  = { r=0.31, g=0.49, b=0.51 },
  ["assault"]   = { r=0.51, g=0.15, b=0.11 },
  ["raid"]      = { r=0.82, g=0.45, b=0.18 }
}

function onLoad()
  spawns_combat = CreatePositioningGrid(GRID_COMBAT)
  spawns_special = CreatePositioningGrid(GRID_SPECIAL)
  ClearDice()
end

function SpawnCombatDie(_,type)

  if is_special then
    ClearDice()
    is_special = not is_special
  end

  local die = DICE[type]
  if die_count[die] == die.max then
    broadcastToAll("Maximum "..type.." dice reached.",MESSAGE_COLOR[type])
    return
  else
    SpawnDie(die, spawns_combat)
  end

end

function SpawnSpecialDie(_,type)

  if not is_special then
    ClearDice()
    is_special = not is_special
  end

  local die = DICE[type]
  if die_count[die] == die.max then
    return
  else
    SpawnDie(die, spawns_special)
  end

end

function SpawnDie(die, spawn_points)

  local pos = spawn_points[#GetDiePool()+1]; pos = self.positionToWorld(pos)
  die_count[die] = die_count[die] and die_count[die] + 1 or 1

  local new_die = spawnObject({
    type = "Custom_Dice",
    position = pos,
    scale = die.scale
  })
  new_die.setCustomObject(die.custom)
  new_die.addTag(TAG)

end

function RollDice() for _, die in ipairs(GetDiePool()) do die.randomize() end end

function ClearDice()
    for _,die in pairs(GetDiePool()) do die.destruct() end
    die_count = {}
end

function GetDiePool()
  return getObjectsWithTag(TAG)
end

function CreatePositioningGrid(parems)

  local r_ct, c_ct        = parems.rows, parems.columns
  local r_space, c_space  = parems.area.z / (parems.rows), parems.area.x / (parems.columns)
  local r_shift, c_shift  = parems.area.z / 2, parems.area.x / 2

  local grid = {}
  local pos_y = parems.area.y

  for r=1, r_ct do
    local pos_x = (r_space*r - r_space/2) - r_shift
    for c=1, c_ct do
      local pos_z = (c_space*c - c_space/2) - c_shift
      table.insert(grid, { x=pos_x, y=pos_y, z=pos_z } )
    end
  end

  return grid

end