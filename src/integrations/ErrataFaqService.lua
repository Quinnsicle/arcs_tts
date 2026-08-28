local ErrataFaqService = {}

local ERRATA_URL = "https://raw.githubusercontent.com/buriedgiantstudios/cards/refs/heads/master/content/errata/arcs/en-US.yml"
local ERRATA_CACHE_SECONDS = 86400
local errata_cache_lookup = nil
local errata_cache_time = 0
local errata_fetch_in_flight = false
local errata_pending_callbacks = {}

local FAQ_URL = "https://raw.githubusercontent.com/buriedgiantstudios/cards/refs/heads/master/content/faq/arcs/en-US.yml"
local FAQ_CACHE_SECONDS = 86400
local faq_cache_lookup = nil
local faq_cache_time = 0
local faq_fetch_in_flight = false
local faq_pending_callbacks = {}

local errata_menu_patched = {}

local function trim(s)
  s = tostring(s or "")
  s = s:gsub("^%s+", "")
  s = s:gsub("%s+$", "")
  return s
end

local function strip_outer_quotes(s)
  s = trim(s)
  local first = s:sub(1, 1)
  local last = s:sub(-1)
  if (first == '"' and last == '"') or (first == "'" and last == "'") then
    s = s:sub(2, -2)
  end
  s = s:gsub('\\"', '"')
  s = s:gsub("\\'", "'")
  return s
end

local function normalize_card_name(name)
  local n = trim(name)
  n = n:gsub("%$link:([^%$]+)%$", "%1")
  n = n:gsub("[%*_`]", "")
  n = n:gsub("[^%w%s]", "")
  n = n:lower()
  n = n:gsub("%s+", " ")
  return trim(n)
end

local function split_slash_keys(name)
  local keys = {}
  if not name then return keys end
  local full = normalize_card_name(name)
  table.insert(keys, full)
  local a, b = name:match("^(.-)%s*/%s*(.-)$")
  if a and b then
    local ka = normalize_card_name(a)
    local kb = normalize_card_name(b)
    if ka ~= full then table.insert(keys, ka) end
    if kb ~= full and kb ~= ka then table.insert(keys, kb) end
  end
  return keys
end

local function get_card_label_for_errata(card_obj)
  if not card_obj then return "" end

  local name = ""
  local desc = ""
  pcall(function() if card_obj.getName then name = tostring(card_obj.getName() or "") end end)
  pcall(function() if card_obj.getDescription then desc = tostring(card_obj.getDescription() or "") end end)

  local lname = string.lower(trim(name))
  local label = trim(name)

  if lname == "action card" or lname == "card" then
    label = trim(desc)
  elseif label == "" and trim(desc) ~= "" then
    label = trim(desc)
  end

  return trim(label)
end

local function parse_errata_yaml_lookup(yaml_text)
  local lookup = {}
  if not yaml_text or yaml_text == "" then return lookup end

  local pending_texts = {}
  local current_text = nil
  local collecting_text = false

  local function push_current_text()
    if current_text and trim(current_text) ~= "" then
      table.insert(pending_texts, trim(current_text))
    end
    current_text = nil
    collecting_text = false
  end

  local pos = 1
  while pos <= #yaml_text do
    local nl = yaml_text:find("\n", pos, true)
    local line
    if nl then
      line = yaml_text:sub(pos, nl - 1)
      pos = nl + 1
    else
      line = yaml_text:sub(pos)
      pos = #yaml_text + 1
    end
    if line:sub(-1) == "\r" then
      line = line:sub(1, -2)
    end

    local card_value = line:match("^%s*card:%s*(.+)%s*$")
    if card_value then
      push_current_text()
      local card_name = strip_outer_quotes(card_value)
      local key = normalize_card_name(card_name)
      if key ~= "" then
        if not lookup[key] then
          lookup[key] = { card = card_name, texts = {} }
        end
        for _, t in ipairs(pending_texts) do
          table.insert(lookup[key].texts, t)
        end
      end
      pending_texts = {}
    else
      local text_value = line:match("^%s*-%s*text:%s*(.*)$")
      if text_value == nil then
        text_value = line:match("^%s*text:%s*(.*)$")
      end

      if text_value ~= nil then
        push_current_text()
        current_text = strip_outer_quotes(text_value)
        collecting_text = true
      elseif collecting_text then
        local is_new_key = false
        if line:match("^%s*card:%s*") or line:match("^%s*-%s*errata:%s*$") or line:match("^%s*errata:%s*$") then
          is_new_key = true
        elseif line:match("^%s+[%a_][%w_%-]*:%s*") then
          is_new_key = true
        end

        if is_new_key then
          push_current_text()
        else
          local continuation = trim(line)
          if continuation ~= "" then
            if current_text == "" then
              current_text = continuation
            else
              current_text = current_text .. " " .. continuation
            end
          end
        end
      end
    end
  end

  push_current_text()
  return lookup
