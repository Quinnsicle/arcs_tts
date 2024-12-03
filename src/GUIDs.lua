reach_board_GUID = "bb7d21"

-- leaders and lore
more_to_explore_fate_GUID = "768d3d"
more_to_explore_lore_GUID = "3441e5"

include_fates_GUID = "be0e27"
action_deck_GUID = "227406"
action_deck_zone_GUID = "80ed31" -- "9bd42d"
action_deck_4P_GUID = "13bedd"
action_card_zone_GUID = "e6eca7"
seize_zone_GUID = "e6eca8"
face_up_discard_action_deck_GUID = "a8e929"
lead_card_zone_GUID = "9e5eae"
FUDiscard_marker_GUID = "000207"

zero_marker_GUID = "0289cb"
ambition_marker_GUIDs = {"c9e0ee", "a9b02a", "b0b4d0"}
ambition_marker_zone_GUID = "06c552"
court_deck_zone_GUID = "7a33ff"

fate_GUID = "2d243a"
lore_GUID = "0d8ede"
base_court_deck_GUID = "9ac2b3"

-- Setup deck
setup_deck_GUID = "f02e75"

-- 4P setup deck
frontiers_4P_GUID = "ec2d75"
mix_up_1_4P_GUID = "646d5a"
mix_up_2_4P_GUID = "53671b"
mix_up_3_4P_GUID = "595066"

-- 3P setup deck
frontiers_3P_GUID = "abc2f1"
core_conflict_3P_GUID = "6ee717"
homelands_3P_GUID = "eac88a"
mix_up_3P_GUID = "eb2f62"

-- 2P setup deck
frontiers_2P_GUID = "d4c37c"
homelands_2P_GUID = "559dbb"
mix_up_1_2P_GUID = "850244"
mix_up_2_2P_GUID = "ddc074"

initiative_GUID = "b3b3d0"
seized_initiative_GUID = "e0f490"

chapter_pawn_GUID = "9c3ac8"

-- Players Pieces
player_pieces_GUIDs = {
    ["White"] = {
        player_board = "999dbd",
        resource = {"822a9c", "00ee1b"},
        ships = "6883e6",
        starports = "b96445",
        agents = "c863eb",
        cities = {"822a9c", "00ee1b", "a50d56", "06f4a8", "81c3a7"},
        initiative_zone = "2e1cd3",
        trophies_zone = "275a50",
        captives_zone = "0c07a0",
        area_zone = "a952c1"
    },
    ["Yellow"] = {
        player_board = "5aa44c",
        resource = {"dbf4de", "799077"},
        ships = "a75924",
        starports = "b9ebd3",
        agents = "7b3749",
        cities = {"dbf4de", "799077", "acfa72", "ac28fb", "b41592"},
        initiative_zone = "3fc6fd",
        trophies_zone = "7f5014",
        captives_zone = "31a56f",
        area_zone = "238a92"
    },
    ["Red"] = {
        player_board = "c0c8a1",
        resource = {"33577c", "cf5b95"},
        ships = "7e0fe2",
        starports = "51a8f5",
        agents = "bbb3aa",
        cities = {"33577c", "cf5b95", "0ac3c2", "6e36ca", "282f37"},
        initiative_zone = "32f290",
        trophies_zone = "48b6fb",
        captives_zone = "7b011e",
        area_zone = "c2bf05"
    },
    ["Teal"] = {
        player_board = "ae512a",
        resource = {"f3da7f", "f3da7f"},
        ships = "2da385",
        starports = "7e625d",
        agents = "791097",
        cities = {"f3da7f", "5e753e", "79b799", "fad0f1", "45c804"},
        initiative_zone = "cdc545",
        trophies_zone = "3085c9",
        captives_zone = "fe0b0d",
        area_zone = "ee4b6e"
    }
}

-- Cluster GUIDs
cluster_zone_GUIDs = {
    [1] = { -- cluster
        gate = "261101",
        a = {
            buildings = {"300802", "a67a63"},
            ships = "296493"
        },
        b = {
            buildings = {"66652d"},
            ships = "7a01be"
        },
        c = {
            buildings = {"b05731", "083a9a"},
            ships = "3b90d3"
        }
    },
    [2] = { -- cluster
        gate = "815b16",
        a = {
            buildings = {"83abbd"},
            ships = "a34cdc"
        },
        b = {
            buildings = {"dfc711"},
            ships = "1dab32"
        },
        c = {
            buildings = {"13e02c", "13e02c"},
            ships = "797680"
        }
    },
    [3] = { -- cluster
        gate = "bd423f",
        a = {
            buildings = {"616435"},
            ships = "0ce2b8"
        },
        b = {
            buildings = {"8d6efe"},
            ships = "396c5e"
        },
        c = {
            buildings = {"50f42c", "9e0f65"},
            ships = "ad2a7c"
        }
    },
    [4] = { -- cluster
        gate = "db8a4f",
        a = {
            buildings = {"e54cea", "283076"},
            ships = "bc8f25"
        },
        b = {
            buildings = {"4dafc5", "8e7828"},
            ships = "5c72ba"
        },
        c = {
            buildings = {"489866"},
            ships = "e2a2f3"
        }
    },
    [5] = { -- cluster
        gate = "42710a",
        a = {
            buildings = {"c36b81"},
            ships = "07b826"
        },
        b = {
            buildings = {"fccac8"},
            ships = "99b331"
        },
        c = {
            buildings = {"6795f2", "b493d4"},
            ships = "d0f854"
        }
    },
    [6] = { -- cluster
        gate = "0b73a3",
        a = {
            buildings = {"13107a"},
            ships = "aa2992"
        },
        b = {
            buildings = {"9e28b7", "7bb712"},
            ships = "d79fe8"
        },
        c = {
            buildings = {"e88c25"},
            ships = "4af68d"
        }
    }
}

resources_GUID = {
    psionics = "1b4b0b",
    relics = "5895b5",
    weapons = "1c2d2a",
    fuel = "ed2820",
    materials = "57c2c6"
}

resources_markers_GUID = {
    psionics = "a89706",
    relics = "473675",
    weapons = "2fdfa3",
    fuel = "5cb321",
    materials = "eb1cba"
}

----------------------------------------------------
-- campaign
----------------------------------------------------

control_GUID = "6e21fe"

event_deck_GUID = "ad423d"
chapter_track_GUID = "4d34d7"
chapter_zone_GUID = "2d2c49"

campaign_court_GUID = "fb55bf"
imperial_council_GUID = "89ddf3"
laws_GUID = "f0362b"
guild_envoys_depart_GUID = "ba6fc8"
govern_GUID = "df60d0"
regents_GUID = "9c8d55"

event_die_GUID = "684608"
number_die_GUID = "d5e298"
die_zone_GUID = "1b45bb"

imperial_ships_GUID = "beb54d"
free_cities_GUID = "80742e"
free_starports_GUID = "c79cb8"
blight_GUID = "ff61a8"

A_Fates_GUID = "0ac7d1"
