require("src/GUIDs")

available_colors = {"White", "Yellow", "Red", "Teal"}

----------------------------------------------------
-- [DEBUG] REMEMBER TO SET TO FALSE BEFORE RELEASE
----------------------------------------------------
debug = false
debug_player_count = 3
----------------------------------------------------

with_more_to_explore = false
with_leaders = false
with_split_discard = false

oop_components = {{
    Sector = {
        pos = {-0.17, 0.97, -1.04},
        rot = {0, 180, -0.01},
        scale = {2.48, 1, 2.48},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769502/1D85B9468BB538D788FCF7576A05606918CD0DD4/"
    },
    Gate = {
        pos = {-0.04, 0.97, -0.63},
        rot = {0, 189.24, -0.01},
        scale = {0.71, 1, 0.71},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
    }
}, {
    Sector = {
        pos = {-0.51, 0.97, -0.66},
        rot = {0, 180, -0.01},
        scale = {2.48, 1, 2.48},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769605/A40A0C79B27F1F1C45E0570E46BA8A7B253F356E/"
    },
    Gate = {
        pos = {-0.23, 0.97, -0.21},
        rot = {0, 252.52, 0},
        scale = {0.44, 1, 0.44},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
}, {
    Sector = {
        pos = {-0.47, 0.97, 0.73},
        rot = {0, 179.99, -0.01},
        scale = {2.36, 1, 2.36},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769710/C408A11914F7F4DEA83686851730DDF10A8BD5D4/"
    },
    Gate = {
        pos = {-0.2, 0.97, 0.28},
        rot = {0, 305.16, 0},
        scale = {0.44, 1, 0.44},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
}, {
    Sector = {
        pos = {0.17, 0.97, 0.91},
        rot = {0, 180, -0.01},
        scale = {2.54, 1, 2.54},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769816/0AA42154550040133E7D6740F85CD487D5F6967B/"
    },
    Gate = {
        pos = {0.05, 0.97, 0.52},
        rot = {-0.01, 12.02, 0},
        scale = {0.71, 1, 0.71},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
    }
}, {
    Sector = {
        pos = {0.5, 0.97, 0.55},
        rot = {0, 179.99, -0.01},
        scale = {2.48, 1, 2.48},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445770194/8600421030523070B8E2F05CECC3281DF24989AC/"
    },
    Gate = {
        pos = {0.24, 0.97, 0.1},
        rot = {-0.01, 72.87, -0.01},
        scale = {0.44, 1, 0.44},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
}, {
    Sector = {
        pos = {0.46, 0.97, -0.85},
        rot = {0, 179.99, -0.01},
        scale = {2.29, 1, 2.29},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445770362/76677A077FC1D6CD3672DCC036646ABFD2881F62/"
    },
    Gate = {
        pos = {0.2, 0.97, -0.39},
        rot = {-0.01, 125.02, -0.01},
        scale = {0.44, 1, 0.44},
        img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
}}

initaitive_player_position = {-2, 0, 0}

active_players = {}
is_player_setup = {
    White = false,
    Yellow = false,
    Red = false,
    Teal = false
}

----------------------------------------------------
local Supplies = require("src/Supplies")
local Counters = require("src/Counters")

function assignPlayerToAvailableColor(player, color)
    local color = table.remove(available_colors, 1)
    broadcastToAll(
        "Assigning " .. player.steam_name .. " to color " .. color)
    player.changeColor(color)
end

function onPlayerConnect(player)
    -- assignPlayerToAvailableColor(player)
end

function onPlayerDisconnect(player)
    table.insert(available_colors, 1, player.color)
end

function onObjectEnterZone(zone, object)
    Counters.update(zone)
end

function onObjectSpawn(object)
    Supplies.addMenuToObject(object)
end

function onObjectLeaveZone(zone, object)
    Counters.update(zone)
end

function onObjectEnterContainer(container, object)
    Counters.update(container)
end

function onObjectLeaveContainer(container, leave_object)
    Counters.update(container)
    if container.type == "Deck" or container.type == "Bag" or
        container.type == "Infinite" then
        leave_object.setTags(container.getTags())

        -- set snap
        leave_object.use_snap_points = true
    end
end

function tryObjectEnterContainer(container, object)
    if object.getStateId() == 2 then
        object.setState(1)
    end
    return container.hasMatchingTag(object)
end

----------------------------------------------------
-- returns a table of colors in order
function getOrderedPlayers()
    local seated_players = getSeatedPlayers()

    local player_count = debug and debug_player_count or
                             #seated_players
    if (debug) then
        broadcastToAll(
            "Debugging enabled for " .. debug_player_count ..
                " players.")
    end

    if (player_count > 4 or player_count < 2) then
        msg = "This game only supports 2-4 players"
        broadcastToAll(msg, {
            r = 1,
            g = 0,
            b = 0
        })
        return {""}
    end

    local players = {"White", "Yellow", "Red", "Teal"}
    local ordered_players = {}
    local i = math.random(player_count)
    local count = 0
    while count < player_count do
        if (i > player_count) then
            i = 1
        end

        table.insert(ordered_players, players[i])
        count = count + 1
        i = i + 1
    end

    if (ordered_players[1] == "White") then
        local color = {1, 1, 1}
        broadcastToAll("----------------------------------", color)
        broadcastToAll("White goes first", color)
        broadcastToAll("----------------------------------", color)
    elseif (ordered_players[1] == "Yellow") then
        local color = {0.905, 0.898, 0.172}
        broadcastToAll("----------------------------------", color)
        broadcastToAll("Yellow goes first", color)
        broadcastToAll("----------------------------------", color)
    elseif (ordered_players[1] == "Red") then
        local color = {0.856, 0.1, 0.094}
        broadcastToAll("----------------------------------", color)
        broadcastToAll("Red goes first", color)
        broadcastToAll("----------------------------------", color)
    elseif (ordered_players[1] == "Teal") then
        local color = {0.129, 0.694, 0.607}
        broadcastToAll("----------------------------------", color)
        broadcastToAll("Blue goes first", color)
        broadcastToAll("----------------------------------", color)
    end

    return ordered_players
end

function takeInitiative(color)
    if color == "" then
        return
    end

    local initiative_marker = getObjectFromGUID(initiative_GUID)
    local player_board = getObjectFromGUID(
        player_pieces_GUIDs[color]["player_board"])
    local initiative_pos = player_board.positionToWorld(
        initaitive_player_position)
    initiative_marker.setPositionSmooth(initiative_pos)
end

function dealGuildCards(qty)

    local court_zone = getObjectFromGUID(court_deck_zone_GUID)
    local court_deck = court_zone.getObjects()[1]

    court_deck.randomize()
    local court_deck_pos = court_deck.getPosition()
    court_deck_pos_z = court_deck_pos.z - 0.35

    for i = 1, qty do
        court_deck.takeObject({
            flip = true,
            position = {court_deck_pos.x, court_deck_pos.y,
                        court_deck_pos_z - (i * 2.41)}
        })
    end

end

-- params = {"psionics", "relics",  "weapons", "fuel", "materials"}
function merchantSetup(params)

    for _, resource in ipairs(params) do
        local zone_pos

        if (resource == "materials") then
            local ambition_zone = getObjectFromGUID(
                merchant_GUID["tycoon"])
            zone_pos = ambition_zone.getPosition()
            zone_pos.z = zone_pos.z - 0.5
        elseif (resource == "fuel") then
            local ambition_zone = getObjectFromGUID(
                merchant_GUID["tycoon"])
            zone_pos = ambition_zone.getPosition()
            zone_pos.z = zone_pos.z + 0.8
        elseif (resource == "weapons") then
            local ambition_zone = getObjectFromGUID(
                merchant_GUID["warlord"])
            zone_pos = ambition_zone.getPosition()
        elseif (resource == "relics") then
            local ambition_zone = getObjectFromGUID(
                merchant_GUID["keeper"])
            zone_pos = ambition_zone.getPosition()
        elseif (resource == "psionics") then
            local ambition_zone = getObjectFromGUID(
                merchant_GUID["empath"])
            zone_pos = ambition_zone.getPosition()
        end

        local token = getObjectFromGUID(resources_GUID[resource])

        token.takeObject({
            position = {zone_pos.x, zone_pos.y, zone_pos.z}
        })

    end
end

----------------------------------------------------

starting_locations = {
    [frontiers_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "a"
            },
            B = {
                cluster = 5,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 4,
                system = "a"
            }
        }
    },
    [homelands_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 5,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 2,
                system = "a"
            }
        }
    },
    [mix_up_1_2P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "a"
            }
        },
        [2] = {
            A = {
                cluster = 6,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            },
            D = {
                cluster = 1,
                system = "b"
            }
        }
    },
    [mix_up_2_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "b"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        }
    },
    [homelands_3P_GUID] = {
        [1] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [frontiers_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        }
    },
    [core_conflict_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_3P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [frontiers_4P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_1_4P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 4,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 6,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_2_4P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_3_4P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    }
}

