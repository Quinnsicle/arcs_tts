local LOG = require("src/LOG")

local BaseGame = {
    components = {
        base_exclusive = {
            setup_cards = "f02e75",
            court = "9ac2b3",
            scavengers_scouts_deck = "94dd8f",
        },
        leaders = "2d243a",
        leaders_expansion = "768d3d",
        laurens_custom_leaders = "4fcf71",
        pnp3_leaders = "0e4deb",
        pnp3_leaders_extra = "ae2eb4", -- no leader cards in here, to be scripted in later not now
        lore = "0d8ede",
        lore_expansion = "3441e5",
        -- faceup_discard_cards = "a8e929",
        action_cards_4p = "13bedd",

        core = {
            control_board = "6e21fe",
            reach_board = "bb7d21",
            dice_board = "af1f85",
            dice_help = "f96808",
            dice_counter1 = "069307",
            dice_counter2 = "4798a5",
            action_help = "28a621",
            rules = "bdf1aa",
            round_help = "bcb75f",
            ambition_high = "c9e0ee",
            ambition_medium = "a9b02a",
            ambition_low = "b0b4d0",
            ambition_high_5p = "5b499a",
            ambition_medium_5p = "d7d474",
            ambition_low_5p = "0f526d",
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
            initiative = "b3b3d0",
            event_die = "684608",
            number_die = "d5e298",
            court_discard_backer = "2840db",
            court_deck_backer = "93690a",
            artifact_deck = "870e15",
            edifice_deck = "becb7c",
            mandate_cards = "c549b5",
            lost_vaults_marker_bag = "7f3e2f",
            lost_vaults_rules = "952d62"
        }
    }
}

local ArcsPlayer = require("src/ArcsPlayer")
local Counters = require("src/Counters")
local Supplies = require("src/Supplies")
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
    Pink = {
        A = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-a.png",
        B = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-b.png",
        C = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-c.png",
        D = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-c.png"
    },
    guids = {}
}

function BaseGame.leaders_visibility(show, with_expansion)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
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
    -- Also apply visibility to Laurens' and PnP#3 custom leader decks (if present)
    if Global.getVar("with_laurens_custom_leader") then
        local laurens = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
        if (laurens) then
            laurens.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = laurens,
                is_visible = show
            })
        end
    end
    if Global.getVar("with_pnp3_leaders") then
        local pnp3 = getObjectFromGUID(BaseGame.components.pnp3_leaders)
        if (pnp3) then
            pnp3.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = pnp3,
                is_visible = show
            })
        end
        local pnp3_extra = getObjectFromGUID(BaseGame.components.pnp3_leaders_extra)
        if (pnp3_extra) then
            pnp3_extra.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = pnp3_extra,
                is_visible = show
            })
        end
    end
end

function BaseGame.lore_visibility(show, with_expansion)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
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
    -- Also apply visibility to Laurens' and PnP#3 custom leader decks (if present)
    local laurens = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
    if (laurens) then
        laurens.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = laurens,
            is_visible = show
        })
    end
    local pnp3 = getObjectFromGUID(BaseGame.components.pnp3_leaders)
    if (pnp3) then
        pnp3.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = pnp3,
            is_visible = show
        })
    end
    local pnp3_extra = getObjectFromGUID(BaseGame.components.pnp3_leaders_extra)
    if (pnp3_extra) then
        pnp3_extra.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = pnp3_extra,
            is_visible = show
        })
    end
end

function BaseGame.core_components_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
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

    -- adjust court row backers so they don't interfere
    -- when players attempts to bury a card under the court deck
    if show then
        Wait.frames(function()
            local court_deck_backer = getObjectFromGUID(BaseGame.components.core.court_deck_backer)
            local court_discard_backer = getObjectFromGUID(BaseGame.components.core.court_discard_backer)

            for _, backer in ipairs({court_deck_backer, court_discard_backer}) do
                if backer then
                    local pos = backer.getPosition()
                    backer.setPosition({pos.x, 0.85, pos.z})
                end
            end
        end, 1)
    end
end

function BaseGame.four_player_cards_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    local obj = getObjectFromGUID(BaseGame.components.action_cards_4p)
    if (obj) then
        obj.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = obj,
            is_visible = show
        })
    end
end

-- Return the list of available setup option tables for a given player count (2..5)
function BaseGame.getSetupOptions(player_count)
    local two_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_2P_GUID"), out_of_play_clusters = {1, 6}, player_colors = 2 },
        { name = "HOMELANDS", guid = Global.getVar("homelands_2P_GUID"), out_of_play_clusters = {1, 4}, player_colors = 2 },
        { name = "MIX UP 1", guid = Global.getVar("mix_up_1_2P_GUID"), out_of_play_clusters = {2, 5}, player_colors = 2 },
        { name = "MIX UP 2", guid = Global.getVar("mix_up_2_2P_GUID"), out_of_play_clusters = {1, 4}, player_colors = 2 }
    }

    local three_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_3P_GUID"), out_of_play_clusters = {2, 3}, player_colors = 3 },
        { name = "HOMELANDS", guid = Global.getVar("homelands_3P_GUID"), out_of_play_clusters = {5, 6}, player_colors = 3 },
        { name = "CORE CONFLICT", guid = Global.getVar("core_conflict_3P_GUID"), out_of_play_clusters = {3, 6}, player_colors = 3 },
        { name = "MIX UP", guid = Global.getVar("mix_up_3P_GUID"), out_of_play_clusters = {1, 4}, player_colors = 3 }
    }

    local four_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_4P_GUID"), out_of_play_clusters = {5}, player_colors = 4 },
        { name = "MIX UP 1", guid = Global.getVar("mix_up_1_4P_GUID"), out_of_play_clusters = {3}, player_colors = 4 },
        { name = "MIX UP 2", guid = Global.getVar("mix_up_2_4P_GUID"), out_of_play_clusters = {4}, player_colors = 4 },
        { name = "MIX UP 3", guid = Global.getVar("mix_up_3_4P_GUID"), out_of_play_clusters = {6}, player_colors = 4 }
    }

    local five_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "EMPIRES", guid = Global.getVar("empires_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "MIX UP 1", guid = Global.getVar("mix_up_1_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "MIX UP 2", guid = Global.getVar("mix_up_2_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "EXTENSION", guid = Global.getVar("extension_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 }
    }

    local setup_cards = { two_player_setup_cards, three_player_setup_cards, four_player_setup_cards, five_player_setup_cards }
    return setup_cards[player_count - 1]
end

function BaseGame.base_exclusive_components_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
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
--     faceup_discard = true,
--     miniatures = true
-- }
function BaseGame.components_visibility(params)
    BaseGame.core_components_visibility(params.is_visible)
    if (not params.is_campaign) then
        BaseGame.base_exclusive_components_visibility(params.is_visible)
    end
    local player_count = params.players and #params.players or 0
    if (params.is_4p or player_count >= 4) then
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
    if (params.miniatures) then
        BaseGame.miniatures_setup(params.is_visible)
    end
