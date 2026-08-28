local courtDiscardTopCard = nil

function onObjectEnterZone(zone, object)
    if zone ~= self or not object.hasTag("Court") then return end

    local zoneObjects = zone.getObjects()
    local courtDiscardDeck = nil
    local courtCards = {}
    for _, obj in ipairs(zoneObjects) do
        if obj.hasTag("Court") then
            if obj.type == "Card" then
                table.insert(courtCards, obj)
            elseif obj.type == "Deck" then
                obj.setTags({"Court"})
                courtDiscardDeck = obj
            end
        end
    end

    -- Check if the object is "SONG OF FREEDOM" and move it (only when face-up)
    if object.getName() == "SONG OF FREEDOM" and not object.is_face_down then
        local pos = object.getPosition()
        object.setPosition({ x = 26, y = pos.y, z = pos.z })
        broadcastToAll("Shuffle Song Of Freedom into the Court deck.")
        return
    end

    -- Special handling for GUILD STRUGGLE (only once per game)
    -- Only resolve Guild Struggle when the card is face-up
    if object.getName() == "GUILD STRUGGLE" and not object.is_face_down then
        object.setName("GUILD STRUGGLE RESOLVED")

        for _, obj in ipairs(zoneObjects) do
            if obj.type == "Card" then
                if obj.hasTag("Guild") then
                    local pos = obj.getPosition()
                    obj.setPosition({ x = 26, y = pos.y, z = pos.z })
                end
            elseif obj.type == "Deck" then
                splitDeckMoveGuildCardsBottom(obj)
            end
        end
        broadcastToAll("Shuffle all Guild cards from the Court discard pile into the Court deck.")

        -- Ensure the resolved Guild Struggle card ends up on top of the Court deck.
        -- Wait a short moment so other deck operations finish, then put this card on top
        Wait.time(function()
            -- re-scan zone for a deck object
            local zoneObjects2 = zone.getObjects()
            local foundDeck = nil
            for _, o in ipairs(zoneObjects2) do
                if o.type == "Deck" then
                    foundDeck = o
                    break
                end
            end

            if foundDeck then
                pcall(function()
                    -- putObject will place it on top of the deck
                    foundDeck.putObject(object)
                end)
            else
                local pos = object.getPosition()
                object.setPosition({ x = pos.x, y = pos.y + 0.4 , z = pos.z })
            end
        end, 0.4)

        return
    end

    -- if a deck object has yet to form, record the newest card entering discard
    if #courtCards == 3 then 
        courtDiscardTopCard = object
        return
    end

    -- handle situations where a deck object has not yet formed but a third card enters discard
    -- we pull the last discarded card from a newly formed deck, place it back on top of the discard pile
    if courtDiscardTopCard and courtDiscardDeck then 
        Wait.time(function()
            local deckObjects = courtDiscardDeck.getObjects()
            local index = nil
            for i, card in ipairs(deckObjects) do
                if card and card.guid and courtDiscardTopCard and courtDiscardTopCard.guid and card.guid == courtDiscardTopCard.guid then
                    index = i - 1
                    break
                end
            end

            if index then
                if courtDiscardDeck then
                    courtDiscardDeck.takeObject({
                        index = index,
                        position = {
                            x = courtDiscardDeck.getPosition().x,
                            y = courtDiscardDeck.getPosition().y + 0.4,
                            z = courtDiscardDeck.getPosition().z
                        },
                        smooth = false,
                        flip = false,
                        top = true
                    })
                end
                courtDiscardTopCard = nil
            end
        end, 0.25)
    end
end
function splitDeckMoveGuildCardsBottom(deck)
    local numCards = deck.getQuantity()
    for i = 1, numCards + 1 do
        Wait.time(function()
            if deck == nil or not deck or deck.type ~= "Deck" then
                
                return
            end
            local card = deck.takeObject({
                position = {
                    x = deck.getPosition().x,
                    y = deck.getPosition().y + 2,
                    z = deck.getPosition().z
                },
                smooth = false,
                top = false
            })
            if card and card.hasTag("Guild") then
                local pos = card.getPosition()
                card.setPosition({
                    x = 26,
                    y = pos.y,
                    z = pos.z
                })
            end
        end, 0.1 * i)
    end
end
