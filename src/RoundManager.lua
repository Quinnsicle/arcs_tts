local ActionCards = require("src/ActionCards")
local AmbitionMarkers = require("src/AmbitionMarkers")
local Initiative = require("src/InitiativeMarker")
local LOG = require("src/LOG")

local RoundManager = {}

function RoundManager.endRound()
    Global.setVar("turn_count", 0)

    LOG.DEBUG("Seize detection")
    -- Seize detection
    local seize_detected = false
    if ActionCards.count_seize_cards() == 1 then
        seize_detected = true
    elseif ActionCards.count_seize_cards() > 1 then
        broadcastToAll(
            "Multiple seize cards detected, please fix the board and try to End Round again",
            Color.Red)
        return
    end

    LOG.DEBUG("Initiative")
    local initiative_player = Global.getVar("initiative_player")
    local all_players = Global.getVar("active_players")

    if not initiative_player then
        LOG.WARNING(
            "Could not determine initiative player. Please ensure initiative marker is near a player board.")
    elseif Initiative.is_seized() and seize_detected then
        -- Someone already manually seized initiative
        Initiative.unseize()
    elseif not Initiative.is_seized() and seize_detected then
        -- Auto seize initiative for player with last played seize card
        local seize_player_color = ActionCards.find_seize_player()
        if seize_player_color then
            Initiative.take(seize_player_color, true)
            broadcastToAll(seize_player_color .. " has seized the initiative",
                seize_player_color)
        else
            broadcastToAll(
                "Whoever is playing the seize card, pick it up and drop it back into place, then hit End Round again.",
                Color.Red)
            return
        end
    else
        -- If initiative is already seized (marker in seized state) then
        -- do not attempt to find a surpassing card; the seizing player
        -- keeps initiative.
        if Initiative.is_seized() then
            if initiative_player then
                broadcastToAll(initiative_player .. " has seized the initiative and keeps it", initiative_player)
            else
                LOG.DEBUG("Initiative seized but initiative_player unknown")
            end
        else
            -- Check for highest surpassing card
            local surpassing = ActionCards.get_surpassing_card()
            if not surpassing then
                broadcastToAll("No surpassing card, " .. initiative_player ..
                                   " keeps the initiative", initiative_player)
            else
                -- Debug: print all last_action_card values and surpassing card
                LOG.DEBUG("Surpassing card: type=" .. tostring(surpassing.type) .. ", number=" .. tostring(surpassing.number))
                for _, p in ipairs(all_players) do
                    if not p.last_action_card then
                        LOG.DEBUG("Player " .. tostring(p.color) .. " has no last_action_card")
                        goto continue
                    end
                    LOG.DEBUG("Player " .. tostring(p.color) .. " last_action_card: type=" .. tostring(p.last_action_card.type) .. ", number=" .. tostring(p.last_action_card.number))
                    if p.last_action_card.type == surpassing.type and p.last_action_card.number == surpassing.number then
                        LOG.INFO("Initiative assigned to " .. tostring(p.color) .. " for surpassing card match.")
                        Initiative.unseize()
                        Initiative.take(p.color, true)
                        broadcastToAll(string.format(
                            "%s has surpassed with %s %d and takes the initiative",
                            p.color, surpassing.type, surpassing.number), p.color)
                        break
                    end
                    ::continue::
                end
            end
        end
    end

    LOG.DEBUG("Cleanup")

    AmbitionMarkers:reset_zero_marker()
    ActionCards.clear_played()
    -- reset p.last_action_card + p.last_seize_card for all players
    -- otherwise weird bugs happen when state carries over to the next round
    for _, p in ipairs(all_players) do
        p.last_action_card = nil
        p.last_seize_card = nil
    end
    broadcastToAll("End Round\n", Color.Purple)

    local next_turn_color = Global.getVar("initiative_player")
    if next_turn_color then
        Turns.turn_color = next_turn_color
    else
        LOG.WARNING("Skipping turn color update because initiative player is unknown")
    end
    Initiative.unseize()
end

return RoundManager
