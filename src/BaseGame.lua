local LOG = require("src/LOG")

local BaseGame = {
    components = {
        base_exclusive = {
            setup_cards = "f02e75",
            court = "9ac2b3"
        },
        leaders = "2d243a",
        leaders_expansion = "768d3d",
        lore = "0d8ede",
        lore_expansion = "3441e5",
        -- faceup_discard_cards = "a8e929",
        action_cards_4p = "13bedd",

        core = {
            control_board = "6e21fe",
            reach_board = "bb7d21",
            dice_board = "af1f85",
            dice_help = "06e7d2",
            dice_counter1 = "069307",
            dice_counter2 = "4798a5",
            rules = "bdf1aa",
            round_help = "bcb75f",
            ambition_high = "c9e0ee",
            ambition_medium = "a9b02a",
            ambition_low = "b0b4d0",
            action_cards = "227406",
            ambition_declared = "0289cb",
            chapter_pawn = "9c3ac8",
            psionic_placeholder = "a89706",
            psionic_stack = "1b4b0b",
            relic_placeholder = "473675",
            relic_stack = "5895b5",
            weapon_placeholder = "2fdfa3",
            weapon_stack = "1c2d2a",
            fuel_placeholder = "5cb321",
            fuel_stack = "ed2820",
            material_placeholder = "eb1cba",
            material_stack = "57c2c6",
            initiative = "b3b3d0"

        }
    }
}

local ArcsPlayer = require("src/ArcsPlayer")
local Counters = require("src/Counters")
local supplies = require("src/Supplies")
local ActionCards = require("src/ActionCards")
local resource = require("src/Resource")
local merchant = require("src/Merchant")

local leader_setup_markers = {
    White = {
        A = "http://cloud-3.steamusercontent.com/ugc/2470859798801204323/C2AB80A86A05E6D091EEEFC3BBC37750441C8458/",
        B = "http://cloud-3.steamusercontent.com/ugc/2470859798801204362/040363BB8DEFF3E79EEF4E9F022346006808DAF1/",
        C = "http://cloud-3.steamusercontent.com/ugc/2470859798801204408/C404410F6AFD3AA2AA563EF27D796C4E8F872B00/",
        D = "http://cloud-3.steamusercontent.com/ugc/2470859798801204408/C404410F6AFD3AA2AA563EF27D796C4E8F872B00/"
    },
    Yellow = {
        A = "http://cloud-3.steamusercontent.com/ugc/2470859798801217991/3B4F2203FBE1A85FA4E892F1B9D453FE72923393/",
        B = "http://cloud-3.steamusercontent.com/ugc/2470859798801218068/F51FD5724585838D7D451AE7E89CF89081E96ACA/",
        C = "http://cloud-3.steamusercontent.com/ugc/2470859798801218131/2CD7AB119161AC27C9EB8CA834FF9B748DCCBC45/",
        D = "http://cloud-3.steamusercontent.com/ugc/2470859798801218131/2CD7AB119161AC27C9EB8CA834FF9B748DCCBC45/"
    },
    Teal = {
        A = "http://cloud-3.steamusercontent.com/ugc/2470859798801203960/A4DC5AF4F4F5E8BB63CDF8B09C11A58F3DA8EA40/",
        B = "http://cloud-3.steamusercontent.com/ugc/2470859798801204036/E06E07F519CA19F4EE40BFF2E728103A233D402B/",
        C = "http://cloud-3.steamusercontent.com/ugc/2470859798801204130/8DBC24130B163534CCF2BD3377B74FF04D9F8A5F/",
        D = "http://cloud-3.steamusercontent.com/ugc/2470859798801204130/8DBC24130B163534CCF2BD3377B74FF04D9F8A5F/"
    },
    Red = {
        A = "http://cloud-3.steamusercontent.com/ugc/2470859798801204187/D190E74F4A0ADBA81C50A4E328B904A236B7C742/",
        B = "http://cloud-3.steamusercontent.com/ugc/2470859798801204242/98F1219A748CF32B8094DF04264245366977D678/",
        C = "http://cloud-3.steamusercontent.com/ugc/2470859798801204273/D14267BB17B5B5F5A0EB5D41DDE2180A8972F7F0/",
        D = "http://cloud-3.steamusercontent.com/ugc/2470859798801204273/D14267BB17B5B5F5A0EB5D41DDE2180A8972F7F0/"
    },
    guids = {}
}