end

local function parse_faq_yaml_lookup(yaml_text)
  local lookup = {}
  if not yaml_text or yaml_text == "" then return lookup end

  local pending_card = nil
  local parsed_items = {}
  local current_item = nil
  local current_section = nil
  local current_text = nil
  local current_key_indent = 0

  local function normalize_block_text(value)
    value = trim(value)
    if value == ">" or value == ">-" or value == "|" or value == "|-" then
      return ""
    end
    return strip_outer_quotes(value)
  end

  local function flush_current_text()
    if current_section and current_item and current_text ~= nil then
      current_item[current_section] = trim(current_text)
    end
    current_section = nil
    current_text = nil
    current_key_indent = 0
  end

  local function flush_current_item()
    flush_current_text()
    if current_item and (trim(current_item.q) ~= "" or trim(current_item.a) ~= "") then
      table.insert(parsed_items, { q = trim(current_item.q), a = trim(current_item.a) })
    end
    current_item = nil
  end

  local pos = 1
  while pos <= #yaml_text do
    local nl = yaml_text:find("\n", pos, true)
    local line
    if nl then
      line = yaml_text:sub(pos, nl - 1)
      pos = nl + 1
    else
      line = yaml_text:sub(pos)
      pos = #yaml_text + 1
    end
    if line:sub(-1) == "\r" then
      line = line:sub(1, -2)
    end

    local indent = #line:match("^(%s*)")
    local card_value = line:match("^%s*card:%s*(.+)%s*$")
    if card_value then
      flush_current_item()
      pending_card = strip_outer_quotes(card_value)
      if #parsed_items > 0 then
        local key = normalize_card_name(pending_card)
        if key ~= "" then
          if not lookup[key] then lookup[key] = { card = pending_card, entries = {} } end
          for _, it in ipairs(parsed_items) do
            table.insert(lookup[key].entries, { q = it.q, a = it.a })
          end
        end
        parsed_items = {}
      end
    else
      local q_value = line:match("^%s*%-?%s*q:%s*(.*)$")
      local a_value = line:match("^%s*%-?%s*a:%s*(.*)$")
      if q_value ~= nil or a_value ~= nil then
        if current_section then
          flush_current_text()
        end
        if q_value ~= nil then
          if current_item and (trim(current_item.q) ~= "" or trim(current_item.a) ~= "") then
            flush_current_item()
          end
          if not current_item then current_item = { q = "", a = "" } end
          current_section = "q"
          current_key_indent = indent
          current_text = normalize_block_text(q_value)
        else
          if not current_item then current_item = { q = "", a = "" } end
          current_section = "a"
          current_key_indent = indent
          current_text = normalize_block_text(a_value)
        end
      else
        if current_section and indent > current_key_indent then
          local continuation = trim(line)
          if continuation ~= "" then
            if current_text == "" then
              current_text = continuation
            else
              current_text = current_text .. " " .. continuation
            end
          end
        else
          if current_section then
            flush_current_text()
          end
        end
      end
    end
  end

  flush_current_item()

  if pending_card and #parsed_items > 0 then
    local key = normalize_card_name(pending_card)
    if key ~= "" then
      if not lookup[key] then lookup[key] = { card = pending_card, entries = {} } end
      for _, it in ipairs(parsed_items) do
        table.insert(lookup[key].entries, { q = it.q, a = it.a })
      end
    end
    parsed_items = {}
  end

  return lookup
end

