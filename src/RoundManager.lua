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
        -- Check for highest surpassing card
        local surpassing = ActionCards.get_surpassing_card()
        if not surpassing then
            broadcastToAll("No surpassing card, " .. initiative_player ..
                               " keeps the initiative", initiative_player)
        else
            -- Assign initiative to player with highest surpassing card
            for _, p in ipairs(all_players) do
                if not p.last_action_card then
                    goto continue
                end

                if string.find(surpassing.type, p.last_action_card.type) and
                    p.last_action_card.number == surpassing.number then
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

    Turns.turn_color = Global.getVar("initiative_player")
    Initiative.unseize()
end

return RoundManager