function BaseGame.leaders_visibility(show, with_expansion)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}
    if (with_expansion) then
        local expansion = getObjectFromGUID(BaseGame.components
                                                .leaders_expansion)
        if (expansion) then
            expansion.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = expansion,
                is_visible = show
            })
        end
    end
    local leaders = getObjectFromGUID(BaseGame.components.leaders)
    if (leaders) then
        leaders.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = leaders,
            is_visible = show
        })
    end
end

function BaseGame.lore_visibility(show, with_expansion)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}
    if (with_expansion) then
        local expansion = getObjectFromGUID(BaseGame.components.lore_expansion)
        if (expansion) then
            expansion.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = expansion,
                is_visible = show
            })
        end
    end
    local lore = getObjectFromGUID(BaseGame.components.lore)
    if (lore) then
        lore.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = lore,
            is_visible = show
        })
    end
end

function BaseGame.core_components_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}
    for _, id in pairs(BaseGame.components.core) do
        local obj = getObjectFromGUID(id)
        if (obj) then
            obj.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = obj,
                is_visible = show
            })
        else
        end
    end
end

function BaseGame.four_player_cards_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}
    local obj = getObjectFromGUID(BaseGame.components.action_cards_4p)
    if (obj) then
        obj.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = obj,
            is_visible = show
        })
    end
end

function BaseGame.base_exclusive_components_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}
    for _, id in pairs(BaseGame.components.base_exclusive) do
        local obj = getObjectFromGUID(id)
        if (obj) then
            obj.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = obj,
                is_visible = show
            })
        end
    end
end

-- params = {
--     is_visible = true,
--     is_campaign = true,
--     is_4p = true,
--     leaders_and_lore = true,
--     leaders_and_lore_expansion = true,
--     faceup_discard = true
-- }
function BaseGame.components_visibility(params)
    BaseGame.core_components_visibility(params.is_visible)
    if (not params.is_campaign) then
        BaseGame.base_exclusive_components_visibility(params.is_visible)
    end
    if (params.is_4p) then
        BaseGame.four_player_cards_visibility(params.is_visible)
    end
    if (params.leaders_and_lore) then
        BaseGame.leaders_visibility(params.is_visible,
            params.leaders_and_lore_expansion)
        BaseGame.lore_visibility(params.is_visible,
            params.leaders_and_lore_expansion)
    end
    if (params.faceup_discard) then
        ActionCards.faceup_discard_visibility(params.is_visible)
    end
end

