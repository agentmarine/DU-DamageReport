--[[
    Damage Report 3.31d
    A LUA script for Dual Universe

    Created By Dorian Gray
    Ingame: DorianGray
    Discord: Dorian Gray#2623

    3.31d changes:
      [ADD] XS space tanks
      [FIX] arrows showing broken elements

    You can find/update this script on GitHub. Explanations, installation and usage information as well as screenshots can be found there too.
    GitHub: https://github.com/DorianTheGrey/DU-DamageReport

    GNU Public License 3.0. Use whatever you want, be so kind to leave credit.

    Credits & thanks:
        Thanks to Jericho, Dmentia and Archaegeo for learning a lot from their fine scripts.
        Thanks to TheBlacklist for testing and wonderful suggestions.
        SVG patterns by Hero Patterns.
        DU atlas data from Jayle Break.

]]

--[[ 1. USER DEFINED VARIABLES ]]

YourShipsName = "Enter here" --export Enter your ship name here if you want it displayed instead of the ship's ID. YOU NEED TO LEAVE THE QUOTATION MARKS.

SkillRepairToolEfficiency = 0 --export Enter (0-5) your talent "Mining and Inventory -> Equipment Manager -> Repair Tool Efficiency"
SkillRepairToolOptimization = 0 --export Enter your talent "Mining and Inventory -> Equipment Manager -> Repair Tool Optimization"

StatAtmosphericFuelTankHandling = 0 --export (0-5) Enter the LEVEL OF YOUR PLACED ATMOSPHERIC FUEL TANKS (from the builders talent "Piloting -> Atmospheric Flight Technician -> Atmospheric Fuel-Tank Handling")
StatSpaceFuelTankHandling = 0 --export (0-5) Enter the LEVEL OF YOUR PLACED FUEL SPACE TANKS (from the builders talent "Piloting -> Atmospheric Engine Technician -> Space Fuel-Tank Handling")
StatRocketFuelTankHandling = 0 --export (0-5) Enter the LEVEL OF YOUR PLACED FUEL ROCKET TANKS (from the builders talent "Piloting -> Rocket Scientist -> Rocket Booster Fuel Tank Handling")
StatContainerOptimization = 0 --export (0-5) Enter the LEVEL OF YOUR PLACED FUEL TANKS "from the builders talent Mining and Inventory -> Stock Control -> Container Optimization"
StatFuelTankOptimization = 0 --export (0-5) Enter the LEVEL OF YOUR PLACED FUEL TANKS "from the builders talent Mining and Inventory -> Stock Control -> Fuel Tank Optimization"

ShowWelcomeMessage = true --export Do you want the welcome message on the start screen with your name?
DisallowKeyPresses = false --export Need your keys for other scripts/huds and want to prevent Damage Report keypresses to be processed? Then check this. (Usability of the HUD mode will be small.)
AddSummertimeHour = false --export: Is summertime currently enabled in your location? (Adds one hour.)

-- SkillAtmosphericFuelEfficiency = 0 --export Enter (0-5) your talent "Mining and Inventory -> Equipment Manager -> Repair Tool Efficiency"
-- SkillSpaceFuelEfficiency = 0 --export Enter (0-5) your talent "Mining and Inventory -> Equipment Manager -> Repair Tool Efficiency"
-- SkillRocketFuelEfficiency = 0 --export Enter (0-5) your talent "Mining and Inventory -> Equipment Manager -> Repair Tool Efficiency"

--[[ 2. GLOBAL VARIABLES ]]

UpdateDataInterval = 1.0 -- How often shall the data be updated? (Increase if running into CPU issues.)
HighlightBlinkingInterval = 0.5 -- How fast shall highlight arrows of marked elements blink?

ColorPrimary = "FF6700" -- Enter the hexcode of the main color to be used by all views.
ColorSecondary = "FFFFFF" -- Enter the hexcode of the secondary color to be used by all views.
ColorTertiary = "000000" -- Enter the hexcode of the tertiary color to be used by all views.
ColorHealthy = "00FF00" -- Enter the hexcode of the 'healthy' color to be used by all views.
ColorWarning = "FFFF00" -- Enter the hexcode of the 'warning' color to be used by all views.
ColorCritical = "FF0000" -- Enter the hexcode of the 'critical' color to be used by all views.
ColorBackground = "000000" -- Enter the hexcode of the background color to be used by all views.
ColorBackgroundPattern = "4F4F4F" -- Enter the hexcode of the background color to be used by all views.
ColorFuelAtmospheric = "004444" -- Enter the hexcode of the atmospheric fuel color.
ColorFuelSpace = "444400" -- Enter the hexcode of the space fuel color.
ColorFuelRocket = "440044" -- Enter the hexcode of the rocket fuel color.

VERSION = "3.31c"
DebugMode = false
DebugRenderClickareas = true

DBData = {}

core = nil
db = nil
screens = {}
dscreens = {}

Warnings = {}

screenModes = {
    ["flight"] = { id="flight" },
    ["damage"] = { id="damage" },
    ["damageoutline"] = { id="damageoutline" },
    ["fuel"] = { id="fuel" },
    ["cargo"] = { id="cargo" },
    ["agg"] = { id="agg" },
    ["map"] = { id="map" },
    ["time"] = { id="time", activetoggle="true" },
    ["settings1"] = { id="settings1" },
    ["startup"] = { id="startup" },
    ["systems"] = { id="systems" }
}

backgroundModes = { "deathstar", "capsule", "rain", "signal", "hexagon", "diagonal", "diamond", "plus", "dots" }
BackgroundMode ="deathstar"
BackgroundSelected = 1
BackgroundModeOpacity = 0.25

SaveVars = { "dscreens",
                "ColorPrimary", "ColorSecondary", "ColorTertiary",
                "ColorHealthy", "ColorWarning", "ColorCritical",
                "ColorBackground", "ColorBackgroundPattern",
                "ColorFuelAtmospheric", "ColorFuelSpace", "ColorFuelRocket",
                "ScrapTier", "HUDMode", "SimulationMode", "DMGOStretch",
                "HUDShiftU", "HUDShiftV", "colorIDIndex", "colorIDTable",
                "BackgroundMode", "BackgroundSelected", "BackgroundModeOpacity" }

HUDMode = false
HUDShiftU = 0
HUDShiftV = 0
hudSelectedIndex = 0
hudStartIndex = 1
hudArrowSticker = {}
highlightOn = false
highlightID = 0
highlightX = 0
highlightY = 0
highlightZ = 0

SimulationMode = false
OkayCenterMessage = "All systems nominal."
CurrentDamagedPage = 1
CurrentBrokenPage = 1
DamagePageSize = 12
ScrapTier = 1
totalScraps = 0
ScrapTierRepairTimes = { 10, 50, 250, 1250 }

coreWorldOffset = 0
totalShipHP = 0
formerTotalShipHP = -1
totalShipMaxHP = 0
totalShipIntegrity = 100
elementsId = {}
elementsIdList = {}
damagedElements = {}
brokenElements = {}
rE = {}
healthyElements = {}
typeElements = {}
ElementCounter = 0
UseMyElementNames = true
dmgoElements = {}
DMGOMaxElements = 250
DMGOStretch = false
ShipXmin = 99999999
ShipXmax = -99999999
ShipYmin = 99999999
ShipYmax = -99999999
ShipZmin = 99999999
ShipZmax = -99999999

totalShipMass = 0
formerTotalShipMass = -1

formerTime = -1

FuelAtmosphericTanks = {}
FuelSpaceTanks = {}
FuelRocketTanks = {}
FuelAtmosphericTotal = 0
FuelSpaceTotal = 0
FuelRocketTotal = 0
FuelAtmosphericCurrent = 0
FuelSpaceTotalCurrent = 0
FuelRocketTotalCurrent = 0
formerFuelAtmosphericTotal = -1
formerFuelSpaceTotal = -1
formerFuelRocketTotal = -1

hexTable = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
colorIDIndex = 1
colorIDTable = {
    [1] = {
        id="ColorPrimary",
        desc="Main HUD Color",
        basec = "FF6700",
        newc = "FF6700"
    },
    [2] = {
        id="ColorSecondary",
        desc="Secondary HUD Color",
        basec = "FFFFFF",
        newc = "FFFFFF"
    },
    [3] = {
        id="ColorTertiary",
        desc="Tertiary HUD Color",
        basec = "000000",
        newc = "000000"
    },
    [4] = {
        id="ColorHealthy",
        desc="Color code for Healthy/Okay",
        basec = "00FF00",
        newc = "00FF00"
    },
    [5] = {
        id="ColorWarning",
        desc="Color code for Damaged/Warning",
        basec = "FFFF00",
        newc = "FFFF00"
    },
    [6] = {
        id="ColorCritical",
        desc="Color code for Broken/Critical",
        basec = "FF0000",
        newc = "FF0000"
    },
    [7] = {
        id="ColorBackground",
        desc="Background Color",
        basec = "000000",
        newc = "000000"
    },
    [8] = {
        id="ColorBackgroundPattern",
        desc="Background Pattern Color",
        basec = "4F4F4F",
        newc = "4F4F4F"
    },
    [9] = {
        id="ColorFuelAtmospheric",
        desc="Color for Atmo Fuel/Elements",
        basec = "004444",
        newc = "004444"
    },
    [10] = {
        id="ColorFuelSpace",
        desc="Color for Space Fuel/Elements",
        basec = "444400",
        newc = "444400"
    },
    [11] = {
        id="ColorFuelRocket",
        desc="Color for Rocket Fuel/Elements",
        basec = "440044",
        newc = "440044"
    }
}

--[[ 3. HELPER FUNCTIONS ]]

function GenerateCommaValue(amount, kify, postcomma)
    kify = kify or false
    postcomma = postcomma or 1
    local formatted = amount
    if kify == true then
        if string.len(amount)>=4 then
            formatted = string.format("%."..postcomma.."fk", amount/1000)
        else
            formatted = string.format("%."..postcomma.."f", amount)
        end
    else
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k == 0) then break end
        end
    end
    return formatted
end

function PrintConsole(output, highlight)
    highlight = highlight or false
    if highlight then
        system.print(
            "------------------------------------------------------------------------")
    end
    system.print(output)
    if highlight then
        system.print(
            "------------------------------------------------------------------------")
    end
end

function DrawCenteredText(output)
    if screens ~= nil and #screens > 0 then
        for i = 1, #screens, 1 do
            screens[i].element.setCenteredText(output)
        end
    end
end

function ClearConsole()
    for i = 1, 10, 1 do
        PrintConsole()
    end
end

function SwitchScreens(state)
    state = state or "on"
    if screens ~= nil and #screens > 0 then
        for i = 1, #screens, 1 do
            if state == "on" then
                screens[i].element.clear()
                screens[i].element.activate()
                screens[i].active = true
            else
                screens[i].element.clear()
                screens[i].element.deactivate()
                screens[i].active = false
            end
        end
    end
end

--[[ Convert seconds to string (by Jericho) ]]
function GetSecondsString(seconds)
  local seconds = tonumber(seconds)

  if seconds == nil or seconds <= 0 then
    return "-";
  else
    days = string.format("%2.f", math.floor(seconds/(3600*24)));
    hours = string.format("%2.f", math.floor(seconds/3600 - (days*24)));
    mins = string.format("%2.f", math.floor(seconds/60 - (hours*60) - (days*24*60)));
    secs = string.format("%2.f", math.floor(seconds - hours*3600  - (days*24*60*60) - mins *60));
    str = ""
    if tonumber(days) > 0 then str = str .. days.."d " end
    if tonumber(hours) > 0 then str = str .. hours.."h " end
    if tonumber(mins) > 0 then str = str .. mins.."m " end
    if tonumber(secs) > 0 then str = str .. secs .."s" end
    return str
  end
end

function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

--[[ 4. RENDER HELPER FUNCTIONS ]]

--[[ epochTime function by Leodr (clock script), enhanced by Jericho (DU Industry script) ]]
function epochTime()
    function rZ(a)
        if string.len(a) <= 1 then
            return "0" .. a
        else
            return a
        end
    end
    function dPoint(b)
        if not (b == math.floor(b)) then
            return true
        else
            return false
        end
    end
    function lYear(year)
        if not dPoint(year / 4) then
            if dPoint(year / 100) then
                return true
            else
                if not dPoint(year / 400) then
                    return true
                else
                    return false
                end
            end
        else
            return false
        end
    end
    local c = 5;
    local d = 3600;
    local e = 86400;
    local f = 31536000;
    local g = 31622400;
    local h = 2419200;
    local i = 2505600;
    local j = 2592000;
    local k = 2678400;
    local l = {4, 6, 9, 11}
    local m = {1, 3, 5, 7, 8, 10, 12}
    local n = 0;
    local o = 1506816000;
    local q = system.getArkTime()
    _G["formerTime"] = q
    if AddSummertimeHour == true then q = q + 3600 end
    now = math.floor(q + o)
    year = 1970;
    secs = 0;
    n = 0;
    while secs + g < now or secs + f < now do
        if lYear(year + 1) then
            if secs + g < now then
                secs = secs + g;
                year = year + 1;
                n = n + 366
            end
        else
            if secs + f < now then
                secs = secs + f;
                year = year + 1;
                n = n + 365
            end
        end
    end
    secondsRemaining = now - secs;
    monthSecs = 0;
    yearlYear = lYear(year)
    month = 1;
    while monthSecs + h < secondsRemaining or monthSecs + j < secondsRemaining or
        monthSecs + k < secondsRemaining do
        if month == 1 then
            if monthSecs + k < secondsRemaining then
                month = 2;
                monthSecs = monthSecs + k;
                n = n + 31
            else
                break
            end
        end
        if month == 2 then
            if not yearlYear then
                if monthSecs + h < secondsRemaining then
                    month = 3;
                    monthSecs = monthSecs + h;
                    n = n + 28
                else
                    break
                end
            else
                if monthSecs + i < secondsRemaining then
                    month = 3;
                    monthSecs = monthSecs + i;
                    n = n + 29
                else
                    break
                end
            end
        end
        if month == 3 then
            if monthSecs + k < secondsRemaining then
                month = 4;
                monthSecs = monthSecs + k;
                n = n + 31
            else
                break
            end
        end
        if month == 4 then
            if monthSecs + j < secondsRemaining then
                month = 5;
                monthSecs = monthSecs + j;
                n = n + 30
            else
                break
            end
        end
        if month == 5 then
            if monthSecs + k < secondsRemaining then
                month = 6;
                monthSecs = monthSecs + k;
                n = n + 31
            else
                break
            end
        end
        if month == 6 then
            if monthSecs + j < secondsRemaining then
                month = 7;
                monthSecs = monthSecs + j;
                n = n + 30
            else
                break
            end
        end
        if month == 7 then
            if monthSecs + k < secondsRemaining then
                month = 8;
                monthSecs = monthSecs + k;
                n = n + 31
            else
                break
            end
        end
        if month == 8 then
            if monthSecs + k < secondsRemaining then
                month = 9;
                monthSecs = monthSecs + k;
                n = n + 31
            else
                break
            end
        end
        if month == 9 then
            if monthSecs + j < secondsRemaining then
                month = 10;
                monthSecs = monthSecs + j;
                n = n + 30
            else
                break
            end
        end
        if month == 10 then
            if monthSecs + k < secondsRemaining then
                month = 11;
                monthSecs = monthSecs + k;
                n = n + 31
            else
                break
            end
        end
        if month == 11 then
            if monthSecs + j < secondsRemaining then
                month = 12;
                monthSecs = monthSecs + j;
                n = n + 30
            else
                break
            end
        end
    end
    day = 1;
    daySecs = 0;
    daySecsRemaining = secondsRemaining - monthSecs;
    while daySecs + e < daySecsRemaining do
        day = day + 1;
        daySecs = daySecs + e;
        n = n + 1
    end
    hour = 0;
    hourSecs = 0;
    hourSecsRemaining = daySecsRemaining - daySecs;
    while hourSecs + d < hourSecsRemaining do
        hour = hour + 1;
        hourSecs = hourSecs + d
    end
    minute = 0;
    minuteSecs = 0;
    minuteSecsRemaining = hourSecsRemaining - hourSecs;
    while minuteSecs + 60 < minuteSecsRemaining do
        minute = minute + 1;
        minuteSecs = minuteSecs + 60
    end
    second = math.floor(now % 60)
    year = rZ(year)
    month = rZ(month)
    day = rZ(day)
    hour = rZ(hour)
    minute = rZ(minute)
    second = rZ(second)

    return [[<text class="f250mx" x="960" y="540">]]..hour..":".. minute..[[</text>]]..
           [[<text class="f100mx" x="960" y="660">]]..year.."/".. month.."/"..day..[[</text>]]
end


function ToggleHUD()
    if HUDMode == true then
        HUDMode = false
        forceDamageRedraw = true
        hudSelectedIndex = 0
        highlightID = 0
        HideHighlight()
        SetRefresh()
        RenderScreens()
    else
        HUDMode = true
        forceDamageRedraw = true
        hudSelectedIndex = 0
        highlightID = 0
        HideHighlight()
        SetRefresh()
        RenderScreens()
    end
end

function HudDeselectElement()
    hudSelectedIndex = 0
    hudStartIndex = 1
    highlightID = 0
    HideHighlight()
    if HUDMode == true then
        SetRefresh("damage")
        SetRefresh("damageoutline")
        RenderScreens()
    end
end

function ChangeHudSelectedElement(step)
    if HUDMode == true and #rE > 0 then

        hudSelectedIndex = hudSelectedIndex + step
        if hudSelectedIndex < 1 then hudSelectedIndex = 1
        elseif hudSelectedIndex > #rE then hudSelectedIndex = #rE
        end

        if hudSelectedIndex > 9 then
            hudStartIndex = hudSelectedIndex-9
        end
        if hudSelectedIndex ~= 0 then
            highlightID = rE[hudSelectedIndex].id
            if highlightID ~=nil and highlightID ~= 0 then
                -- PrintConsole("CHSE: hudSelectedIndex: "..hudSelectedIndex.." / hudStartIndex: "..hudStartIndex.." / highlightID: "..highlightID)
                HideHighlight()
                elementPosition = vec3(rE[hudSelectedIndex].pos)
                highlightX = elementPosition.x
                highlightY = elementPosition.y
                highlightZ = elementPosition.z
                highlightOn = true
                ShowHighlight()
            end
        end

        SetRefresh("damage")
        SetRefresh("damageoutline")
        RenderScreens()

    end
end

function HideHighlight()
    if #hudArrowSticker > 0 then
        for i in pairs(hudArrowSticker) do
            core.deleteSticker(hudArrowSticker[i])
        end
        hudArrowSticker = {}
    end
end

function ShowHighlight()
    if highlightOn == true and highlightID > 0 then
        table.insert(hudArrowSticker, core.spawnArrowSticker(highlightX + 2, highlightY, highlightZ, "north"))
        table.insert(hudArrowSticker, core.spawnArrowSticker(highlightX, highlightY - 2, highlightZ, "east"))
        table.insert(hudArrowSticker, core.spawnArrowSticker(highlightX - 2, highlightY, highlightZ, "south"))
        table.insert(hudArrowSticker, core.spawnArrowSticker(highlightX, highlightY + 2, highlightZ, "west"))
        table.insert(hudArrowSticker, core.spawnArrowSticker(highlightX, highlightY, highlightZ - 2, "up"))
        table.insert(hudArrowSticker, core.spawnArrowSticker(highlightX, highlightY, highlightZ + 2,"down"))
    end
end

function ToggleHighlight()
    if highlightOn == true then
        highlightOn = false
        HideHighlight()
    else
        highlightOn = true
        ShowHighlight()
    end
end

function SortDamageTables()
    table.sort(damagedElements, function(a, b) return a.missinghp > b.missinghp end)
    table.sort(brokenElements, function(a, b) return a.maxhp > b.maxhp end)
end

function getScraps(damage,commaval)
    commaval = commaval or false
    damage = damage - SkillRepairToolOptimization * 0.05 * damage
    local res = math.ceil( damage / ( 10 * 5^(ScrapTier-1) ) )
    if commaval ==true then
        return GenerateCommaValue(string.format("%.0f", res ), false)
    else
        return res
    end
end

function getRepairTime(damage,buildstring)
    buildstring = buildstring or false
    damage = damage - SkillRepairToolOptimization * 0.05 * damage
    local res = math.ceil(damage / ScrapTierRepairTimes[ScrapTier])
    res = res - ( SkillRepairToolEfficiency * 0.1  * res )
    if buildstring == true then
        return GetSecondsString(string.format("%.0f", res ) )
    else
        return res
    end
end

