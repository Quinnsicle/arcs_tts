local Timer = {}

Timer.player_timers = {}
Timer.running = false
Timer.start_time = 0
Timer.timer_id = nil

function Timer.start(active_players)    
    if Timer.running then return end

    if not Turns.turn_color or Turns.turn_color == "" then
        broadcastToAll("No active turn - please use the turn system", {1, 0, 0})
        return
    end

    if Timer.timer_id then
        Wait.stop(Timer.timer_id)
    end
    
    Timer.running = true
    Timer.start_time = os.time()
    Timer.timer_id = Wait.time(function() Timer.update(active_players) end, 1, -1)
end

function Timer.formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function Timer.pause()
    if not Timer.running then return end

    Timer.running = false

    if Timer.timer_id then
        Wait.stop(Timer.timer_id)
        Timer.timer_id = nil
    end
end

function Timer.reset()
    Timer.running = false
    Timer.start_time = 0
    for _, color in ipairs({"Red", "White", "Yellow", "Teal"}) do
        Timer.player_timers[color] = 0
        Timer.updateDisplay(color)
    end
    UI.setValue("totalTime", Timer.formatTime(0))
    if Timer.timer_id then
        Wait.stop(Timer.timer_id)
        Timer.timer_id = nil
    end
end

function Timer.update(active_players)
    if Timer.running and Turns.turn_color then
        -- Update the current player's total time
        if not Timer.player_timers[Turns.turn_color] then
            Timer.player_timers[Turns.turn_color] = 0
        end
        Timer.player_timers[Turns.turn_color] = Timer.player_timers[Turns.turn_color] + 1
        
        -- Update display for all players
        for _, player in ipairs(active_players) do
            local timerId = player.color:lower() .. "Timer"
            Timer.updateDisplay(player.color)
            if player.color == Turns.turn_color then
                UI.setAttribute(timerId, "fontStyle", "Bold")
                UI.setAttribute(timerId, "fontSize", "16")
            else
                UI.setAttribute(timerId, "fontStyle", "Normal")
                UI.setAttribute(timerId, "fontSize", "12")
            end
        end

        UI.setValue("totalTime", Timer.formatTime(Timer.getTotalTime()))
    end
end

function Timer.updateDisplay(color)
    local seconds = Timer.player_timers[color] or 0
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    local display = string.format("%02d:%02d", minutes, seconds)
    UI.setValue(color:lower() .. "Timer", display)
end

function Timer.generatePlayerTimerDisplays(active_players)
    local playerTimersXml = ""
    local buttonColors = {
        Red = "#FF0000",
        White = "#FFFFFF",
        Yellow = "#FFFF00",
        Teal = "#00FFFF"
    }

    for _, player in ipairs(active_players) do
        local isActive = player.color == Turns.turn_color
        local currentTime = Timer.player_timers[player.color] or 0
        local timeDisplay = Timer.formatTime(currentTime)
        
        playerTimersXml = playerTimersXml .. string.format(
            [[<HorizontalLayout spacing="5">
                <Text id="%sTimer" text="%s" color="%s" fontSize="12" fontStyle="%s" preferredWidth="25" preferredHeight="13"/>
                <Button text="%s" id="%sCamera" textColor="%s" onClick="on%sBoardClick" preferredWidth="28"/>
            </HorizontalLayout>]],
            player.color:lower(),
            timeDisplay,
            buttonColors[player.color],
            isActive and "Bold" or "Normal",
            player.color,
            player.color:lower(),
            buttonColors[player.color],
            player.color
        )
    end
    
    return playerTimersXml
end

function Timer.getTotalTime()
    local total = 0
    for _, color in ipairs({"Red", "White", "Yellow", "Teal"}) do
        total = total + (Timer.player_timers[color] or 0)
    end
    return total
end

function Timer.generateTimerControls(timer_running, active_players)
    -- Only show timer controls if there are 2 or more players
    if not active_players or #active_players < 2 then
        return ""
    end

    return string.format([[
        <!-- Timer Controls at bottom -->
        <HorizontalLayout spacing="5">
            <Text id="totalTime" text="%s" color="#808080" fontSize="12" preferredWidth="25" preferredHeight="13"/>
            <Button text="%s" id="playPauseButton" textColor="White" onClick="onPlayPauseTimer" width="30" flexibleWidth="0"/>
            <Button text="↺" id="resetTimer" textColor="Grey" onClick="resetTimer" width="30" fontStyle="Normal" tooltip="Reset all timers back to 0"/>
        </HorizontalLayout>
    ]], Timer.formatTime(Timer.getTotalTime()), timer_running and "||" or "▶")
end

return Timer