local LOG = {
    logLevel = 5
}

function LOG.TRACE(message)
    if LOG.logLevel <= 1 then
        print("[TRACE] " .. message)
    end
end

function LOG.DEBUG(message)
    if LOG.logLevel <= 2 then
        print("[DEBUG] " .. message)
    end
end

function LOG.INFO(message)
    if LOG.logLevel <= 3 then
        print("[INFO]" .. message)
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