function UpdateDataDamageoutline()

    dmgoElements = {}

    for i,element in ipairs(brokenElements) do
        if #dmgoElements < DMGOMaxElements then
            local elementPosition = vec3(element.pos)
            local x = elementPosition.x - coreWorldOffset
            local y = elementPosition.y - coreWorldOffset
            local z = elementPosition.z - coreWorldOffset
            if x < ShipXmin then ShipXmin = x end
            if y < ShipYmin then ShipYmin = y end
            if z < ShipZmin then ShipZmin = z end
            if x > ShipXmax then ShipXmax = x end
            if y > ShipYmax then ShipYmax = y end
            if z > ShipZmax then ShipZmax = z end
            table.insert( dmgoElements, {
                id = element.id,
                type = "b",
                size = element.maxhp,
                x = x, y = y, z = z,
                xp = 0, yp = 0, zp = 0,
                u = 0, v = 0
            })
        end
    end

    if #dmgoElements < DMGOMaxElements then
        for i,element in ipairs(damagedElements) do
            if #dmgoElements < DMGOMaxElements then
                local elementPosition = vec3(element.pos)
                local x = elementPosition.x - coreWorldOffset
                local y = elementPosition.y - coreWorldOffset
                local z = elementPosition.z - coreWorldOffset
                if x < ShipXmin then ShipXmin = x end
                if y < ShipYmin then ShipYmin = y end
                if z < ShipZmin then ShipZmin = z end
                if x > ShipXmax then ShipXmax = x end
                if y > ShipYmax then ShipYmax = y end
                if z > ShipZmax then ShipZmax = z end
                table.insert( dmgoElements, {
                    id = element.id,
                    type = "d",
                    size = element.maxhp,
                    x = x, y = y, z = z,
                    xp = 0, yp = 0, zp = 0,
                    u = 0, v = 0
                })
            end
        end
    end

    if #dmgoElements < DMGOMaxElements then
        for i,element in ipairs(healthyElements) do
            if #dmgoElements < DMGOMaxElements then
                local elementPosition = vec3(element.pos)
                local x = elementPosition.x - coreWorldOffset
                local y = elementPosition.y - coreWorldOffset
                local z = elementPosition.z - coreWorldOffset
                if x < ShipXmin then ShipXmin = x end
                if y < ShipYmin then ShipYmin = y end
                if z < ShipZmin then ShipZmin = z end
                if x > ShipXmax then ShipXmax = x end
                if y > ShipYmax then ShipYmax = y end
                if z > ShipZmax then ShipZmax = z end
                table.insert( dmgoElements, {
                    id = element.id,
                    type = "h",
                    size = element.maxhp,
                    x = x, y = y, z = z,
                    xp = 0, yp = 0, zp = 0,
                    u = 0, v = 0
                })
            end
        end
    end

    ShipX = math.abs(ShipXmax-ShipXmin)
    ShipY = math.abs(ShipYmax-ShipYmin)
    ShipZ = math.abs(ShipZmax-ShipZmin)

     for i,element in ipairs(dmgoElements) do
        dmgoElements[i].xp = math.abs(100/(ShipXmax-ShipXmin)*(element.x-ShipXmin))
        dmgoElements[i].yp = math.abs(100/(ShipYmax-ShipYmin)*(element.y-ShipYmin))
        dmgoElements[i].zp = math.abs(100/(ShipZmax-ShipZmin)*(element.z-ShipZmin))
    end

end

function UpdateViewDamageoutline(screen)
    -- Full Width of virtual screen:
    -- UStart = 20
    -- VStart = 180
    -- UDim = 1880
    -- VDim = 840
    -- Adding frames:
    UFrame = 40
    VFrame = 40

    UStart = 20 + UFrame
    VStart = 180 + VFrame
    UDim = 1880 - 2*UFrame
    VDim = 840 - 2*VFrame

    if screen.submode == "top" then
        if DMGOStretch == false then
            local UFactor = UDim/(ShipYmax-ShipYmin)
            local VFactor = VDim/(ShipXmax-ShipXmin)
            if UFactor>=VFactor then
                local cFactor = UFactor/VFactor
                local newUDim = math.floor(UDim/cFactor)
                UStart = UStart+(UDim-newUDim)/2
                for i,element in ipairs(dmgoElements) do
                    dmgoElements[i].u = math.floor(UDim/100/cFactor*element.yp+UStart)
                    dmgoElements[i].v = math.floor(VDim/100*element.xp+VStart)
                end
            else
                local cFactor = VFactor/UFactor
                local newVDim = math.floor(VDim/cFactor)
                VStart = VStart+(VDim-newVDim)/2
                for i,element in ipairs(dmgoElements) do
                    dmgoElements[i].u = math.floor(UDim/100*element.yp+UStart)
                    dmgoElements[i].v = math.floor(VDim/100/cFactor*element.xp+VStart)
                end
            end
        else
            for i,element in ipairs(dmgoElements) do
                dmgoElements[i].u = math.floor(UDim/100*element.yp+UStart)
                dmgoElements[i].v = math.floor(VDim/100*element.xp+VStart)
            end
        end


    elseif screen.submode == "front" then
        if DMGOStretch == false then
            local UFactor = UDim/(ShipXmax-ShipXmin)
            local VFactor = VDim/(ShipZmax-ShipZmin)
            if UFactor>=VFactor then
                local cFactor = UFactor/VFactor
                local newUDim = math.floor(UDim/cFactor)
                UStart = UStart+(UDim-newUDim)/2
                for i,element in ipairs(dmgoElements) do
                    dmgoElements[i].u = math.floor(UDim/100/cFactor*element.xp+UStart)
                    dmgoElements[i].v = math.floor(VDim/100*(100-element.zp)+VStart)
                end
            else
                local cFactor = VFactor/UFactor
                local newVDim = math.floor(VDim/cFactor)
                VStart = VStart+(VDim-newVDim)/2
                for i,element in ipairs(dmgoElements) do
                    dmgoElements[i].u = math.floor(UDim/100*element.xp+UStart)
                    dmgoElements[i].v = math.floor(VDim/100/cFactor*(100-element.zp)+VStart)
                end
            end
        else
            for i,element in ipairs(dmgoElements) do
                dmgoElements[i].u = math.floor(UDim/100*element.xp+UStart)
                dmgoElements[i].v = math.floor(VDim/100*(100-element.zp)+VStart)
            end
        end

    elseif screen.submode == "side" then
        if DMGOStretch == false then
            local UFactor = UDim/(ShipYmax-ShipYmin)
            local VFactor = VDim/(ShipXmax-ShipZmin)
            if UFactor>=VFactor then
                local cFactor = UFactor/VFactor
                local newUDim = math.floor(UDim/cFactor)
                UStart = UStart+(UDim-newUDim)/2
                for i,element in ipairs(dmgoElements) do
                    dmgoElements[i].u = math.floor(UDim/100/cFactor*element.yp+UStart)
                    dmgoElements[i].v = math.floor(VDim/100*(100-element.zp)+VStart)
                end
            else
                local cFactor = VFactor/UFactor
                local newVDim = math.floor(VDim/cFactor)
                VStart = VStart+(VDim-newVDim)/2
                for i,element in ipairs(dmgoElements) do
                    dmgoElements[i].u = math.floor(UDim/100*element.yp+UStart)
                    dmgoElements[i].v = math.floor(VDim/100/cFactor*(100-element.zp)+VStart)
                end
            end
        else
            for i,element in ipairs(dmgoElements) do
                dmgoElements[i].u = math.floor(UDim/100*element.yp+UStart)
                dmgoElements[i].v = math.floor(VDim/100*(100-element.zp)+VStart)
            end
        end
    else
        DrawCenteredText("ERROR: non-existing DMGO mode set.")
        PrintConsole("ERROR: non-existing DMGO mode set.")
        unit.exit()
    end
end

function GetDamageoutlineShip()
    local output = ""

    for i,element in ipairs(dmgoElements) do
        local cclass = ""
        local size = 1

        if element.type == "h" then
            cclass ="ch"
        elseif element.type == "d" then
            cclass = "cw"
        else
            cclass = "cc"
        end
        if element.id == highlightID then
            cclass = "f2"
        end

        if element.size > 0 and element.size < 1000 then
            size = 5
        elseif element.size >= 1000 and element.size < 2000 then
            size = 8
        elseif element.size >= 2000 and element.size < 5000 then
            size = 12
        elseif element.size >= 5000 and element.size < 10000 then
            size = 15
        elseif element.size >= 10000 and element.size < 20000 then
            size = 20
        elseif element.size >= 20000 then
            size = 30
        end
        output = output .. [[<circle cx=]]..element.u..[[ cy=]]..element.v..[[ r=]]..size..[[ class=]]..cclass..[[ />]]
        if element.id == highlightID then
            output = output .. [[<line class=daline x1=20 y1=]]..element.v..[[ x2=1900 y2=]]..element.v..[[ />]]
            output = output .. [[<line class=daline x1=]]..element.u..[[ y1=180 x2=]]..element.u..[[ y2=1020 />]]
        end
    end

    return output
end

function GetContentClickareas(screen)
    local output = ""
    if screen ~= nil and screen.ClickAreas ~= nil and #screen.ClickAreas > 0 then
        for i,ca in ipairs(screen.ClickAreas) do
            output = output ..
                [[<rect class=ll x=]]..ca.x1..[[ width=]]..(ca.x2-ca.x1)..[[ y=]]..ca.y1..[[ height=]]..(ca.y2-ca.y1)..[[ />]]
        end
    end
    return output
end

function GetElement1(x, y, width, height)
    x = x or 0
    y = y or 0
    width = width or 600
    height = height or 600
    local output = ""
    output = output ..
        [[<svg x="]]..x..[[px" y="]]..y..[[px" width="]]..width..[[px" height="]]..height..[[px" viewBox="0 0 200 200">
            <g>
              <path fill="none" stroke="#]]..ColorTertiary..[[" stroke-width="3" stroke-miterlimit="10" d="M138.768,100c0,21.411-17.356,38.768-38.768,38.768c-21.411,0-38.768-17.356-38.768-38.768c0-21.411,17.357-38.768,38.768-38.768"/>
              <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 100 100" to="360 100 100" dur="8s" repeatCount="indefinite"/>
            </g>
            <g>
              <path fill="none" stroke="#]]..ColorTertiary..[[" stroke-width="3" stroke-miterlimit="10" d="M132.605,100c0,18.008-14.598,32.605-32.605,32.605c-18.007,0-32.605-14.598-32.605-32.605c0-18.007,14.598-32.605,32.605-32.605"/>
              <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 100 100" to="360 100 100" dur="4s" repeatCount="indefinite"/>
            </g>
            <g>
              <path fill="none" stroke="#]]..ColorTertiary..[[" stroke-width="3" stroke-miterlimit="10" d="M126.502,100c0,14.638-11.864,26.502-26.502,26.502c-14.636,0-26.501-11.864-26.501-26.502c0-14.636,11.865-26.501,26.501-26.501"/>
              <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 100 100" to="360 100 100" dur="2s" repeatCount="indefinite"/>
            </g>
            <g>
              <path fill="none" stroke="#]]..ColorTertiary..[[" stroke-width="3" stroke-miterlimit="10" d="M120.494,100c0,11.32-9.174,20.494-20.494,20.494c-11.319,0-20.495-9.174-20.495-20.494c0-11.319,9.176-20.495,20.495-20.495"/>
              <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 100 100" to="360 100 100" dur="1s" repeatCount="indefinite"/>
            </g>
        </svg>]]
    return output
end

function GetElement2(x, y)
    x = x or 0
    y = y or 0
    local output = ""
    output = output .. [[<svg x="]]..x..[[" y="]]..y..[["><rect class="f" y="13.25" width="1356.84" height="1.96"/><rect class="f" x="49.27" y="12.27" width="44.12" height="3.93"/><rect class="f" x="142.33" y="10.3" width="109.16" height="7.85"/><rect class="f" x="320.08" y="10.3" width="32.52" height="7.85"/><rect class="f" x="379.01" y="12.27" width="106.26" height="3.93"/><rect class="f" x="565.14" y="12.27" width="15.78" height="3.93"/><rect class="f" x="607.64" y="12.27" width="63.44" height="3.93"/><rect class="f" x="692.98" y="13.25" width="15.14" height="1.96"/><rect class="f" x="743.53" y="12.27" width="68.59" height="3.93"/><rect class="f" x="877.17" y="10.3" width="86.62" height="7.85"/><rect class="f" x="992.13" y="12.27" width="56.35" height="3.93"/><rect class="f" x="1092.6" y="10.3" width="40.9" height="7.85"/><rect class="f" x="1172.14" y="12.27" width="11.59" height="3.93"/><rect class="f" x="1202.08" y="12.27" width="40.25" height="3.93"/><rect class="f" x="1260.69" y="13.25" width="12.83" height="1.96"/><rect class="f" x="1306.74" y="10.3" width="28.98" height="7.85"/><rect class="f" x="16.58" y="1.47" width="122.21" height="1.96"/><rect class="f" x="158.11" y="23.06" width="38.8" height="1.96"/><rect class="f" x="209.79" y="1.47" width="12.56" height="1.96"/><rect class="f" x="251.49" width="66.01" height="1.96"/><rect class="f" x="341.66" width="26.57" height="1.96"/><rect class="f" x="432.14" y="23.06" width="106.91" height="1.96"/><rect class="f" x="584.14" y="23.06" width="23.51" height="1.96"/><rect class="f" x="637.27" y="23.06" width="11.11" height="1.96"/><rect class="f" x="625.69" width="79.68" height="1.96"/><rect class="f" x="732.91" width="38.64" height="1.96"/><rect class="f" x="823.23" y="23.06" width="68.19" height="1.96"/><rect class="f" x="914.76" y="23.06" width="81.03" height="1.96"/><rect class="f" x="1023.69" y="23.06" width="18.35" height="1.96"/><rect class="f" x="1056.05" width="35.32" height="1.96"/><rect class="f" x="1113.05" width="28.98" height="1.96"/><rect class="f" x="1213.09" width="93.65" height="1.96"/><rect class="f" x="1249.26" y="26.5" width="37.19" height="1.96"/></svg>]]
    return output
end