local function finish_errata_fetch(lookup, err)
  errata_fetch_in_flight = false
  local callbacks = errata_pending_callbacks
  errata_pending_callbacks = {}
  for _, cb in ipairs(callbacks) do
    pcall(function() cb(lookup, err) end)
  end
end

local function finish_faq_fetch(lookup, err)
  faq_fetch_in_flight = false
  local callbacks = faq_pending_callbacks
  faq_pending_callbacks = {}
  for _, cb in ipairs(callbacks) do
    pcall(function() cb(lookup, err) end)
  end
end

local function fetch_errata_lookup(callback)
  if callback then
    table.insert(errata_pending_callbacks, callback)
  end

  if errata_cache_lookup and (os.time() - errata_cache_time) < ERRATA_CACHE_SECONDS then
    finish_errata_fetch(errata_cache_lookup, nil)
    return
  end

  if errata_fetch_in_flight then
    return
  end
  errata_fetch_in_flight = true

  if not WebRequest or not WebRequest.custom then
    finish_errata_fetch(nil, "WebRequest API not available")
    return
  end

  local headers = { ["Accept"] = "text/plain, text/yaml, */*" }
  local ok, err = pcall(function()
    WebRequest.custom(ERRATA_URL, "GET", true, "", headers, function(response)
      if response and response.is_error then
        local msg = (response and response.text) and response.text or tostring(response)
        finish_errata_fetch(nil, msg)
        return
      end

      local body = (response and response.text) and tostring(response.text) or ""
      if body == "" then
        finish_errata_fetch(nil, "Empty response")
        return
      end

      local lookup = parse_errata_yaml_lookup(body)
      errata_cache_lookup = lookup
      errata_cache_time = os.time()
      finish_errata_fetch(lookup, nil)
    end)
  end)

  if not ok then
    finish_errata_fetch(nil, tostring(err))
  end
end

local function fetch_faq_lookup(callback)
  if callback then
    table.insert(faq_pending_callbacks, callback)
  end

  if faq_cache_lookup and (os.time() - faq_cache_time) < FAQ_CACHE_SECONDS then
    finish_faq_fetch(faq_cache_lookup, nil)
    return
  end

  if faq_fetch_in_flight then
    return
  end
  faq_fetch_in_flight = true

  if not WebRequest or not WebRequest.custom then
    finish_faq_fetch(nil, "WebRequest API not available")
    return
  end

  local headers = { ["Accept"] = "text/plain, text/yaml, */*" }
  local ok, err = pcall(function()
    WebRequest.custom(FAQ_URL, "GET", true, "", headers, function(response)
      if response and response.is_error then
        local msg = (response and response.text) and response.text or tostring(response)
        finish_faq_fetch(nil, msg)
        return
      end

      local body = (response and response.text) and tostring(response.text) or ""
      if body == "" then
        finish_faq_fetch(nil, "Empty response")
        return
      end

      local lookup = parse_faq_yaml_lookup(body)
      faq_cache_lookup = lookup
      faq_cache_time = os.time()
      finish_faq_fetch(lookup, nil)
    end)
  end)

  if not ok then
    finish_faq_fetch(nil, tostring(err))
  end
end

local function show_card_errata(card_obj, player_color)
  local card_label = get_card_label_for_errata(card_obj)
  if card_label == "" then
    broadcastToColor("Errata: Could not determine this card's name.", player_color, {1, 0.4, 0.4})
    return
  end

  fetch_errata_lookup(function(lookup, err)
    if not lookup then
      broadcastToColor("Errata fetch failed: " .. tostring(err or "unknown error"), player_color, {1, 0.4, 0.4})
      return
    end

    local keys = split_slash_keys(card_label)
    local found = false
    for _, k in ipairs(keys) do
      local entry = lookup[k]
      if entry and entry.texts and #entry.texts > 0 then
        found = true
        local title = "Errata: " .. tostring(entry.card or card_label)
        broadcastToAll("=== " .. title .. " ===", {1, 0.75, 0.15})
        for i, text in ipairs(entry.texts) do
          broadcastToAll("- " .. tostring(text), {1, 0.9, 0.4})
          if i < #entry.texts then Wait.time(function() end, 0.05) end
        end
      end
    end
    if not found then
      broadcastToColor("No errata found for " .. card_label .. ".", player_color, {0.8, 0.8, 0.8})
    end
  end)
