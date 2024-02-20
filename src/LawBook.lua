local LawBook = {}

local LAW_BOOK = self

local open_button = {
    click_function = "openLawBook",
    function_owner = LAW_BOOK,
    label = "Open\nBook of Law",
    tooltip = "Open Book of Law",
    position = {0,0.5,.37},
    width = 600,
    height = 10,
    font_size = 60,
    scale = {.8, .8, 0.8},
    color = {1,1,1},
    font_color = {0, 0, 0} 
}

function LawBook.setup()
    LAW_BOOK.createButton(open_button)
end

function LawBook.open(player_color)
    LAW_BOOK.Container.search(player_color)
end

-- Begin Object Code --
function onLoad()                       LawBook.setup()             end
function openLawBook(_,player_color)    LawBook.open(player_color)  end
-- End Object Code --

return LawBook