function GetElementLogo(x, y, primaryC, secondaryC, tertiaryC)
    x = x or 812
    y = y or 380
    primaryC = primaryC or "f"
    secondaryC = secondaryC or "f2"
    tertiaryC = tertiaryC or "f3"
    local output = ""
    output = output .. [[
        <svg x="]]..x..[[" y="]]..y..[[">
          <g>
            <g>
                <path class="]]..tertiaryC..[[" d="M909.49,556l0,.63a9.39,9.39,0,0,0-.07,1.37c0,1-.07,2-.07,2H813l.14-5.73c0-1.43.12-2.86.21-3.94s.13-1.79.13-1.79Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M910.2,550.62s-.05.24-.11.61-.19.84-.23,1.34c-.11,1-.25,2-.25,2l-95.72-10.2.72-5.71c.18-1.43.47-2.84.65-3.91s.31-1.78.31-1.78Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M911.46,545.36s-.25,1-.54,1.9l-.44,1.93-94.07-20.42s.63-2.82,1.32-5.62,1.57-5.56,1.57-5.56Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M913.28,540.28s-.34.93-.71,1.84a12.07,12.07,0,0,0-.46,1.28l-.2.58L820.6,513.53s.23-.69.58-1.71.8-2.4,1.35-3.74l2.13-5.36Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M1007.3,578.3a18.4,18.4,0,0,0,.67-1.85c.16-.46.32-.93.45-1.28s.16-.59.16-.59l92.23,27.53-.5,1.74c-.35,1-.81,2.39-1.26,3.76-.9,2.75-2,5.43-2,5.43Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M1002.33,587.93s.53-.85,1.08-1.67,1-1.73,1-1.73l84.19,46.67-2.87,5-3.1,4.85Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M999.09,592.32s.62-.78,1.23-1.57a12.58,12.58,0,0,0,.81-1.1l.36-.51,78.71,55.41s-.41.59-1,1.47-1.45,2.05-2.35,3.17-1.78,2.27-2.45,3.11l-1.12,1.41Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M934.59,516.17a19.52,19.52,0,0,0-1.7,1l-1.15.73-.51.36-54.77-79.15,1.47-1,3.33-2.15c2.4-1.58,4.92-3,4.92-3Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M939.41,513.7l-.56.26a12.84,12.84,0,0,0-1.23.58c-.87.46-1.77.89-1.77.89l-46-84.56,5.13-2.64c1.28-.67,2.6-1.25,3.58-1.7l1.65-.75Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M949.68,510.38s-1,.24-1.92.45a13.32,13.32,0,0,0-1.31.35l-.6.17-26.78-92.46,1.73-.49c1.05-.29,2.43-.7,3.84-1l5.63-1.29Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M935.2,604.24l.53.32c.32.19.78.38,1.22.62s.87.46,1.2.62l.57.25-40.51,87.32-1.64-.76c-1-.46-2.26-1.13-3.54-1.78s-2.57-1.31-3.52-1.84L888,688.1Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M930.61,601.32l.51.36a11.48,11.48,0,0,0,1.13.77l1.15.74a6.12,6.12,0,0,0,.52.33L884.26,686s-.62-.36-1.53-1l-3.34-2.13c-1.22-.77-2.4-1.59-3.27-2.22l-1.47-1Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M985,515.92a18,18,0,0,0-1.74-.95l-1.21-.63-.57-.25,40.84-87.17,1.63.76,3.54,1.8c2.58,1.28,5.06,2.74,5.06,2.74Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M989.55,518.85l-.51-.36c-.31-.21-.69-.53-1.12-.77-.85-.53-1.67-1.08-1.67-1.08l50-82.28,4.85,3.1c1.22.76,2.38,1.61,3.27,2.23l1.46,1Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M997.69,526.13a3.89,3.89,0,0,0-.43-.46l-1-1a11,11,0,0,0-1-1l-.45-.43,66.29-69.8,1.3,1.24c.78.74,1.81,1.75,2.79,2.8l2.73,2.86c.74.78,1.21,1.32,1.21,1.32Z" transform="translate(-813.04 -413.09)"/>
                <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 147 147" to="360 147 147" dur="15s" repeatCount="indefinite"/>
            </g>
            <g>
                <path class="]]..tertiaryC..[[" d="M985,515.92a18,18,0,0,0-1.74-.95l-1.21-.63-.57-.25,40.84-87.17,1.63.76,3.54,1.8c2.58,1.28,5.06,2.74,5.06,2.74Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M939.41,513.7l-.56.26a12.84,12.84,0,0,0-1.23.58c-.87.46-1.77.89-1.77.89l-46-84.56,5.13-2.64c1.28-.67,2.6-1.25,3.58-1.7l1.65-.75Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M910.2,550.62s-.05.24-.11.61-.19.84-.23,1.34c-.11,1-.25,2-.25,2l-95.72-10.2.72-5.71c.18-1.43.47-2.84.65-3.91s.31-1.78.31-1.78Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..tertiaryC..[[" d="M930.61,601.32l.51.36a11.48,11.48,0,0,0,1.13.77l1.15.74a6.12,6.12,0,0,0,.52.33L884.26,686s-.62-.36-1.53-1l-3.34-2.13c-1.22-.77-2.4-1.59-3.27-2.22l-1.47-1Z" transform="translate(-813.04 -413.09)"/>
                <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="360 147 147" to="0 147 147" dur="8s" repeatCount="indefinite"/>
            </g>
            <g>
                <path class="]]..primaryC..[[" d="M873.15,471.64l-.37.36c-.25.22-.6.57-1,1l-3.57,3.76a128.19,128.19,0,0,0-9.79,12.31c-.85,1.16-1.64,2.35-2.39,3.54s-1.52,2.35-2.21,3.5c-1.33,2.34-2.64,4.47-3.59,6.41s-1.82,3.49-2.32,4.65l-.81,1.79-21-9.49s.36-.77,1-2.13,1.6-3.24,2.76-5.51,2.67-4.84,4.26-7.6c.81-1.36,1.72-2.74,2.62-4.15s1.83-2.83,2.82-4.2a153.32,153.32,0,0,1,11.61-14.59c1.74-1.86,3.21-3.39,4.23-4.45.51-.54.93-.95,1.22-1.23l.43-.42Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M985.66,438.77s-.7-.17-1.93-.39-3-.55-5.12-.89a126.07,126.07,0,0,0-15.67-1.33c-2.85-.12-5.71,0-8.38.06s-5.18.36-7.31.52l-5.15.65c-.63.08-1.11.15-1.44.22l-.51.08L936.48,415l.61-.1c.39-.08,1-.16,1.7-.26l6.11-.76c2.53-.21,5.49-.49,8.66-.62s6.54-.22,9.92-.08A149,149,0,0,1,982,414.73c2.52.4,4.61.79,6.07,1.06s2.3.45,2.3.45Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M1077.65,521l-.64-1.87c-.38-1.2-1-2.87-1.82-4.87a122.77,122.77,0,0,0-6.73-14.25,127.15,127.15,0,0,0-8.49-13.26c-1.25-1.75-2.4-3.12-3.16-4.11l-1.22-1.54,17.74-14.66,1.45,1.82c.91,1.18,2.27,2.81,3.75,4.88a149,149,0,0,1,10.06,15.71,144.75,144.75,0,0,1,8,16.91c1,2.37,1.71,4.36,2.16,5.78l.76,2.22Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M1083,574.9s.09-.71.24-1.95.25-3,.41-5.17.18-4.64.26-7.31c0-1.34,0-2.72-.08-4.13s-.06-2.83-.19-4.26-.22-2.85-.33-4.25-.33-2.78-.49-4.11c-.3-2.67-.8-5.14-1.17-7.25s-.84-3.86-1.1-5.08-.45-1.92-.45-1.92l22.31-5.67s.2.83.54,2.28.87,3.52,1.3,6,1,5.44,1.39,8.6c.19,1.58.42,3.21.58,4.87s.26,3.35.39,5,.18,3.38.23,5,.09,3.3.08,4.89c-.08,3.16-.08,6.12-.29,8.65s-.34,4.65-.49,6.13-.28,2.31-.28,2.31Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M1018,669.57l.46-.23c.3-.16.74-.38,1.28-.7l4.5-2.59a128.6,128.6,0,0,0,12.89-9l1.69-1.33,1.61-1.39c1.06-.92,2.12-1.82,3.11-2.72,1.93-1.86,3.8-3.53,5.26-5.11,3-3.07,4.83-5.27,4.83-5.27L1071,656.3s-2.18,2.6-5.73,6.24c-1.73,1.86-3.93,3.86-6.23,6.05-1.18,1.07-2.43,2.14-3.69,3.23l-1.91,1.64-2,1.58a152.35,152.35,0,0,1-15.29,10.69l-5.34,3.07c-.64.38-1.16.65-1.51.83l-.55.28Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M854.89,625.68l1.06,1.66c.34.53.75,1.17,1.23,1.9l1.68,2.4a126.18,126.18,0,0,0,9.88,12.24,130,130,0,0,0,11.36,10.88c1.61,1.41,3.07,2.46,4,3.25l1.55,1.21-13.81,18.42L870,676.21c-1.15-.94-2.86-2.19-4.78-3.87a150.72,150.72,0,0,1-13.45-12.89A145.71,145.71,0,0,1,840.09,645c-.74-1-1.41-2-2-2.84s-1.05-1.63-1.46-2.25c-.8-1.25-1.25-2-1.25-2Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M836.93,574.52l.25,2c.08.62.18,1.38.29,2.24s.32,1.84.5,2.9l.62,3.41c.27,1.2.56,2.47.86,3.78.56,2.63,1.43,5.37,2.21,8.13.93,2.72,1.77,5.47,2.8,8,.5,1.25,1,2.46,1.44,3.6s1,2.19,1.43,3.17c.86,2,1.69,3.56,2.26,4.67s.9,1.76.9,1.76l-20.33,10.79-1.07-2.08c-.68-1.32-1.66-3.21-2.69-5.55l-1.68-3.76c-.57-1.34-1.13-2.78-1.71-4.27-1.22-3-2.24-6.2-3.33-9.43-.93-3.27-1.95-6.53-2.62-9.65-.35-1.56-.7-3.06-1-4.49l-.74-4c-.22-1.26-.42-2.41-.59-3.43s-.25-1.92-.35-2.66c-.19-1.47-.29-2.31-.29-2.31Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M912.27,674.43l1.83.73c1.18.44,2.82,1.16,4.87,1.83s4.4,1.52,7,2.21,5.38,1.42,8.18,2a123,123,0,0,0,15.58,2.27c2.14.16,3.92.32,5.17.33l2,0-.57,23-2.33-.06c-1.47,0-3.59-.2-6.12-.39a146.55,146.55,0,0,1-18.48-2.69c-3.32-.75-6.64-1.51-9.7-2.43s-5.9-1.81-8.31-2.63-4.39-1.65-5.78-2.17l-2.17-.87Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..primaryC..[[" d="M965.68,683.83s.72,0,2-.11l5.17-.41a125.38,125.38,0,0,0,15.53-2.63c2.81-.6,5.55-1.45,8.14-2.18s4.94-1.61,7-2.38l4.84-1.91,1.8-.8,9.31,21.05-2.14.95-5.74,2.27c-2.38.9-5.22,1.84-8.25,2.82s-6.33,1.87-9.66,2.59a151.67,151.67,0,0,1-18.43,3.12c-2.53.23-4.64.38-6.12.49s-2.32.13-2.32.13Z" transform="translate(-813.04 -413.09)"/>
                <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="360 147 147" to="0 147 147" dur="100s" repeatCount="indefinite"/>
            </g>
            <g>
                <path class="]]..secondaryC..[[" d="M930,519.2a3.27,3.27,0,0,0-.5.37l-1.28,1c-1,.85-2.4,2-3.7,3.3-.66.61-1.23,1.31-1.84,1.9s-1.06,1.24-1.52,1.74-.76,1-1,1.27l-.38.49L881.5,500l.74-.95c.49-.59,1.12-1.48,2-2.46s1.84-2.17,2.95-3.37,2.3-2.48,3.57-3.69c2.5-2.45,5.13-4.75,7.17-6.39l2.49-2c.59-.48,1-.72,1-.72Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M977.4,512.38s-.85-.25-2.11-.71c-.63-.2-1.39-.38-2.19-.63s-1.68-.37-2.54-.61-1.76-.3-2.58-.47l-2.28-.3c-.66-.12-1.24-.09-1.63-.14l-.61,0,3.18-48,1.2.09c.76.08,1.86.1,3.16.28s2.82.34,4.43.59,3.34.57,5.05.93,3.42.75,5,1.19,3.06.85,4.31,1.25l4.13,1.4Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M959.68,509.35l-1.08,0-1.1,0c-.4,0-.83.07-1.25.1a22.56,22.56,0,0,0-2.34.22l-1,.13-6.67-47.67,2-.26c1.23-.18,2.88-.31,4.53-.43.83-.05,1.65-.14,2.43-.17l2.11-.05,2.07,0Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M1009.87,551s0-.22-.1-.61a13.68,13.68,0,0,0-.34-1.58c-.16-.65-.28-1.42-.55-2.21s-.43-1.67-.76-2.5c-.14-.42-.28-.85-.41-1.26s-.33-.81-.47-1.2c-.3-.78-.58-1.51-.88-2.11l-.66-1.47-.29-.55L1048.49,516l.55,1.07c.31.7.76,1.69,1.31,2.89s1.13,2.6,1.72,4.13c.29.77.63,1.54.9,2.36s.56,1.64.84,2.47c.6,1.64,1,3.33,1.49,4.91s.77,3.07,1.08,4.34.54,2.34.65,3.1l.22,1.18Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M1003.64,534.22a7.16,7.16,0,0,0-.56-.91c-.36-.52-.77-1.27-1.27-1.95s-1-1.41-1.37-1.9l-.67-.84,37.74-29.87,1.28,1.62c.77,1,1.69,2.35,2.66,3.69s1.8,2.77,2.49,3.81,1.07,1.76,1.07,1.76Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M1009.26,572s.06-.23.15-.64.27-1,.36-1.69a48.31,48.31,0,0,0,.72-5.21c.06-1,.18-1.92.16-2.84s.08-1.76,0-2.49,0-1.34,0-1.76-.06-.66-.06-.66l48-3.06s0,.47.1,1.28,0,2,.08,3.39,0,3,0,4.78-.18,3.61-.32,5.48a100.31,100.31,0,0,1-1.4,10.17c-.22,1.38-.53,2.51-.7,3.31s-.29,1.25-.29,1.25Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M977.17,607.75a55.37,55.37,0,0,0,6.51-2.89c.81-.38,1.55-.89,2.29-1.28s1.37-.89,1.94-1.23,1-.72,1.34-.93l.51-.36L1018.07,640l-1,.7c-.63.43-1.49,1.11-2.6,1.8s-2.38,1.56-3.79,2.39-2.91,1.73-4.47,2.52c-3.09,1.63-6.28,3.08-8.7,4.08l-2.95,1.16a11.58,11.58,0,0,1-1.12.41Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M956.34,610.57a21.57,21.57,0,0,0,2.42.12l1.18,0,1.31,0,1.41,0,1.43-.12a52,52,0,0,0,7.56-1.17l11,46.86-1.25.29-1.44.33-1.88.34c-1.38.24-3,.57-4.72.75s-3.59.48-5.45.58l-2.78.21-2.7.07-2.52.06-2.26-.06c-2.81,0-4.67-.22-4.67-.22Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M913.63,580.53a50,50,0,0,0,3.35,6.31c.5.74.94,1.53,1.46,2.19s.91,1.35,1.36,1.86.76,1,1,1.29.41.47.41.47l-36.81,31-.78-.92-2-2.49c-.83-1-1.69-2.28-2.65-3.61s-1.88-2.81-2.83-4.28A97.28,97.28,0,0,1,869.63,600Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M943.81,608.07l1.1.39c.68.17,1.57.43,2.47.7s1.82.42,2.51.57l1.16.19-8.41,47.39-2.25-.4c-1.35-.28-3.13-.72-4.92-1.12l-4.86-1.37-2.17-.74Z" transform="translate(-813.04 -413.09)"/>
                <path class="]]..secondaryC..[[" d="M909.3,560s.06,1,.07,2.43c0,.72.11,1.57.18,2.47s.25,1.84.33,2.8l.5,2.76c.23.86.39,1.68.56,2.37.41,1.37.64,2.29.64,2.29l-46,14.31L864.35,585c-.33-1.35-.68-3-1.08-4.66s-.66-3.55-1-5.39-.5-3.7-.66-5.45-.27-3.37-.34-4.77l-.12-4.67Z" transform="translate(-813.04 -413.09)"/>
                <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 147 147" to="360 147 147" dur="45s" repeatCount="indefinite"/>
            </g>
            <g>
                <path class="]]..secondaryC..[[" d="M909.3,560s.06,1,.07,2.43c0,.72.11,1.57.18,2.47s.25,1.84.33,2.8l.5,2.76c.23.86.39,1.68.56,2.37.41,1.37.64,2.29.64,2.29l-46,14.31L864.35,585c-.33-1.35-.68-3-1.08-4.66s-.66-3.55-1-5.39-.5-3.7-.66-5.45-.27-3.37-.34-4.77l-.12-4.67Z" transform="translate(-813.04 -413.09)"/>
                <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 147 147" to="360 147 147" dur="4s" repeatCount="indefinite"/>
            </g>
            <g>
                <path class="]]..secondaryC..[[" d="M909.3,560s.06,1,.07,2.43c0,.72.11,1.57.18,2.47s.25,1.84.33,2.8l.5,2.76c.23.86.39,1.68.56,2.37.41,1.37.64,2.29.64,2.29l-46,14.31L864.35,585c-.33-1.35-.68-3-1.08-4.66s-.66-3.55-1-5.39-.5-3.7-.66-5.45-.27-3.37-.34-4.77l-.12-4.67Z" transform="translate(-813.04 -413.09)"/>
                <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="360 147 147" to="0 147 147" dur="12s" repeatCount="indefinite"/>
            </g>
          </g>
        </svg>]]
    return output
end

function GetHeader(headertext)
    headertext = headertext or "ERROR: UNDEFINED"
    local output = ""
    output = output ..
        [[<path class="f" d="M1920,582v-2.42H1820l-3.71,4.66h-49.75l-4.65-4.66H1572.63L1519,526H1462.8l-2.84-6H1154l-6,6H0v74.06H28.43l5.4,5.4H260.42l2.78-5.4H490.58l3.66-4.58H788.61l4.58,4.58h574.75l8.91-11.16h119L1507,600.08h405.19v0l7.77-.1V582.81h-3.22V582Zm-7.77,14.87-.13,0h.13Z" transform="translate(0 -520.01)"/>
            <text class="f50sxx" x="40" y="60">]]..headertext..[[</text>]]
    return output
end

