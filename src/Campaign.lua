local LOG = require("src/LOG")

local Campaign = {
    guids = {
        -- A Plots
        a_plots = "0ac7d1",
        steward = "111666",
        magnate = "77dbd5",
        caretaker = "7d2e2f",
        partisan = "ffca5f",
        advocate = "0a2f8b",
        founder = "e60ae0",
        admiral = "1c96a7",
        believer = "132ec8",
        -- B Plots
        b_plots = "34808c",
        pathfinder = "2a11a7",
        hegemon = "958e7e",
        planet_breaker = "c2d3f6",
        pirate = "1cd72e",
        blight_speaker = "027b8d",
        pacifist = "1c35fe",
        peacemaker = "6a4456",
        warden = "ac3550",
        -- C Plots
        c_plots = "284e7b",
        overlord = "e0c9fa",
        survivalist = "42e8ad",
        redeemer = "2868af",
        guardian = "1239bb",
        naturalist = "e417c1",
        gate_wraith = "364937",
        conspirator = "3747fe",
        judge = "6dc4a9",

        event_die = "684608",
        number_die = "d5e298",
        chapter_card = "4d34d7",

        first_regent = "e9b0f4",
        book_of_law = "f0362b",
        in_session = "89ddf3",
        guild_envoys_depart = "ba6fc8",
        govern_edicts = "df60d0",
        regent_cards = "9c8d55",

        free_starports = "c79cb8",
        free_cities = "80742e",
        imperial_ships = "beb54d",
        blight = "ff61a8",

        court = "fb55bf",
        event_cards = "ad423d",
        flagships = "ea53d9",
        rules = "f1dd49",
        intermission_help = "b25b55",
        empire_help = "dad146"

    }
}

local BaseGame = require("src/BaseGame")
local Counters = require("src/Counters")
local supplies = require("src/Supplies")
local action_cards = require("src/ActionCards")
local resource = require("src/Resource")
local merchant = require("src/Merchant")

function Campaign.components_visibility(is_visible)
    local visibility = is_visible and {} or
                           {"Red", "White", "Yellow", "Teal", "Black",
                            "Grey"}

    for _, id in pairs(Campaign.guids) do
        local obj = getObjectFromGUID(id)
        obj.setInvisibleTo(visibility)
    end
end

