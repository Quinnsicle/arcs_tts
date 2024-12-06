local authors = "Quinnsicle, Scyth02, McChew, fallspectrum"
local version = "1.0"

require("src/GUIDs")

available_colors = {"White", "Yellow", "Red", "Teal"}

----------------------------------------------------
-- [DEBUG] REMEMBER TO SET TO FALSE BEFORE RELEASE
----------------------------------------------------
debug = false
debug_player_count = 2
----------------------------------------------------

with_more_to_explore = false
with_leaders = false
is_face_up_discard_active = false

oop_components = {
    {
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
    }
}

initiative_player_position = {-2, 0, 0}

active_players = {}
active_ambitions = {
    c9e0ee = "",
    a9b02a = "",
    b0b4d0 = ""
}

----------------------------------------------------
local AmbitionMarkers = require("src/AmbitionMarkers")
local ActionCards = require("src/ActionCards")
local ArcsPlayer = require("src/ArcsPlayer")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Counters = require("src/Counters")
local Initiative = require("src/InitiativeMarker")
local SetupControl = require("src/SetupControl")
local Supplies = require("src/Supplies")
local Camera = require("src/Camera")
local Timer = require("src/Timer")

function assignPlayerToAvailableColor(player, color)
    local color = table.remove(available_colors, 1)
    broadcastToAll("\nAssigning " .. player.steam_name .. " to color " .. color)
    player.changeColor(color)
end

function get_arcs_player(color)
    for _, p in ipairs(active_players) do
        if (p.color == color) then
            return p
        end
    end
end

function update_player_scores()
    for _, p in ipairs(active_players) do
        p:update_score()
    end
end

function onObjectDrop(player_color, object)
    local object_name = object.getName()

    -- update power
    if (object_name == "Power") then
        local power_color = object.getDescription()
        local player = get_arcs_player(power_color)
        Wait.time(function()
            player:update_score()
        end, 0.5)
    end

    -- update last played action card
    if (object_name == "Action Card" and not object.is_face_down) then
        -- TODO: check if in play zone
        local played_zone = getObjectFromGUID(action_card_zone_GUID)
        local is_in_action_zone = false
        for i, zone_obj in ipairs(played_zone.getObjects()) do
            if (zone_obj == object) then
                is_in_action_zone = true
                break
            end
        end

        if (is_in_action_zone) then
            local player = get_arcs_player(player_color)
            if (player) then
                player:set_last_played_action_card(object.getDescription())
            end
        end
    end

    if (object_name == "Action Card" and object.is_face_down) then
        local seize_zone = getObjectFromGUID(seize_zone_GUID)
        local is_in_seize_zone = false
        for i, zone_obj in ipairs(seize_zone.getObjects()) do
            if (zone_obj == object) then
                is_in_seize_zone = true
                break
            end
        end
        if (is_in_seize_zone) then
            local player = get_arcs_player(player_color)
            if (player) then
                player:set_last_played_seize_card(object.getDescription())
                broadcastToAll(player.color .. " is seizing the initiative", player.color)
            end
        end
    end

    -- ambitions
    if (object_name == "Ambition") then

        Wait.time(function()
            AmbitionMarkers.get_ambition_info(object)
        end, 0.5)
    end

end

function onPlayerAction(player, action, targets)
    if action ~= Player.Action.FlipOver then return end
    
    -- Ensure onObjectDrop when someone flips an action card
    if #targets == 1 and targets[1].hasTag("Action") then
        Wait.time(function()
            onObjectDrop(player.color, targets[1])
        end, 0.25)
        return false
    end

    -- Convert ship flips into damage state changes
    for _, obj in ipairs(targets) do
        if obj.hasTag("Ship") then
            obj.setState(obj.getStateId() == 1 and 2 or 1)
        else
            obj.flip()
        end
    end
    return false -- Prevent default flip behavior
end

function onObjectEnterZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end

    if ((object.getGUID() == initiative_GUID or object.getGUID() == seized_initiative_GUID)
        and zone_name == "initiative_zone") then
        local zone_color = zone.getDescription()
        Global.setVar("initiative_player", zone_color)
    end
end

function onObjectSpawn(object)
    Initiative.add_menu()
    Supplies.addMenuToObject(object)
end

function onObjectLeaveZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end
end

function onObjectEnterContainer(container, object)
    Counters.update(container)
end

function onObjectLeaveContainer(container, leave_object)
    Counters.update(container)
    local container_tags = container.getTags()
    if #container_tags > 0 then
        if container.type == "Bag" or container.type =="Infinite" then
            leave_object.setTags(container.getTags())
    
            -- set snap
            leave_object.use_snap_points = true
        end
    end
end

function tryObjectEnterContainer(container, object)
    if object.hasTag('Ship') and container.hasTag('Ship') and object.getStateId() == 2 then
        object.setState(1)
    end
    
    -- require object to have every container tag
    for _,  tag in ipairs(container.getTags()) do
        if not object.hasTag(tag) then
            return false
        end
    end

    return true
end

----------------------------------------------------
-- returns a table of colors in order
function getOrderedPlayers()
    local seated_players = getSeatedPlayers()
    if (debug and #seated_players == 1) then
        broadcastToAll("\nDebugging enabled for " .. debug_player_count ..
                           " players.")
        if (debug_player_count > 3) then
            seated_players = {"White", "Yellow", "Teal", "Red"}
        else
            local all_colors = {"White", "Yellow", "Teal", "Red"}
            -- remove seated players from all_colors
            for _, seated in ipairs(seated_players) do
                for i, all in ipairs(all_colors) do
                    if (seated == all) then
                        table.remove(all_colors, i)
                    end
                end
            end
            -- insert random color in seated_players
            for i = 1, debug_player_count - 1, 1 do
                local rng = math.random(#all_colors)
                local random_color = all_colors[rng]
                table.insert(seated_players, random_color)
                table.remove(all_colors, rng)
            end
        end
    end

    local player_count = #seated_players
    if (player_count > 4 or player_count < 2) then
        msg = "\nThis game only supports 2-4 players"
        broadcastToAll(msg, {
            r = 1,
            g = 0,
            b = 0
        })
        return {""}
    end

    local clockwise_order = {"White", "Yellow", "Teal", "Red"}
    local ordered_players = {}
    local start_index = math.random(player_count)

    for i = 1, #clockwise_order do
        local color = clockwise_order[(start_index + i - 2) % #clockwise_order + 1]
        for _, seated_color in ipairs(seated_players) do
            if color == seated_color then
                table.insert(ordered_players, ArcsPlayer:new{color = color})
                break
            end
        end
    end

    broadcastToAll("Randomly choosing first player...", Color.Purple)

    return ordered_players
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
            position = {
                court_deck_pos.x, court_deck_pos.y,
                court_deck_pos_z - (i * 2.41)
            }
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
        }
    },
    ["bcc792"] = { -- Elder
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
    ["a7e9eb"] = { -- Fuel-Drinker
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
    ["8109e1"] = { -- Upstart
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
        resources = {"psionic", "material"}
    },
    ["aa0e68"] = { -- Mystic
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
    ["996b9d"] = { -- Feastbringer
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
    ["da8b99"] = { -- Rebel
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
    ["639b42"] = { -- Warrior
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
    ["1848eb"] = { -- Noble
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
    ["2a5b6f"] = { -- Archivist
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
    ["942aaa"] = { -- Quartermaster
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
    ["4363db"] = { -- Agitator
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
    ["003bc2"] = { -- Anarchist
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
    ["843e46"] = { -- Shaper
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
    ["a1b65d"] = { -- Corsair
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
    ["2409c0"] = { -- Overseer
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

-- params = {obj, is_visible}
function move_and_lock_object(params)
    local y_pos = params.is_visible and 1 or -2
    local pos = params.obj.getPosition()
    pos.y = y_pos
    params.obj.setPosition(pos)
    if (params.obj.hasTag("Lock")) then
        params.obj.locked = true
    else
        params.obj.locked = not params.is_visible
    end
end

function set_active_players(players)
    active_players = players
end

function setup_custom_game()

    for _, v in ipairs({"Red", "White", "Yellow", "Teal"}) do
        local arcs_player = ArcsPlayer:new{
            color = v
        }
        table.insert(active_players, arcs_player)
    end
    for _, v in ipairs(active_players) do
        ArcsPlayer.components_visibility(v.color, true, true)
    end

    local p = {
        is_campaign = true,
        is_4p = true,
        leaders_and_lore = true,
        leaders_and_lore_expansion = true,
        with_faceup_discard = true,
        players = {"Red", "White", "Yellow", "Teal"}
    }
    set_game_in_progress(p)

    BaseGame.base_exclusive_components_visibility(true)
    BaseGame.setupOutOfPlayForCustom()
end

----------------------------------------------------
-- params = {
--     is_campaign = false,
--     is_4p = #active_players == 4,
--     leaders_and_lore = with_leaders,
--     leaders_and_lore_expansion = with_ll_expansion,
--     faceup_discard = ActionCards.is_face_up_discard_active(),
--     players = active_players
-- }
function set_game_in_progress(params)
    Counters.setup()
    local reach_board = getObjectFromGUID(reach_board_GUID)
    reach_board.setDescription("in progress")

    local visibility = {"Red", "White", "Yellow", "Teal", "Black", "Grey"}

    if (params.with_faceup_discard) then
        ActionCards.faceup_discard_visibility(true)
        local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
        fud_marker.setDescription("active")
    end

    BaseGame.core_components_visibility(true)
    if (params.is_campaign) then
        local campaign_rules = getObjectFromGUID(Campaign.guids.rules)
        campaign_rules.setDescription("active")

        Campaign.components_visibility(true)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    else
        BaseGame.base_exclusive_components_visibility(true)
    end
    if (params.is_4p) then
        BaseGame.four_player_cards_visibility(true)
    end
    if (params.leaders_and_lore) then
        BaseGame.leaders_visibility(true, params.leaders_and_lore_expansion)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    end

    -- player components visibility
    for _, color in ipairs(params.players) do
        ArcsPlayer.components_visibility(color, true, params.is_campaign)
        local player_board = getObjectFromGUID(
            player_pieces_GUIDs[color].player_board)
        player_board.setDescription("active")
    end
    -- for _, v in ipairs(getOrderedPlayers()) do
    --     ArcsPlayer.components_visibility(v.color, true, params.is_campaign)
    --     local player_board = getObjectFromGUID(v.components.board)
    --     player_board.setDescription("active")
    -- end
end

function onLoad()
    Initiative.add_menu()

    for _, obj in pairs(getObjectsWithTag("City")) do
        Supplies.addMenuToObject(obj)
    end

    local reach_board = getObjectFromGUID(reach_board_GUID)
    if (reach_board.getDescription() == "in progress") then
        broadcastToAll("Loading game in progress")

        for _, v in ipairs({"Red", "White", "Yellow", "Teal"}) do
            local player_board = getObjectFromGUID(
                player_pieces_GUIDs[v].player_board)
            if (player_board.getDescription() == "active") then
                local arcs_player = ArcsPlayer:new{
                    color = v
                }
                table.insert(active_players, arcs_player)
            end
        end

        Counters.setup()
    elseif debug then
        Campaign.components_visibility(true)
        BaseGame.components_visibility({
            is_visible = true,
            is_campaign = true,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true,
            with_faceup_discard = true
        })
    else
        -- Hide components
        Campaign.components_visibility(false)
        BaseGame.components_visibility({
            is_visible = false,
            is_campaign = false,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true -- ,
            -- faceup_discard = true
        })

        for _, v in pairs(available_colors) do
            ArcsPlayer.components_visibility(v, false, false)
        end
    end

    local action_deck = ActionCards.get_action_deck()
    action_deck.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)

    for _, obj in pairs(getObjectsWithTag("Noninteractable")) do
        obj.locked = true
        obj.interactable = false
    end

    if (not debug) then
        local face_up_discard_action_deck = getObjectFromGUID(
            face_up_discard_action_deck_GUID)
        face_up_discard_action_deck.setInvisibleTo({
            "Red", "White", "Yellow", "Teal", "Black", "Grey"
        })
        face_up_discard_action_deck.interactable = false
        face_up_discard_action_deck.locked = false -- set this to false otherwise it breaks
    end

    -- Initialize turn system
    Turns.enable = true
    Turns.pass_turns = true

    -- Initialize timer system
    resetTimer()  -- Reset all player timers
    loadCameraTimerMenu(false)  -- Load the UI with menu closed initially
end