function BaseGame.setup(with_leaders, with_ll_expansion)

    local active_players = Global.call("getOrderedPlayers")
    Global.setVar("active_players", active_players)
    if (#active_players < 2 or #active_players > 4) then
        return false
    end

    local active_player_colors = {}
    for _, p in pairs(active_players) do
        ArcsPlayer.setup(p, false)
        table.insert(active_player_colors, p.color)
    end
    local p = {
        is_campaign = false,
        is_4p = #active_players == 4,
        leaders_and_lore = with_leaders,
        leaders_and_lore_expansion = with_ll_expansion,
        with_faceup_discard = ActionCards.is_face_up_discard_active(),
        players = active_player_colors
    }
    Global.call("set_game_in_progress", p)

    -- B
    local initiative = require("src/InitiativeMarker")
    initiative.take(active_players[1].color)

    -- D
    ActionCards.setup_deck(#active_players)
    BaseGame.setupBaseCourt(#active_players)

    chosen_setup_card = BaseGame.chooseSetupCard(#active_players)
    BaseGame.setupOutOfPlayClusters(chosen_setup_card)
    if (#active_players == 2) then
        merchant:setup(chosen_setup_card.out_of_play_clusters)
    end

    if (Global.getVar("with_leaders")) then
        BaseGame.dealLeaders(#active_players)
        BaseGame.place_player_markers(active_players, chosen_setup_card)
    else
        BaseGame.setupPlayers(active_players, chosen_setup_card)
    end

    Turns.type = 2
    Turns.order = active_player_colors

    return true
end

function BaseGame.setup_leaders()
    LOG.INFO("Setup Leaders")

    local active_players = Global.getTable("active_players")

    -- check if leader is in player area
    local leader_count = 0
    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    for i, player in ipairs(active_players) do
        local player_zones = getObjectFromGUID(
                                 player_pieces_guids[player.color]["area_zone"]).getObjects()

        for _, obj in pairs(player_zones) do
            if (obj.hasTag("Leader")) then
                leader_count = leader_count + 1
            end
        end
    end
    if leader_count < #active_players then
        return false
    end

    -- delete setup markers
    for _, marker_guid in pairs(leader_setup_markers["guids"]) do
        local marker = getObjectFromGUID(marker_guid)
        destroyObject(marker)
    end

    -- setup players
    BaseGame.setupPlayers(active_players, chosen_setup_card)
    return true
end

-- H
function BaseGame.setupBaseCourt(player_count)
    LOG.INFO("Setup Base Court")

    local court_zone = getObjectFromGUID(Global.getVar("court_deck_zone_GUID"))
    local court_zone_pos = court_zone.getPosition()
    local base_court = getObjectFromGUID(Global.getVar("base_court_deck_GUID"))

    base_court.setPosition(court_zone_pos)
    base_court.setRotation({0, 270, 180})

    Wait.time(function()
        base_court.randomize()
        Global.call("dealGuildCards", player_count == 2 and 3 or 4)
    end, 1)
end

-- I
function BaseGame.chooseSetupCard(player_count)
    LOG.INFO("Choose Setup Card")

    local player_colors = {"White", "Yellow", "Teal", "Red"}

    local two_player_setup_cards = {
        {
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
        }
    }

    local three_player_setup_cards = {
        {
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
        }
    }

    local four_player_setup_cards = {
        {
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
        }
    }

    local setup_cards = {
        two_player_setup_cards, three_player_setup_cards,
        four_player_setup_cards
    }

    local chosen_setup_card = setup_cards[player_count - 1][math.random(
        #setup_cards[player_count - 1])]

    local setup_deck = getObjectFromGUID(Global.getVar("setup_deck_GUID"))
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
                    spawnedObject.setPositionSmooth({-49.4, 2, 11})
                end
            end)
        end
    })

    getObjectFromGUID(chosen_setup_card.guid).setScale({3, 1, 3})
    return chosen_setup_card

end

-- J
function BaseGame.setupOutOfPlayClusters(setup_card)
    LOG.INFO("Setup Out of Play Clusters")
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
            object.setCustomObject({
                image = component.img
            })
            object.setLock(true)
        end
    end

end

function BaseGame.place_player_markers(ordered_players, setup_card)
    LOG.INFO("Place Player Markers")

    local locations = Global.getVar("starting_locations")[setup_card.guid]
    local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")
    local board = getObjectFromGUID(Global.getVar("reach_board_GUID"))

    for player_number, ABC in pairs(locations) do
        local player_color = ordered_players[player_number].color
        local player_marker_images = leader_setup_markers[player_color]

        -- iterate through setup card's ABCs
        LOG.DEBUG("iterate through setup card's ABCs")
        for starting_letter, cluster_system in pairs(ABC) do
            local cluster = cluster_system["cluster"]
            local system = cluster_system["system"]

            local move_pos
            if (system == "gate") then -- a gate system
                LOG.DEBUG("a gate system")
                move_pos =
                    getObjectFromGUID(cluster_zone_guids[cluster][system]).getPosition()
            else -- this is a planetary system
                LOG.DEBUG("a planetary system")
                move_pos = getObjectFromGUID(
                               cluster_zone_guids[cluster][system]["ships"]).getPosition()
            end

            LOG.DEBUG("spawn marker")
            local marker = spawnObject({
                type = "Custom_Token",
                position = move_pos,
                rotation = {0, 180, 0},
                scale = {0.5, 0.5, 0.5},
                sound = false
            })
            marker.setCustomObject({
                image = player_marker_images[starting_letter]
            })
            marker.setLock(true)
            table.insert(leader_setup_markers["guids"], marker.guid)
            -- marker.reload()
        end
    end
    return true
end

function BaseGame.dealLeaders(player_count)

    local leader_deck = getObjectFromGUID(Global.getVar("fate_GUID"))
    local lore_deck = getObjectFromGUID(Global.getVar("lore_GUID"))
    local mte_fate = getObjectFromGUID(
        Global.getVar("more_to_explore_fate_GUID"))
    local mte_lore = getObjectFromGUID(
        Global.getVar("more_to_explore_lore_GUID"))

    if (Global.getVar("with_more_to_explore")) then
        broadcastToAll("Playing with the Leaders & Lore Expansion")

        leader_deck.putObject(mte_fate)
        lore_deck.putObject(mte_lore)
    end

    leader_deck.randomize()
    lore_deck.randomize()

    local leader_pos = {
        x = 25,
        y = 1,
        z = 2
    }
    local lore_pos = {
        x = 25,
        y = 1,
        z = -2.5
    }

    for i = 1, player_count + 1 do
        leader_deck.takeObject({
            flip = true,
            position = {leader_pos.x + (i * 3.2), leader_pos.y, leader_pos.z}
        })
        lore_deck.takeObject({
            flip = true,
            position = {lore_pos.x + (i * 3.2), lore_pos.y, lore_pos.z}
        })

    end
end

function BaseGame.setupPlayers(ordered_players, setup_card)
    LOG.INFO("Setup Players")

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
                                 player_pieces_guids[player.color]["area_zone"]).getObjects()

        for _, obj in pairs(player_zones) do
            if (obj.hasTag("Leader")) then
                player_leaders[i] = obj.guid
            end
        end
    end

    local locations = Global.getVar("starting_locations")[setup_card.guid]

    for player_number, ABC in pairs(locations) do
        local player_color = ordered_players[player_number].color

        LOG.DEBUG("get player ship and starport bags and city objects")
        local ship_bag = getObjectFromGUID(
            player_pieces_guids[player_color]["ships"])
        local starport_bag = getObjectFromGUID(
            player_pieces_guids[player_color]["starports"])
        local city1 = getObjectFromGUID(
            player_pieces_guids[player_color]["cities"][1])
        local city2 = getObjectFromGUID(
            player_pieces_guids[player_color]["cities"][2])

        LOG.DEBUG("get starting pieces")
        local leader = player_leaders[player_number]
        local pieces = Global.getVar("starting_pieces")[leader]

        LOG.DEBUG("iterate through setup card's ABCs")
        for starting_letter, cluster_system in pairs(ABC) do
            local cluster = cluster_system["cluster"]
            local system = cluster_system["system"]

            LOG.DEBUG("get building/ship/gate zones in cluster and system")
            local building_zone
            local ship_zone
            local gate_zone

            -- TODO determine a different condition to determine a gate system
            if (system == "gate") then -- a gate system
                gate_zone = getObjectFromGUID(
                                cluster_zone_guids[cluster][system]).getPosition()

                LOG.DEBUG("move ships to gate zone")
                local ship_qty = pieces[starting_letter]["ships"]
                local ship_place_offset = 0
                for i = 1, ship_qty, 1 do
                    ship_bag.takeObject({
                        position = {
                            gate_zone.x, gate_zone.y + 0.5,
                            gate_zone.z + ship_place_offset
                        }
                    })
                    ship_place_offset = ship_place_offset + 0.3
                end
            else -- this is a planetary system
                building_zone = getObjectFromGUID(
                                    cluster_zone_guids[cluster][system]["buildings"][1]).getPosition()

                LOG.DEBUG("get building type to move")
                local building_type = pieces[starting_letter]["building"]

                LOG.DEBUG("move building to building zone one")
                if (building_type == "city") then
                    if (starting_letter == "A") then
                        city1.setPositionSmooth(building_zone)
                    else
                        city2.setPositionSmooth(building_zone)
                    end
                elseif (building_type == "starport") then
                    starport_bag.takeObject({
                        position = {
                            building_zone.x, building_zone.y + 0.5,
                            building_zone.z
                        },
                        rotation = {0, 180, 0}
                    })
                end

                LOG.DEBUG("move ships to ship zone")
                ship_zone = getObjectFromGUID(
                                cluster_zone_guids[cluster][system]["ships"]).getPosition()
                local ship_qty = pieces[starting_letter]["ships"]
                local ship_place_offset = 0
                for i = 1, ship_qty, 1 do
                    ship_bag.takeObject({
                        position = {
                            ship_zone.x, ship_zone.y + 0.5,
                            ship_zone.z + ship_place_offset
                        }
                    })
                    ship_place_offset = ship_place_offset + 0.3
                end
            end
        end

        LOG.INFO("Disperse starting resources")
        -- TODO: refactor the rest of this function to use Player module
        local player = ArcsPlayer
        player.color = player_color

        local starting_resources = pieces["resources"]

        if not (starting_resources) then
            starting_resources = {
                resource:name_from_cluster(ABC["A"]["cluster"],
                    ABC["A"]["system"]),
                resource:name_from_cluster(ABC["B"]["cluster"],
                    ABC["B"]["system"])
            }
        end

        LOG.DEBUG("starting_resource: " .. starting_resources[1])

        player:take_resource(starting_resources[1], 1)
        player:take_resource(starting_resources[2], 2)

    end
end

return BaseGame