end
function shift_ambition_markers() --5p
    local first_pos = {}
    local height_offset = 0.3  -- adjust this if needed

    -- Step 1: store positions of first 3
    for i = 1, 3 do
        local obj = getObjectFromGUID(ambition_marker_GUIDs[i])
        if obj then
            local pos = obj.getPosition()
            first_pos[i] = {x = pos.x, y = pos.y + height_offset, z = pos.z}
        end
    end

    -- Step 2: delete first 3
    for i = 1, 3 do
        local obj = getObjectFromGUID(ambition_marker_GUIDs[i])
        if obj then
            obj.destruct()
        end
    end

    -- Step 3 + 4: wait, then move last 3
    Wait.time(function()
        for i = 1, 3 do
            local obj = getObjectFromGUID(ambition_marker_GUIDs[i + 3])
            if obj and first_pos[i] then
                obj.setPositionSmooth(first_pos[i], false, true)
            else
                print("Missing object or position at index " .. i)
            end
        end
    end, 0.2)
end

-- Move/scale action deck and related zones for 5-player layout
function BaseGame.hide_and_disable_5p_snaps()
    local snaps_obj = getObjectFromGUID(snaps_5p_GUID)
    if not snaps_obj then
        return
    end

    -- If we're running in debug mode, keep the snaps visible and usable
    -- so developers can inspect and manipulate the 5P helper snaps.
    local debug_mode = false
    pcall(function() debug_mode = Global.getVar("debug") end)
    if debug_mode then
        snaps_obj.setInvisibleTo({})
        snaps_obj.interactable = true
        return
    end

    -- Keep helper snaps hidden and non-interactable for players.
    snaps_obj.setInvisibleTo({"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"})
    snaps_obj.setLock(true)
    snaps_obj.interactable = false
end

function BaseGame.adjust_action_deck_for_5p()
    pcall(function()
        local target = {-12.14, 1.08, 8.52}
        local target_zone = {-12.14, 1.3, 8.52}

        -- Move the physical action deck (if present)
        local ok, deck = pcall(function() return ActionCards.get_action_deck() end)
        if ok and deck then
            if deck.setPositionSmooth then
                deck.setPositionSmooth(target)
            elseif deck.setPosition then
                deck.setPosition(target)
            end
        end

        -- Move the action deck zone object so zone coordinates match
        local zone = getObjectFromGUID(action_deck_zone_GUID)
        if zone then
            if zone.setPositionSmooth then
                zone.setPositionSmooth(target_zone)
            elseif zone.setPosition then
                zone.setPosition(target_zone)
            end
        end

        -- Move and scale the action card zone for 5P
        local action_card_zone = getObjectFromGUID(action_card_zone_GUID)
        if action_card_zone then
            local action_card_pos = {-12.13, 3.54, 0.34}
            local action_card_scale = {3.84, 5.10, 12.65}
            if action_card_zone.setPositionSmooth then
                action_card_zone.setPositionSmooth(action_card_pos)
            elseif action_card_zone.setPosition then
                action_card_zone.setPosition(action_card_pos)
            end
            pcall(function()
                if action_card_zone.setScale then
                    action_card_zone.setScale(action_card_scale)
                end
            end)
        end
        -- Move or create snaps object for 5P layout
        local snaps_obj = getObjectFromGUID(snaps_5p_GUID)
        if snaps_obj then
            local snaps_target = {-12.18, 0.73, 5.26}
            if snaps_obj.setPositionSmooth then
                snaps_obj.setPositionSmooth(snaps_target)
            elseif snaps_obj.setPosition then
                snaps_obj.setPosition(snaps_target)
            end
            BaseGame.hide_and_disable_5p_snaps()
        end
    end)
end