function GetContentBackground(candidate, bgcolor)
    bgColor = ColorBackgroundPattern

    local output = ""

    if candidate == "dots" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='4' height='4' viewBox='0 0 4 4'%3E%3Cpath fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[[' d='M1 3h1v1H1V3zm2-2h1v1H3V1z'%3E%3C/path%3E%3C/svg%3E");]]
    elseif candidate == "rain" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg width='12' height='16' viewBox='0 0 12 16' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M4 .99C4 .445 4.444 0 5 0c.552 0 1 .45 1 .99v4.02C6 5.555 5.556 6 5 6c-.552 0-1-.45-1-.99V.99zm6 8c0-.546.444-.99 1-.99.552 0 1 .45 1 .99v4.02c0 .546-.444.99-1 .99-.552 0-1-.45-1-.99V8.99z' fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[[' fill-rule='evenodd'/%3E%3C/svg%3E");]]
    elseif candidate == "plus" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[['%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");]]
    elseif candidate == "signal" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg width='84' height='48' viewBox='0 0 84 48' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M0 0h12v6H0V0zm28 8h12v6H28V8zm14-8h12v6H42V0zm14 0h12v6H56V0zm0 8h12v6H56V8zM42 8h12v6H42V8zm0 16h12v6H42v-6zm14-8h12v6H56v-6zm14 0h12v6H70v-6zm0-16h12v6H70V0zM28 32h12v6H28v-6zM14 16h12v6H14v-6zM0 24h12v6H0v-6zm0 8h12v6H0v-6zm14 0h12v6H14v-6zm14 8h12v6H28v-6zm-14 0h12v6H14v-6zm28 0h12v6H42v-6zm14-8h12v6H56v-6zm0-8h12v6H56v-6zm14 8h12v6H70v-6zm0 8h12v6H70v-6zM14 24h12v6H14v-6zm14-8h12v6H28v-6zM14 8h12v6H14V8zM0 8h12v6H0V8z' fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[[' fill-rule='evenodd'/%3E%3C/svg%3E");]]
    elseif candidate == "deathstar" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='105' viewBox='0 0 80 105'%3E%3Cg fill-rule='evenodd'%3E%3Cg fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[['%3E%3Cpath d='M20 10a5 5 0 0 1 10 0v50a5 5 0 0 1-10 0V10zm15 35a5 5 0 0 1 10 0v50a5 5 0 0 1-10 0V45zM20 75a5 5 0 0 1 10 0v20a5 5 0 0 1-10 0V75zm30-65a5 5 0 0 1 10 0v50a5 5 0 0 1-10 0V10zm0 65a5 5 0 0 1 10 0v20a5 5 0 0 1-10 0V75zM35 10a5 5 0 0 1 10 0v20a5 5 0 0 1-10 0V10zM5 45a5 5 0 0 1 10 0v50a5 5 0 0 1-10 0V45zm0-35a5 5 0 0 1 10 0v20a5 5 0 0 1-10 0V10zm60 35a5 5 0 0 1 10 0v50a5 5 0 0 1-10 0V45zm0-35a5 5 0 0 1 10 0v20a5 5 0 0 1-10 0V10z' /%3E%3C/g%3E%3C/g%3E%3C/svg%3E");]]
    elseif candidate == "diamond" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='32' viewBox='0 0 16 32'%3E%3Cg fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[['%3E%3Cpath fill-rule='evenodd' d='M0 24h4v2H0v-2zm0 4h6v2H0v-2zm0-8h2v2H0v-2zM0 0h4v2H0V0zm0 4h2v2H0V4zm16 20h-6v2h6v-2zm0 4H8v2h8v-2zm0-8h-4v2h4v-2zm0-20h-6v2h6V0zm0 4h-4v2h4V4zm-2 12h2v2h-2v-2zm0-8h2v2h-2V8zM2 8h10v2H2V8zm0 8h10v2H2v-2zm-2-4h14v2H0v-2zm4-8h6v2H4V4zm0 16h6v2H4v-2zM6 0h2v2H6V0zm0 24h2v2H6v-2z'/%3E%3C/g%3E%3C/svg%3E");]]
    elseif candidate == "hexagon" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='28' height='49' viewBox='0 0 28 49'%3E%3Cg fill-rule='evenodd'%3E%3Cg id='hexagons' fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[[' fill-rule='nonzero'%3E%3Cpath d='M13.99 9.25l13 7.5v15l-13 7.5L1 31.75v-15l12.99-7.5zM3 17.9v12.7l10.99 6.34 11-6.35V17.9l-11-6.34L3 17.9zM0 15l12.98-7.5V0h-2v6.35L0 12.69v2.3zm0 18.5L12.98 41v8h-2v-6.85L0 35.81v-2.3zM15 0v7.5L27.99 15H28v-2.31h-.01L17 6.35V0h-2zm0 49v-8l12.99-7.5H28v2.31h-.01L17 42.15V49h-2z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");]]
    elseif candidate == "capsule" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg width='32' height='26' viewBox='0 0 32 26' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M14 0v3.994C14 7.864 10.858 11 7 11c-3.866 0-7-3.138-7-7.006V0h2v4.005C2 6.765 4.24 9 7 9c2.756 0 5-2.236 5-4.995V0h2zm0 26v-5.994C14 16.138 10.866 13 7 13c-3.858 0-7 3.137-7 7.006V26h2v-6.005C2 17.235 4.244 15 7 15c2.76 0 5 2.236 5 4.995V26h2zm2-18.994C16 3.136 19.142 0 23 0c3.866 0 7 3.138 7 7.006v9.988C30 20.864 26.858 24 23 24c-3.866 0-7-3.138-7-7.006V7.006zm2-.01C18 4.235 20.244 2 23 2c2.76 0 5 2.236 5 4.995v10.01C28 19.765 25.756 22 23 22c-2.76 0-5-2.236-5-4.995V6.995z' fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[[' fill-rule='evenodd'/%3E%3C/svg%3E");]]
    elseif candidate == "diagonal" then
        output=[[background-image: url("data:image/svg+xml,%3Csvg width='6' height='6' viewBox='0 0 6 6' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='%23]]..bgColor..[[' fill-opacity=']]..BackgroundModeOpacity..[[' fill-rule='evenodd'%3E%3Cpath d='M5 0h1L0 6V5zM6 5v1H5z'/%3E%3C/g%3E%3C/svg%3E");]]
    end
    return output;
end

function GetContentDamageHUDOutput()
    local hudWidth = 300
    local hudHeight = 165
    if #damagedElements > 0 or #brokenElements > 0 then hudHeight = 510 end
    local output = ""

    output = output .. [[<svg style="position:absolute;top:]].. HUDShiftV ..[[; left:]] .. HUDShiftU .. [[;" viewBox="0 0 ]] .. hudWidth .. [[ ]] .. hudHeight .. [[" width="]] .. hudWidth .. [[" height="]] .. hudHeight .. [[">
            <style>
                .f22mxxxb { font-size: 22px; font-weight: bold; text-anchor: middle; fill: #]]..ColorTertiary..[[; }
                .f20mxxb { font-size: 20px; font-weight:bold; text-anchor: middle; fill: #]]..ColorSecondary..[[; }
                .f18sxx { font-size: 18px; text-anchor: start; fill: #]]..ColorSecondary..[[; }
                .f18exx { font-size: 18px; text-anchor: end; fill: #]]..ColorSecondary..[[; }
                .f18mh { font-size: 18px; text-anchor: middle; fill: #]]..ColorHealthy..[[; }
                .f18exxb { font-size: 18px; font-weight: bold; text-anchor: end; fill: #]]..ColorSecondary..[[; }
                .f15swb { font-size: 15px; font-weight: bold; text-anchor: start; fill:#]]..ColorWarning..[[; }
                .f15scb { font-size: 15px; font-weight: bold; text-anchor: start; fill:#]]..ColorCritical..[[; }
                .f15ewb { font-size: 15px; font-weight: bold; text-anchor: end; fill:#]]..ColorWarning..[[; }
                .f15ecb { font-size: 15px; font-weight: bold; text-anchor: end; fill:#]]..ColorCritical..[[; }
                .f15sxxxb { font-size: 15px; font-weight: bold; text-anchor: start; fill:#]]..ColorTertiary..[[; }
                .f15exxxb { font-size: 15px; font-weight: bold; text-anchor: end; fill:#]]..ColorTertiary..[[; }
                .f12mxx { font-size: 12px; fill: #]]..ColorSecondary..[[; text-anchor: middle}
                .xfill { fill:#]]..ColorPrimary..[[;}
                .xline { stroke: #]]..ColorPrimary..[[; stroke-width: 1;}
            </style>
        ]]
        output = output .. [[<rect stroke=#]]..ColorPrimary..[[ stroke-width=2 x=0 y=0 rx=10 ry=10 width="]] .. hudWidth .. [[" height="]] .. hudHeight .. [[" fill=#]]..ColorBackground..[[ fill-opacity=0.6 />]] ..
                           [[<rect class=xfill x=0 x=0 y=0 rx=10 ry=10 width=300 height=30 />]] ..
                           [[<rect class=xfill x=0 x=0 y=5 rx=0 ry=0 width=300 height=30 />]] ..
                           [[<text x=150 y=24 class="f20mxxb">]]..(YourShipsName=="Enter here" and ("Ship ID "..ShipID) or YourShipsName) .. [[</text>]] ..
                           [[<circle cx=17 cy=17 r=10 stroke=#]]..ColorBackground..[[ stroke-width=2 fill=none />]]
                            if #brokenElements > 0 then
                                output = output .. [[<svg x="2px" y="2px" width="30px" height="30px" viewBox="0 0 50 50"><path fill="#]]..ColorCritical..[[" d="M43.935,25.145c0-10.318-8.364-18.683-18.683-18.683c-10.318,0-18.683,8.365-18.683,18.683h4.068c0-8.071,6.543-14.615,14.615-14.615c8.072,0,14.615,6.543,14.615,14.615H43.935z"><animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 25 25" to="360 25 25" dur="1s" repeatCount="indefinite"/></path></svg>]]
                            elseif #damagedElements > 0 then
                                output = output .. [[<svg x="2px" y="2px" width="30px" height="30px" viewBox="0 0 50 50"><path fill="#]]..ColorWarning..[[" d="M43.935,25.145c0-10.318-8.364-18.683-18.683-18.683c-10.318,0-18.683,8.365-18.683,18.683h4.068c0-8.071,6.543-14.615,14.615-14.615c8.072,0,14.615,6.543,14.615,14.615H43.935z"><animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 25 25" to="360 25 25" dur="1s" repeatCount="indefinite"/></path></svg>]]
                            else
                                output = output .. [[<svg x="2px" y="2px" width="30px" height="30px" viewBox="0 0 50 50"><path fill="#]]..ColorHealthy..[[" d="M43.935,25.145c0-10.318-8.364-18.683-18.683-18.683c-10.318,0-18.683,8.365-18.683,18.683h4.068c0-8.071,6.543-14.615,14.615-14.615c8.072,0,14.615,6.543,14.615,14.615H43.935z"><animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 25 25" to="360 25 25" dur="1s" repeatCount="indefinite"/></path></svg>]]
                            end

        if #damagedElements > 0 or #brokenElements > 0 then

            output = output .. [[<text x=10 y=55 class="f18sxx">Total Damage</text>]] ..
                               [[<text x=290 y=55 class="f18exxb">]]..GenerateCommaValue(string.format("%.0f", totalShipMaxHP - totalShipHP))..[[</text>]]
            output = output .. [[<text x=10 y=75 class="f18sxx">T]]..ScrapTier..[[ Scrap Needed</text>]] ..
                               [[<text x=290 y=75 class="f18exxb">]]..getScraps(totalShipMaxHP - totalShipHP, true)..[[</text>]]
            output = output .. [[<text x=10 y=95 class="f18sxx">Repair Time</text>]] ..
                               [[<text x=290 y=95 class="f18exxb">]]..getRepairTime(totalShipMaxHP - totalShipHP, true)..[[</text>]]

            output = output .. [[<rect class=xfill x=0 y=105 rx=0 ry=0 width=300 height=40 />]] ..
                               [[<rect fill=#]]..ColorHealthy..[[ stroke=#]]..ColorTertiary..[[ stroke-width=1 x=10 y=110 rx=5 ry=5 width=90 height=30 />]] ..
                               [[<text x=55 y=132 class="f22mxxxb">]]..#healthyElements..[[</text>]] ..
                               [[<rect fill=#]]..ColorWarning..[[ stroke=#]]..ColorTertiary..[[ stroke-width=1 x=105 y=110 rx=5 ry=5 width=90 height=30 />]] ..
                               [[<text x=150 y=132 class="f22mxxxb">]]..#damagedElements..[[</text>]] ..
                               [[<rect fill=#]]..ColorCritical..[[ stroke=#]]..ColorTertiary..[[ stroke-width=1 x=200 y=110 rx=5 ry=5 width=90 height=30 />]] ..
                               [[<text x=245 y=132 class="f22mxxxb">]]..#brokenElements..[[</text>]]
            local j=0

            for currentIndex=hudStartIndex,hudStartIndex+9,1 do
                if rE[currentIndex] ~= nil then
                    v = rE[currentIndex]
                    if v.hp > 0 then
                        output = output .. [[<rect fill=#]]..ColorWarning..[[ fill-opacity=0.2 x=1 y=]]..(147+j*26)..[[ width=298 height=25 />]] ..
                                           [[<text x=10 y=]]..(165+j*26)..[[ class="f15swb">]]..string.format("%.30s", v.name)..[[</text>]] ..
                                           [[<text x=290 y=]]..(165+j*26)..[[ class="f15ewb">]]..GenerateCommaValue(string.format("%.0f", v.missinghp))..[[</text>]]
                        if v.id == highlightID then
                            output = output .. [[<rect fill=#]]..ColorWarning..[[ fill-opacity=1 x=1 y=]]..(147+j*26)..[[ width=298 height=25 />]] ..
                                               [[<text x=10 y=]]..(165+j*26)..[[ class="f15sxxxb">]]..string.format("%.30s", v.name)..[[</text>]] ..
                                               [[<text x=290 y=]]..(165+j*26)..[[ class="f15exxxb">]]..GenerateCommaValue(string.format("%.0f", v.missinghp))..[[</text>]]
                        end
                    else
                        output = output .. [[<rect fill=#]]..ColorCritical..[[ x=1 y=]]..(147+j*26)..[[ fill-opacity=0.2 width=298 height=25 />]] ..
                                           [[<text x=10 y=]]..(165+j*26)..[[ class="f15scb">]]..string.format("%.30s", v.name)..[[</text>]] ..
                                           [[<text x=290 y=]]..(165+j*26)..[[ class="f15ecb">]]..GenerateCommaValue(string.format("%.0f", v.missinghp))..[[</text>]]
                        if v.id == highlightID then
                            highlightX = elementPosition.x - coreWorldOffset
                            highlightY = elementPosition.y - coreWorldOffset
                            highlightZ = elementPosition.z - coreWorldOffset
                            output = output .. [[<rect fill=#]]..ColorCritical..[[ x=1 y=]]..(147+j*26)..[[ fill-opacity=1 width=298 height=25 />]] ..
                                               [[<text x=10 y=]]..(165+j*26)..[[ class="f15sxxxb">]]..string.format("%.30s", v.name)..[[</text>]] ..
                                               [[<text x=290 y=]]..(165+j*26)..[[ class="f15exxxb">]]..GenerateCommaValue(string.format("%.0f", v.missinghp))..[[</text>]]
                        end
                    end
                    j=j+1
                end
            end
            if DisallowKeyPresses == true then
                output = output ..
                    [[<svg x="0" y="408">]] ..
                        [[<rect class=xfill x=0 y=0 rx=0 ry=0 width=300 height=40 />]] ..
                        [[<rect class=xfill x=0 y=22 rx=10 ry=10 width=300 height=80 />]] ..
                        [[<svg x=0 y=3>]] ..
                            [[<text x="150" y="15" class="f12mxx"></text>]] ..
                            [[<text x="150" y="30" class="f12mxx"></text>]] ..
                            [[<text x="150" y="45" class="f12mxx">Keypresses disabled.</text>]] ..
                            [[<text x="150" y="60" class="f12mxx">Change in LUA parameters</text>]] ..
                            [[<text x="150" y="75" class="f12mxx">by unchecking DisallowKeyPresses.</text>]] ..
                            [[<text x="150" y="90" class="f12mxx"></text>]] ..
                        [[<svg>]] ..
                    [[</svg>]]
            else
                output = output ..
                    [[<svg x="0" y="408">]] ..
                        [[<rect class=xfill x=0 y=0 rx=0 ry=0 width=300 height=40 />]] ..
                        [[<rect class=xfill x=0 y=22 rx=10 ry=10 width=300 height=80 />]] ..
                        [[<svg x=0 y=3>]] ..
                            [[<text x="150" y="15" class="f12mxx">Up/down arrows to highlight</text>]] ..
                            [[<text x="150" y="30" class="f12mxx">CTRL + arrows to move HUD</text>]] ..
                            [[<text x="150" y="45" class="f12mxx">Left arrow to toggle HUD Mode</text>]] ..
                            [[<text x="150" y="60" class="f12mxx">ALT+1-4 to set Scrap Tier</text>]] ..
                            [[<text x="150" y="75" class="f12mxx">ALT+8 to reset HUD position</text>]] ..
                            [[<text x="150" y="90" class="f12mxx">ALT+9 to shut script off</text>]] ..
                        [[<svg>]] ..
                    [[</svg>]]
            end
        else
            if DisallowKeyPresses == true then
                output = output ..
                    [[<text x="150" y="60" class="f18mh" fill="#]]..ColorHealthy..[[">]] .. OkayCenterMessage .. [[</text>]] ..
                    [[<text x="150" y="88" class="f18mh" fill="#]]..ColorHealthy..[[">]]..#healthyElements..[[ elements / ]] .. GenerateCommaValue(string.format("%.0f", totalShipMaxHP)) .. [[ HP.</text>]] ..
                    [[<svg x="0" y="100">]] ..
                        [[<rect class=xfill x=0 y=0 rx=0 ry=0 width=300 height=40 />]] ..
                        [[<rect class=xfill x=0 y=35 rx=10 ry=10 width=300 height=30 />]] ..
                        [[<svg x=0 y=3>]] ..
                            [[<text x="150" y="10" class="f12mxx">Keypresses disabled.</text>]] ..
                            [[<text x="150" y="25" class="f12mxx">Change in LUA parameters</text>]] ..
                            [[<text x="150" y="40" class="f12mxx">by unchecking DisallowKeyPresses.</text>]] ..
                            [[<text x="150" y="55" class="f12mxx"></text>]] ..
                        [[<svg>]] ..
                    [[</svg>]]
            else
                output = output ..
                    [[<text x="150" y="60" class="f18mh" fill="#]]..ColorHealthy..[[">]] .. OkayCenterMessage .. [[</text>]] ..
                    [[<text x="150" y="88" class="f18mh" fill="#]]..ColorHealthy..[[">]]..#healthyElements..[[ elements / ]] .. GenerateCommaValue(string.format("%.0f", totalShipMaxHP)) .. [[ HP.</text>]] ..
                    [[<svg x="0" y="100">]] ..
                        [[<rect class=xfill x=0 y=0 rx=0 ry=0 width=300 height=40 />]] ..
                        [[<rect class=xfill x=0 y=35 rx=10 ry=10 width=300 height=30 />]] ..
                        [[<svg x=0 y=3>]] ..
                            [[<text x="150" y="10" class="f12mxx">Left arrow to toggle HUD Mode</text>]] ..
                            [[<text x="150" y="25" class="f12mxx">CTRL + arrows to move HUD</text>]] ..
                            [[<text x="150" y="40" class="f12mxx">ALT+8 to reset HUD position</text>]] ..
                            [[<text x="150" y="55" class="f12mxx">ALT+9 to shut script off</text>]] ..
                        [[<svg>]] ..
                    [[</svg>]]
            end
        end
        output = output .. [[</svg>]]
    return output
end

function GetContentDamageScreen()

    local screenOutput = ""

    -- Draw damage elements
    if #damagedElements > 0 then
        local damagedElementsToDraw = #damagedElements
        if damagedElementsToDraw > DamagePageSize then
            damagedElementsToDraw = DamagePageSize
        end
        if CurrentDamagedPage == math.ceil(#damagedElements / DamagePageSize) then
            damagedElementsToDraw = #damagedElements % DamagePageSize + 12
            if damagedElementsToDraw > 12 then damagedElementsToDraw = damagedElementsToDraw - 12 end
        end
        screenOutput = screenOutput .. [[<rect x="20" y="300" rx="5" ry="5" width="930" height="]] .. (70+(damagedElementsToDraw + 1) * 50) .. [[" fill="#000000" fill-opacity="0.5" style="stroke:#]]..ColorWarning..[[;stroke-width:3;" />]]
        screenOutput = screenOutput .. [[<rect x="30" y="310" rx="5" ry="5" width="910" height="40" fill="#]]..ColorWarning..[[" fill-opacity="0.5" />]]

        if UseMyElementNames == true then screenOutput = screenOutput .. [[<text x="110" y="341" class="f30sxx">Damaged Name</text>]]
        else screenOutput = screenOutput .. [[<text x="110" y="341" class="f30sxx">Damaged Type</text>]]
        end

        screenOutput = screenOutput .. [[<text x="417" y="341" class="f30sxx">HLTH</text><text x="545" y="341" class="f30sxx">DMG</text>]]
        screenOutput = screenOutput .. [[<text x="655" y="341" class="f30sxx">T]]..ScrapTier..[[ SCR</text><text x="790" y="341" class="f30sxx">REPTIME</text>]]

        AddClickArea("damage", {
                    id = "SwitchScrapTier",
                    mode ="damage",
                    x1 = 650,
                    x2 = 775,
                    y1 = 315,
                    y2 = 360
                })

        local i = 0
        for j = 1 + (CurrentDamagedPage - 1) * DamagePageSize, damagedElementsToDraw + (CurrentDamagedPage - 1) * DamagePageSize, 1 do
            i = i + 1
            local DP = damagedElements[j]
            if UseMyElementNames == true then screenOutput = screenOutput .. [[<text x="40" y="]] .. (330 + i * 50) .. [[" class="f25sxx">]] .. string.format("%.23s", DP.name) .. [[</text>]]
            else screenOutput = screenOutput .. [[<text x="40" y="]] .. (330 + i * 50) .. [[" class="f25sxx">]] .. string.format("%.23s", DP.type) .. [[</text>]]
            end
            screenOutput = screenOutput .. [[<text x="485" y="]] .. (330 + i * 50) .. [[" class="f25exx">]] .. DP.percent .. [[%</text>]] ..
                               [[<text x="614" y="]] .. (330 + i * 50) .. [[" class="f25exx">]] .. GenerateCommaValue(string.format("%.0f", DP.missinghp), true) .. [[</text>]] ..
                               [[<text x="734" y="]] .. (330 + i * 50) .. [[" class="f25exx">]] .. getScraps(DP.missinghp, true) .. [[</text>]] ..
                               [[<text x="908" y="]] .. (330 + i * 50) .. [[" class="f25exx">]] .. getRepairTime(DP.missinghp, true) .. [[</text>]] ..
                               [[<line x1="30" x2="940" y1="]] .. (336 + i * 50) .. [[" y2="]] .. (336 + i * 50) .. [[" style="stroke:#]]..ColorSecondary..[[;stroke-opacity:0.2" />]]
        end

        if #damagedElements > DamagePageSize then
            screenOutput = screenOutput ..
                               [[<text x="485" y="]] .. (30+300 + 11 + (damagedElementsToDraw + 1) * 50) .. [[" class="f25mw">Page ]] .. CurrentDamagedPage .. " of " .. math.ceil(#damagedElements / DamagePageSize) ..[[</text>]]

            if CurrentDamagedPage < math.ceil(#damagedElements / DamagePageSize) then
                screenOutput = screenOutput .. [[<svg x="30" y="]] .. (300 + 11 + (damagedElementsToDraw + 1) * 50) .. [[">
                            <rect x="0" y="0" rx="10" ry="10" width="200" height="50" style="fill:#]]..ColorWarning..[[;" />
                            <svg x="80" y="15"><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>
                        </svg>]]
                AddClickArea("damage", {
                    id = "DamagedPageDown",
                    mode ="damage",
                    x1 = 65,
                    x2 = 260,
                    y1 = 290 + (damagedElementsToDraw + 1) * 50,
                    y2 = 290 + 50 + (damagedElementsToDraw + 1) * 50
                })
            else
                DisableClickArea("DamagedPageDown","damage")
            end

            if CurrentDamagedPage > 1 then
                screenOutput = screenOutput .. [[<svg x="740" y="]] .. (300 + 11 + (damagedElementsToDraw + 1) * 50) .. [[">
                            <rect x="0" y="0" rx="10" ry="10" width="200" height="50" style="fill:#]]..ColorWarning..[[;" />
                            <svg x="80" y="15"><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>
                        </svg>]]
                AddClickArea("damage", {
                    id = "DamagedPageUp",
                    mode ="damage",
                    x1 = 750,
                    x2 = 950,
                    y1 = 290 + (damagedElementsToDraw + 1) * 50,
                    y2 = 290 + 50 + (damagedElementsToDraw + 1) * 50
                })
            else
                DisableClickArea("DamagedPageUp","damage")
            end
        end
    end

    -- Draw broken elements
    if #brokenElements > 0 then
        local brokenElementsToDraw = #brokenElements
        if brokenElementsToDraw > DamagePageSize then
            brokenElementsToDraw = DamagePageSize
        end
        if CurrentBrokenPage == math.ceil(#brokenElements / DamagePageSize) then
            brokenElementsToDraw = #brokenElements % DamagePageSize + 12
            if brokenElementsToDraw > 12 then brokenElementsToDraw = brokenElementsToDraw - 12 end
        end
        screenOutput = screenOutput .. [[<rect x="970" y="300" rx="5" ry="5" width="930" height="]] .. (70+(brokenElementsToDraw + 1) * 50) .. [[" fill="#000000" fill-opacity="0.5" style="stroke:#]]..ColorCritical..[[;stroke-width:3;" />]]
        screenOutput = screenOutput .. [[<rect x="980" y="310" rx="5" ry="5" width="910" height="40" fill="#]]..ColorCritical..[[" fill-opacity="0.5" />]]

        if UseMyElementNames == true then screenOutput = screenOutput .. [[<text x="1070" y="341" class="f30sxx">Broken Name</text>]]
        else screenOutput = screenOutput .. [[<text x="1070" y="341" class="f30sxx">Broken Type</text>]]
        end

        screenOutput = screenOutput .. [[<text x="1495" y="341" class="f30sxx">DMG</text>]]
        screenOutput = screenOutput .. [[<text x="1605" y="341" class="f30sxx">T]]..ScrapTier..[[ SCR</text><text x="1740" y="341" class="f30sxx">REPTIME</text>]]

        AddClickArea("damage", {
                    id = "SwitchScrapTier2",
                    mode ="damage",
                    x1 = 1570,
                    x2 = 1690,
                    y1 = 315,
                    y2 = 360
                })

        local i = 0
        for j = 1 + (CurrentBrokenPage - 1) * DamagePageSize, brokenElementsToDraw + (CurrentBrokenPage - 1) * DamagePageSize, 1 do
            i = i + 1
            local DP = brokenElements[j]
            if UseMyElementNames == true then screenOutput = screenOutput .. [[<text x="1000" y="]] .. (330 + i * 50) .. [[" class="f25sxx">]] .. string.format("%.30s", DP.name) .. [[</text>]]
            else screenOutput = screenOutput .. [[<text x="1000" y="]] .. (330 + i * 50) .. [[" class="f25sxx">]] .. string.format("%.30s", DP.type) .. [[</text>]]
            end
            screenOutput = screenOutput .. [[<text x="1564" y="]] .. (330 + i * 50) .. [[" class="f25exx">]] .. GenerateCommaValue(string.format("%.0f", DP.missinghp), true) .. [[</text>]] ..
                               [[<text x="1684" y="]] .. (330 + i * 50) .. [[" class="f25exx">]] .. getScraps(DP.missinghp, true) .. [[</text>]] ..
                               [[<text x="1858" y="]] .. (330 + i * 50) .. [[" class="f25exx">]] .. getRepairTime(DP.missinghp, true) .. [[</text>]] ..
                               [[<line x1="980" x2="1890" y1="]] .. (336 + i * 50) .. [[" y2="]] .. (336 + i * 50) .. [[" style="stroke:#]]..ColorSecondary..[[;stroke-opacity:0.2" />]]
        end



        if #brokenElements > DamagePageSize then
            screenOutput = screenOutput ..
                               [[<text x="1435" y="]] .. (30+300 + 11 + (brokenElementsToDraw + 1) * 50) .. [[" class="f25mr">Page ]] .. CurrentBrokenPage .. " of " .. math.ceil(#brokenElements / DamagePageSize) .. [[</text>]]

            if CurrentBrokenPage > 1 then
                screenOutput = screenOutput .. [[<svg x="1690" y="]] .. (300 + 11 + (brokenElementsToDraw + 1) * 50) .. [[">
                            <rect x="0" y="0" rx="10" ry="10" width="200" height="50" style="fill:#]]..ColorCritical..[[;" />
                            <svg x="80" y="15"><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>
                        </svg>]]
                AddClickArea("damage", {
                    id = "BrokenPageUp",
                    mode ="damage",
                    x1 = 1665,
                    x2 = 1865,
                    y1 = 290 + (brokenElementsToDraw + 1) * 50,
                    y2 = 290 + 50 + (brokenElementsToDraw + 1) * 50
                })
            else
                DisableClickArea("BrokenPageUp", "damage")
            end

            if CurrentBrokenPage < math.ceil(#brokenElements / DamagePageSize) then
                screenOutput = screenOutput .. [[<svg x="980" y="]] .. (300 + 11 + (brokenElementsToDraw + 1) * 50) .. [[">
                            <rect x="0" y="0" rx="10" ry="10" width="200" height="50" style="fill:#]]..ColorCritical..[[;" />
                            <svg x="80" y="15"><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>
                        </svg>]]
                AddClickArea("damage", {
                    id = "BrokenPageDown",
                    mode ="damage",
                    x1 = 980,
                    x2 = 1180,
                    y1 = 290 + (brokenElementsToDraw + 1) * 50,
                    y2 = 290 + 50 + (brokenElementsToDraw + 1) * 50
                })
            else
                DisableClickArea("BrokenPageDown", "damage")
            end
        end

    end

    -- Draw summary
    if #damagedElements > 0 or #brokenElements > 0 then
        local dWidth = math.floor(1878/#elementsIdList*#damagedElements)
        local bWidth = math.floor(1878/#elementsIdList*#brokenElements)
        local hWidth = 1878-dWidth-bWidth+1

        screenOutput = screenOutput .. [[<rect x="20" y="180" rx="0" ry="0" width="1880" height="100" fill="#000000" fill-opacity="1.0" style="stroke:#FF6700;stroke-width:0;" />]]
        screenOutput = screenOutput .. [[<svg><rect style="stroke: #]]..ColorWarning..[[;stroke-width:5px;" x="21" y="180" rx="0" ry="0" width="]]..dWidth..[[" height="100" fill="#]]..ColorWarning..[[" fill-opacity="0.2" /></svg>]]
        screenOutput = screenOutput .. [[<rect x="]]..(21+dWidth)..[[" y="180" rx="0" ry="0" width="]]..hWidth..[[" height="100" fill="#]]..ColorHealthy..[[" fill-opacity="0.2" />]]
        screenOutput = screenOutput .. [[<rect style="stroke: #]]..ColorCritical..[[;stroke-width:5px;" x="]]..(21+dWidth+hWidth-1)..[[" y="180" rx="0" ry="0" width="]]..bWidth..[[" height="100" fill="#]]..ColorCritical..[[" fill-opacity="0.2" />]]

        if #damagedElements > 0 then
            screenOutput = screenOutput .. [[<text x="]]..(21+dWidth/2)..[[" y="246" class="f60m" fill="#]]..ColorWarning..[[">]]..#damagedElements..[[</text>]]
        end
        if #healthyElements > 0 then
            screenOutput = screenOutput .. [[<text x="]]..(21+dWidth+hWidth/2)..[[" y="246" class="f60m" fill="#]]..ColorHealthy..[[">]]..#healthyElements..[[</text>]]
        end
        if #brokenElements > 0 then
            screenOutput = screenOutput .. [[<text x="]]..(21+dWidth+hWidth-1+bWidth/2)..[[" y="246" class="f60m" fill="#]]..ColorCritical..[[">]]..#brokenElements..[[</text>]]
        end

        screenOutput = screenOutput .. [[<rect x="20" y="180" rx="0" ry="0" width="1880" height="100" fill="#000000" fill-opacity="0" style="stroke:#FF6700;stroke-width:0;" />]]

        screenOutput = screenOutput .. [[<text x="960" y="140" class="f36mxx">]] ..
                                        GenerateCommaValue(string.format("%.0f", totalShipMaxHP - totalShipHP)) .. [[ HP damage in total ]] ..
                                        getScraps(totalShipMaxHP - totalShipHP, true) .. [[ T]]..ScrapTier..[[ scraps needed. ]] ..
                                        getRepairTime(totalShipMaxHP - totalShipHP, true) .. [[ projected repair time.</text>]]
    else
        screenOutput = screenOutput .. GetElementLogo(812, 380, "ch", "ch", "ch") ..
                                            [[<text x="960" y="320" class="f50m" fill="#]]..ColorHealthy..[[">]] .. OkayCenterMessage .. [[</text>]] ..
                                            [[<text x="960" y="760" class="f50m" fill="#]]..ColorHealthy..[[">]]..#healthyElements..[[ elements stand ]] .. GenerateCommaValue(string.format("%.0f", totalShipMaxHP)) .. [[ HP strong.</text>]]
    end

    forceDamageRedraw = false

    return screenOutput
end

function ActionStopengines()
    if DisallowKeyPresses == true then return end
    ToggleHUD()
end

function ActionStrafeRight()
    if DisallowKeyPresses == true then return end
    if KeyCTRLPressed == true then
        if HUDShiftU < 4000 then
            HUDShiftU = HUDShiftU + 50
            SaveToDatabank()
            RenderScreens()
        end
    else
        HudDeselectElement()
    end
end

function ActionStrafeLeft()
    if DisallowKeyPresses == true then return end
    if KeyCTRLPressed == true then
        if HUDShiftU >= 50 then
            HUDShiftU = HUDShiftU - 50
            SaveToDatabank()
            RenderScreens()
            end
        else
            ToggleHUD()
        end
end

function ActionDown()
    if DisallowKeyPresses == true then return end
    if KeyCTRLPressed == true then
        if HUDShiftV < 4000 then
            HUDShiftV = HUDShiftV + 50
            SaveToDatabank()
            RenderScreens()
        end
    else
        ChangeHudSelectedElement(1)
    end
end

function ActionUp()
    if DisallowKeyPresses == true then return end
    if KeyCTRLPressed == true then
        if HUDShiftV >= 50 then
            HUDShiftV = HUDShiftV - 50
            SaveToDatabank()
            RenderScreens()
        end
    else
        ChangeHudSelectedElement(-1)
    end
end

function ActionOption1()
    if DisallowKeyPresses == true then return end
    ScrapTier = 1
    SetRefresh("damage")
    RenderScreens("damage")
end

function ActionOption2()
    if DisallowKeyPresses == true then return end
    ScrapTier = 2
    SetRefresh("damage")
    RenderScreens("damage")
end

function ActionOption3()
    if DisallowKeyPresses == true then return end
    ScrapTier = 3
    SetRefresh("damage")
    RenderScreens("damage")
end

function ActionOption4()
    if DisallowKeyPresses == true then return end
    ScrapTier = 4
    SetRefresh("damage")
    RenderScreens("damage")
end

function ActionOption8()
    if DisallowKeyPresses == true then return end
    HUDShiftU=0
    HUDShiftV=0
    SetRefresh("damage")
    RenderScreens("damage")
end

function ActionOption9()
    if DisallowKeyPresses == true then return end
    SaveToDatabank()
    SwitchScreens("off")
    unit.exit()
end

--[[ 5. PROCESSING FUNCTIONS ]]

function InitiateSlots()
    for slot_name, slot in pairs(unit) do
        if type(slot) == "table" and type(slot.export) == "table" and
            slot.getElementClass then
            local elementClass = slot.getClass():lower()
            if elementClass:find("coreunit") then
                core = slot
                local coreHP = core.getMaxHitPoints()
                if coreHP > 10000 then
                    coreWorldOffset = 128
                elseif coreHP > 1000 then
                    coreWorldOffset = 64
                elseif coreHP > 150 then
                    coreWorldOffset = 32
                else
                    coreWorldOffset = 16
                end
            elseif elementClass == 'databankunit' then
                db = slot
            elseif elementClass == "screenunit" then
                local iScreenMode = "startup"
                screens[#screens + 1] = {
                    element = slot,
                    id = slot.getLocalId(),
                    mode = iScreenMode,
                    submode = "",
                    ClickAreas = {},
                    refresh = true,
                    active = false,
                    fuelA = true,
                    fuelS = true,
                    fuelR = true,
                    fuelIndex = 1
                }
            end
        end
    end
end

function LoadFromDatabank()
    if db == nil then
        return
    else
        for _, data in pairs(SaveVars) do
            if db.hasKey(data) then
                local jData = json.decode( db.getStringValue(data) )
                if jData ~= nil then
                    if data == "YourShipsName" or data == "AddSummertimeHour" or data == "UpdateDataInterval" or data == "HighlightBlinkingInterval" or
                        data == "SkillRepairToolEfficiency" or data == "SkillRepairToolOptimization" or data == "SkillAtmosphericFuelEfficiency" or
                        data == "SkillSpaceFuelEfficiency" or data == "SkillRocketFuelEfficiency" or data == "StatAtmosphericFuelTankHandling" or
                        data == "StatSpaceFuelTankHandling" or data ==  "StatRocketFuelTankHandling"
                    then
                        -- Nada
                    else
                        _G[data] = jData
                    end
                end
            end
        end

        for i,v in ipairs(screens) do
            for j,dv in ipairs(dscreens) do
                if screens[i].id == dscreens[j].id then
                    screens[i].mode = dscreens[j].mode
                    screens[i].submode = dscreens[j].submode
                    screens[i].active = dscreens[j].active
                    screens[i].refresh = true
                    screens[i].fuelA = dscreens[j].fuelA
                    screens[i].fuelS = dscreens[j].fuelS
                    screens[i].fuelR = dscreens[j].fuelR
                    screens[i].fuelIndex = dscreens[j].fuelIndex
                end
            end
        end
    end
end

function SaveToDatabank()
    if db == nil then
        return
    else
        dscreens = {}
        for i,screen in ipairs(screens) do
            dscreens[i] = {}
            dscreens[i].id = screen.id
            dscreens[i].mode = screen.mode
            dscreens[i].submode = screen.submode
            dscreens[i].active = screen.active
            dscreens[i].fuelA = screen.fuelA
            dscreens[i].fuelS = screen.fuelS
            dscreens[i].fuelR = screen.fuelR
            dscreens[i].fuelIndex = screen.fuelIndex
        end

        db.clear()

        for _, data in pairs(SaveVars) do
            db.setStringValue(data, json.encode(_G[data]))
        end

    end
end

function InitiateScreens()
    if screens ~= nil and #screens > 0 then
        for i = 1, #screens, 1 do
            screens[i] = CreateClickAreasForScreen(screens[i])
        end
    end
end

function UpdateTypeData()
    FuelAtmosphericTanks = {}
    FuelSpaceTanks = {}
    FuelRocketTanks = {}

    FuelAtmosphericTotal = 0
    FuelAtmosphericCurrent = 0
    FuelSpaceTotal = 0
    FuelSpaceCurrent = 0
    FuelRocketCurrent = 0
    FuelRocketTotal = 0

    local weightAtmosphericFuel = 4
    local weightSpaceFuel = 6
    local weightRocketFuel = 0.8

    if StatContainerOptimization > 0 then
        weightAtmosphericFuel = weightAtmosphericFuel - 0.05 * StatContainerOptimization * weightAtmosphericFuel
        weightSpaceFuel = weightSpaceFuel - 0.05 * StatContainerOptimization * weightSpaceFuel
        weightRocketFuel = weightRocketFuel - 0.05 * StatContainerOptimization * weightRocketFuel
    end
    if StatFuelTankOptimization > 0 then
        weightAtmosphericFuel = weightAtmosphericFuel - 0.05 * StatFuelTankOptimization * weightAtmosphericFuel
        weightSpaceFuel = weightSpaceFuel - 0.05 * StatFuelTankOptimization * weightSpaceFuel
        weightRocketFuel = weightRocketFuel - 0.05 * StatFuelTankOptimization * weightRocketFuel
    end

    for i, id in ipairs(typeElements) do
        local idName = core.getElementNameById(id) or ""
        local idType = core.getElementDisplayNameById(id) or ""
        local idPos = core.getElementPositionById(id) or 0
        local idHP = core.getElementHitPointsById(id) or 0
        local idMaxHP = core.getElementMaxHitPointsById(id) or 0
        local idMass = core.getElementMassById(id) or 0

        local baseSize = ""
        local baseVol = 0
        local baseMass = 0
        local cMass = 0
        local cVol = 0

        if idType == "Atmospheric Fuel Tank" then
            if idMaxHP > 10000 then
                baseSize = "L"
                baseMass = 5480
                baseVol = 12800
            elseif idMaxHP > 1300 then
                baseSize = "M"
                baseMass = 988.67
                baseVol = 1600
            elseif idMaxHP > 150 then
                baseSize = "S"
                baseMass = 182.67
                baseVol = 400
            else
                baseSize = "XS"
                baseMass = 35.03
                baseVol = 100
            end
            if StatAtmosphericFuelTankHandling > 0 then
                baseVol = 0.2 * StatAtmosphericFuelTankHandling * baseVol + baseVol
            end
            cMass = idMass - baseMass
            if cMass <=10 then cMass = 0 end
            cVol = string.format("%.0f", cMass / weightAtmosphericFuel)
            cPercent = string.format("%.1f", math.floor(100/baseVol * tonumber(cVol)))
            table.insert(FuelAtmosphericTanks, {
                type = 1,
                id = id,
                name = idName,
                maxhp = idMaxHP,
                hp = GetHPforElement(id),
                pos = idPos,
                size = baseSize,
                mass = baseMass,
                vol = baseVol,
                cvol = cVol,
                percent = cPercent
            })
            if idHP > 0 then
                FuelAtmosphericCurrent = FuelAtmosphericCurrent + cVol
            end
            FuelAtmosphericTotal = FuelAtmosphericTotal + baseVol
        elseif idType == "Space Fuel Tank" then
            if idMaxHP > 10000 then
                baseSize = "L"
                baseMass = 5480
                baseVol = 12800
            elseif idMaxHP > 1300 then
                baseSize = "M"
                baseMass = 988.67
                baseVol = 1600
            elseif idMaxHP > 150 then
                baseSize = "S"
                baseMass = 182.67
                baseVol = 400
            else
                baseSize = "XS"
                baseMass = 35.03
                baseVol = 100
            end
            if StatSpaceFuelTankHandling > 0 then
                baseVol = 0.2 * StatSpaceFuelTankHandling * baseVol + baseVol
            end
            cMass = idMass - baseMass
            if cMass <=10 then cMass = 0 end
            cVol = string.format("%.0f", cMass / weightSpaceFuel)
            cPercent = string.format("%.1f", (100/baseVol * tonumber(cVol)))
            table.insert(FuelSpaceTanks, {
                type = 2,
                id = id,
                name = idName,
                maxhp = idMaxHP,
                hp = GetHPforElement(id),
                pos = idPos,
                size = baseSize,
                mass = baseMass,
                vol = baseVol,
                cvol = cVol,
                percent = cPercent
            })
            if idHP > 0 then
                FuelSpaceCurrent = FuelSpaceCurrent + cVol
            end
            FuelSpaceTotal = FuelSpaceTotal + baseVol
        elseif idType == "Rocket Fuel Tank" then
            if idMaxHP > 65000 then
                baseSize = "L"
                baseMass = 25740
                baseVol = 50000
            elseif idMaxHP > 6000 then
                baseSize = "M"
                baseMass = 4720
                baseVol = 6400
            elseif idMaxHP > 700 then
                baseSize = "S"
                baseMass = 886.72
                baseVol = 800
            else
                baseSize = "XS"
                baseMass = 173.42
                baseVol = 400
            end
            if StatRocketFuelTankHandling > 0 then
                baseVol = 0.1 * StatRocketFuelTankHandling * baseVol + baseVol
            end
            cMass = idMass - baseMass
            if cMass <=10 then cMass = 0 end
            cVol = string.format("%.0f", cMass / weightRocketFuel)
            cPercent = string.format("%.1f", (100/baseVol * tonumber(cVol)))
            table.insert(FuelRocketTanks, {
                type = 3,
                id = id,
                name = idName,
                maxhp = idMaxHP,
                hp = GetHPforElement(id),
                pos = idPos,
                size = baseSize,
                mass = baseMass,
                vol = baseVol,
                cvol = cVol,
                percent = cPercent
            })
            if idHP > 0 then
                FuelRocketCurrent = FuelRocketCurrent + cVol
            end
            FuelRocketTotal = FuelRocketTotal + baseVol
        end

    end

    if FuelAtmosphericCurrent ~= formerFuelAtmosphericCurrent then
        SetRefresh("fuel")
        formerFuelAtmosphericCurrent = FuelAtmosphericCurrent
    end
    if FuelSpaceCurrent ~= formerFuelSpaceCurrent then
        SetRefresh("fuel")
        formerFuelSpaceCurrent = FuelSpaceCurrent
    end
    if FuelRocketCurrent ~= formerFuelRocketCurrent then
        SetRefresh("fuel")
        formerFuelRocketCurrent = FuelRocketCurrent
    end



end

function UpdateDamageData(initial)

    initial = initial or false

    if SimulationActive == true then return end

    local formerTotalShipHP = totalShipHP
    totalShipHP = 0
    totalShipMaxHP = 0
    totalShipIntegrity = 100
    damagedElements = {}
    brokenElements = {}
    healthyElements = {}
    if initial == true then
        typeElements = {}
    end

    ElementCounter = 0

    elementsIdList = core.getElementIdList()

    for i, id in pairs(elementsIdList) do

        ElementCounter = ElementCounter + 1

        local idName = core.getElementNameById(id)

        local idType = core.getElementDisplayNameById(id)
        local idPos = core.getElementPositionById(id)
        local idHP = core.getElementHitPointsById(id)
        local idMaxHP = core.getElementMaxHitPointsById(id)

        if SimulationMode == true then
            SimulationActive = true
            local dice = math.random(0, 10)
            if dice < 2 and #brokenElements < 30 then
                idHP = 0
            elseif dice >= 2 and dice < 4 and #damagedElements < 30 then
                idHP = math.random(1, math.ceil(idMaxHP))
            else
                idHP = idMaxHP
            end
        end

        totalShipHP = totalShipHP + idHP
        totalShipMaxHP = totalShipMaxHP + idMaxHP

        if idMaxHP - idHP > constants.epsilon then

            if idHP > 0 then
                table.insert(damagedElements, {
                    id = id,
                    name = idName,
                    type = idType,
                    counter = ElementCounter,
                    hp = idHP,
                    maxhp = idMaxHP,
                    missinghp = idMaxHP - idHP,
                    percent = math.ceil(100 / idMaxHP * idHP),
                    pos = idPos
                })
            else
                table.insert(brokenElements, {
                    id = id,
                    name = idName,
                    type = idType,
                    counter = ElementCounter,
                    hp = idHP,
                    maxhp = idMaxHP,
                    missinghp = idMaxHP - idHP,
                    percent = 0,
                    pos = idPos
                })
            end
        else
            table.insert(healthyElements, {
                    id = id,
                    name = idName,
                    type = idType,
                    counter = ElementCounter,
                    hp = idHP,
                    maxhp = idMaxHP,
                    pos = idPos
                })
            if id == highlightID then
                highlightID = 0
                highlightOn = false
                HideHighlight()
                hudSelectedIndex = 0
            end
        end

        if initial == true then
            if
                idType == "Atmospheric Fuel Tank" or
                idType == "Space Fuel Tank" or
                idType == "Rocket Fuel Tank"
            then
               table.insert(typeElements, id)
            end
        end
    end

    SortDamageTables()

    rE = {}

    if #brokenElements > 0 then
        for _,v in ipairs(brokenElements) do
            table.insert(rE, {id=v.id, missinghp=v.missinghp, hp=v.hp, name=v.name, type=v.type, pos=v.pos})
        end
    end
    if #damagedElements > 0 then
        for _,v in ipairs(damagedElements) do
            table.insert(rE, {id=v.id, missinghp=v.missinghp, hp=v.hp, name=v.name, type=v.type, pos=v.pos})
        end
    end
    if #rE > 0 then
        table.sort(rE, function(a,b) return a.missinghp>b.missinghp end)
    end

    totalShipIntegrity = string.format("%2.0f", 100 / totalShipMaxHP * totalShipHP)

    if formerTotalShipHP ~= totalShipHP then
        forceDamageRedraw = true
        formerTotalShipHP = totalShipHP
    else
        forceDamageRedraw = false
    end
end

function GetHPforElement(id)
    for i,v in ipairs(brokenElements) do
        if v.id == id then
            return 0
        end
    end
    for i,v in ipairs(damagedElements) do
        if v.id == id then
            return v.hp
        end
    end
    for i,v in ipairs(healthyElements) do
        if v.id == id then
            return v.maxhp
        end
    end
end

function UpdateClickArea(candidate, newEntry, mode)
    for i, screen in ipairs(screens) do
        for k, v in pairs(screens[i].ClickAreas) do
            if v.id == candidate and v.mode == mode then
                screens[i].ClickAreas[k] = newEntry
            end
        end
    end
end

function AddClickArea(mode, newEntry)
    for i, screen in ipairs(screens) do
        if screens[i].mode == mode then
            table.insert(screens[i].ClickAreas, newEntry)
        end
    end
end

function AddClickAreaForScreenID(screenid, newEntry)
    for i, screen in ipairs(screens) do
        if screens[i].id == screenid then
            table.insert(screens[i].ClickAreas, newEntry)
        end
    end
end

function DisableClickArea(candidate, mode)
    UpdateClickArea(candidate, {
        id = candidate,
        mode = mode,
        x1 = -1,
        x2 = -1,
        y1 = -1,
        y2 = -1
    })
end

function SetRefresh(mode, submode)
    mode = mode or "all"
    submode = submode or "all"
    if screens ~= nil and #screens > 0 then
        for i = 1, #screens, 1 do
            if screens[i].mode == mode or mode == "all" then
                if screens[i].submode == submode or submode =="all" then
                    screens[i].refresh = true
                end
            end
        end
    end
end

function WipeClickAreasForScreen(screen)
    screen.ClickAreas = {}
    return screen
end

function CreateBaseClickAreas(screen)
    table.insert(screen.ClickAreas, {mode = "all", id = "ToggleHudMode", x1 = 1537, x2 = 1728, y1 = 1015, y2 = 1075} )
    table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "damage", x1 = 193, x2 = 384, y1 = 1015, y2 = 1075} )
    table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "damageoutline", x1 = 385, x2 = 576, y1 = 1015, y2 = 1075} )
    table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "fuel", x1 = 577, x2 = 768, y1 = 1015, y2 = 1075} )
    -- table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "flight", x1 = 769, x2 = 960, y1 = 1015, y2 = 1075} )
    -- table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "cargo", x1 = 961, x2 = 1152, y1 = 1015, y2 = 1075} )
    -- table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "agg", x1 = 1153, x2 = 1344, y1 = 1015, y2 = 1075} )
    -- table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "map", x1 = 1345, x2 = 1536, y1 = 1015, y2 = 1075} )
    table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "time", x1 = 0, x2 = 192, y1 = 1015, y2 = 1075} )
    table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "settings1", x1 = 1729, x2 = 1920, y1 = 1015, y2 = 1075} )
    return screen
end

function CreateClickAreasForScreen(screen)

    if screen == nil then return {} end

    if screen.mode == "flight" then
    elseif screen.mode == "damage" then
        table.insert( screen.ClickAreas, {mode = "damage", id = "ToggleElementLabel", x1 = 70, x2 = 425, y1 = 325, y2 = 355} )
        table.insert( screen.ClickAreas, {mode = "damage", id = "ToggleElementLabel2", x1 = 980, x2 = 1400, y1 = 325, y2 = 355} )
    elseif screen.mode == "damageoutline" then
        table.insert(screen.ClickAreas, {mode = "damageoutline", id = "DMGOChangeView", param = "top", x1 = 60, x2 = 439, y1 = 150, y2 = 200} )
        table.insert(screen.ClickAreas, {mode = "damageoutline", id = "DMGOChangeView", param = "side", x1 = 440, x2 = 824, y1 = 150, y2 = 200} )
        table.insert(screen.ClickAreas, {mode = "damageoutline", id = "DMGOChangeView", param = "front", x1 = 825, x2 = 1215, y1 = 150, y2 = 200} )
        table.insert(screen.ClickAreas, {mode = "damageoutline", id = "DMGOChangeStretch", x1 = 1530, x2 = 1580, y1 = 150, y2 = 200} )
    elseif screen.mode == "fuel" then
    elseif screen.mode == "cargo" then
    elseif screen.mode == "agg" then
    elseif screen.mode == "map" then
    elseif screen.mode == "time" then
    elseif screen.mode == "settings1" then
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ToggleBackground", x1 = 75, x2 = 860, y1 = 170, y2 = 215} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "PreviousBackground", x1 = 75, x2 = 460, y1 = 235, y2 = 285} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "NextBackground", x1 = 480, x2 = 860, y1 = 235, y2 = 285} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "DecreaseOpacity", x1 = 75, x2 = 460, y1 = 300, y2 = 350} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "IncreaseOpacity", x1 = 480, x2 = 860, y1 = 300, y2 = 350} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ResetColors", x1 = 75, x2 = 860, y1 = 370, y2 = 415} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "PreviousColorID", x1 = 90, x2 = 140, y1 = 500, y2 = 550} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "NextColorID", x1 = 795, x2 = 845, y1 = 500, y2 = 550} )

        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosUp", param="1", x1 = 210, x2 = 290, y1 = 655, y2 = 700} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosUp", param="2", x1 = 300, x2 = 380, y1 = 655, y2 = 700} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosUp", param="3", x1 = 385, x2 = 465, y1 = 655, y2 = 700} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosUp", param="4", x1 = 470, x2 = 550, y1 = 655, y2 = 700} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosUp", param="5", x1 = 560, x2 = 640, y1 = 655, y2 = 700} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosUp", param="6", x1 = 645, x2 = 725, y1 = 655, y2 = 700} )

        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosDown", param="1", x1 = 210, x2 = 290, y1 = 740, y2 = 780} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosDown", param="2", x1 = 300, x2 = 380, y1 = 740, y2 = 780} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosDown", param="3", x1 = 385, x2 = 465, y1 = 740, y2 = 780} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosDown", param="4", x1 = 470, x2 = 550, y1 = 740, y2 = 780} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosDown", param="5", x1 = 560, x2 = 640, y1 = 740, y2 = 780} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ColorPosDown", param="6", x1 = 645, x2 = 725, y1 = 740, y2 = 780} )

        table.insert( screen.ClickAreas, {mode = "settings1", id = "ResetPosColor", x1 = 160, x2 = 340, y1 = 885, y2 = 935} )
        table.insert( screen.ClickAreas, {mode = "settings1", id = "ApplyPosColor", x1 = 355, x2 = 780, y1 = 885, y2 = 935} )

    elseif screen.mode == "startup" then
    elseif screen.mode == "systems" then
    end

    screen = CreateBaseClickAreas(screen)

    return screen
end

function CheckClick(x, y, HitTarget)
    x = x*1920
    y = y*1120
    HitTarget = HitTarget or ""
    HitPayload = {}
    -- PrintConsole("Clicked: "..x.." / "..y)
    if screens ~= nil and #screens > 0 then
        for i = 1, #screens, 1 do
            if screens[i].active == true and screens[i].element.getMouseX() ~= -1 and screens[i].element.getMouseY() ~= -1 then
               if HitTarget == "" then
                    for k, v in pairs(screens[i].ClickAreas) do
                        if v ~=nil and x >= v.x1 and x <= v.x2 and y >= v.y1 and y <= v.y2 then
                            HitTarget = v.id
                            HitPayload = v
                            break
                        end
                    end
                end
                if HitTarget == "ButtonPress" then
                    if screens[i].mode == HitPayload.param then
                        screens[i].mode = "startup"
                    else
                        screens[i].mode = HitPayload.param
                    end

                    if screens[i].mode == "damageoutline" then
                        if screens[i].submode == "" then
                            screens[i].submode = "top"
                        end
                    end
                    screens[i].refresh = true
                    screens[i].ClickAreas = {}
                    SaveToDatabank()
                    SetRefresh()
                    RenderScreens()
                elseif HitTarget == "ToggleBackground" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if BackgroundMode == "" then
                        BackgroundSelected = 1
                        BackgroundMode = backgroundModes[BackgroundSelected]
                    else
                        BackgroundSelected = 1
                        BackgroundMode = ""
                    end
                    for k, screen in pairs(screens) do
                        screens[k].refresh = true
                    end
                    SaveToDatabank()
                    SetRefresh()
                    RenderScreens()
                elseif HitTarget == "PreviousBackground" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if BackgroundMode == "" then
                        BackgroundSelected = 1
                        BackgroundMode = backgroundModes[BackgroundSelected]
                    else
                        if BackgroundSelected <= 1 then
                            BackgroundSelected = #backgroundModes
                        else
                            BackgroundSelected = BackgroundSelected - 1
                        end
                        BackgroundMode = backgroundModes[BackgroundSelected]
                    end
                    for k, screen in pairs(screens) do
                        screens[k].refresh = true
                    end
                    SaveToDatabank()
                    SetRefresh()
                    RenderScreens()
                elseif HitTarget == "NextBackground" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                     if BackgroundMode == "" then
                        BackgroundSelected = 1
                        BackgroundMode = backgroundModes[BackgroundSelected]
                    else
                        if BackgroundSelected >= #backgroundModes then
                            BackgroundSelected = 1
                        else
                            BackgroundSelected = BackgroundSelected + 1
                        end
                        BackgroundMode = backgroundModes[BackgroundSelected]
                    end
                    for k, screen in pairs(screens) do
                        screens[k].refresh = true
                    end
                    SaveToDatabank()
                    SetRefresh()
                    RenderScreens()
                elseif HitTarget == "DecreaseOpacity" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if BackgroundModeOpacity>0.1 then
                        BackgroundModeOpacity = BackgroundModeOpacity - 0.05
                        for k, screen in pairs(screens) do
                            screens[k].refresh = true
                        end
                        SaveToDatabank()
                        SetRefresh()
                        RenderScreens()
                    end
                elseif HitTarget == "IncreaseOpacity" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if BackgroundModeOpacity<1.0 then
                        BackgroundModeOpacity = BackgroundModeOpacity + 0.05
                        for k, screen in pairs(screens) do
                            screens[k].refresh = true
                        end
                        SaveToDatabank()
                        SetRefresh()
                        RenderScreens()
                    end
                elseif HitTarget == "ResetColors" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    db.clear()
                    ColorPrimary = "FF6700"
                    ColorSecondary = "FFFFFF"
                    ColorTertiary = "000000"
                    ColorHealthy = "00FF00"
                    ColorWarning = "FFFF00"
                    ColorCritical = "FF0000"
                    ColorBackground = "000000"
                    ColorBackgroundPattern = "4f4f4f"
                    ColorFuelAtmospheric = "004444"
                    ColorFuelSpace = "444400"
                    ColorFuelRocket = "440044"
                    BackgroundMode = "deathstar"
                    BackgroundSelected = 1
                    BackgroundModeOpacity = 0.25
                    colorIDTable = {
                        [1] = {
                            id="ColorPrimary",
                            desc="Main HUD Color",
                            basec = "FF6700",
                            newc = "FF6700"
                        },
                        [2] = {
                            id="ColorSecondary",
                            desc="Secondary HUD Color",
                            basec = "FFFFFF",
                            newc = "FFFFFF"
                        },
                        [3] = {
                            id="ColorTertiary",
                            desc="Tertiary HUD Color",
                            basec = "000000",
                            newc = "000000"
                        },
                        [4] = {
                            id="ColorHealthy",
                            desc="Color code for Healthy/Okay",
                            basec = "00FF00",
                            newc = "00FF00"
                        },
                        [5] = {
                            id="ColorWarning",
                            desc="Color code for Damaged/Warning",
                            basec = "FFFF00",
                            newc = "FFFF00"
                        },
                        [6] = {
                            id="ColorCritical",
                            desc="Color code for Broken/Critical",
                            basec = "FF0000",
                            newc = "FF0000"
                        },
                        [7] = {
                            id="ColorBackground",
                            desc="Background Color",
                            basec = "000000",
                            newc = "000000"
                        },
                        [8] = {
                            id="ColorBackgroundPattern",
                            desc="Background Pattern Color",
                            basec = "4F4F4F",
                            newc = "4F4F4F"
                        },
                        [9] = {
                            id="ColorFuelAtmospheric",
                            desc="Color for Atmo Fuel/Elements",
                            basec = "004444",
                            newc = "004444"
                        },
                        [10] = {
                            id="ColorFuelSpace",
                            desc="Color for Space Fuel/Elements",
                            basec = "444400",
                            newc = "444400"
                        },
                        [11] = {
                            id="ColorFuelRocket",
                            desc="Color for Rocket Fuel/Elements",
                            basec = "440044",
                            newc = "440044"
                        }
                    }
                    SaveToDatabank()
                    SetRefresh()
                    RenderScreens()
                elseif HitTarget == "PreviousColorID" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    colorIDIndex = colorIDIndex - 1
                    if colorIDIndex < 1 then colorIDIndex = #colorIDTable end
                    SaveToDatabank()
                    SetRefresh("settings1")
                    RenderScreens("settings1")
                elseif HitTarget == "NextColorID" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    colorIDIndex = colorIDIndex + 1
                    if colorIDIndex > #colorIDTable then colorIDIndex = 1 end
                    SaveToDatabank()
                    SetRefresh("settings1")
                    RenderScreens("settings1")
                elseif HitTarget == "ColorPosUp" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    local s = tonumber(string.sub(colorIDTable[colorIDIndex].newc, HitPayload.param, HitPayload.param),16)
                    s = s + 1
                    if s > 15 then s = 0 end
                    colorIDTable[colorIDIndex].newc = replace_char(HitPayload.param, colorIDTable[colorIDIndex].newc, hexTable[s+1])
                    SaveToDatabank()
                    SetRefresh("settings1")
                    RenderScreens("settings1")
                elseif HitTarget == "ColorPosDown" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    local s = tonumber(string.sub(colorIDTable[colorIDIndex].newc, HitPayload.param, HitPayload.param),16)
                    s = s - 1
                    if s < 0 then s = 15 end
                    colorIDTable[colorIDIndex].newc = replace_char(HitPayload.param, colorIDTable[colorIDIndex].newc, hexTable[s+1])
                    SaveToDatabank()
                    SetRefresh("settings1")
                    RenderScreens("settings1")
                elseif HitTarget == "ResetPosColor" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    colorIDTable[colorIDIndex].newc = colorIDTable[colorIDIndex].basec
                    _G[colorIDTable[colorIDIndex].id] = colorIDTable[colorIDIndex].basec
                    SaveToDatabank()
                    SetRefresh()
                    RenderScreens()
                elseif HitTarget == "ApplyPosColor" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    _G[colorIDTable[colorIDIndex].id] = colorIDTable[colorIDIndex].newc
                    SaveToDatabank()
                    SetRefresh()
                    RenderScreens()
                elseif HitTarget == "DamagedPageDown" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    CurrentDamagedPage = CurrentDamagedPage + 1
                    if CurrentDamagedPage > math.ceil(#damagedElements / DamagePageSize) then
                        CurrentDamagedPage = math.ceil(#damagedElements / DamagePageSize)
                    end
                    HudDeselectElement()
                    SaveToDatabank()
                    SetRefresh("damage")
                    RenderScreens("damage")
                elseif HitTarget == "DamagedPageUp" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    CurrentDamagedPage = CurrentDamagedPage - 1
                    if CurrentDamagedPage < 1 then CurrentDamagedPage = 1 end
                    HudDeselectElement()
                    SaveToDatabank()
                    SetRefresh("damage")
                    RenderScreens("damage")
                elseif HitTarget == "BrokenPageDown" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    CurrentBrokenPage = CurrentBrokenPage + 1
                    if CurrentBrokenPage > math.ceil(#brokenElements / DamagePageSize) then
                        CurrentBrokenPage = math.ceil(#brokenElements / DamagePageSize)
                    end
                    HudDeselectElement()
                    SaveToDatabank()
                    SetRefresh("damage")
                    RenderScreens("damage")
                elseif HitTarget == "BrokenPageUp" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    CurrentBrokenPage = CurrentBrokenPage - 1
                    if CurrentBrokenPage < 1 then CurrentBrokenPage = 1 end
                    HudDeselectElement()
                    SaveToDatabank()
                    SetRefresh("damage")
                    RenderScreens("damage")
                elseif HitTarget == "DMGOChangeView" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    screens[i].submode = HitPayload.param
                    UpdateViewDamageoutline(screens[i])
                    SaveToDatabank()
                    SetRefresh("damageoutline", screens[i].submode)
                    RenderScreens("damageoutline", screens[i].submode)
                elseif HitTarget == "DMGOChangeStretch" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if DMGOStretch == true then
                        DMGOStretch = false
                    else
                        DMGOStretch = true
                    end
                    UpdateViewDamageoutline(screens[i])
                    SaveToDatabank()
                    SetRefresh("damageoutline")
                    RenderScreens("damageoutline")
                elseif HitTarget == "ToggleDisplayAtmosphere" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if screens[i].fuelA == true then
                        screens[i].fuelA = false
                    else
                        screens[i].fuelA = true
                    end
                    screens[i].fuelIndex = 1
                    SaveToDatabank()
                    SetRefresh("fuel")
                    RenderScreens("fuel")
                elseif HitTarget == "ToggleDisplaySpace" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if screens[i].fuelS == true then
                        screens[i].fuelS = false
                    else
                        screens[i].fuelS = true
                    end
                    screens[i].fuelIndex = 1
                    SaveToDatabank()
                    SetRefresh("fuel")
                    RenderScreens("fuel")
                elseif HitTarget == "ToggleDisplayRocket" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if screens[i].fuelR == true then
                        screens[i].fuelR = false
                    else
                        screens[i].fuelR = true
                    end
                    screens[i].fuelIndex = 1
                    SaveToDatabank()
                    SetRefresh("fuel")
                    RenderScreens("fuel")
                elseif HitTarget == "DecreaseFuelIndex" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    screens[i].fuelIndex = screens[i].fuelIndex - 1
                    if screens[i].fuelIndex < 1 then screens[i].fuelIndex = 1 end
                    SaveToDatabank()
                    SetRefresh("fuel")
                    RenderScreens("fuel")
                elseif HitTarget == "IncreaseFuelIndex" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    screens[i].fuelIndex = screens[i].fuelIndex + 1
                    SaveToDatabank()
                    SetRefresh("fuel")
                    RenderScreens("fuel")
                elseif HitTarget == "ToggleHudMode" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if HUDMode == true then
                        HUDMode = false
                        forceDamageRedraw = true
                        HudDeselectElement()
                        SaveToDatabank()
                        SetRefresh()
                        RenderScreens()
                    else
                        HUDMode = true
                        forceDamageRedraw = true
                        HudDeselectElement()
                        SaveToDatabank()
                        SetRefresh()
                        RenderScreens()
                    end
                elseif HitTarget == "ToggleSimulation" and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    CurrentDamagedPage = 1
                    CurrentBrokenPage = 1
                    if SimulationMode == true then
                        SimulationMode = false
                        SimulationActive = false
                        UpdateDamageData()
                        UpdateTypeData()
                        forceDamageRedraw = true
                        HudDeselectElement()
                        SetRefresh("damage")
                        SetRefresh("damageoutline")
                        SetRefresh("settings1")
                        SetRefresh("fuel")
                        SaveToDatabank()
                        RenderScreens()
                    else
                        SimulationMode = true
                        SimulationActive = false
                        UpdateDamageData()
                        UpdateTypeData()
                        forceDamageRedraw = true
                        HudDeselectElement()
                        SetRefresh("damage")
                        SetRefresh("damageoutline")
                        SetRefresh("settings1")
                        SetRefresh("fuel")
                        SaveToDatabank()
                        RenderScreens()
                    end
                elseif (HitTarget == "ToggleElementLabel" or HitTarget == "ToggleElementLabel2") and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    if UseMyElementNames == true then
                        UseMyElementNames = false
                        SetRefresh("damage")
                        RenderScreens("damage")
                    else
                        UseMyElementNames = true
                        SetRefresh("damage")
                        RenderScreens("damage")
                    end
                elseif (HitTarget == "SwitchScrapTier" or HitTarget == "SwitchScrapTier2") and (HitPayload.mode == screens[i].mode or HitPayload.mode == "all") then
                    ScrapTier = ScrapTier + 1
                    if ScrapTier > 4 then ScrapTier = 1 end
                    SetRefresh("damage")
                    RenderScreens("damage")
                end


            end
        end
    end
end

--[[ 6. RENDERING FUNCTIONS ]]

function GetContentFlight()
    local output = ""
    output = output .. GetHeader("Flight Data Report") ..
    [[

    ]]
    return output
end

function GetContentDamage()
    local output = ""
    if SimulationMode == true then
        output = output .. GetHeader("Damage Report (Simulated damage)") .. [[]]
    else
        output = output .. GetHeader("Damage Report") .. [[]]
    end
    output = output .. GetContentDamageScreen()
    return output
end

function GetContentDamageoutline(screen)
    UpdateDataDamageoutline()
    UpdateViewDamageoutline(screen)
    local output = ""
    output = output .. GetHeader("Damage Ship Outline Report") ..
    GetDamageoutlineShip() ..
    [[<rect x=20 y=180 rx=5 ry=5 width=1880 height=840 fill=#000000 fill-opacity=0.5 style="stroke:#]]..ColorPrimary..[[;stroke-width:3;" />]]

    if screen.submode=="top" then
        output = output ..
            [[
              <rect class=xfill x=20 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mxx x=220 y=165>Top View</text>
              <rect class=xborder x=420 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mx x=620 y=165>Side View</text>
              <rect class=xborder x=820 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mx x=1020 y=165>Front View</text>
            ]]
    elseif screen.submode=="side" then
        output = output ..
            [[
              <rect class=xborder x=20 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mx x=220 y=165>Top View</text>
              <rect class=xfill x=420 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mxx x=620 y=165>Side View</text>
              <rect class=xborder x=820 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mx x=1020 y=165>Front View</text>
            ]]
    elseif screen.submode=="front" then
        output = output ..
            [[
              <rect class=xborder x=20 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mx x=220 y=165>Top View</text>
              <rect class=xborder x=420 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mx x=620 y=165>Side View</text>
              <rect class=xfill x=820 y=130 rx=5 ry=5 width=400 height=50 />
              <text class=f30mxx x=1020 y=165>Front View</text>
            ]]
    else
    end
    output = output .. [[<text class=f30exx x=1900 y=120>]]..#dmgoElements..[[ of ]]..ElementCounter..[[ shown</text>]]
    output = output .. [[<rect class=xborder x=1550 y=130 rx=5 ry=5 width=50 height=50 />]]
    if DMGOStretch == true then
        output = output .. [[<rect class=xfill x=1558 y=138 rx=5 ry=5 width=34 height=34 />]]
    end
    output = output .. [[<text class=f30exx x=1900 y=165>Stretch both axis</text>]]
    return output
end

function GetContentFuel(screen)

    if #FuelAtmosphericTanks < 1 and #FuelSpaceTanks < 1 and #FuelRocketTanks < 1 then return "" end

    local FuelTypes = 0
    local output = ""
    local addHeadline = {}

    FuelDisplay = { screen.fuelA, screen.fuelS, screen.fuelR }

    if FuelDisplay[1] == true and #FuelAtmosphericTanks > 0 then
        table.insert(addHeadline, "Atmospheric")
        FuelTypes = FuelTypes + 1
    end
    if FuelDisplay[2] == true and #FuelSpaceTanks > 0 then
        table.insert(addHeadline, "Space")
        FuelTypes = FuelTypes + 1
    end
    if FuelDisplay[3] == true and #FuelRocketTanks > 0 then
        table.insert(addHeadline, "Rocket")
        FuelTypes = FuelTypes + 1
    end

    output = output .. GetHeader("Fuel Report ("..table.concat(addHeadline, ", ")..")") ..
    [[
    <style>
        .fuele{fill:#]]..ColorBackground..[[;}
        .fuela{fill:#]]..ColorFuelAtmospheric..[[;fill-opacity:1;}
        .fuels{fill:#]]..ColorFuelSpace..[[;fill-opacity:1;}
        .fuelr{fill:#]]..ColorFuelRocket..[[;fill-opacity:1;}

        .fuela2{fill:none;stroke:#]]..ColorFuelAtmospheric..[[;stroke-width:3px;opacity:1;}
        .fuels2{fill:none;stroke:#]]..ColorFuelSpace..[[;stroke-width:3px;opacity:1;}
        .fuelr2{fill:none;stroke:#]]..ColorFuelRocket..[[;stroke-width:3px;opacity:1;}

        .fuela3{fill:#]]..ColorFuelAtmospheric..[[;fill-opacity:0.1;}
        .fuels3{fill:#]]..ColorFuelSpace..[[;fill-opacity:0.1;}
        .fuelr3{fill:#]]..ColorFuelRocket..[[;fill-opacity:0.1;}

        .fuela4{fill:#]]..ColorFuelAtmospheric..[[;fill-opacity:1;}
        .fuels4{fill:#]]..ColorFuelSpace..[[;fill-opacity:1;}
        .fuelr4{fill:#]]..ColorFuelRocket..[[;fill-opacity:1;}
    </style> ]]

    local totalH = 150
    local counter = 0
    local tOffset = 0

    if FuelDisplay[1] == true and #FuelAtmosphericTanks > 0 then

        if FuelTypes == 1 then tOffset = 50
        elseif FuelTypes == 2 then tOffset = 6
        elseif FuelTypes == 3 then tOffset = 0
        end

        output = output .. [[
        <svg x=20 y=]]..(95+totalH/FuelTypes*counter)..[[ width=1880 height=]]..totalH/FuelTypes..[[>
            <rect class="fuele" width="100%" height="100%"/>
            <rect class="fuela" width="]]..math.floor(100/FuelAtmosphericTotal*FuelAtmosphericCurrent)..[[%" height="100%"/>
        </svg>]]

        output = output ..
        [[<text class=f25sxx x=40 y=]]..(130+totalH/FuelTypes*counter+tOffset)..[[>]]..
        GenerateCommaValue(FuelAtmosphericCurrent, true)..
        [[ of ]]..GenerateCommaValue(FuelAtmosphericTotal, true)..
        [[ | Total Atmospheric Fuel in ]]..#FuelAtmosphericTanks..[[ tank]]..(#FuelAtmosphericTanks==1 and "" or "s")..[[ (]]..math.floor(100/FuelAtmosphericTotal*FuelAtmosphericCurrent)..[[%)</text>]]
        counter = counter + 1
    end

    if FuelDisplay[2] == true and #FuelSpaceTanks > 0 then

        if FuelTypes == 1 then tOffset = 50
        elseif FuelTypes == 2 then tOffset = 6
        elseif FuelTypes == 3 then tOffset = 0
        end

        output = output .. [[
        <svg x=20 y=]]..(95+totalH/FuelTypes*counter)..[[ width=1880 height=]]..totalH/FuelTypes..[[>
            <rect class="fuele" width="100%" height="100%"/>
            <rect class="fuels" width="]]..math.floor(100/FuelSpaceTotal*FuelSpaceCurrent)..[[%" height="100%"/>
        </svg>]]

        output = output ..
        [[<text class=f25sxx x=40 y=]]..(130+totalH/FuelTypes*counter+tOffset)..[[>]]..
        GenerateCommaValue(FuelSpaceCurrent, true)..
        [[ of ]]..GenerateCommaValue(FuelSpaceTotal, true)..
        [[ | Total Space Fuel in ]]..#FuelSpaceTanks..[[ tank]]..(#FuelSpaceTanks==1 and "" or "s")..[[ (]]..math.floor(100/FuelSpaceTotal*FuelSpaceCurrent)..[[%)</text>]]
        counter = counter + 1
    end

    if FuelDisplay[3] == true and #FuelRocketTanks > 0 then

        if FuelTypes == 1 then tOffset = 50
        elseif FuelTypes == 2 then tOffset = 6
        elseif FuelTypes == 3 then tOffset = 0
        end

        output = output .. [[
        <svg x=20 y=]]..(95+totalH/FuelTypes*counter)..[[ width=1880 height=]]..totalH/FuelTypes..[[>
            <rect class="fuele" width="100%" height="100%"/>
            <rect class="fuelr" width="]]..math.floor(100/FuelRocketTotal*FuelRocketCurrent)..[[%" height="100%"/>
        </svg> ]]

        output = output ..
        [[<text class=f25sxx x=40 y=]]..(130+totalH/FuelTypes*counter+tOffset)..[[>]]..
        GenerateCommaValue(FuelRocketCurrent, true)..
        [[ of ]]..GenerateCommaValue(FuelRocketTotal, true)..
        [[ | Total Rocket Fuel in ]]..#FuelRocketTanks..[[ tank]]..(#FuelRocketTanks==1 and "" or "s")..[[ (]]..math.floor(100/FuelRocketTotal*FuelRocketCurrent)..[[%)</text>]]
    end

    output = output .. [[
    <svg x=20 y=95 width=1880 height=]]..totalH..[[>
        <rect class="xborder" width="100%" height="100%"/>
    </svg>
    ]]

    local DisplayTable = {}
    if screen.fuelIndex == nil or screen.fuelIndex < 1 then
        screen.fuelIndex = 1
    end

    if FuelDisplay[1] == true then
        for _,v in ipairs(FuelAtmosphericTanks) do
            table.insert(DisplayTable, v)
        end
    end
    if FuelDisplay[2] == true then
        for _,v in ipairs(FuelSpaceTanks) do
            table.insert(DisplayTable, v)
        end
    end
    if FuelDisplay[3] == true then
        for _,v in ipairs(FuelRocketTanks) do
            table.insert(DisplayTable, v)
        end
    end

    table.sort(DisplayTable, function(a,b) return a.type<b.type or (a.type == b.type and a.id<b.id) end)

    local cCounter = 0
    for i=screen.fuelIndex, screen.fuelIndex+6, 1 do
        if DisplayTable[i] ~= nil then
            local tank = DisplayTable[i]
            cCounter = cCounter + 1
            local colorChar = ""
            if tank.type == 1 then
                colorChar = "a"
            elseif tank.type == 2 then
                colorChar = "s"
            elseif tank.type == 3 then
                colorChar = "r"
            end


            local twidth = 1853/100
            if tank.percent == nil or tank.percent==0 then
                twidth = 0
            else
                twidth = twidth * tank.percent
            end
            if tank.cvol == nil then tank.cvol = 0 end
            if tank.name == nil then tank.name = "" end



            output = output .. [[
                <svg x=20 y=]]..(cCounter*100+220)..[[ width=1880 height=100 viewBox="0 0 1880 100">
                    <rect class="fuel]]..colorChar..[[3" x="13.5" y="9.5" width="1853" height="81"/>
                    <rect class="fuel]]..colorChar..[[4" x="13.5" y="9.5" width="]]..twidth..[[" height="81"/>
                    <rect class="fuel]]..colorChar..[[2" x="13.5" y="9.5" width="1853" height="81"/>]]
            if tank.hp == 0 then
                output = output .. [[<polygon class="cc" points="7 3 7 97 15 97 15 100 4 100 4 74.9 0 71.32 0 18.7 4 14.4 4 0 15 0 15 3 7 3"/><polygon class="cc" points="1873 3 1873 97 1865 97 1865 100 1876 100 1876 74.9 1880 71.32 1880 18.7 1876 14.4 1876 0 1865 0 1865 3 1873 3"/>]]
            elseif tank.maxhp - tank.hp > constants.epsilon then
                output = output .. [[<polygon class="cw" points="7 3 7 97 15 97 15 100 4 100 4 74.9 0 71.32 0 18.7 4 14.4 4 0 15 0 15 3 7 3"/><polygon class="cw" points="1873 3 1873 97 1865 97 1865 100 1876 100 1876 74.9 1880 71.32 1880 18.7 1876 14.4 1876 0 1865 0 1865 3 1873 3"/>]]
            else
                output = output .. [[<polygon class="ch" points="7 3 7 97 15 97 15 100 4 100 4 74.9 0 71.32 0 18.7 4 14.4 4 0 15 0 15 3 7 3"/><polygon class="ch" points="1873 3 1873 97 1865 97 1865 100 1876 100 1876 74.9 1880 71.32 1880 18.7 1876 14.4 1876 0 1865 0 1865 3 1873 3"/>]]
            end
            if tank.hp == 0 then output = output .. [[<text class=f80mc x=60 y=82>]]..tank.size..[[</text>]]
            else output = output .. [[<text class=f80mxx07 x=60 y=82>]]..tank.size..[[</text>]]
            end

            if tank.hp == 0 then
                output = output .. [[<text class=f60mc x=940 y=74>Broken</text>]] ..
                                   [[<text class=f25ec x=1860 y=60>0 of ]]..GenerateCommaValue(tank.vol)..[[</text>]]
            elseif tonumber(tank.percent) < 10 then
                output = output .. [[<text class=f60mc x=940 y=74>]]..tank.percent..[[%</text>]] ..
                                   [[<text class=f25ec x=1860 y=60>]]..GenerateCommaValue(tank.cvol)..[[ of ]]..GenerateCommaValue(tank.vol)..[[</text>]]
            elseif tonumber(tank.percent) < 30 then
                output = output .. [[<text class=f60mw x=940 y=74>]]..tank.percent..[[%</text>]] ..
                                   [[<text class=f25ew x=1860 y=60>]]..GenerateCommaValue(tank.cvol)..[[ of ]]..GenerateCommaValue(tank.vol)..[[</text>]]
            else output =
                output .. [[<text class=f60mxx x=940 y=74>]]..tank.percent..[[%</text>]] ..
                          [[<text class=f25exx x=1860 y=60>]]..GenerateCommaValue(tank.cvol)..[[ of ]]..GenerateCommaValue(tank.vol)..[[</text>]]
            end

            output = output ..[[<text class=f25sxx x=140 y=60>]]..tank.name..[[</text>]]

            output = output .. [[</svg>]]

        end
    end



    if #FuelAtmosphericTanks > 0 then
        output = output .. [[<rect class=xborder x=20 y=260 rx=5 ry=5 width=50 height=50 />]]
        if FuelDisplay[1] == true then
            output = output .. [[<rect class=xfill x=28 y=268 rx=5 ry=5 width=34 height=34 />]]
        end
        output = output .. [[<text class=f25sx x=80 y=290>ATM</text>]]
        AddClickAreaForScreenID(screen.id, {mode = "fuel", id = "ToggleDisplayAtmosphere", x1 = 50, x2 = 100, y1 = 270, y2 = 320} )
    end

    if #FuelSpaceTanks > 0 then
        output = output .. [[<rect class=xborder x=170 y=260 rx=5 ry=5 width=50 height=50 />]]
        if FuelDisplay[2] == true then
            output = output .. [[<rect class=xfill x=178 y=268 rx=5 ry=5 width=34 height=34 />]]
        end
        output = output .. [[<text class=f25sx x=230 y=290>SPC</text>]]
        AddClickAreaForScreenID(screen.id, {mode = "fuel", id = "ToggleDisplaySpace", x1 = 200, x2 = 250, y1 = 270, y2 = 320} )
    end

    if #FuelRocketTanks > 0 then
        output = output .. [[<rect class=xborder x=320 y=260 rx=5 ry=5 width=50 height=50 />]]
        if FuelDisplay[3] == true then
            output = output .. [[<rect class=xfill x=328 y=268 rx=5 ry=5 width=34 height=34 />]]
        end
        output = output .. [[<text class=f25sx x=380 y=290>RKT</text>]]
        AddClickAreaForScreenID(screen.id, {mode = "fuel", id = "ToggleDisplayRocket", x1 = 350, x2 = 400, y1 = 270, y2 = 320} )
    end

    if screen.fuelIndex > 1 then
        output = output .. [[<svg x="1490" y="260">
                                <rect x="0" y="0" rx="10" ry="10" width="200" height="50" style="fill:#]]..ColorPrimary..[[;" />
                                <svg x="80" y="15"><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>
                            </svg>]]
        AddClickAreaForScreenID(screen.id, {mode = "fuel", id = "DecreaseFuelIndex", x1 = 1470, x2 = 1670, y1 = 270, y2 = 320} )
    end

    if screen.fuelIndex+cCounter-1 < #DisplayTable then
        output = output .. [[<svg x="1700" y="260">
                                <rect x="0" y="0" rx="10" ry="10" width="200" height="50" style="fill:#]]..ColorPrimary..[[;" />
                                <svg x="80" y="15"><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>
                            </svg>]]
        AddClickAreaForScreenID(screen.id, {mode = "fuel", id = "IncreaseFuelIndex", x1 = 1680, x2 = 1880, y1 = 270, y2 = 320} )
    end

    if cCounter > 0 then
        output = output .. [[<text class=f30mx x=960 y=300>]]..
                           #DisplayTable..
                           [[ Tank]]..(#DisplayTable == 1 and "" or "s")..
                           [[ (Showing ]]..screen.fuelIndex..[[ to ]]..(screen.fuelIndex+cCounter-1)..[[)</text>]]
    end

    return output
end

function GetContentCargo()
    local output = ""
    output = output .. GetHeader("Cargo Report") ..
    [[

    ]]
    return output
end

function GetContentAGG()
    local output = ""
    output = output .. GetHeader("Anti-Grav Control") ..
    [[

    ]]
    return output
end

function GetContentMap()
    local output = ""
    output = output .. GetHeader("Map Overview") ..
    [[

    ]]
    return output
end

function GetContentTime()
    local output = ""
    output = output .. GetHeader("Time") .. epochTime()
    output = output ..
                [[<svg x=460 y=370 width=120 height=150 viewBox="0 0 24 30">
                    <rect x=0 y=13 width=4 height=5 fill=#]]..ColorPrimary..[[>
                      <animate attributeName="height" attributeType="XML"
                        values="5;21;5"
                        begin="0s" dur="1s" repeatCount="indefinite" />
                      <animate attributeName="y" attributeType="XML"
                        values="13; 5; 13"
                        begin="0s" dur="1s" repeatCount="indefinite" />
                    </rect>
                    <rect x=10 y=13 width=4 height=5 fill=#]]..ColorPrimary..[[>
                      <animate attributeName="height" attributeType="XML"
                        values="5;21;5"
                        begin="0.15s" dur="1s" repeatCount="indefinite" />
                      <animate attributeName="y" attributeType="XML"
                        values="13; 5; 13"
                        begin="0.15s" dur="1s" repeatCount="indefinite" />
                    </rect>
                    <rect x=20 y=13 width=4 height=5 fill=#]]..ColorPrimary..[[>
                      <animate attributeName="height" attributeType="XML"
                        values="5;21;5"
                        begin="0.3s" dur="1s" repeatCount="indefinite" />
                      <animate attributeName="y" attributeType="XML"
                        values="13; 5; 13"
                        begin="0.3s" dur="1s" repeatCount="indefinite" />
                    </rect>
                  </svg>]]
    return output
end

function GetContentSettings1()
    local output = ""
    output = output .. GetHeader("Settings") .. [[<rect class="xfill" x="40" y="150" rx="5" ry="5" width="820" height="50" />]]
    if BackgroundMode=="" then
        output = output ..[[<text class="f30mxxx" x="440" y="185">Activate background</text>]]
    else
        output = output ..[[<text class="f30mxxx" x="440" y="185">Deactivate background (']]..BackgroundMode..[[', ]]..string.format("%.0f",BackgroundModeOpacity*100)..[[%)</text>]]
    end
    output = output ..[[
        <rect class="xfill" x="40" y="220" rx="5" ry="5" width="400" height="50" />
        <text class="f30mxxx" x="240" y="255">Previous background</text>
        <rect class="xfill" x="460" y="220" rx="5" ry="5" width="400" height="50" />
        <text class="f30mxxx" x="660" y="255">Next background</text>

        <rect class="xfill" x="40" y="290" rx="5" ry="5" width="400" height="50" />
        <text class="f30mxxx" x="240" y="325">Decrease Opacity</text>
        <rect class="xfill" x="460" y="290" rx="5" ry="5" width="400" height="50" />
        <text class="f30mxxx" x="660" y="325">Increase Opacity</text>
    ]]

    output = output ..
        [[<rect class="xfill" x="40" y="360" rx="5" ry="5" width="820" height="50" />]] ..
        [[<text class="f30mxxx" x="440" y="395">Reset background and all colors</text>]]

    output = output ..
        [[<svg x=40 y=430 width=820 height=574>]] ..
            [[<rect class="xborder" x="0" y="0" rx="5" ry="5" width="820" height="574" stroke-dasharray="2 5" />]] ..
            [[<rect class="xborder" x="0" y="0" rx="5" ry="5" width="820" height="50" />]] ..
            [[<text class="f30mxx" x="410" y="35">Select and change any of the ]]..#colorIDTable..[[ HUD colors</text>]] ..
            [[<rect class="xfill" x="20" y="70" rx="5" ry="5" width="50" height="50" />]] ..
                [[<svg x=32 y=74><path d="M1,23.13,16.79,40.25a3.23,3.23,0,0,0,5.6-2.19V3.24a3.23,3.23,0,0,0-5.6-2.19L1,18.17A3.66,3.66,0,0,0,1,23.13Z" transform="translate(0.01 -0.01)"/></svg>]] ..
            [[<rect class="xfill" x="750" y="70" rx="5" ry="5" width="50" height="50" />]] ..
                [[<svg x=764 y=74><path d="M21.42,18.17,5.59,1.05A3.23,3.23,0,0,0,0,3.24V38.06a3.23,3.23,0,0,0,5.6,2.19L21.42,23.13A3.66,3.66,0,0,0,21.42,18.17Z" transform="translate(0.01 -0.01)"/></svg>]] ..
            [[<rect class="xborder" x="90" y="70" rx="5" ry="5" width="640" height="50" />]] ..
            [[<text class="f30mxx" x="410" y="105">]]..colorIDTable[colorIDIndex].desc..[[</text>]] ..
            [[<rect style="fill: #]].._G[colorIDTable[colorIDIndex].id]..[[; fill-opacity: 1; stroke: #]]..ColorPrimary..[[; stroke-width:3;" x="90" y="140" rx="5" ry="5" width="640" height="70" />]] ..
            [[<text class="f20sxx" x="100" y="160">Current color</text>]] ..
            [[<svg x=90 y=230 width=640 height=140>]] ..

                [[<rect class=xbfill x=55 y=5 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=75 y=15><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=145 y=5 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=165 y=15><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=235 y=5 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=255 y=15><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=325 y=5 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=345 y=15><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=415 y=5 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=435 y=15><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=505 y=5 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=525 y=15><path d="M47.52,14.77,30.4,30.6a3.23,3.23,0,0,0,2.19,5.6H67.41a3.23,3.23,0,0,0,2.19-5.6L52.48,14.77A3.66,3.66,0,0,0,47.52,14.77Z" transform="translate(-29.36 -13.8)"/></svg>]] ..

                [[<text class=f60mx x=27 y=92>#</text>]] ..

                [[<rect class=xborder x=55 y=50 rx=5 ry=5 width=80 height=40 />]] ..
                [[<text class=f30mxx x=95 y=80>]]..string.sub(colorIDTable[colorIDIndex].newc,1,1)..[[</text>]] ..
                [[<rect class=xborder x=145 y=50 rx=5 ry=5 width=80 height=40 />]] ..
                [[<text class=f30mxx x=185 y=80>]]..string.sub(colorIDTable[colorIDIndex].newc,2,2)..[[</text>]] ..
                [[<rect class=xborder x=235 y=50 rx=5 ry=5 width=80 height=40 />]] ..
                [[<text class=f30mxx x=275 y=80>]]..string.sub(colorIDTable[colorIDIndex].newc,3,3)..[[</text>]] ..
                [[<rect class=xborder x=325 y=50 rx=5 ry=5 width=80 height=40 />]] ..
                [[<text class=f30mxx x=365 y=80>]]..string.sub(colorIDTable[colorIDIndex].newc,4,4)..[[</text>]] ..
                [[<rect class=xborder x=415 y=50 rx=5 ry=5 width=80 height=40 />]] ..
                [[<text class=f30mxx x=455 y=80>]]..string.sub(colorIDTable[colorIDIndex].newc,5,5)..[[</text>]] ..
                [[<rect class=xborder x=505 y=50 rx=5 ry=5 width=80 height=40 />]] ..
                [[<text class=f30mxx x=545 y=80>]]..string.sub(colorIDTable[colorIDIndex].newc,6,6)..[[</text>]] ..

                [[<rect class=xbfill x=55 y=95 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=75 y=105><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=145 y=95 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=165 y=105><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=235 y=95 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=255 y=105><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=325 y=95 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=345 y=105><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=415 y=95 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=435 y=105><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>]] ..
                [[<rect class=xbfill x=505 y=95 rx=5 ry=5 width=80 height=40 />]] ..
                    [[<svg x=525 y=105><path d="M52.48,35.23,69.6,19.4a3.23,3.23,0,0,0-2.19-5.6H32.59a3.23,3.23,0,0,0-2.19,5.6L47.52,35.23A3.66,3.66,0,0,0,52.48,35.23Z" transform="translate(-29.36 -13.8)"/></svg>]] ..

            [[</svg>]] ..
            [[<rect style="fill: #]]..colorIDTable[colorIDIndex].newc..[[; fill-opacity: 1; stroke: #]]..ColorPrimary..[[; stroke-width:3;" x="90" y="390" rx="5" ry="5" width="640" height="70" />]] ..
            [[<text class=f20sxx x=100 y=410>New color</text>]] ..
            [[<rect class=xfill x=290 y=480 rx=5 ry=5 width=440 height=50 />]] ..
            [[<text class=f30mxxx x=510 y=515>Apply new color</text>]] ..
            [[<rect class=xfill x=90 y=480 rx=5 ry=5 width=185 height=50 />]] ..
            [[<text class=f30mxxx x=182 y=515>Reset</text>]] ..
        [[</svg>]]

    output = output ..
            [[<svg x=940 y=150 width=936 height=774>]] ..
                [[<rect class=xborder x=0 y=0 rx=5 ry=5 width=936 height=774 stroke-dasharray="2 5" />]] ..
                [[<rect class=xborder x=0 y=0 rx=5 ry=5 width=936 height=50 />]] ..
                [[<text class=f30mxx x=468 y=35>Explanation / Hints</text>]] ..
                [[<text class=f30mxx x=468 y=400>Coming soon.</text>]]


    output = output .. [[</svg>]]

    if SimulationMode == true then
        output = output .. [[<rect class="cfill" x="940" y="954" rx="5" ry="5" width="936" height="50" /><text class="f30mxxx" x="1408" y="989">Simulating Damage to elements</text>]]
        AddClickArea("settings1", { id = "ToggleSimulation", mode ="settings1", x1 = 940, x2 = 1850, y1 = 919, y2 = 969 })
    else
        output = output .. [[<rect class="xfill" x="940" y="954" rx="5" ry="5" width="936" height="50" /><text class="f30mxxx" x="1408" y="989">Simulate Damage to elements</text>]]
        AddClickArea("settings1", { id = "ToggleSimulation", mode ="settings1", x1 = 940, x2 = 1850, y1 = 919, y2 = 969 })
    end

    return output
end

function GetContentStartup()
    local output = ""
    output = output .. GetElementLogo(812, 380, "f", "f", "f")
    if YourShipsName == "Enter here" then
        output = output .. [[<g><text class="f160m" x="960" y="330">Spaceship ID ]]..ShipID..[[</text><animate attributeName="fill" values="#]]..ColorPrimary..[[;#]]..ColorSecondary..[[;#]]..ColorPrimary..[[" dur="30s" repeatCount="indefinite" /></g>]]
    else
        output = output .. [[<g><text class="f160m" x="960" y="330">]]..YourShipsName..[[</text><animate attributeName="fill" values="#]]..ColorPrimary..[[;#]]..ColorSecondary..[[;#]]..ColorPrimary..[[" dur="30s" repeatCount="indefinite" /></g>]]
    end
    if ShowWelcomeMessage == true then output = output .. [[<text class="f50mx" x="960" y="750">Greetings, Commander ]]..PlayerName..[[.</text>]] end
    if #Warnings > 0 then
        output = output .. [[<text class="f25mc" x="960" y="880">Warning: ]]..(table.concat(Warnings, " "))..[[</text>]]
    end
    output = output .. [[<text class="f30mxx" style="fill-opacity:0.2" x="960" y="1000">Damage Report v]]..VERSION..[[, by DorianGray - Discord: Dorian Gray#2623.</text>]]
    return output
end

function RenderScreen(screen, contentToRender)
    if contentToRender == nil then
        PrintConsole("ERROR: contentToRender is nil.")
        unit.exit()
    end

    CreateClickAreasForScreen(screen)

    local output =""
    output = output .. [[
    <style>
      body{
        background-color: #]]..ColorBackground..[[; ]]..GetContentBackground(BackgroundMode)..[[
      }
      .screen { width: 1920px; height: 1120px; }
      .main { width: 1920px; height: 1040px; }
      .menu { width: 1920px; height: 70px; stroke: #]]..ColorPrimary..[[; stroke-width: 3; }

      .xline { stroke: #]]..ColorPrimary..[[; stroke-width: 3;}
      .daline { stroke: #]]..ColorSecondary..[[; stroke-dasharray: 2 5; }
      .ll { fill: #FF55FF; stroke: #FF0000}
      .xborder { fill:#]]..ColorPrimary..[[; fill-opacity:0.05; stroke: #]]..ColorPrimary..[[; stroke-width:3; }
      .xfill { fill:#]]..ColorPrimary..[[; fill-opacity:1; }
      .xbfill { fill:#]]..ColorPrimary..[[; fill-opacity:1; stroke: #]]..ColorPrimary..[[; stroke-width:3; }
      .cfill { fill:#]]..ColorCritical..[[; fill-opacity:1; }

      .hlrect { fill: #]]..ColorPrimary..[[; }
      .cx { fill: #]]..ColorPrimary..[[; }
      .ch { fill: #]]..ColorHealthy..[[; }
      .cw { fill: #]]..ColorWarning..[[; }
      .cc { fill: #]]..ColorCritical..[[; }

      .f { fill:#]]..ColorPrimary..[[; }
      .f2 { fill:#]]..ColorSecondary..[[; }
      .f3 { fill:#]]..ColorTertiary..[[; }
      .f250mx { font-size: 250px; text-anchor: middle; fill: #]]..ColorPrimary..[[; font-family: Impact, Charcoal, sans-serif; }
      .f160m { font-size: 160px; text-anchor: middle; font-family: Impact, Charcoal, sans-serif; }
      .f160mx { font-size: 160px; text-anchor: middle; fill: #]]..ColorPrimary..[[; font-family: Impact, Charcoal, sans-serif; }
      .f100mx { font-size: 100px; text-anchor: middle; fill: #]]..ColorPrimary..[[; font-family: Impact, Charcoal, sans-serif; }
      .f80mxx07 { opacity:0.7; font-size: 80px; text-anchor: middle; fill: #]]..ColorSecondary..[[; font-family: Impact, Charcoal, sans-serif; }
      .f80mc { opacity:1; font-size: 80px; text-anchor: middle; fill: #]]..ColorCritical..[[; font-family: Impact, Charcoal, sans-serif; }
      .f60s { font-size: 60px; text-anchor: start; }
      .f60m { font-size: 60px; text-anchor: middle; }
      .f60e { font-size: 60px; text-anchor: end; }
      .f60mx { font-size: 60px; text-anchor: middle; fill: #]]..ColorPrimary..[[; font-family: Impact, Charcoal, sans-serif; }
      .f60mxx { font-size: 60px; text-anchor: middle; fill: #]]..ColorSecondary..[[; font-family: Impact, Charcoal, sans-serif; }
      .f60mxx07 { opacity:0.7; font-size: 60px; text-anchor: middle; fill: #]]..ColorSecondary..[[; font-family: Impact, Charcoal, sans-serif; }
      .f60mc { opacity:1; font-size: 60px; text-anchor: middle; fill: #]]..ColorCritical..[[; font-family: Impact, Charcoal, sans-serif; }
      .f60mw { opacity:1; font-size: 60px; text-anchor: middle; fill: #]]..ColorWarning..[[; font-family: Impact, Charcoal, sans-serif; }
      .f50m { font-size: 50px; text-anchor: middle; }
      .f50sxx { font-size: 50px; text-anchor: start; fill: #]]..ColorSecondary..[[; }
      .f50mx { font-size: 50px; fill: #]]..ColorPrimary..[[; fill-opacity: 1; text-anchor: middle; }
      .f50mx02 { font-size: 50px; fill: #]]..ColorPrimary..[[; fill-opacity: 0.2; text-anchor: middle; }
      .f50mxx { font-size: 50px; fill: #]]..ColorSecondary..[[; fill-opacity: 1; text-anchor: middle }
      .f36mxx { font-size: 36px; fill: #]]..ColorSecondary..[[; fill-opacity: 1; text-anchor: middle }
      .f30mx { font-size: 30px; fill: #]]..ColorPrimary..[[; fill-opacity: 1; text-anchor: middle; }
      .f30sxx { font-size: 30px; fill: #]]..ColorSecondary..[[; fill-opacity: 1; text-anchor: start; }
      .f30exx { font-size: 30px; fill: #]]..ColorSecondary..[[; fill-opacity: 1; text-anchor: end; }
      .f30mxx { font-size: 30px; fill: #]]..ColorSecondary..[[; fill-opacity: 1; text-anchor: middle; }
      .f30mxxx { font-size: 30px; fill: #]]..ColorTertiary..[[; fill-opacity: 1; text-anchor: middle; }
      .f25sx { font-size: 25px; text-anchor: start; fill: #]]..ColorPrimary..[[; }
      .f25exx { font-size: 25px; text-anchor: end; fill: #]]..ColorSecondary..[[; }
      .f25sxx { font-size: 25px; text-anchor: start; fill: #]]..ColorSecondary..[[; }
      .f25mw { font-size: 25px; text-anchor: middle; fill: #]]..ColorWarning..[[; }
      .f25mr { font-size: 25px; text-anchor: middle; fill: #]]..ColorCritical..[[; }
      .f25ew { font-size: 25px; text-anchor: end; fill: #]]..ColorWarning..[[; }
      .f25ec { font-size: 25px; text-anchor: end; fill: #]]..ColorCritical..[[; }
      .f25mc { font-size: 25px; text-anchor: middle; fill: #]]..ColorCritical..[[; }
      .f20sxx { font-size: 20px; text-anchor: start; fill: #]]..ColorSecondary..[[; }
      .f20mxx { font-size: 20px; text-anchor: middle; fill: #]]..ColorSecondary..[[; }
    </style>
    <svg class=screen viewBox="0 0 1920 1120">
      <svg class=main x=0 y=0>]]

        output = output .. contentToRender

        if screen.mode == "startup" then
            output = output .. [[<rect class=xborder x=0 y=0 rx=5 ry=5 width=1920 height=1040 />]]
        else
            output = output .. [[<rect class=xborder x=0 y=70 rx=5 ry=5 width=1920 height=970 />]]
        end

        output = output .. [[
      </svg>
      <svg class=menu x=0 y=1050>
        <rect class=xline x=0 y=0 rx=5 ry=5 width=1920 height=70 fill=#]]..ColorBackground..[[ />
        <text class=f50mx x=96 y=50>TIME</text>
        <text class=f50mx x=288 y=50>DMG</text>
        <text class=f50mx x=480 y=50>DMGO</text>
        <text class=f50mx x=672 y=50>FUEL</text>
        <text class=f50mx x=864 y=50>SYS</text>]]

        --[[
        <text class=f50mx x=672 y=50>FUEL</text>
        <text class=f50mx x=864 y=50>FLGT</text>
        <text class=f50mx x=1056 y=50>CRGO</text>
        <text class=f50mx x=1248 y=50>AGG</text>
        <text class=f50mx x=1440 y=50>MAP</text>
        ]]

        output = output .. [[
        <text class=f50mx x=1632 y=50>HUD</text>
        <text class=f50mx x=1824 y=50>SETS</text>
        <line class=xline x1=192 y1=10 x2=192 y2=60 />
        <line class=xline x1=384 y1=10 x2=384 y2=60 />
        <line class=xline x1=576 y1=10 x2=576 y2=60 />
        <line class=xline x1=768 y1=10 x2=768 y2=60 />
        <line class=xline x1=960 y1=10 x2=960 y2=60 />
        ]] ..
        -- [[
        -- <line class=xline x1=1152 y1=10 x2=1152 y2=60 />
        ---<line class=xline x1=1344 y1=10 x2=1344 y2=60 />]] ..
        [[<line class=xline x1=1536 y1=10 x2=1536 y2=60 />
        <line class=xline x1=1728 y1=10 x2=1728 y2=60 />]]
        if HUDMode == true then
            output = output .. [[
            <rect class=hlrect x=1544 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=1632 y=50>HUD</text>
            ]]
        end
        if screen.mode == "damage" then
            output = output .. [[
            <rect class=hlrect x=200 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=288 y=50>DMG</text>
            ]]
        elseif screen.mode == "damageoutline" then
            output = output .. [[
            <rect class=hlrect x=392 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=480 y=50>DMGO</text>
            ]]
        elseif screen.mode == "fuel" then
            output = output .. [[
            <rect class=hlrect x=584 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=672 y=50>FUEL</text>
            ]]
        elseif screen.mode == "flight" then
            output = output .. [[
            <rect class=hlrect x=776 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=864 y=50>FLGT</text>
            ]]
        elseif screen.mode == "cargo" then
            output = output .. [[
            <rect class=hlrect x=968 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=1056 y=50>CRGO</text>
            ]]
        elseif screen.mode == "agg" then
            output = output .. [[
            <rect class=hlrect x=1160 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=1248 y=50>AGG</text>
            ]]
        elseif screen.mode == "map" then
            output = output .. [[
            <rect class=hlrect x=1352 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=1440 y=50>MAP</text>
            ]]
        elseif screen.mode == "time" then
            output = output .. [[
            <rect class=hlrect x=8 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=96 y=50>TIME</text>
            ]]
        elseif screen.mode == "settings1" then
            output = output .. [[
            <rect class=hlrect x=1736 y=6 rx=0 ry=0 width=176 height=58 />
            <text class=f50mxx x=1824 y=50>SETS</text>
            ]]
        end
      output = output .. [[</svg>]]
    output = output .. [[</svg>]]

    -- Center:

    -- <line style="stroke: white;" class="xline" x1="960" y1="0" x2="960" y2="1040" />
    -- <line style="stroke: white;" class="xline" x1="0" y1="520" x2="1920" y2="520" />
    -- <line style="stroke: white;" class="xline" x1="960" y1="0" x2="960" y2="1120" />
    -- <line style="stroke: white;" class="xline" x1="0" y1="560" x2="1920" y2="560" />

    local outputLength = string.len(output)
    -- PrintConsole("Render: "..screen.mode.." ("..outputLength.." chars)")
    screen.element.setSVG(output)
end

function RenderScreens(onlymode, onlysubmode)

    onlymode = onlymode or "all"
    onlysubmode = onlysubmode or "all"

    if screens ~= nil and #screens > 0 then

        local contentFlight = ""
        local contentDamage = ""
        local contentDamageoutlineTop = ""
        local contentDamageoutlineSide = ""
        local contentDamageoutlineFront = ""
        local contentFuel = ""
        local contentCargo = ""
        local contentAGG = ""
        local contentMap = ""
        local contentTime = ""
        local contentSettings1 = ""
        local contentStartup = ""

        for k,screen in pairs(screens) do
            if screen.refresh == true then
                local contentToRender = ""

                if screen.mode == "flight" and (onlymode =="flight" or onlymode =="all") then
                    if contentFlight == "" then contentFlight = GetContentFlight() end
                    contentToRender = contentFlight
                elseif screen.mode == "damage" and (onlymode =="damage" or onlymode =="all") then
                    if contentDamage == "" then contentDamage = GetContentDamage() end
                    contentToRender = contentDamage
                elseif screen.mode == "damageoutline" and (onlymode =="damageoutline" or onlymode =="all") then
                    if screen.submode == "" then
                        screen.submode = "top"
                        screens[k].submode = "top"
                    end
                    if screen.submode == "top" and (onlysubmode == "top" or onlysubmode == "all") then
                        if contentDamageoutlineTop == "" then contentDamageoutlineTop = GetContentDamageoutline(screen) end
                        contentToRender = contentDamageoutlineTop
                    end
                    if screen.submode == "side" and (onlysubmode == "side" or onlysubmode == "all") then
                        if contentDamageoutlineSide == "" then contentDamageoutlineSide = GetContentDamageoutline(screen) end
                        contentToRender = contentDamageoutlineSide
                    end
                    if screen.submode == "front" and (onlysubmode == "front" or onlysubmode == "all") then
                        if contentDamageoutlineFront == "" then contentDamageoutlineFront = GetContentDamageoutline(screen) end
                        contentToRender = contentDamageoutlineFront
                    end
                elseif screen.mode == "fuel" and (onlymode =="fuel" or onlymode =="all") then
                    screen = WipeClickAreasForScreen(screens[k])
                    contentToRender = GetContentFuel(screen)
                elseif screen.mode == "cargo" and (onlymode =="cargo" or onlymode =="all") then
                    if contentCargo == "" then contentCargo = GetContentCargo() end
                    contentToRender = contentCargo
                elseif screen.mode == "agg" and (onlymode =="agg" or onlymode =="all") then
                    if contentAGG == "" then contentAGG = GetContentAGG() end
                    contentToRender = contentAGG
                elseif screen.mode == "map" and (onlymode =="map" or onlymode =="all") then
                    if contentMap == "" then contentMap = GetContentMap() end
                    contentToRender = contentMap
                elseif screen.mode == "time" and (onlymode =="time" or onlymode =="all") then
                    if contentTime == "" then contentTime = GetContentTime() end
                    contentToRender = contentTime
                elseif screen.mode == "settings1" and (onlymode =="settings1" or onlymode =="all") then
                    if contentSettings1 == "" then contentSettings1 = GetContentSettings1() end
                    contentToRender = contentSettings1
                elseif screen.mode == "startup" and (onlymode =="startup" or onlymode =="all") then
                    if contentStartup == "" then contentStartup = GetContentStartup() end
                    contentToRender = contentStartup
                else
                    contentToRender = "Invalid screen mode. ('"..screen.mode.."')"
                end

                if contentToRender ~= "" then
                    RenderScreen(screen, contentToRender)
                else
                    DrawCenteredText("ERROR: No contentToRender delivered for "..screen.mode)
                    PrintConsole("ERROR: No contentToRender delivered for "..screen.mode)
                    unit.exit()
                end
                screens[k].refresh = false
            end
        end
    end

    if HUDMode == true then
         system.setScreen(GetContentDamageHUDOutput())
         system.showScreen(1)
    else
         system.showScreen(0)
    end

end

function OnTickData(initial)
    if formerTime + 60 < system.getArkTime() then
        SetRefresh("time")
    end
    totalShipMass = construct.getMass()
    if formerTotalShipMass ~= totalShipMass then
        UpdateDamageData(true)
        UpdateTypeData()
        SetRefresh()
        formerTotalShipMass = totalShipMass
    else
        UpdateDamageData(initial)
        UpdateTypeData()
    end
    RenderScreens()
end

--[[ 7. EXECUTION ]]

unit.hideWidget()
ClearConsole()
PrintConsole("DAMAGE REPORT v"..VERSION.." STARTED", true)
InitiateSlots()
LoadFromDatabank()
SwitchScreens("on")
InitiateScreens()

if core == nil then
    PrintConsole("ERROR: Connect the core to the programming board.")
    unit.exit()
else
    OperatorID = player.getId()
    OperatorData = database.getPlayer(OperatorID)
    PlayerName = OperatorData["name"]
    ShipID = construct.getId()
end

if db == nil then
    table.insert(Warnings, "No databank connected, won't save/load settings.")
end

if YourShipsName == "Enter here" then
    table.insert(Warnings, "No ship name set in LUA settings.")
end

if SkillRepairToolEfficiency == 0 and SkillRepairToolOptimization == 0 and StatFuelTankOptimization == 0 and StatContainerOptimization ==0 and
    StatAtmosphericFuelTankHandling == 0 and StatSpaceFuelTankHandling == 0 and StatRocketFuelTankHandling ==0 then
    table.insert(Warnings, "No talents/stats set in LUA settings.")
end

if SkillRepairToolEfficiency < 0 or SkillRepairToolOptimization < 0 or StatFuelTankOptimization < 0 or StatContainerOptimization < 0 or
    StatAtmosphericFuelTankHandling < 0 or StatSpaceFuelTankHandling < 0 or StatRocketFuelTankHandling < 0 or
    SkillRepairToolEfficiency > 5 or SkillRepairToolOptimization > 5 or StatFuelTankOptimization > 5 or StatContainerOptimization > 5 or
    StatAtmosphericFuelTankHandling > 5 or StatSpaceFuelTankHandling > 5 or StatRocketFuelTankHandling > 5 then
        PrintConsole("ERROR: Talents/stats can only range from 0 to 5. Please set correctly in LUA settings and reactivate script.")
        unit.exit()
end

if screens == nil or #screens == 0 then
    HUDMode = true
    PrintConsole("Warning: No screens connected. Entering HUD mode only.")
end

OnTickData(true)

unit.setTimer('UpdateData', UpdateDataInterval)
unit.setTimer('UpdateHighlight', HighlightBlinkingInterval)
