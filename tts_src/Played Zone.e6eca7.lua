supplies = require("src/Supplies")

FUDiscard_zone = getObjectFromGUID(Global.getVar("FUDiscard_zone_GUID"))
FUDiscard_marker = getObjectFromGUID(Global.getVar("FUDiscard_marker_GUID"))
FUDiscard_active = true

function onLoad()

    FUDiscard_zone.setPosition(FUDiscard_marker.getPosition())

    FUD_card_pos            = FUDiscard_zone.getPosition()
    FUD_card_rot            = FUDiscard_zone.getRotation()

    FUDsicard_zone_pos      = FUDiscard_zone.getPosition()
    FUDiscard_marker_pos    = FUDiscard_marker.getPosition()

end

function toggleFUDiscard()
    FUDiscard_active = not FUDiscard
    if FUDiscard_active then
        FUDiscard_zone.setPosition(FUDsicard_zone_pos)
        FUDiscard_marker.setPosition(FUDiscard_marker_pos)
    else
        FUDiscard_zone.setPosition(FUDsicard_zone_pos + Vector(0,-5,0))
        FUDiscard_marker.setPosition(FUDiscard_marker_pos + Vector(0,-5,0))
    end
end

function clearPlayed()

    local played_objects = self.getObjects()

    -- Error on union card
    for _, obj in pairs(played_objects) do
        if obj.hasTag("Union") then
            broadcastToAll("Resolve Union card before cleanup!", Color.Red)
            return
        end
    end

    -- clean up
    broadcastToAll("Cleanup action card area")

    for _, obj in pairs(played_objects) do

        -- If FUDiscard is enable and the obj is a face-up action card 
        -- send it to face-up action card dicard
        if obj.getName() == "Action Card" and FUDiscard_active and not obj.is_face_down then
            obj.setPositionSmooth(FUD_card_pos)
            obj.setRotationSmooth(FUD_card_rot)

        -- Attempt to return anything else to its supply
        else
            supplies.returnObject(obj)
        end
    end

    Wait.frames(function() FUDiscard_zone.LayoutZone.layout() end, 100)

end

function clearFUDiscard()
    for _, obj in pairs(FUDiscard_zone.getObjects()) do
        if obj.type=="Card" then
            obj.setPositionSmooth(action_card_pos)
            obj.setRotationSmooth(action_card_rot)
        end
    end
end