function BaseGame.setup(with_leaders, with_ll_expansion, with_miniatures)

    local init_choice_color = Global.getVar("initiative_choice_color")
    local init_choice_index = Global.getVar("initiative_choice_index") or 0

    -- Prefer using Global to compute the ordered players starting with
    -- the chosen player (if present) so rotation happens in the Global
    -- script and avoids cross-script resource operations.
    local active_players
    if init_choice_color then
        active_players = Global.call("getOrderedPlayersStartingWith", init_choice_color)
    elseif init_choice_index and init_choice_index >= 1 then
        active_players = Global.call("getOrderedPlayersStartingWith", init_choice_index)
    else
        active_players = Global.call("getOrderedPlayers")
    end

    if #active_players >= 5 then
        shift_ambition_markers()
        -- Adjust action deck and related objects for 5P layout
        BaseGame.adjust_action_deck_for_5p()
    else
        -- Ensure the 5P snaps object is removed when not using 5P layout
        pcall(function()
            local snaps_obj = getObjectFromGUID(snaps_5p_GUID)
            if snaps_obj then
                local debug_mode = false
                pcall(function() debug_mode = Global.getVar("debug") end)
                if debug_mode then
                    -- In debug mode keep the snaps visible and interactable for inspection
                    snaps_obj.setInvisibleTo({})
                    snaps_obj.setLock(false)
                    snaps_obj.interactable = true
                else
                    destroyObject(snaps_obj)
                end
            end
        end)
    end

    -- B: determine initiative recipient (respect stored choice or random)
    local initiative = require("src/InitiativeMarker")
    local init_choice_color = Global.getVar("initiative_choice_color")
    local init_choice_index = Global.getVar("initiative_choice_index") or 0
    local init_choice_pcount = Global.getVar("initiative_choice_player_count")

    -- determine chosen_color: prefer stored choice, else pick randomly
    local chosen_color
    if init_choice_color then
        for _, p in ipairs(active_players) do
            if p.color == init_choice_color then chosen_color = p.color; break end
        end
    elseif init_choice_index and init_choice_index >= 1 and init_choice_pcount == #active_players and init_choice_index <= #active_players then
        chosen_color = active_players[init_choice_index].color
    else
        -- random mode: pick a random seated player to receive initiative and
        -- rotate the active players so that player 1 is that chosen player
        chosen_color = active_players[math.random(#active_players)].color
        active_players = Global.call("getOrderedPlayersStartingWith", chosen_color)
    end

    -- Now that we've finalized `active_players`, store it and validate
    Global.setVar("active_players", active_players)
    if (#active_players < 2 or #active_players > 5) then
        return false
    end

    BaseGame.setup_or_destroy_miniatures(with_miniatures, active_players)

    -- Set up per-player boards/objects now that active_players order is final
    local active_player_colors = {}
    for _, p in pairs(active_players) do
        ArcsPlayer.setup(p, false)
        table.insert(active_player_colors, p.color)
    end
    local p = {
        is_campaign = false,
        is_4p = #active_players == 4 or 5,
        leaders_and_lore = with_leaders,
        leaders_and_lore_expansion = with_ll_expansion,
        with_faceup_discard = ActionCards.is_face_up_discard_active(),
        players = active_player_colors
    }
    -- mark that we're performing the initial base setup so modules
    -- (like ArcsPlayer) can perform one-time actions (e.g., destroy objectives)
    Global.setVar("is_initial_setup", true)
    Global.call("set_game_in_progress", p)
    -- Clear the flag after setup to avoid affecting reloads or later calls
    Global.setVar("is_initial_setup", false)

    -- Place initiative marker for chosen player (chosen_color computed earlier)
    initiative.take(chosen_color)

    -- D
    ActionCards.setup_deck(#active_players)
    BaseGame.setupBaseCourt(#active_players)
    if (not Global.getVar("with_pnp2_lost_vaults")) then
        LOG.INFO("no vaults")
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
    else
        -- Lost Vaults enabled: instead of placing leaders on table, include
        -- any enabled custom leader decks and deal 2 leader cards into each
        -- player's hand.
        local leader_deck = getObjectFromGUID(Global.getVar("fate_GUID"))
        local lore_deck = getObjectFromGUID(Global.getVar("lore_GUID"))
        local mte_fate = getObjectFromGUID(Global.getVar("more_to_explore_fate_GUID"))
        local mte_lore = getObjectFromGUID(Global.getVar("more_to_explore_lore_GUID"))
        local artifact_deck = getObjectFromGUID(Global.getVar("artifact_deck_GUID"))

        if not leader_deck then
            LOG.INFO("Leader deck not found; cannot deal leaders to hands")
            return
        end

        -- Include Leaders & Lore expansion cards if enabled
        if (Global.getVar("with_more_to_explore")) then
            leader_deck.putObject(mte_fate)
            if lore_deck and mte_lore then lore_deck.putObject(mte_lore) end
        end

        -- If the user requested to not use the base and pack leader objects,
        -- remove those physical objects so custom decks fully replace them.
        local base_leaders_pos, base_leaders_rot
        if (Global.getVar("dont_use_base_and_pack_leaders")) then
            local base_leaders_obj = getObjectFromGUID(BaseGame.components.leaders)
            if (base_leaders_obj) then
                base_leaders_pos = base_leaders_obj.getPosition()
                base_leaders_rot = base_leaders_obj.getRotation()
                destroyObject(base_leaders_obj)
                broadcastToAll("Removed base leaders from the table")
            end
            local expansion_leaders_obj = getObjectFromGUID(BaseGame.components.leaders_expansion)
            if (expansion_leaders_obj) then
                destroyObject(expansion_leaders_obj)
                broadcastToAll("Removed expansion leaders from the table")
            end
        end

        -- Optionally include custom leader decks (Laurens, PnP#3, etc.)
        local custom_decks = {}
        local custom_names = {}
        if Global.getVar("with_laurens_custom_leader") then
            local d = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
            if d then table.insert(custom_decks, d); table.insert(custom_names, "Laurens") end
        end
        if Global.getVar("with_pnp3_custom_leader") then
            local d = getObjectFromGUID(BaseGame.components.pnp3_leaders)
            if d then table.insert(custom_decks, d); table.insert(custom_names, "PnP#3") end
        end

        if #custom_decks > 0 then
            if Global.getVar("dont_use_base_and_pack_leaders") then
                -- Use the first custom deck as the leader deck: move it to the
                -- base leaders' position if available, then merge any others into it.
                local target = custom_decks[1]
                if base_leaders_pos then
                    target.setPosition({base_leaders_pos.x, base_leaders_pos.y, base_leaders_pos.z})
                    if base_leaders_rot then target.setRotation(base_leaders_rot) end
                elseif leader_deck and leader_deck.getPosition then
                    local p = leader_deck.getPosition()
                    target.setPosition({p.x, p.y, p.z})
                end
                for i = 2, #custom_decks do
                    pcall(function() target.putObject(custom_decks[i]) end)
                end
                leader_deck = target
                for i, name in ipairs(custom_names) do
                    if name == "Laurens" then
                        broadcastToAll("Including Celestial Leader Expansion by Laurens")
                    elseif name == "PnP#3" then
                        broadcastToAll("Including PnP#3 Leader Deck")
                    else
                        broadcastToAll("Including " .. name .. "'s custom leader deck")
                    end
                end
            else
                -- Merge selected custom decks into the base fate deck
                for i, d in ipairs(custom_decks) do
                    pcall(function() leader_deck.putObject(d) end)
                    if custom_names[i] == "Laurens" then
                        broadcastToAll("Including Celestial Leader Expansion by Laurens")
                    elseif custom_names[i] == "PnP#3" then
                        broadcastToAll("Including PnP#3 Leader Deck")
                    else
                        broadcastToAll("Including " .. custom_names[i] .. "'s leader deck")
                    end
                end
            end
        end

        leader_deck.randomize()
        Wait.time(function()
            leader_deck.deal(2)
        end, 1)


        local edifice_guid = Global.getVar("edifice_deck_GUID") or "becb7c"
        local edifice = getObjectFromGUID(edifice_guid)
        if edifice and edifice.setPosition then
            pcall(function()
                edifice.setPosition({2.37, 1.12, -0.29})
                if edifice.randomize then edifice.randomize() end
            end)
            LOG.INFO("Moved and shuffled edifice deck (GUID=" .. tostring(edifice_guid) .. ") for Lost Vaults setup")
        else
            LOG.INFO("Edifice deck not found for Lost Vaults (GUID=" .. tostring(edifice_guid) .. ")")
        end
        LOG.INFO("with_pnp2_lost_vaults enabled: randomized base court; skipping card draws")

        for i = 1, 2 do
            edifice.takeObject({
                position = {x = -62.36, y = 1.02, z = -38.22}
            })
        end
        -- Place 6 random lore cards and 6 random artifact cards on top of the
        -- edifice deck, using the same randomize/wait/take pattern used when
        -- dealing leaders. Artifact cards are moved alongside lore cards.
        if edifice and (lore_deck or artifact_deck) then
            pcall(function()
                if lore_deck and lore_deck.randomize then lore_deck.randomize() end
                if artifact_deck and artifact_deck.randomize then artifact_deck.randomize() end
                local ed_pos = edifice.getPosition and edifice.getPosition() or {x=0,y=1,z=0}

                -- Wait a frame like leader dealing, then take cards and place them into edifice
                Wait.time(function()
                    for i = 1, 6 do
                        -- take a lore card (if available)
                        if lore_deck and lore_deck.takeObject then
                            lore_deck.takeObject({
                                flip = false,
                                position = {ed_pos.x, ed_pos.y + 1 + (i * 0.02), ed_pos.z},
                                callback_function = function(card)
                                    Wait.frames(function()
                                        if card and not (card.isDestroyed and card.isDestroyed()) then
                                            pcall(function()
                                                if edifice.putObject then
                                                    edifice.putObject(card)
                                                else
                                                    local p = edifice.getPosition and edifice.getPosition() or ed_pos
                                                    card.setPositionSmooth({p.x, p.y + 1, p.z})
                                                end
                                            end)
                                        end
                                    end, 1)
                                end
                            })
                        end

                        -- take an artifact card (if available)
                        if artifact_deck and artifact_deck.takeObject then
                            artifact_deck.takeObject({
                                flip = false,
                                -- slight x offset so spawned objects don't collide visually
                                position = {ed_pos.x + 0.03, ed_pos.y + 1 + (i * 0.02), ed_pos.z},
                                callback_function = function(card)
                                    Wait.frames(function()
                                        if card and not (card.isDestroyed and card.isDestroyed()) then
                                            pcall(function()
                                                if edifice.putObject then
                                                    edifice.putObject(card)
                                                else
                                                    local p = edifice.getPosition and edifice.getPosition() or ed_pos
                                                    card.setPositionSmooth({p.x, p.y + 1, p.z})
                                                end
                                            end)
                                        end
                                    end, 1)
                                end
                            })
                        end
                    end

                    -- After a short delay, shuffle the edifice deck to mix the added cards.
                    Wait.time(function()
                        if edifice then
                            pcall(function()
                                if edifice.randomize then
                                    edifice.randomize()
                                elseif edifice.shuffle then
                                    edifice.shuffle()
                                end
                            end)
                            LOG.INFO("Placed 6 lore and 6 artifact cards on top of edifice and shuffled (Lost Vaults setup)")

                            -- After shuffling, take one card for each of two random planets
                            local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs") or {}
                            local planet_candidates = {}
                            for cluster = 1, 6 do
                                local entry = cluster_zone_guids[cluster]
                                if entry then
                                    for _, sys in ipairs({"a", "b", "c"}) do
                                        local sys_entry = entry[sys]
                                        if sys_entry and sys_entry["buildings"] and #sys_entry["buildings"] > 0 then
                                            local bguid = sys_entry["buildings"][1]
                                            local obj = getObjectFromGUID(bguid)
                                            if obj and obj.getPosition then
                                                table.insert(planet_candidates, {cluster = cluster, system = sys, pos = obj.getPosition(), building_guid = bguid})
                                            end
                                        end
                                    end
                                end
                            end

                            if #planet_candidates >= 2 and edifice.takeObject then
                                -- pick two distinct random indices
                                local function pick_two(n)
                                    local i = math.random(n)
                                    local j = math.random(n-1)
                                    if j >= i then j = j + 1 end
                                    return i, j
                                end
                                local i, j = pick_two(#planet_candidates)
                                local targets = {planet_candidates[i], planet_candidates[j]}
                                local remaining = {}
                                for idx, p in ipairs(planet_candidates) do
                                    if idx ~= i and idx ~= j then table.insert(remaining, p) end
                                end

                                local clusters_with_cards = {}
                                for _, entry in ipairs(targets) do
                                    local pos = entry.pos
                                    table.insert(clusters_with_cards, entry.cluster)
                                    pcall(function()
                                        edifice.takeObject({
                                            flip = true,
                                            position = {pos.x, pos.y + 1, pos.z},
                                            callback_function = function(card)
                                                Wait.frames(function()
                                                    if card and card.setPositionSmooth and pos then
                                                        card.setPositionSmooth({pos.x, pos.y + 0.5, pos.z})
                                                    end
                                                    -- If the script placed this card, also place a matching
                                                    -- Lost Vaults marker from the bag (if present).
                                                    -- marker placement handled centrally in Global.lua detection
                                                end, 1)
                                            end
                                        })
                                    end)
                                end
                                LOG.INFO("Placed 1 edifice card onto 2 random planets")

                                -- Move the existing initiative marker (by GUID) to a remaining
                                -- planet (do not spawn a new copy). Choose one remaining entry.
                                local initiative_cluster = nil
                                if #remaining > 0 then
                                    local target_entry = remaining[math.random(#remaining)]
                                    local target_pos = target_entry.pos
                                    initiative_cluster = target_entry.cluster
                                    pcall(function()
                                        local init_guid = BaseGame.components and BaseGame.components.core and BaseGame.components.core.initiative
                                            or Global.getVar("initiative_GUID")
                                        local init_obj = init_guid and getObjectFromGUID(init_guid)
                                        if init_obj and (init_obj.setPositionSmooth or init_obj.setPosition) then
                                            if init_obj.setPositionSmooth then
                                                init_obj.setPositionSmooth({target_pos.x, target_pos.y + 0.5, target_pos.z})
                                            else
                                                init_obj.setPosition({target_pos.x, target_pos.y + 0.5, target_pos.z})
                                            end

                                            -- Move the event and number dice to the die zone instead (a bit higher)
                                            local die_zone_guid = Global.getVar("die_zone_GUID") or "1b45bb"
                                            local die_zone = getObjectFromGUID(die_zone_guid)
                                            local die_x, die_y, die_z = nil, nil, nil
                                            if die_zone and die_zone.getPosition then
                                                local dz = die_zone.getPosition()
                                                die_x, die_y, die_z = dz.x - 2, dz.y + 1.2, dz.z
                                            else
                                                -- fallback to the planet target if die zone missing
                                                die_x, die_y, die_z = target_pos.x, target_pos.y + 1.2, target_pos.z
                                            end

                                            local event_die_guid = Global.getVar("event_die_GUID") or "684608"
                                            local number_die_guid = Global.getVar("number_die_GUID") or "d5e298"
                                            local event_die = getObjectFromGUID(event_die_guid)
                                            local number_die = getObjectFromGUID(number_die_guid)

                                            -- pcall(function()
                                            --     if event_die and event_die.setPositionSmooth then
                                            --         event_die.setPositionSmooth({die_x + 0.18, die_y, die_z})
                                            --     elseif event_die and event_die.setPosition then
                                            --         event_die.setPosition({die_x + 0.18, die_y, die_z})
                                            --     end
                                            -- end)
                                            pcall(function()
                                                if number_die and number_die.setPositionSmooth then
                                                    number_die.setPositionSmooth({die_x - 0.18, die_y, die_z})
                                                elseif number_die and number_die.setPosition then
                                                    number_die.setPosition({die_x - 0.18, die_y, die_z})
                                                end
                                            end)
                                            LOG.INFO("Moved initiative marker (" .. tostring(init_guid) .. ") and dice to die zone " .. tostring(die_zone_guid) .. " (cluster " .. tostring(initiative_cluster) .. ")")
                                        else
                                            LOG.INFO("Initiative marker not found or cannot be moved")
                                        end
                                    end)
                                else
                                    LOG.INFO("No remaining planet to place initiative marker")
                                end

                                if initiative_cluster then table.insert(clusters_with_cards, initiative_cluster) end

                                -- Now mark clusters out of play based on player count, excluding
                                -- clusters we placed cards or initiative on.
                                local players_count = #active_players
                                local clusters_to_remove
                                if players_count == 5 then
                                    clusters_to_remove = 0
                                elseif players_count >= 4 then
                                    clusters_to_remove = 1
                                else
                                    clusters_to_remove = 2
                                end
                                local candidates = {}
                                for cluster = 1, 6 do
                                    local skip = false
                                    for _, c in ipairs(clusters_with_cards) do
                                        if c == cluster then skip = true; break end
                                    end
                                    if not skip then table.insert(candidates, cluster) end
                                end

                                if #candidates >= clusters_to_remove then
                                    local chosen = {}
                                    while #chosen < clusters_to_remove do
                                        local idx = math.random(#candidates)
                                        table.insert(chosen, candidates[idx])
                                        table.remove(candidates, idx)
                                    end
                                    local fake_setup = { out_of_play_clusters = chosen }
                                    BaseGame.setupOutOfPlayClusters(fake_setup)
                                    LOG.INFO("Marked clusters out of play: " .. table.concat(chosen, ", "))
                                    -- After marking clusters out of play, move Vault cards per request.
                                    -- First move the lost vaults rules object into position.
                                    pcall(function()
                                        local rules_guid = Global.getVar("lost_vaults_rules_GUID") or "952d62"
                                        local ok, rules_obj = pcall(function() return getObjectFromGUID(rules_guid) end)
                                        if ok and rules_obj then
                                            pcall(function()
                                                if rules_obj.setPositionSmooth then
                                                    rules_obj.setPositionSmooth({36.48, 0.96, -0.20})
                                                elseif rules_obj.setPosition then
                                                    rules_obj.setPosition({36.48, 0.96, -0.20})
                                                end
                                            end)
                                        end
                                    end)
                                    pcall(function()
                                        local target_v1 = {22.00, 0.97, 3.99}
                                        local moved_v1 = 0
                                        local bag_guid = Global.getVar("lost_vaults_marker_bag_GUID") or "7f3e2f"
                                        local bag = getObjectFromGUID(bag_guid)
                                        if bag and bag.getObjects then
                                            local okc, contents = pcall(function() return bag.getObjects() end)
                                            if okc and contents then
                                                for _, item in ipairs(contents) do
                                                    if moved_v1 >= 2 then break end
                                                    if item and item.name and item.name == "Vault 1" and item.guid then
                                                        moved_v1 = moved_v1 + 1
                                                        pcall(function()
                                                            if bag.takeObject then
                                                                local place_x = target_v1[1] + ((moved_v1 - 1) * 0.4)
                                                                local place_z = target_v1[3] + ((moved_v1 - 1) * 0.2)
                                                                bag.takeObject({
                                                                    guid = item.guid,
                                                                    position = {place_x, target_v1[2] + 0.5, place_z},
                                                                    callback_function = function(taken)
                                                                        Wait.frames(function()
                                                                            if taken then
                                                                                pcall(function()
                                                                                    if taken.setRotation then taken.setRotation({0, 180, 0}) end
                                                                                end)
                                                                                if taken.setPositionSmooth then
                                                                                    taken.setPositionSmooth({place_x, target_v1[2], place_z})
                                                                                elseif taken.setPosition then
                                                                                    taken.setPosition({place_x, target_v1[2], place_z})
                                                                                end
                                                                            end
                                                                        end, 1)
                                                                    end
                                                                })
                                                            end
                                                        end)
                                                    end
                                                end
                                            end
                                        else
                                            LOG.INFO("Vault 1 bag not found; could not move Vault 1 cards")
                                        end
                                        LOG.INFO("Moved " .. tostring(moved_v1) .. " Vault 1 card(s) to {22.00,0.97,3.99}")

                                        -- Move 2 cards named Vault 2 from the bag named "Vault 2"
                                        local target_v2 = {22.00, 0.97, 1.58}
                                        local moved_v2 = 0
                                        local vault2_bag_guid = Global.getVar("lost_vaults_marker_bag_GUID") or "7f3e2f"
                                        local vault2_bag = getObjectFromGUID(vault2_bag_guid)
                                        if vault2_bag and vault2_bag.getObjects then
                                            local okc, contents = pcall(function() return vault2_bag.getObjects() end)
                                            if okc and contents then
                                                for _, item in ipairs(contents) do
                                                    if moved_v2 >= 2 then break end
                                                    if item and item.name and item.name == "Vault 2" and item.guid then
                                                        moved_v2 = moved_v2 + 1
                                                        pcall(function()
                                                            if vault2_bag.takeObject then
                                                                local place_x2 = target_v2[1] + ((moved_v2 - 1) * 0.4)
                                                                local place_z2 = target_v2[3] + ((moved_v2 - 1) * 0.2)
                                                                vault2_bag.takeObject({
                                                                    guid = item.guid,
                                                                    position = {place_x2, target_v2[2] + 0.5, place_z2},
                                                                    callback_function = function(taken)
                                                                        Wait.frames(function()
                                                                            if taken then
                                                                                pcall(function()
                                                                                    if taken.setRotation then taken.setRotation({0, 180, 0}) end
                                                                                end)
                                                                                if taken.setPositionSmooth then
                                                                                    taken.setPositionSmooth({place_x2, target_v2[2], place_z2})
                                                                                elseif taken.setPosition then
                                                                                    taken.setPosition({place_x2, target_v2[2], place_z2})
                                                                                end
                                                                            end
                                                                        end, 1)
                                                                    end
                                                                })
                                                            end
                                                        end)
                                                    end
                                                end
                                            end
                                        else
                                            LOG.INFO("Vault 2 bag not found; could not move Vault 2 cards")
                                        end
                                        LOG.INFO("Moved " .. tostring(moved_v2) .. " Vault 2 card(s) to {22.00,0.97,1.58}")
                                        pcall(function()
                                            broadcastToAll("Continue at step 5 of the Lost Vaults Setup: Choose leader and establish home.", Color.Blue)
                                        end)
                                    end)
                                else
                                    LOG.INFO("Not enough available clusters to mark out of play")
                                end
                            else
                                LOG.INFO("Not enough planet positions or edifice.takeObject missing; cannot place planet cards")
                            end
                        end
                    end, 2)
                end, 1)
            end)
        else
            LOG.INFO("Could not place lore/artifact cards on edifice (missing objects)")
        end
    end

    if #active_players >= 5 then
        BaseGame.adjust_action_deck_for_5p()
    end

    Turns.type = 2
    Turns.order = active_player_colors
    Turns.turn_color = active_players[1].color

    return true
end

function BaseGame.setup_leaders()
    LOG.INFO("Setup Leaders")

    local active_players = Global.getTable("active_players")

    -- check if leader is in player area
    local leader_count = 0
    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    local placed_leaders = {}
    for i, player in ipairs(active_players) do
        placed_leaders[i] = nil
        local player_zones = getObjectFromGUID(
                                 player_pieces_guids[player.color]["area_zone"]).getObjects()

        for _, obj in pairs(player_zones) do
            if (obj.hasTag("Leader")) then
                leader_count = leader_count + 1
                placed_leaders[i] = obj
                break
            end
        end
    end
    if leader_count < #active_players then
        local msg = "Setup Leaders: " .. tostring(leader_count) .. " placed of " .. tostring(#active_players) .. " expected"
        LOG.DEBUG(msg)
        broadcastToAll(msg, {r=1, g=0.6, b=0.2})
        return false
    end

    -- Award any immediate effects for leaders placed in player areas
    for i, player in ipairs(active_players) do
        local leader_obj = placed_leaders[i]
        if leader_obj and leader_obj.getName then
            local name = leader_obj.getName()
            local guid = leader_obj.getGUID and leader_obj.getGUID() or leader_obj.guid
            local display_name = player.color
            local info = "Player " .. tostring(display_name) .. " placed leader: " .. tostring(name) .. " (" .. tostring(guid) .. ")"
            LOG.DEBUG(info)
           -- broadcastToAll(info, {r=0.9, g=0.9, b=0.5})
            -- if name == "Seer" then
            --     local dbg = "Awarding 1 Fuel to " .. tostring(display_name) .. " for Seer"
            --     LOG.DEBUG(dbg)
            --     broadcastToAll(dbg, {r=0.8, g=0.58, b=0.27})
            --     local player_proxy = ArcsPlayer
            --     player_proxy.color = player.color
            --     player_proxy:take_resource("Fuel", 3)
            -- end
        end
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

    local use_scavengers = Global.getVar("use_scavengers_scouts_deck")
    local base_court_guid
    if use_scavengers then
        base_court_guid = Global.getVar("scavengers_scouts_deck_GUID") or BaseGame.components.base_exclusive.scavengers_scouts_deck or Global.getVar("base_court_deck_GUID")
    else
        base_court_guid = Global.getVar("base_court_deck_GUID")
    end

    local base_court = getObjectFromGUID(base_court_guid)
    if not base_court then
        broadcastToAll("Warning: court deck object not found (using default).", {r=1,g=0.5,b=0})
        base_court = getObjectFromGUID(Global.getVar("base_court_deck_GUID"))
        if not base_court then return end
    end

    base_court.setPosition(court_zone_pos)
    base_court.setRotation({0, 270, 180})

    Wait.time(function()
        local qty = (player_count == 2 and 3 or 4)

        -- Always shuffle/randomize the base court deck after placing it
        base_court.randomize()

        -- If Lost Vaults (PnP#2) is enabled, do not move or flip any cards
        -- from the base court during setup; leave the deck in place.
        if Global.getVar("with_pnp2_lost_vaults") then
            -- Move the edifice deck to the requested position and shuffle it
            return
        end

        local court_deck_pos = base_court.getPosition()
        court_deck_pos_z = court_deck_pos.z + 0.35

        for i = 1, qty do
            base_court.takeObject({
                flip = true,
                position = {
                    court_deck_pos.x, court_deck_pos.y,
                    court_deck_pos_z - (i * -2.41)
                }
            })
        end
    end, 1)
end

-- I
function BaseGame.chooseSetupCard(player_count)
    LOG.INFO("Choose Setup Card")

    local player_colors = {"White", "Yellow", "Teal", "Red", "Pink"}

    local two_player_setup_cards = {
        {
            name = "FRONTIERS",
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
            name = "CORE CONFLICT",
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

    local five_player_setup_cards = {
        {
            name = "FRONTIERS",
            guid = Global.getVar("frontiers_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }, {
            name = "EMPIRES",
            guid = Global.getVar("empires_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }, {
            name = "MIX UP 1",
            guid = Global.getVar("mix_up_1_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }, {
            name = "MIX UP 2",
            guid = Global.getVar("mix_up_2_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        },{
            name = "EXTENSION",
            guid = Global.getVar("extension_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }
    }

    local setup_cards = {
        two_player_setup_cards, three_player_setup_cards,
        four_player_setup_cards, five_player_setup_cards
    }

    -- Allow an external selection to override randomness. Global var
    -- 'setup_choice_index' stores 0 for random or 1..N to pick a specific
    -- option. 'setup_choice_player_count' keeps the player count the
    -- selection was made for.
    local options = BaseGame.getSetupOptions(player_count) or setup_cards[player_count - 1]
    local N = #options
    local choice_index = Global.getVar("setup_choice_index") or 0
    local choice_pcount = Global.getVar("setup_choice_player_count")
    local chosen_setup_card
    if choice_index and choice_index >= 1 and choice_pcount == player_count and choice_index <= N then
        chosen_setup_card = options[choice_index]
    else
        chosen_setup_card = options[math.random(N)]
    end

    -- If a chosen 5P setup card has no GUID configured, fall back to a 4P card
    if player_count == 5 and not chosen_setup_card.guid then
        LOG.WARN("5P setup card '" .. tostring(chosen_setup_card.name) .. "' has no GUID; falling back to a 4P setup card")
        chosen_setup_card = four_player_setup_cards[math.random(#four_player_setup_cards)]
        chosen_setup_card.out_of_play_clusters = {}
    end

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

            object.setPosition({object.getPosition().x, 0.93, object.getPosition().z})
        end
    end

end

function BaseGame.setupOutOfPlayForCustom()
    local oop_components = Global.getTable("oop_components")
    
    local bag = spawnObject({
        type = "Bag",
        position = {-52.7995567, 0.7801895, -24.3295612},
        sound = false
    })
    bag.setName("Out of Play Tokens")
    bag.setColorTint({r=1, g=0.7472, b=0})

    local function spawnAndBagToken(tokenData, shouldTagAsGate)
        local token = spawnObject({
            type = "Custom_Token",
            position = bag.getPosition() + Vector(0, 2, 0),
            rotation = tokenData.rot,
            scale = tokenData.scale,
            sound = false
        })
        token.setCustomObject({image = tokenData.img})
        if shouldTagAsGate then token.addTag("oop_gate") end
        Wait.frames(function() bag.putObject(token) end, 1)
    end

    Wait.frames(function()
        for _, cluster in ipairs(oop_components) do
            spawnAndBagToken(cluster.Sector, false)
            spawnAndBagToken(cluster.Gate, true)
        end
    end, 1)
    
    return bag
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

    -- Optionally remove the base and expansion leader objects entirely.
    -- Capture their position/rotation first so we can move the custom deck
    -- to that location even after deletion.
    local base_leaders_pos, base_leaders_rot
    if (Global.getVar("dont_use_base_and_pack_leaders")) then
        local base_leaders_obj = getObjectFromGUID(BaseGame.components.leaders)
        if (base_leaders_obj) then
            base_leaders_pos = base_leaders_obj.getPosition()
            base_leaders_rot = base_leaders_obj.getRotation()
            destroyObject(base_leaders_obj)
            broadcastToAll("Removed base leaders from the table")
        end
        local expansion_leaders_obj = getObjectFromGUID(BaseGame.components.leaders_expansion)
        if (expansion_leaders_obj) then
            destroyObject(expansion_leaders_obj)
            broadcastToAll("Removed expansion leaders from the table")
        end
    end

    -- Optionally include custom leader decks (Laurens, PnP#3, etc.)
    local custom_decks = {}
    local custom_names = {}
    if Global.getVar("with_laurens_custom_leader") then
        local d = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
        if d then table.insert(custom_decks, d); table.insert(custom_names, "Laurens") end
    end
    if Global.getVar("with_pnp3_custom_leader") then
        local d = getObjectFromGUID(BaseGame.components.pnp3_leaders)
        if d then table.insert(custom_decks, d); table.insert(custom_names, "PnP#3") end
    end

    if #custom_decks > 0 then
        if Global.getVar("dont_use_base_and_pack_leaders") then
            -- Move first custom deck to base leaders position (if recorded),
            -- then put all other custom decks into that deck so they are shuffled together.
            local target = custom_decks[1]
            if base_leaders_pos then
                target.setPosition({base_leaders_pos.x, base_leaders_pos.y, base_leaders_pos.z})
                if base_leaders_rot then target.setRotation(base_leaders_rot) end
            else
                if leader_deck and leader_deck.getPosition then
                    local p = leader_deck.getPosition()
                    target.setPosition({p.x, p.y, p.z})
                end
            end
            for i = 2, #custom_decks do
                leader_deck = target
                leader_deck.putObject(custom_decks[i])
            end
            leader_deck = target
            for i, name in ipairs(custom_names) do
                if name == "Laurens" then
                    broadcastToAll("Including Celestial Leader Expansion by Laurens")
                elseif name == "PnP#3" then
                    broadcastToAll("Including PnP#3 Leader Deck")
                else
                    broadcastToAll("Including " .. name .. "'s custom leader deck")
                end
            end
        else
            -- Merge selected custom decks into the base fate deck
            for i, d in ipairs(custom_decks) do
                leader_deck.putObject(d)
                if custom_names[i] == "Laurens" then
                    broadcastToAll("Including Celestial Leader Expansion by Laurens")
                elseif custom_names[i] == "PnP#3" then
                    broadcastToAll("Including PnP#3 Leader Deck")
                else
                    broadcastToAll("Including " .. custom_names[i] .. "'s custom leader deck")
                end
            end
        end
    end

    leader_deck.randomize()
    lore_deck.randomize()

    -- If Laurens' custom deck exists but is NOT selected for inclusion,
    -- move it to the left of the starting leader deck so it's visible but not used.
    -- If custom decks exist but are NOT selected for inclusion, move them aside
    -- local laurens_obj = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
    -- if laurens_obj and not Global.getVar("with_laurens_custom_leader") then
    --     if leader_deck and leader_deck.getPosition then
    --         local p = leader_deck.getPosition()
    --         local left_x = p.x - 3.2
    --         laurens_obj.setPosition({left_x, p.y, p.z})
    --     end
    -- end
    -- local pnp3_obj = getObjectFromGUID(BaseGame.components.pnp3_leaders)
    -- if pnp3_obj and not Global.getVar("with_pnp3_custom_leader") then
    --     if leader_deck and leader_deck.getPosition then
    --         local p = leader_deck.getPosition()
    --         local left_x = p.x - 3.2
    --         pnp3_obj.setPosition({left_x, p.y, p.z})
    --     end
    -- end

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

    local leader_qty = Global.getVar("leader_draft_count")
    local lore_qty = Global.getVar("lore_draft_count")
    if not leader_qty or not lore_qty then
        local ordered = Global.call("getOrderedPlayers") or {}
        local n = 0
        local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
        for _, p in ipairs(ordered) do
            for _, c in ipairs(colors) do
                if p.color == c then
                    n = n + 1
                    break
                end
            end
        end
        local default_count
        if n >= 1 then
            default_count = n + 1
        else
            default_count = (Global.getVar("debug_player_count") or 3) + 1
        end
        leader_qty = leader_qty or default_count
        lore_qty = lore_qty or default_count
    end

    -- Place leaders in rows of 5. If >5, wrap to a row above (increasing z).
    local cols = 5
    local spacing = 3.2
    -- shift all cards one column to the right (so card 1 appears where card 2 was)
    local start_x_offset = spacing
    -- increase vertical separation between rows
    local row_spacing_leaders = 5.5
    local row_spacing_lore = 3.3
    for i = 1, leader_qty do
        local idx = i - 1
        local row = math.floor(idx / cols)
        local col = idx % cols
        local pos = {leader_pos.x + (col * spacing) + start_x_offset, leader_pos.y, leader_pos.z + (row * row_spacing_leaders)}
        leader_deck.takeObject({
            flip = true,
            position = pos,
            callback_function = function(spawnedObject)
                Wait.frames(function()
                    if not spawnedObject or spawnedObject.isDestroyed and spawnedObject.isDestroyed() then return end
                    local card_name = nil
                    if spawnedObject.getName then
                        card_name = spawnedObject.getName()
                    end
                    local card_guid = nil
                    if spawnedObject.getGUID then
                        card_guid = spawnedObject.getGUID()
                    elseif spawnedObject.guid then
                        card_guid = spawnedObject.guid
                    end

                    -- Explicit checks for special leaders by name or GUID.
                    -- Add or duplicate blocks here for each leader you want to handle.

                    -- Example: Seer
                    if (card_name and card_name == "Seer") or (card_guid and card_guid == "SEER_GUID_PLACEHOLDER") then
                        local match_msg = "Seer drawn while dealing: " .. tostring(card_name) .. " (" .. tostring(card_guid) .. ")"
                        LOG.DEBUG(match_msg)
                       -- broadcastToAll(match_msg, {r=0.2, g=0.9, b=0.2})
                        pcall(function() Global.call("on_special_leader_drawn", {card = spawnedObject, name = card_name, guid = card_guid, leader = "Seer"}) end)
                    end

                    -- Add more if-blocks above as needed for other leaders.
                        -- Explicit card stacks for specific leaders
                        local function placeCardsOnTop(guids)
                            local sd = getObjectFromGUID(BaseGame.components.pnp3_leaders_extra) or lore_deck
                            if not sd or not sd.takeObject then return end
                            local base_pos = spawnedObject.getPosition()
                            -- Place GUIDs in reverse order so the last GUID in the list
                            -- becomes the bottom card and the first becomes the top card.
                            local n = #guids
                            for i = n, 1, -1 do
                                local g = guids[i]
                                local stack_index = n - i + 1 -- 1 = bottom, increases upward
                                -- First try to find the object directly on the table
                                local obj = getObjectFromGUID(g)
                                if obj and not (obj.isDestroyed and obj.isDestroyed()) then
                                    if spawnedObject and spawnedObject.getPosition then
                                        local top_pos = spawnedObject.getPosition()
                                        obj.setPositionSmooth({top_pos.x, top_pos.y + 0.6 + ((stack_index - 1) * 0.2), top_pos.z})
                                        if obj.getRotation and spawnedObject.getRotation then
                                            obj.setRotation(spawnedObject.getRotation())
                                        end
                                    end
                                else
                                    -- Otherwise attempt to take the specific GUID from the source deck.
                                    if sd and sd.takeObject then
                                        pcall(function()
                                            sd.takeObject({
                                                guid = g,
                                                flip = true,
                                                position = {base_pos.x, base_pos.y + 1 + (stack_index * 0.2), base_pos.z},
                                                callback_function = function(card)
                                                    Wait.frames(function()
                                                        if not card or card.isDestroyed and card.isDestroyed() then return end
                                                        if spawnedObject and spawnedObject.getPosition then
                                                            local top_pos = spawnedObject.getPosition()
                                                            card.setPositionSmooth({top_pos.x, top_pos.y + 0.6 + ((stack_index - 1) * 0.2), top_pos.z})
                                                            card.setRotation(spawnedObject.getRotation())
                                                        end
                                                    end, 1)
                                                end
                                            })
                                        end)
                                    end
                                end
                            end
                        end

                        local name_lower = card_name and string.lower(card_name) or nil

                        -- God's Hand
                        if (name_lower and name_lower == string.lower("God's Hand")) or (card_guid and (card_guid == "fe9e2d" or card_guid == "8a8534" or card_guid == "28334e" or card_guid == "db3626" or card_guid == "d28723" or card_guid == "add17e" or card_guid == "e692cf" or card_guid == "ee34d8")) then
                            placeCardsOnTop({"fe9e2d", "8a8534", "28334e", "db3626", "d28723", "add17e", "e692cf", "ee34d8"})
                        end

                        -- Firebrand
                        if (name_lower and name_lower == string.lower("Firebrand")) or (card_guid and card_guid == "69202b") then
                            placeCardsOnTop({"69202b"})
                        end

                        -- Ancient Wraith
                        if (name_lower and name_lower == string.lower("Ancient Wraith")) or (card_guid and card_guid == "68b727") then
                            placeCardsOnTop({"68b727"})
                        end

                        -- Paladin
                        if (name_lower and name_lower == string.lower("paladin")) or (card_guid and card_guid == "d72ac5") then
                            placeCardsOnTop({"d72ac5"})
                            -- Also take card 123db0 from bag 1239bb and place it on top of Paladin
                            pcall(function()
                                local bag = getObjectFromGUID("1239bb")
                                if bag and bag.takeObject and spawnedObject and spawnedObject.getPosition then
                                    local pal_pos = spawnedObject.getPosition()
                                    bag.takeObject({
                                        guid = "123db0",
                                        flip = true,
                                        position = {pal_pos.x, pal_pos.y + 1, pal_pos.z},
                                        callback_function = function(card)
                                            Wait.frames(function()
                                                if not card or card.isDestroyed and card.isDestroyed() then return end
                                                if spawnedObject and spawnedObject.getPosition then
                                                    local top_pos = spawnedObject.getPosition()
                                                    card.setPositionSmooth({top_pos.x, top_pos.y + 0.6, top_pos.z})
                                                    if card.getRotation and spawnedObject.getRotation then
                                                        card.setRotation(spawnedObject.getRotation())
                                                    end
                                                end
                                            end, 1)
                                        end
                                    })
                                end
                            end)
                        end

                        -- Profiteer
                        if (name_lower and name_lower == string.lower("Profiteer")) or (card_guid and (card_guid == "ddcb42" or card_guid == "16d945" or card_guid == "2762fa" or card_guid == "cfaceb")) then
                            placeCardsOnTop({"ddcb42", "2762fa", "16d945", "cfaceb"})
                        end
                end, 1)
            end
        })
    end

    -- Place lores in rows of 5. If >5, wrap to a row below (decreasing z).
    for i = 1, lore_qty do
        local idx = i - 1
        local row = math.floor(idx / cols)
        local col = idx % cols
        local pos = {lore_pos.x + (col * spacing) + start_x_offset, lore_pos.y, lore_pos.z - (row * row_spacing_lore)}
        lore_deck.takeObject({
            flip = true,
            position = pos
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
        local leader_ref = player_leaders[player_number]
        local leader_name = leader_ref
        -- If the stored value is a GUID for the leader object, resolve its name
        if type(leader_ref) == "string" then
            local leader_obj = getObjectFromGUID(leader_ref)
            if leader_obj and leader_obj.getName then
                leader_name = leader_obj.getName()
            end
        end
        local starting_pieces = Global.getVar("starting_pieces")
        local pieces = nil
        if starting_pieces then
            pieces = starting_pieces[leader_name] or starting_pieces[leader_ref] or starting_pieces["Default"]
        end
        if not pieces then
            LOG.DEBUG("No starting_pieces entry for leader: " .. tostring(leader_name) .. " (or GUID: " .. tostring(leader_ref) .. "). Using Default if available.")
            pieces = starting_pieces and starting_pieces["Default"] or {}
        end

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

        -- If the leader defines no starting resources, do not give any.
        if starting_resources then
            -- Allow a single resource string or a list of resources
            if type(starting_resources) == "string" then
                starting_resources = { starting_resources }
            end

            if type(starting_resources) == "table" and #starting_resources > 0 then
                LOG.DEBUG("starting_resource: " .. tostring(starting_resources[1]))
                player:take_resource(starting_resources[1], 1)
                if starting_resources[2] then
                    player:take_resource(starting_resources[2], 2)
                end
            end
        end

    end
end

function BaseGame.miniatures_visibility(show)
    local DISPLAY_HEIGHT = 7
    
    local function move_object(obj, shouldRaise)
        if obj and not obj.isDestroyed() then
            local pos = obj.getPosition()
            local newY = pos.y + (shouldRaise and DISPLAY_HEIGHT or -DISPLAY_HEIGHT)
            local newPos = {pos.x, newY, pos.z}
            obj.setPosition(newPos)
            obj.setLock(not shouldRaise)  -- Only lock when hiding (not showing) the object
        end
    end

    local miniatures = Global.getVar("setup_miniatures_GUIDs")
    if miniatures then
        for _, guid in pairs(miniatures) do
            local obj = getObjectFromGUID(guid)
            move_object(obj, show)
        end
    end

    local meeples = Global.getVar("setup_meeples_GUIDs")
    if meeples then
        for _, guid in pairs(meeples) do
            local obj = getObjectFromGUID(guid)
            move_object(obj, not show)
        end
    end
end

function BaseGame.destroy_grey_setup_menu_objects()
    local grey_miniatures = Global.getVar("setup_miniatures_GUIDs")
    local grey_meeples = Global.getVar("setup_meeples_GUIDs")
    local grey_unchanged_meeples = Global.getVar("setup_unchanged_meeples_GUIDs")
    local function destroy_objects(guid_table)
        if guid_table then
            for _, guid in pairs(guid_table) do
                local obj = getObjectFromGUID(guid)
                if obj then obj.destroy() end
            end
        end
    end

    destroy_objects(grey_miniatures)
    destroy_objects(grey_meeples)
    destroy_objects(grey_unchanged_meeples)
end

function BaseGame.destroy_unused_miniature_supplies()
    local player_colors = {"White", "Red", "Yellow", "Pink", "Teal"}
    for _, color in ipairs(player_colors) do
        local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
        local ship_bag = getObjectFromGUID(player_pieces_guids[color]["mini_ships"])
        if ship_bag then
            ship_bag.destroy()
        end
        -- Also destroy miniature agent supplies if present
        local agent_bag = getObjectFromGUID(player_pieces_guids[color]["mini_agents"])
        if agent_bag then
            agent_bag.destroy()
        end
    end
    local mini_imperial_ships_bag = getObjectFromGUID(Global.getVar("mini_imperial_ships_GUID"))
    if mini_imperial_ships_bag then
        mini_imperial_ships_bag.destroy()
    end
    local mini_flagships = getObjectFromGUID(Global.getVar("mini_flagships_GUID"))
    if mini_flagships then
        mini_flagships.destroy()
    end
end

function BaseGame.upgrade_to_miniatures(active_players)
    local function replace_piece_bag(regular_guid, mini_guid, update_global)
        local regular_bag = getObjectFromGUID(regular_guid)
        if not regular_bag then return end
        
        local original_pos = regular_bag.getPosition()
        regular_bag.destroy()
        
        local mini_bag = getObjectFromGUID(mini_guid)
        if mini_bag then
            mini_bag.setPosition(original_pos)
        end
        
        if update_global then
            Global.setVar(update_global, mini_guid)
        end
    end

    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    local players = active_players or Global.getVar("active_players") or {}
    for _, player in ipairs(players) do
        local pieces = player_pieces_guids[player.color]
        if pieces then
            replace_piece_bag(pieces["ships"], pieces["mini_ships"])
            replace_piece_bag(pieces["agents"], pieces["mini_agents"])
            pieces["ships"] = pieces["mini_ships"]
            pieces["agents"] = pieces["mini_agents"]
        end
    end

    replace_piece_bag(
        Global.getVar("imperial_ships_GUID"),
        Global.getVar("mini_imperial_ships_GUID"),
        "imperial_ships_GUID"
    )

    replace_piece_bag(
        Global.getVar("flagships_GUID"),
        Global.getVar("mini_flagships_GUID")
    )
end

function BaseGame.setup_or_destroy_miniatures(with_miniatures, active_players)
    BaseGame.destroy_grey_setup_menu_objects()
    if with_miniatures then
        BaseGame.upgrade_to_miniatures(active_players)
    else
        BaseGame.destroy_unused_miniature_supplies()
    end
end


return BaseGame
