require("src/GUIDs")
local resource = require("src/Resource")

local player_boards = {
    ["White"] = "999dbd",
    ["Yellow"] = "5aa44c",
    ["Teal"] = "ae512a",
    ["Red"] = "c0c8a1"
}

ArcsPlayer = {
    color = "",
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

function ArcsPlayer:take_named_resource(name, slot_num)
    self.board = getObjectFromGUID(player_boards[self.color])
    local board_pos = self.board.getPosition()
    local slot_pos = self.resource_slot_pos[slot_num]

    resource:takeNamed(name, self.board.positionToWorld(slot_pos))
end

function ArcsPlayer:take_system_resource(cluster, system, slot_num)
    self.board = getObjectFromGUID(player_boards[self.color])
    local board_pos = self.board.getPosition()
    local slot_pos = self.resource_slot_pos[slot_num]

    resource:takeSystem(cluster, system, self.board.positionToWorld(slot_pos))
end

return ArcsPlayer