function Campaign.setup(with_leaders, with_ll_expansion)

    local active_players = Global.call("getOrderedPlayers")
    if (#active_players < 2 or #active_players > 4) then
        return false
    end

    Campaign.components_visibility(true)
    BaseGame.components_visibility({
        is_visible = true,
        is_campaign = true,
        is_4p = #active_players == 4,
        leaders_and_lore = with_leaders,
        leaders_and_lore_expansion = with_ll_expansion
    })

    -- B
    local initiative = require("src/InitiativeMarker")
    initiative.take(active_players[1].color)

    -- C, D, E
    action_cards.setup_deck(#active_players)
    action_cards.setup_events(#active_players)

    Campaign.setupChapterTrack()
    LOG.INFO("setupChapterTrack Complete")
    Campaign.setupCampaignGuildCards(#active_players)
    LOG.INFO("setupCampaignGuildCards Complete")
    Campaign.setupImperialCouncil()
    LOG.INFO("setupImperialCouncil Complete")
    Campaign.setupImperialRules(#active_players)
    LOG.INFO("setupImperialRules Complete")
    Campaign.setupClusters(#active_players)
    LOG.INFO("setupClusters Complete")

    for _, p in pairs(active_players) do
        ArcsPlayer.setup(p, true)
    end
    Counters.setup()

    Wait.time(function()
        Campaign.dealPlayerFates()
    end, 5)

    local reach_board = getObjectFromGUID(Global.getVar(
        "reach_board_GUID"))
    reach_board.setDescription("in progress")
    return true
end

-- G
function Campaign.setupChapterTrack()

    local chapter_track = getObjectFromGUID(Global.getVar(
        "chapter_track_GUID"))
    local chapter_zone = getObjectFromGUID(Global.getVar(
        "chapter_zone_GUID"))
    local chapter_zone_pos = chapter_zone.getPosition()

    chapter_track.setPosition(chapter_zone_pos)

    local pawn = getObjectFromGUID(Global.getVar("chapter_pawn_GUID"))
    pawn.setPositionSmooth({16.79, 1.8, -8.23})

end

-- I,J
function Campaign.setupCampaignGuildCards(player_count)
    local court_zone = getObjectFromGUID(Global.getVar(
        "court_deck_zone_GUID"))
    local court_zone_pos = court_zone.getPosition()
    local campaign_court = getObjectFromGUID(Global.getVar(
        "campaign_court_GUID"))

    campaign_court.setPosition(court_zone_pos)
    campaign_court.setRotation({0, 270, 180})

    Wait.time(function()
        -- deal guild cards
        Global.call("dealGuildCards", player_count == 2 and 3 or 4)

        -- add lore cards
        local lore_deck =
            getObjectFromGUID(Global.getVar("lore_GUID"))

        if (Global.getVar("with_more_to_explore")) then
            broadcastToAll("Playing with the Leaders & Lore Expansion")

            local mte_lore = getObjectFromGUID(Global.getVar(
                "more_to_explore_lore_GUID"))

            lore_deck.putObject(mte_lore)
        end

        lore_deck.randomize()

        for i = 1, player_count, 1 do
            lore_deck.takeObject({
                position = {court_zone_pos.x, court_zone_pos.y + 1,
                            court_zone_pos.z},
                rotation = {0, 270, 180},
                flip = false,
                smooth = false
            })
        end

        Wait.time(function()
            campaign_court.randomize()
        end, 1)

    end, 1)
end

-- K
function Campaign.setupImperialCouncil()

    local imperial_council = getObjectFromGUID(Global.getVar(
        "imperial_council_GUID"))
    imperial_council.setPositionSmooth({22, 1, -8.40})
    imperial_council.setRotation({0, 270, 0})

end

-- L,M
function Campaign.setupImperialRules(player_count)

    local laws = getObjectFromGUID(Global.getVar("laws_GUID"))

    laws.setPositionSmooth({34, 1, 5})
    laws.setRotation({0, 270, 0})

    local next_law_pos_z = 5 - 2.4
    local next_law_pos = {
        x = 34,
        y = 1,
        z = next_law_pos_z
    }

    if (player_count == 2) then
        local guild_envoys_depart =
            getObjectFromGUID(Global.getVar("guild_envoys_depart_GUID"))
        guild_envoys_depart.setRotation({0, 270, 0})
        guild_envoys_depart.setPositionSmooth(next_law_pos)
        next_law_pos_z = next_law_pos_z - 2.4
        next_law_pos.z = next_law_pos_z
    end

    local govern = getObjectFromGUID(Global.getVar("govern_GUID"))
    govern.setRotation({0, 270, 0})
    govern.setPositionSmooth(next_law_pos)
    next_law_pos_z = next_law_pos_z - 2.4
    next_law_pos.z = next_law_pos_z

    govern.randomize()

end

-- N,O,P
function Campaign.setupClusters(player_count)
    -- Roll Dice
    local number_die = getObjectFromGUID(Global.getVar(
        "number_die_GUID"))
    local die_zone_pos = getObjectFromGUID(Global.getVar(
        "die_zone_GUID")).getPosition()
    number_die.setPosition({
        x = die_zone_pos.x - 1.2,
        y = die_zone_pos.y,
        z = die_zone_pos.z
    })

    local event_die = getObjectFromGUID(
        Global.getVar("event_die_GUID"))
    local die_zone_pos = getObjectFromGUID(Global.getVar(
        "die_zone_GUID")).getPosition()
    event_die.setPosition({
        x = die_zone_pos.x + 1.2,
        y = die_zone_pos.y,
        z = die_zone_pos.z
    })

    number_die.randomize()
    event_die.randomize()

    -- Imperial Cluster
    local is_imperial_cluster = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false
    }

    Wait.condition(function() -- Executed after our condition is met
        local imperial_clusters = {}
        local cluster_zones = Global.getVar("cluster_zone_GUIDs")
        local system_ship_zone

        if number_die.isDestroyed() or event_die.isDestroyed() then
            LOG.ERROR("Die was destroyed before it came to rest.")
        else
            imperial_clusters[1] = number_die.getRotationValue()
            imperial_clusters[2] = imperial_clusters[1] == 6 and 1 or
                                       imperial_clusters[1] + 1

            LOG.INFO("Setup Imperial Ships")
            local imperial_ships = getObjectFromGUID(Global.getVar(
                "imperial_ships_GUID"))
            imperial_ships.setPosition({-19.75, 1, 6.00})

            for i = 1, 2, 1 do
                for system, v in pairs(
                    cluster_zones[imperial_clusters[i]]) do
                    system_ship_zone =
                        (system == "gate") and getObjectFromGUID(v) or
                            getObjectFromGUID(v["ships"])
                    local pos = system_ship_zone.getPosition()
                    imperial_ships.takeObject({
                        position = {pos.x, pos.y + 0.5, pos.z}
                    })
                end
            end

            is_imperial_cluster[imperial_clusters[1]] = true
            is_imperial_cluster[imperial_clusters[2]] = true

            local system_city_zone

            local event_die_planets = {"b", "c", "a", "a", "b", "c"}

            LOG.INFO("Setup Free Cities and Blight")
            local free_cities_supply =
                getObjectFromGUID(Global.getVar("free_cities_GUID"))
            free_cities_supply.setPosition({-16.25, 1, 6})

            local free_starports_supply =
                getObjectFromGUID(Global.getVar("free_starports_GUID"))
            free_starports_supply.setPosition({-16.25, 1, 7.75})

            local blight_supply = getObjectFromGUID(Global.getVar(
                "blight_GUID"))
            blight_supply.setPosition({-19.75, 1, 7.75})

            for cluster, value in pairs(cluster_zones) do
                if (not is_imperial_cluster[cluster]) then
                    for system, system_value in pairs(value) do
                        -- Free Cities
                        local free_system =
                            event_die_planets[event_die.getRotationValue()]
                        if (system == free_system) then
                            system_city_zone =
                                getObjectFromGUID(
                                    system_value["buildings"][1])
                            local pos = system_city_zone.getPosition()
                            free_cities_supply.takeObject({
                                position = {pos.x, pos.y + 0.5, pos.z},
                                rotation = {
                                    x = 0,
                                    y = 180,
                                    z = 0
                                }
                            })
                        end

                        -- Blight
                        if (system == "gate") then
                            system_ship_zone =
                                getObjectFromGUID(system_value)
                        else
                            system_ship_zone =
                                getObjectFromGUID(
                                    system_value["ships"])
                        end

                        local blight_pos =
                            system_ship_zone.getPosition()

                        local blight =
                            getObjectFromGUID(Global.getVar(
                                "blight_GUID"))
                        blight.takeObject({
                            position = {blight_pos.x,
                                        blight_pos.y + 0.5,
                                        blight_pos.z},
                            rotation = {
                                x = 0,
                                y = 180,
                                z = 180
                            }
                        })

                    end
                end
            end

            -- Merchant
            if (player_count == 2) then
                LOG.INFO("imperial merchant setup")
                merchant:setup(imperial_clusters)
            end
        end
    end, function() -- Condition function
        return number_die.isDestroyed() or event_die.isDestroyed() or
                   (number_die.resting and event_die.resting)
    end)

end

-- O
function Campaign.setupFreeCities()

end

-- P
function Campaign.setupBlight()

end

-- Setup Players

-- B
function Campaign.dealPlayerFates()
    local A_Fates = getObjectFromGUID(Global.getVar("A_Fates_GUID"))

    A_Fates.shuffle()
    A_Fates.deal(2)

    broadcastToAll("\nChoose a Fate secretly, discard the other.", {
        r = 1,
        g = 0,
        b = 0
    })

    Wait.time(function()
        broadcastToAll(
            "\nWhen everyone has chosen one, reveal them and take the matching fate bag.",
            {
                r = 1,
                g = 0,
                b = 0
            })
    end, 5)
end

-- D
function Campaign.dealObjectiveMarkers()

end

-- F
function Campaign.takeTitleCard()

end

-- G, H
function Campaign.playersPlacePieces()

end

-- I
function Campaign.placeFreeCities()

end

return Campaign
