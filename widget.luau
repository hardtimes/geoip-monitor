--!nonstrict

local cachedIp = nil
local cachedCity = nil
local cachedRegion = nil

local function getDisplayText(showCity, showState, showIp, separator)
    local geoParts = {}
    if showCity then
        table.insert(geoParts, cachedCity or "Loading...")
    end
    if showState then
        table.insert(geoParts, cachedRegion or "Loading...")
    end
    
    local geoStr = table.concat(geoParts, ", ")
    
    if (showCity or showState) and showIp then
        if geoStr ~= "" and cachedIp then
            return geoStr .. separator .. cachedIp
        elseif cachedIp then
            return cachedIp
        else
            return geoStr
        end
    elseif (showCity or showState) then
        return geoStr ~= "" and geoStr or "Loading..."
    elseif showIp then
        return cachedIp or "Loading..."
    else
        return ""
    end
end

local function renderWidget()
    local showIp = noctalia.getConfig("show_ip")
    if showIp == nil then showIp = true end

    local showCity = noctalia.getConfig("show_city")
    if showCity == nil then showCity = true end

    local showState = noctalia.getConfig("show_state")
    if showState == nil then showState = true end

    local showIcon = noctalia.getConfig("show_icon")
    if showIcon == nil then showIcon = true end

    local separator = noctalia.getConfig("separator")
    if separator == nil then separator = " | " end

    local container = barWidget.isVertical() and ui.column or ui.row
    local children = {}

    if showIcon then
        table.insert(children, ui.glyph({ name = "globe", size = 14 }))
    end

    local text = getDisplayText(showCity, showState, showIp, separator)
    if text ~= "" then
        table.insert(children, ui.label({ text = text }))
    end

    barWidget.render(container({ gap = 6, align = "center" }, children))
end

function update()
    local intervalSec = noctalia.getConfig("interval") or 5
    noctalia.setUpdateInterval(intervalSec * 1000)

    renderWidget()

    noctalia.runAsync({"curl", "-s", "https://ipwho.is/"}, function(result)
        if result.exitCode == 0 then
            local ip = string.match(result.stdout, '"ip"%s*:%s*"([^"]+)"')
            local city = string.match(result.stdout, '"city"%s*:%s*"([^"]+)"')
            local region = string.match(result.stdout, '"region"%s*:%s*"([^"]+)"')

            if ip then
                cachedIp = ip
            end
            if city then
                cachedCity = city
            end
            if region then
                cachedRegion = region
            end

            renderWidget()
        else
            cachedCity = "Offline"
            cachedRegion = "Offline"
            renderWidget()
        end
    end)
end

function onClick()
    cachedIp = nil
    cachedCity = nil
    cachedRegion = nil
    renderWidget()
    update()
end