starting_pieces = {
    Default = {
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionics", "weapons"}
    },
    ["059b13"] = { -- Elder
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "material"}
    },
    ["410a63"] = { -- Fuel-Drinker
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "fuel"}
    },
    ["1d1a5d"] = { -- Upstart
        A = {
            building = "city",
            ships = 4
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "weapon"}
    },
    ["94d6be"] = { -- Mystic
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "relic"}
    },
    ["c37bb3"] = { -- Demagogue
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "weapon"}
    },
    ["3ebad2"] = { -- Feastbringer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["7e36eb"] = { -- Rebel
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"material", "weapon"}
    },
    ["1e1496"] = { -- Warrior
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"weapon", "material"}
    },
    ["e1a8d1"] = { -- Noble
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "psionic"}
    },
    ["2b9ad6"] = { -- Archivist
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "relic"}
    },
    ["82c8e5"] = { -- Quartermaster
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["00f4dd"] = { -- Agitator
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    },
    ["cbde4b"] = { -- Anarchist
        A = {
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "weapon"}
    },
    ["41d253"] = { -- Shaper
        A = {
            building = "city",
            ships = 3
        },
        B = {
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["129303"] = { -- Corsair
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["f6e746"] = { -- Overseer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    }
}

----------------------------------------------------

function onLoad()
    Counters.setup()

    for _, obj in pairs(getObjectsWithTag("Noninteractable")) do
        obj.interactable = false
    end
    -- Assign all connected players to a color spot.
    -- for _, player in ipairs(Player.getPlayers()) do
    --     assignPlayerToAvailableColor(player)
    -- end

end
