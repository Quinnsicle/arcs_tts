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
    -- If a WARNING occurs we want users to see it so they can report it
    print("[WARNING] " .. message)
end

function LOG.ERROR(message)
    -- If an ERROR occurs we want users to see it so they can report it
    print("[ERROR] " .. message)
end

return LOG