end

local function show_card_faq(card_obj, player_color)
  local card_label = get_card_label_for_errata(card_obj)
  if card_label == "" then
    broadcastToColor("FAQ: Could not determine this card's name.", player_color, {1, 0.4, 0.4})
    return
  end

  fetch_faq_lookup(function(lookup, err)
    if not lookup then
      broadcastToColor("FAQ fetch failed: " .. tostring(err or "unknown error"), player_color, {1, 0.4, 0.4})
      return
    end

    local keys = split_slash_keys(card_label)
    local found = false
    local q_color = {0.45, 0.8, 1}
    local a_color = {0.6, 1, 0.6}
    for _, k in ipairs(keys) do
      local entry = lookup[k]
      if entry and entry.entries and #entry.entries > 0 then
        found = true
        local title = "FAQ: " .. tostring(entry.card or card_label)
        broadcastToAll("=== " .. title .. " ===", {0.35, 0.7, 1})
        for idx, pair in ipairs(entry.entries) do
          if pair.q and trim(pair.q) ~= "" then
            broadcastToAll("Q" .. idx .. ": " .. tostring(pair.q), q_color)
          end
          if pair.a and trim(pair.a) ~= "" then
            broadcastToAll("A" .. idx .. ": " .. tostring(pair.a), a_color)
          end
          if idx < #entry.entries then
            broadcastToAll(" ", {0.9, 0.9, 0.9})
          end
        end
      end
    end
    if not found then
      broadcastToColor("No FAQ found for " .. card_label .. ".", player_color, {0.8, 0.8, 0.8})
    end
  end)
end

function ErrataFaqService.add_menu_to_card(object)
  if not object then return end

  local object_type = nil
  pcall(function() object_type = object.type end)
  if object_type ~= "Card" then return end

  local guid = nil
  pcall(function() if object.getGUID then guid = object.getGUID() end end)
  if not guid and object.guid then guid = object.guid end
  if not guid then return end

  if errata_menu_patched[guid] then return end

  local card_label = get_card_label_for_errata(object)
  local keys = split_slash_keys(card_label)

  pcall(function()
    local has_errata = false
    local has_faq = false
    if errata_cache_lookup then
      for _, k in ipairs(keys) do
        if errata_cache_lookup[k] then has_errata = true break end
      end
    end
    if faq_cache_lookup then
      for _, k in ipairs(keys) do
        if faq_cache_lookup[k] then has_faq = true break end
      end
    end

    if has_errata then
      object.addContextMenuItem("Show Errata", function(player_color, position, clicked_object)
        local target = clicked_object or object
        show_card_errata(target, player_color)
      end)
    end
    if has_faq then
      object.addContextMenuItem("Show FAQ", function(player_color, position, clicked_object)
        local target = clicked_object or object
        show_card_faq(target, player_color)
      end)
    end
  end)

  errata_menu_patched[guid] = true
end

function ErrataFaqService.scan_cards_for_menu()
  local seen = {}
  for _, object in ipairs(getObjects()) do
    local guid = nil
    if object and object.type == "Card" then
      if object.getGUID then guid = object.getGUID() end
      if not guid and object.guid then guid = object.guid end
      if guid then seen[guid] = true end
      ErrataFaqService.add_menu_to_card(object)
    end
  end

  for guid, _ in pairs(errata_menu_patched) do
    if not seen[guid] then
      errata_menu_patched[guid] = nil
    end
  end
end

function ErrataFaqService.proactive_fetch(on_info, on_warning)
  fetch_errata_lookup(function(_, err)
    if not err then
      if on_info then on_info("Errata YAML pre-fetched and cached") end
      ErrataFaqService.scan_cards_for_menu()
    elseif on_warning then
      on_warning("Failed to pre-fetch errata YAML: " .. tostring(err))
    end
  end)

  fetch_faq_lookup(function(_, err)
    if not err then
      if on_info then on_info("FAQ YAML pre-fetched and cached") end
      ErrataFaqService.scan_cards_for_menu()
    elseif on_warning then
      on_warning("Failed to pre-fetch FAQ YAML: " .. tostring(err))
    end
  end)
end

return ErrataFaqService
