local BaseGame = {}

local merchant = require("src/Merchant")
local supplies = require("src/Supplies")

function BaseGame.setup()

    for _, obj in pairs(getObjectsWithTag("Campaign Only")) do
        supplies.removeFromGame(obj)
    end

    local active_players = Global.call("getOrderedPlayers")
    if (#active_players < 2 or #active_players > 4) then
        return false
    end

    -- B
    Global.call("takeInitiative", active_players[1])

    BaseGame.setupActionDeck(#active_players)
    BaseGame.setupBaseCourt(#active_players)

    chosen_setup_card = BaseGame.chooseSetupCard(#active_players)
    BaseGame.setupOutOfPlayClusters(chosen_setup_card)
    if (#active_players == 2) then
        merchant.setup(chosen_setup_card.out_of_play_clusters)
    end

    if (Global.getVar("with_leaders")) then
        BaseGame.dealLeaders(#active_players)
        Global.setVar("active_players", active_players)
        return false
    else
        BaseGame.setupPlayers(active_players, chosen_setup_card)
    end

    Global.setVar("active_players", active_players)
    return true
end

function BaseGame.dispersePlayerPieces()
    -- print("disperse starting pieces")

    setupPlayers(Global.getVar("active_players"), chosen_setup_card)
end

-- D
function BaseGame.setupActionDeck(player_count)
    -- print("Base Game Setup Action Deck")

    -- Add 7s and 1s to the action deck for 4 players
    local four_player_action_deck =
        getObjectFromGUID(Global.getVar("action_deck_4P_GUID"))
    local action_deck = getObjectFromGUID(Global.getVar(
        "action_deck_GUID"))
    local event_deck = getObjectFromGUID(Global.getVar(
        "event_deck_GUID"))

    if (player_count == 4) then
        action_deck.putObject(four_player_action_deck)
    end

    Wait.time(function()
        action_deck.randomize()
    end, 1.5)
end

-- H
function BaseGame.setupBaseCourt(player_count)
    -- print("Setup Base Court")

    local court_zone = getObjectFromGUID(Global.getVar(
        "court_deck_zone_GUID"))
    local court_zone_pos = court_zone.getPosition()
    local base_court = getObjectFromGUID(Global.getVar(
        "base_court_deck_GUID"))

    base_court.setPosition(court_zone_pos)
    base_court.setRotation({0, 270, 180})

    Wait.time(function()
        -- deal guild cards
        Global.call("dealGuildCards", player_count == 2 and 3 or 4)
    end, 1)
end

-- I
function BaseGame.chooseSetupCard(player_count)
    -- print("Choose Setup Card")

    local player_colors = {"White", "Yellow", "Red", "Teal"}

    local two_player_setup_cards = {{
        name = "FRONTIERS *For Experienced Players*",
        guid = Global.getVar("frontiers_2P_GUID"),
        out_of_play_clusters = {1, 6},
        player_colors = 2
    }, {
        name = "HOMELANDS",
        guid = Global.getVar("homelands_2P_GUID"),
        out_of_play_clusters = {1, 4},
        player_colors = 2
    }, {
        name = "MIX UP 1",
        guid = Global.getVar("mix_up_1_2P_GUID"),
        out_of_play_clusters = {2, 5},
        player_colors = 2
    }, {
        name = "MIX UP 2",
        guid = Global.getVar("mix_up_2_2P_GUID"),
        out_of_play_clusters = {1, 4},
        player_colors = 2
    }}

    local three_player_setup_cards = {{
        name = "FRONTIERS",
        guid = Global.getVar("frontiers_3P_GUID"),
        out_of_play_clusters = {2, 3},
        player_colors = 3
    }, {
        name = "HOMELANDS",
        guid = Global.getVar("homelands_3P_GUID"),
        out_of_play_clusters = {5, 6},
        player_colors = 3
    }, {
        name = "CORE CONFLICT *For Experienced Players*",
        guid = Global.getVar("core_conflict_3P_GUID"),
        out_of_play_clusters = {3, 6},
        player_colors = 3
    }, {
        name = "MIX UP",
        guid = Global.getVar("mix_up_3P_GUID"),
        out_of_play_clusters = {1, 4},
        player_colors = 3
    }}

    local four_player_setup_cards = {{
        name = "FRONTIERS",
        guid = Global.getVar("frontiers_4P_GUID"),
        out_of_play_clusters = {5},
        player_colors = 4
    }, {
        name = "MIX UP 1",
        guid = Global.getVar("mix_up_1_4P_GUID"),
        out_of_play_clusters = {3},
        player_colors = 4
    }, {
        name = "MIX UP 2",
        guid = Global.getVar("mix_up_2_4P_GUID"),
        out_of_play_clusters = {4},
        player_colors = 4
    }, {
        name = "MIX UP 3",
        guid = Global.getVar("mix_up_3_4P_GUID"),
        out_of_play_clusters = {6},
        player_colors = 4
    }}

    local setup_cards = {two_player_setup_cards,
                         three_player_setup_cards,
                         four_player_setup_cards}

    local chosen_setup_card =
        setup_cards[player_count - 1][math.random(
            #setup_cards[player_count - 1])]

    local setup_deck = getObjectFromGUID(Global.getVar(
        "setup_deck_GUID"))
    setup_deck.takeObject({
        guid = chosen_setup_card.guid,
        flip = true,
        position = {0, 4, 0},
        callback_function = function(spawnedObject)
            Wait.frames(function()
                -- We've just waited a frame, which has given the object time to unfreeze.
                -- However, it's also given the object time to enter another container, if
                -- it spawned on one. Thus, we must confirm the object is not destroyed.
                if not spawnedObject.isDestroyed() then
                    spawnedObject.setPositionSmooth({-30, 1, 16})
                end
            end)
        end
    })

    getObjectFromGUID(chosen_setup_card.guid).setScale({5, 5, 5})
    return chosen_setup_card

end

-- J
function BaseGame.setupOutOfPlayClusters(setup_card)
    -- print("Setup Out of Play Clusters")
    local oop_components = Global.getTable("oop_components")
    local board = getObjectFromGUID(Global.getVar("reach_board_GUID"))

    for _, cluster_num in pairs(setup_card.out_of_play_clusters) do
        for _, component in pairs(oop_components[cluster_num]) do
            local object = spawnObject({
                type = "Custom_Token",
                position = board.positionToWorld(component.pos),
                rotation = component.rot,
                scale = component.scale,
                sound = false
            })
            object.setCustomObject({image = component.img})
            object.setLock(true)
        end
    end

end

function BaseGame.dealLeaders(player_count)

    local leader_deck = getObjectFromGUID(Global.getVar("fate_GUID"))
    local lore_deck = getObjectFromGUID(Global.getVar("lore_GUID"))
    local mte_fate = getObjectFromGUID(Global.getVar(
        "more_to_explore_fate_GUID"))
    local mte_lore = getObjectFromGUID(Global.getVar(
        "more_to_explore_lore_GUID"))

    if (Global.getVar("with_more_to_explore")) then
        broadcastToAll("Playing with the Leaders & Lore Expansion")

        leader_deck.putObject(mte_fate)
        lore_deck.putObject(mte_lore)
    end

    leader_deck.randomize()
    lore_deck.randomize()

    local leader_pos = {
        x = -39,
        y = 1,
        z = 7
    }
    local lore_pos = {
        x = -39,
        y = 1,
        z = 2.5
    }

    for i = 1, player_count + 1 do
        leader_deck.takeObject({
            flip = true,
            position = {leader_pos.x + (i * 3.2), leader_pos.y,
                        leader_pos.z}
        })
        lore_deck.takeObject({
            flip = true,
            position = {lore_pos.x + (i * 3.2), lore_pos.y, lore_pos.z}
        })

    end
end

function BaseGame.setupPlayers(ordered_players, setup_card)
    -- print("Setup Players")

    local player_leaders = {
        [1] = "Default",
        [2] = "Default",
        [3] = "Default",
        [4] = "Default"
    }
    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")

    for i, player in ipairs(ordered_players) do
        local player_zones = getObjectFromGUID(
                                 player_pieces_guids[player]["area_zone"]).getObjects()

        for _, obj in pairs(player_zones) do
            if (obj.hasTag("Leader")) then
                player_leaders[i] = obj.guid
            end
        end
    end

    local locations =
        Global.getVar("starting_locations")[setup_card.guid]

    for player_number, ABC in pairs(locations) do
        local player_color = ordered_players[player_number]

        -- get player ship and starport bags and city objects
        local ship_bag = getObjectFromGUID(
            player_pieces_guids[player_color]["ships"])
        local starport_bag = getObjectFromGUID(
            player_pieces_guids[player_color]["starports"])
        local city1 = getObjectFromGUID(
            player_pieces_guids[player_color]["city"][1])
        local city2 = getObjectFromGUID(
            player_pieces_guids[player_color]["city"][2])

        -- get starting pieces
        local pieces =
            Global.getVar("starting_pieces")[player_leaders[player_number]]

        -- iterate through setup card's ABCs
        for starting_letter, cluster_system in pairs(ABC) do
            local cluster = cluster_system["cluster"]
            local system = cluster_system["system"]

            -- get building/ship/gate zones in cluster and system
            local building_zone
            local ship_zone
            local gate_zone

            -- TODO determine a different condition to determine a gate system
            if (system == "gate") then -- a gate system
                gate_zone = getObjectFromGUID(
                                cluster_zone_guids[cluster][system]).getPosition()

                -- move ships to gate zone
                local ship_qty = pieces[starting_letter]["ships"]
                local ship_place_offset = 0
                for i = 1, ship_qty, 1 do
                    ship_bag.takeObject({
                        position = {gate_zone.x, gate_zone.y,
                                    gate_zone.z + ship_place_offset}
                    })
                    ship_place_offset = ship_place_offset + 0.3
                end
            else -- this is a planetary system
                building_zone = getObjectFromGUID(
                                    cluster_zone_guids[cluster][system]["buildings"][1]).getPosition()

                -- get building type to move
                local building_type =
                    pieces[starting_letter]["building"]

                -- move building to building zone one
                if (building_type == "city") then
                    if (starting_letter == "A") then
                        city1.setPositionSmooth(building_zone)
                    else
                        city2.setPositionSmooth(building_zone)
                    end
                elseif (building_type == "starport") then
                    starport_bag.takeObject({
                        position = building_zone,
                        rotation = {0, 180, 0}
                    })
                end

                -- move ships to ship zone
                ship_zone = getObjectFromGUID(
                                cluster_zone_guids[cluster][system]["ships"]).getPosition()
                local ship_qty = pieces[starting_letter]["ships"]
                local ship_place_offset = 0
                for i = 1, ship_qty, 1 do
                    ship_bag.takeObject({
                        position = {ship_zone.x, ship_zone.y,
                                    ship_zone.z + ship_place_offset}
                    })
                    ship_place_offset = ship_place_offset + 0.3
                end
            end

        end
    end
end

return BaseGame
