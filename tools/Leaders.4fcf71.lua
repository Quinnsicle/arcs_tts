local newCards = {
    "Kaiju",
    "Shapeshifter",
    "Sentient",
    "Hierarch",
    "Smuggler",
    "Manipulator",
    "Necromancer",
    "Composer",
    "Maw",
    "Saint",
    "Seer",
    "Terrestrial",
    "General",
    "Sentinel",
    "Prefect",
    "Ghost",
    "Chosen",
    "Sage",
    "Gambler",
    "Engineer",
    "Magician",
    "Weaver",
    "Dreamer",
    "Seeker",
    "Augur",
    "Alchemist",
    "Architect",
    "Martyr",
    "Scourge",
    "Beggar",
    "Feral",
    "Conduit",
    "Puppeteer",
    "Automaton",
    "Golem",
    "Solian",
    "Racketeer",
    "Terraformer",
    "Trickster",
    "Nomad",
    "Iconoclast",
    "Fiend",
    "Hustler",
    "Curator",
    "Cartographer",
    "Custodian",
    "Salvager",
    "Chief",
    "Duelist",
    "Prophet",
    "Broker",
    "Siegebreaker",
    "Courier",
    "Forager",
    "Punter",
    "Insurgent",
    "Bomber",
    "Musician",
    "Ozymandias",
    "Collector",
    "Samurai",
    "Assassin",
    "Witch",
    "Ambassador",
    "Shaman",
    "Mediator",
    "Despot",
    "Viceroy",
    "Artificer",
    "Warmonger",
    "Extortioner",
    "Emperor",
    "Titan",
    "Egoist",
    "Enforcer",
    "Treasurer",
    "Wayfinder",
    "Champion",
    "Tribune",
    "Dissector",
    "Schemer",
    "Hydra",
    "Enchanter",
    "Creator",
    "Messiah",
    "Abomination",
    "Crusader",
    "Phantom",
    "Harbormaster",
    "Investor",
    "Envoy",
    "Syndic",
    "Solicitor",
    "Seraph",
    "Paragon",
    "Tactician",
    "Purist",
    "Marauder",
    "Berserker",
    "Underwriter",
    "Doppelganger",
    "Bulwark",
    "Demon",
    "Soulbinder",
    "Vessel",
    "Conqueror",
    "Comedian",
    "Animator",
    "Merchant",
    "Wretch",
    "Rascal",
    "Devourer",
    "Swarm",
    "Predator",
    "Reaver",
    "Prospector",
    "Smokecaller",
    "Dragon",
    "Sniper",
    "Poltergeist",
    "Homesteader",
    "Instigator",
    "Replicator",
    "Armsdealer",
    "Veteran",
    "Evader",
    "Mathematician",
    "Underdog",
    "Mobster",
    "Glutton",
    "Contrarian",
    "Cat",
    "Cavalier",
    "Surveyor",
    "Jester",
}

-- Bump this to force clients to reload leader face images (cache-bust query param).
local LEADER_IMAGE_REV = "2026-05-30a"

function onLoad()
    -- Only proceed if this is a deck and has less than 3 cards
    if self.tag == "Deck" and self.getQuantity() >= 3 then
        return
    end

    -- Capture the original cards that are already in the deck before spawning.
    local original_guids = {}
    if self and self.getObjects then
        local existing = self.getObjects() or {}
        for _, entry in ipairs(existing) do
            if entry and entry.guid then
                table.insert(original_guids, entry.guid)
            end
        end
    end

    for _, name in ipairs(newCards) do
        local card = spawnObject({
            type = "Card",
            position = self.getPosition() + Vector(0, 1, 0),
            sound = false,
            snap_to_grid = true,
        })
        card.setCustomObject({
            face = "https://raw.githubusercontent.com/Laurens1234/Arcs-Leader-Generator/main/results/leader/" .. name .. "_Card.png?v=" .. LEADER_IMAGE_REV,
            back = "https://dl.dropboxusercontent.com/s/tiltx24hgxe5c6s/starting%20power%20back.jpg?dl=1",
            type = 0,
            back_is_hidden = true,
            unique_back = false,
        })
        card.setName(name)
        card.setTags({"Base Game Only", "Leader"})
        self.putObject(card)
    end

    -- After cards have stacked into the deck, remove the original source cards.
    Wait.time(function()
        local deck = self
        if not deck then
            return
        end

        for _, guid in ipairs(original_guids) do
            pcall(function()
                deck.takeObject({
                    guid = guid,
                    smooth = false,
                    callback_function = function(obj)
                        if obj and obj.destruct then
                            obj.destruct()
                        end
                    end
                })
            end)
        end
    end, 0.6)
end