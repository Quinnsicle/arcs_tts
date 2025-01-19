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

    -- if a deck object has yet to form, record the newst card entering discard
    if #courtCards == 3 then 
        courtDiscardTopCard = object
        return
    end

    -- handle situations where a deck object has not yet formed but a third cards enters discard
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
