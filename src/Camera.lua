local Timer = require("src/Timer")

local Camera = {}

-- note that these onClick functions are used by wrapper functions in Global.lua
function Camera.onCourtClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=22.26, y=1.49, z=-1.65},
        pitch = 70,
        yaw = 90,
        distance = 10
    })
end

function Camera.onActionCardsClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-14.0, y=1.49, z=-1.65},
        pitch = 70,
        yaw = 270,
        distance = 12
    })
end

function Camera.onDiceBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-33.2, y=1.07, z=-15.22},
        pitch = 80,
        yaw = 0,
        distance = 18
    })
end

function Camera.onMapClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=2.79, y=0.98, z=-1.35},
        pitch = 70,
        yaw = 0,
        distance = 35
    })
end

function Camera.onRedBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-10.6, y=1.48, z=14.92},
        pitch = 80,
        yaw = 0,
        distance = 11
    })
end

function Camera.onWhiteBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=13.14, y=1.48, z=14.92},
        pitch = 80,
        yaw = 0,
        distance = 11
    })
end

function Camera.onYellowBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=13.14, y=1.48, z=-16.12},
        pitch = 80,
        yaw = 0,
        distance = 11
    })
end

function Camera.onTealBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-10.6, y=1.48, z=-16.12},
        pitch = 80,
        yaw = 0,
        distance = 11
    })
end

-- note that these onClick functions reference the wrapper functions in Global.lua
function Camera.generateControlsXml(active_players, timer_running)
    -- Generate camera control buttons
    return string.format([[
        <VerticalLayout spacing="10">
            <!-- Camera Controls in pairs -->
            <HorizontalLayout spacing="5">
                <Button text="Action" id="actionCardsCamera" textColor="Grey" onClick="onActionCardsClick" width="85"/>
                <Button text="Court" id="courtCamera" textColor="Grey" onClick="onCourtClick" width="85"/>
            </HorizontalLayout>
            <HorizontalLayout spacing="5">
                <Button text="Dice" id="diceCamera" textColor="Grey" onClick="onDiceBoardClick" width="85"/>
                <Button text="Map" id="mapCamera" textColor="Grey" onClick="onMapClick" width="85"/>
            </HorizontalLayout>

            <!-- Player Timer Displays -->
            %s

            <!-- Timer Controls at bottom -->
            <HorizontalLayout spacing="5" padding="0 60 0 0">
                <Button text="%s" id="playPauseButton" textColor="White" onClick="onPlayPauseTimer" width="30" flexibleWidth="0"/>
                <Button text="Reset" id="resetTimer" textColor="Grey" onClick="resetTimer" width="55" fontStyle="Normal" tooltip="Reset all timers back to 0"/>
            </HorizontalLayout>
        </VerticalLayout>
    ]], Timer.generatePlayerTimerDisplays(active_players),
        timer_running and "||" or "▶"
    )
end

function Camera.generateMenuXml(menuOpen, controlsXml)
    return string.format([[
        <Defaults>
            <Button color="black" fontStyle="Bold" />
            <Button class="cameraControl" onClick="onCameraClick" />
        </Defaults>

        <VerticalLayout
            id="cameraLayout"
            height="320"
            width="160"
            allowDragging="true"
            returnToOriginalPositionWhenReleased="false"
            rectAlignment="UpperRight"
            anchorMin="1 1"
            anchorMax="1 1"
            offsetXY="-5 -150"
            spacing="5"
            childForceExpandHeight="false"
            childForceExpandWidth="true"
            >
            <Button
                onClick="toggleCameraControls"
                text="Camera Controls"
                textColor="white"
                color="Grey"
                tooltip="Toggle camera controls / timer"
                tooltipBackgroundColor="Grey"
                tooltipTextColor="Black"
                >
            </Button>
            <VerticalLayout
                id="cameraControls"
                height="320"
                width="180"
                active="%s"
                >
                %s
            </VerticalLayout>
        </VerticalLayout>
    ]], tostring(menuOpen), controlsXml)
end

return Camera