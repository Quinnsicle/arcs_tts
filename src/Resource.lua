require("src/GUIDs")
local LOG = require("src/LOG")

local Resource = {
    supplies = {
        psionic = getObjectFromGUID(resources_GUID["psionics"]),
        relic = getObjectFromGUID(resources_GUID["relics"]),
        weapon = getObjectFromGUID(resources_GUID["weapons"]),
        fuel = getObjectFromGUID(resources_GUID["fuel"]),
        material = getObjectFromGUID(resources_GUID["materials"])

    }
}

function Resource:take(name, pos)
    LOG.DEBUG("name:" .. name)
    self.supplies[name].takeObject({
        position = pos,
        smooth = true
    })
end

return Resource
