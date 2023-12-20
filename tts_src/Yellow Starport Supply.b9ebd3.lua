--[[ supply_GUID =
    Global.getVar("player_pieces_GUIDs")["Yellow"]["starports"]
supply = getObjectFromGUID(supply_GUID)

function onLoad()
    self.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "" .. #supply.getObjects(),
        position = {0.53, 0.06, 0.05}, -- drop shadow bottom right
        -- position = {0.48, 0.06, 0.04}, --drop shadow bottom left
        width = 1,
        height = 1,
        font_size = 365,
        scale = {1, 1, 1},
        font_color = {0, 0, 0}
    })

    self.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = "" .. #supply.getObjects(),
        position = {0.5, 0.06, 0.03},
        width = 1,
        height = 1,
        font_size = 360,
        scale = {1, 1, 1},
        font_color = {1, 1, 1}
    })
end

function onObjectEnterContainer(container, object)
    self.editButton({
        index = 0,
        label = "" .. #supply.getObjects()
    })
    self.editButton({
        index = 1,
        label = "" .. #supply.getObjects()
    })
end

function onObjectLeaveContainer(container, object)
    self.editButton({
        index = 0,
        label = "" .. #supply.getObjects()
    })
    self.editButton({
        index = 1,
        label = "" .. #supply.getObjects()
    })
end

function filterObjectEnter(obj)
    return self.hasMatchingTag(obj)
end --]]