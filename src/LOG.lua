local LOG = {}

function LOG.INFO(message)
    if Global.getVar("debug") then
        print("[INFO]" .. message)
    end
end

function LOG.DEBUG(message)
    if Global.getVar("debug") then
        print("[DEBUG] " .. message)
    end
end

function LOG.WARNING(message)
    if Global.getVar("debug") then
        print("[WARNING] " .. message)
    end
end

function LOG.ERROR(message)
    if Global.getVar("debug") then
        print("[ERROR] " .. message)
    end
end

return LOG
