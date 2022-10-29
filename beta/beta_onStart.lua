--[[
    Damage Report 3.32
    A LUA script for Dual Universe

    Created By Dorian Gray
    Maintained By CredenceH

    You can find/update this script on GitHub. Explanations, installation and usage information as well as screenshots can be found there too.
    GitHub: https://github.com/LocuraDU/DU-DamageReport

    GNU Public License 3.0. Use whatever you want, be so kind to leave credit.

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

VERSION = "3.32"
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
   local t = system.getUtcTime()
    if not utc then t = t + system.getUtcOffset() end
    local DSEC=24*60*60
    local YSEC=365*DSEC
    local LSEC=YSEC+DSEC
    local FSEC=4*YSEC+DSEC
    local BASE_DOW=4
    local BASE_YEAR=1970
    local _days={-1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333, 364}
    local _lpdays={}
    for i=1,2  do _lpdays[i]=_days[i]   end
    for i=3,13 do _lpdays[i]=_days[i]+1 end
    local y,j,m,d,w,h,n,s
    local mdays=_days
    s=t
    y=math.floor(s/FSEC)
    s=s-y*FSEC
    y=y*4+BASE_YEAR
    if s>=YSEC then
        y=y+1
        s=s-YSEC
        if s>=YSEC then
            y=y+1
            s=s-YSEC
            if s>=LSEC then
                y=y+1
                s=s-LSEC
            else
                mdays=_lpdays
            end
        end
    end
    j=math.floor(s/DSEC)
    s=s-j*DSEC
    local m=1
    while mdays[m]<j do m=m+1 end
    m=m-1
    local d=j-mdays[m]
    w=(math.floor(t/DSEC)+BASE_DOW)%7
    if w == 0 then w = 7 end
    h=math.floor(s/3600)
    s=s-h*3600
    n=math.floor(s/60)
    function round(a,b)if b then return utils.round(a/b)*b end;return a>=0 and math.floor(a+0.5)or math.ceil(a-0.5)end
    s=round(s-n*60)
    local weekDaysNames = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
    local weekDaysShortNames = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}
    local monthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    local monthShortNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}

    return [[<text class="f250mx" x="960" y="540">]]..string.format("%02d",h).." : "..string.format("%02d",n)..[[</text>]]..
           [[<text class="f100mx" x="960" y="660">]]..weekDaysNames[w].." / ".. monthNames[m].." / ".. d .." / ".. y ..[[</text>]]
           
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
    x = 750
    y = 320
    primaryC = primaryC or "f"
    secondaryC = secondaryC or "f2"
    tertiaryC = tertiaryC or "f3"
    local output = ""
    output = output .. [[
        <svg x="]]..x..[[" y="]]..y..[[">
	<circle class="]]..primaryC..[[" cx="204" cy="200" r="53">
		<animate
			attributeName="r"
			dur="3.5s"
			begin="0s"
			repeatCount="indefinite"
			keyTimes="0; 0.5; 1"
			keySplines="0.5  0   0.1  1;
			0.5  0   0.1  1"
			calcMode="spline"
			values="53; 40; 53"
		/>
	</circle>
			
	<path class="]]..secondaryC..[[">
		<animate
			attributeName="d"
			dur="3.5s"
			begin="0s"
			fill="freeze"
			repeatCount="indefinite"
			keyTimes="0; 0.5; 1"
			keySplines="0.5  0   0.1  1;
			0.5  0   0.1  1"
			calcMode="spline"
			values="M168.9 146.2C171.8 146.2 174.1 143.9 174.1 141 174.1 138.1 171.8 135.8 168.9 135.8 166 135.8 163.7 138.1 163.7 141 163.7 143.9 166 146.2 168.9 146.2ZM168.9 264.7C171.8 264.7 174.1 262.3 174.1 259.5 174.1 256.6 171.8 254.2 168.9 254.2 166 254.2 163.7 256.6 163.7 259.5 163.7 262.3 166 264.7 168.9 264.7ZM147.7 240.6C150.2 240.6 152.2 238.6 152.2 236.1 152.2 233.6 150.2 231.6 147.7 231.6 145.2 231.6 143.2 233.6 143.2 236.1 143.2 238.6 145.2 240.6 147.7 240.6ZM260.2 131.5C262.7 131.5 264.7 129.5 264.7 127 264.7 124.5 262.7 122.5 260.2 122.5 257.7 122.5 255.7 124.5 255.7 127 255.7 129.5 257.7 131.5 260.2 131.5ZM241.1 278.4C243.6 278.4 245.6 276.3 245.6 273.9 245.6 271.4 243.6 269.4 241.1 269.4 238.7 269.4 236.6 271.4 236.6 273.9 236.6 276.3 238.7 278.4 241.1 278.4ZM176.1 286.6C178.6 286.6 180.6 284.6 180.6 282.1 180.6 279.7 178.6 277.6 176.1 277.6 173.6 277.6 171.6 279.7 171.6 282.1 171.6 284.6 173.6 286.6 176.1 286.6ZM132.2 172.9C134.7 172.9 136.7 170.9 136.7 168.4 136.7 165.9 134.7 163.9 132.2 163.9 129.7 163.9 127.7 165.9 127.7 168.4 127.7 170.9 129.7 172.9 132.2 172.9ZM139.1 215.4C141.5 215.4 143.5 213.4 143.5 210.9 143.5 208.4 141.5 206.4 139.1 206.4 136.6 206.4 134.6 208.4 134.6 210.9 134.6 213.4 136.6 215.4 139.1 215.4ZM271.7 199.5C274.2 199.5 276.2 197.5 276.2 195 276.2 192.5 274.2 190.5 271.7 190.5 269.2 190.5 267.2 192.5 267.2 195 267.2 197.5 269.2 199.5 271.7 199.5ZM215.3 272.6C217.7 272.6 219.8 270.6 219.8 268.1 219.8 265.6 217.7 263.6 215.3 263.6 212.8 263.6 210.8 265.6 210.8 268.1 210.8 270.6 212.8 272.6 215.3 272.6ZM207.7 139.4C210.2 139.4 212.2 137.4 212.2 134.9 212.2 132.4 210.2 130.4 207.7 130.4 205.2 130.4 203.2 132.4 203.2 134.9 203.2 137.4 205.2 139.4 207.7 139.4ZM126.5 210.7C129.4 210.7 131.7 208.3 131.7 205.5 131.7 202.6 129.4 200.2 126.5 200.2 123.6 200.2 121.3 202.6 121.3 205.5 121.3 208.3 123.6 210.7 126.5 210.7ZM264.2 240.6C267 240.6 269.4 238.2 269.4 235.3 269.4 232.5 267 230.1 264.2 230.1 261.3 230.1 258.9 232.5 258.9 235.3 258.9 238.2 261.3 240.6 264.2 240.6ZM154.7 142.3C156.9 142.3 158.6 140.5 158.6 138.3 158.6 136.1 156.9 134.4 154.7 134.4 152.5 134.4 150.7 136.1 150.7 138.3 150.7 140.5 152.5 142.3 154.7 142.3ZM269.7 187.6C271.5 187.6 273 186.2 273 184.4 273 182.6 271.5 181.2 269.7 181.2 267.9 181.2 266.5 182.6 266.5 184.4 266.5 186.2 267.9 187.6 269.7 187.6ZM274.8 261.8C276.5 261.8 278 260.4 278 258.6 278 256.8 276.5 255.3 274.8 255.3 273 255.3 271.5 256.8 271.5 258.6 271.5 260.4 273 261.8 274.8 261.8ZM167.6 275.5C169.4 275.5 170.9 274 170.9 272.2 170.9 270.5 169.4 269 167.6 269 165.8 269 164.4 270.5 164.4 272.2 164.4 274 165.8 275.5 167.6 275.5ZM136.4 235.9C138.1 235.9 139.6 234.4 139.6 232.6 139.6 230.9 138.1 229.4 136.4 229.4 134.6 229.4 133.1 230.9 133.1 232.6 133.1 234.4 134.6 235.9 136.4 235.9ZM202.5 125.4C204.3 125.4 205.7 123.9 205.7 122.1 205.7 120.3 204.3 118.9 202.5 118.9 200.7 118.9 199.3 120.3 199.3 122.1 199.3 123.9 200.7 125.4 202.5 125.4ZM255 142.3C257.2 142.3 258.9 140.5 258.9 138.3 258.9 136.1 257.2 134.4 255 134.4 252.8 134.4 251 136.1 251 138.3 251 140.5 252.8 142.3 255 142.3ZM137.8 203.5C140 203.5 141.7 201.7 141.7 199.5 141.7 197.3 140 195.6 137.8 195.6 135.6 195.6 133.8 197.3 133.8 199.5 133.8 201.7 135.6 203.5 137.8 203.5ZM186 277.6C190.5 277.6 194.2 273.9 194.2 269.4 194.2 264.8 190.5 261.1 186 261.1 181.4 261.1 177.7 264.8 177.7 269.4 177.7 273.9 181.4 277.6 186 277.6ZM239.5 149.1C244.1 149.1 247.8 145.4 247.8 140.8 247.8 136.3 244.1 132.6 239.5 132.6 235 132.6 231.3 136.3 231.3 140.8 231.3 145.4 235 149.1 239.5 149.1ZM143.5 248.1C145.1 248.1 146.4 246.8 146.4 245.2 146.4 243.7 145.1 242.4 143.5 242.4 142 242.4 140.7 243.7 140.7 245.2 140.7 246.8 142 248.1 143.5 248.1ZM232 280.2C233.6 280.2 234.9 278.9 234.9 277.3 234.9 275.7 233.6 274.4 232 274.4 230.4 274.4 229.1 275.7 229.1 277.3 229.1 278.9 230.4 280.2 232 280.2ZM285.5 237C287.1 237 288.4 235.7 288.4 234.1 288.4 232.5 287.1 231.2 285.5 231.2 284 231.2 282.7 232.5 282.7 234.1 282.7 235.7 284 237 285.5 237ZM286.6 161C288.2 161 289.5 159.7 289.5 158.1 289.5 156.5 288.2 155.2 286.6 155.2 285 155.2 283.7 156.5 283.7 158.1 283.7 159.7 285 161 286.6 161ZM239.9 130C241.5 130 242.8 128.8 242.8 127.2 242.8 125.6 241.5 124.3 239.9 124.3 238.3 124.3 237 125.6 237 127.2 237 128.8 238.3 130 239.9 130ZM210.4 127.9C212 127.9 213.3 126.6 213.3 125 213.3 123.4 212 122.1 210.4 122.1 208.8 122.1 207.5 123.4 207.5 125 207.5 126.6 208.8 127.9 210.4 127.9ZM152.9 158.5C154.5 158.5 155.8 157.2 155.8 155.6 155.8 154 154.5 152.7 152.9 152.7 151.3 152.7 150 154 150 155.6 150 157.2 151.3 158.5 152.9 158.5ZM165.8 283.8C167.4 283.8 168.7 282.5 168.7 280.9 168.7 279.3 167.4 278 165.8 278 164.2 278 163 279.3 163 280.9 163 282.5 164.2 283.8 165.8 283.8ZM101.2 162.4C102.3 162.4 103.3 161.5 103.3 160.3 103.3 159.1 102.3 158.1 101.2 158.1 100 158.1 99 159.1 99 160.3 99 161.5 100 162.4 101.2 162.4ZM307.5 219.1C308.3 219.1 309 218.4 309 217.5 309 216.7 308.3 216 307.5 216 306.6 216 305.9 216.7 305.9 217.5 305.9 218.4 306.6 219.1 307.5 219.1ZM133.1 100.1C134 100.1 134.7 99.4 134.7 98.5 134.7 97.7 134 97 133.1 97 132.3 97 131.6 97.7 131.6 98.5 131.6 99.4 132.3 100.1 133.1 100.1ZM131.3 300.1C132.2 300.1 132.9 299.4 132.9 298.5 132.9 297.7 132.2 297 131.3 297 130.5 297 129.8 297.7 129.8 298.5 129.8 299.4 130.5 300.1 131.3 300.1ZM218 277.7C218.8 277.7 219.5 277.1 219.5 276.2 219.5 275.4 218.8 274.7 218 274.7 217.1 274.7 216.4 275.4 216.4 276.2 216.4 277.1 217.1 277.7 218 277.7ZM279.8 210.3C280.6 210.3 281.3 209.6 281.3 208.8 281.3 207.9 280.6 207.3 279.8 207.3 278.9 207.3 278.3 207.9 278.3 208.8 278.3 209.6 278.9 210.3 279.8 210.3ZM219.8 114.2C220.6 114.2 221.3 113.5 221.3 112.7 221.3 111.8 220.6 111.1 219.8 111.1 218.9 111.1 218.2 111.8 218.2 112.7 218.2 113.5 218.9 114.2 219.8 114.2ZM122.3 217.9C123.2 217.9 123.9 217.2 123.9 216.3 123.9 215.5 123.2 214.8 122.3 214.8 121.5 214.8 120.8 215.5 120.8 216.3 120.8 217.2 121.5 217.9 122.3 217.9ZM159 261.1C159.9 261.1 160.5 260.4 160.5 259.5 160.5 258.7 159.9 258 159 258 158.2 258 157.5 258.7 157.5 259.5 157.5 260.4 158.2 261.1 159 261.1ZM247.4 301.5C248.3 301.5 249 300.8 249 300 249 299.1 248.3 298.4 247.4 298.4 246.6 298.4 245.9 299.1 245.9 300 245.9 300.8 246.6 301.5 247.4 301.5ZM209 118.9C210.2 118.9 211.1 117.9 211.1 116.7 211.1 115.5 210.2 114.6 209 114.6 207.8 114.6 206.8 115.5 206.8 116.7 206.8 117.9 207.8 118.9 209 118.9ZM296.7 250.3C297.9 250.3 298.8 249.3 298.8 248.1 298.8 246.9 297.9 246 296.7 246 295.5 246 294.5 246.9 294.5 248.1 294.5 249.3 295.5 250.3 296.7 250.3ZM144.6 255C145.8 255 146.8 254 146.8 252.8 146.8 251.6 145.8 250.6 144.6 250.6 143.4 250.6 142.5 251.6 142.5 252.8 142.5 254 143.4 255 144.6 255ZM136 160.3C137.2 160.3 138.2 159.3 138.2 158.1 138.2 156.9 137.2 156 136 156 134.8 156 133.8 156.9 133.8 158.1 133.8 159.3 134.8 160.3 136 160.3ZM218 127.5C219.1 127.5 220.1 126.6 220.1 125.4 220.1 124.2 219.1 123.2 218 123.2 216.8 123.2 215.8 124.2 215.8 125.4 215.8 126.6 216.8 127.5 218 127.5ZM269.7 208.5C270.9 208.5 271.9 207.6 271.9 206.4 271.9 205.2 270.9 204.2 269.7 204.2 268.5 204.2 267.6 205.2 267.6 206.4 267.6 207.6 268.5 208.5 269.7 208.5ZM147.1 267.6C148.3 267.6 149.3 266.6 149.3 265.4 149.3 264.2 148.3 263.2 147.1 263.2 146 263.2 145 264.2 145 265.4 145 266.6 146 267.6 147.1 267.6ZM256.2 161.4C260.1 161.4 263.3 158.2 263.3 154.3 263.3 150.5 260.1 147.3 256.2 147.3 252.4 147.3 249.2 150.5 249.2 154.3 249.2 158.2 252.4 161.4 256.2 161.4ZM165.7 122.5C167.7 122.5 169.4 120.8 169.4 118.7 169.4 116.6 167.7 114.9 165.7 114.9 163.6 114.9 161.9 116.6 161.9 118.7 161.9 120.8 163.6 122.5 165.7 122.5ZM123.2 167.3C124.6 167.3 125.8 166.2 125.8 164.8 125.8 163.4 124.6 162.3 123.2 162.3 121.8 162.3 120.7 163.4 120.7 164.8 120.7 166.2 121.8 167.3 123.2 167.3ZM242.2 291.9C243.6 291.9 244.7 290.7 244.7 289.3 244.7 288 243.6 286.8 242.2 286.8 240.8 286.8 239.7 288 239.7 289.3 239.7 290.7 240.8 291.9 242.2 291.9ZM160.1 152.9C162.2 152.9 163.9 151.2 163.9 149.1 163.9 147 162.2 145.3 160.1 145.3 158 145.3 156.3 147 156.3 149.1 156.3 151.2 158 152.9 160.1 152.9ZM275.8 237.9C277.9 237.9 279.6 236.2 279.6 234.1 279.6 232 277.9 230.3 275.8 230.3 273.7 230.3 272.1 232 272.1 234.1 272.1 236.2 273.7 237.9 275.8 237.9ZM113.7 217.3C115.8 217.3 117.5 215.7 117.5 213.6 117.5 211.5 115.8 209.8 113.7 209.8 111.6 209.8 109.9 211.5 109.9 213.6 109.9 215.7 111.6 217.3 113.7 217.3ZM284.8 175.9C286.3 175.9 287.5 174.7 287.5 173.2 287.5 171.8 286.3 170.5 284.8 170.5 283.3 170.5 282.1 171.8 282.1 173.2 282.1 174.7 283.3 175.9 284.8 175.9ZM261.5 168.4C262.9 168.4 264.2 167.2 264.2 165.7 264.2 164.2 262.9 163 261.5 163 260 163 258.8 164.2 258.8 165.7 258.8 167.2 260 168.4 261.5 168.4ZM281.6 244.7C283.1 244.7 284.3 243.5 284.3 242 284.3 240.5 283.1 239.3 281.6 239.3 280.1 239.3 278.9 240.5 278.9 242 278.9 243.5 280.1 244.7 281.6 244.7ZM194.6 296.5C196.1 296.5 197.3 295.3 197.3 293.8 197.3 292.3 196.1 291.1 194.6 291.1 193.1 291.1 191.9 292.3 191.9 293.8 191.9 295.3 193.1 296.5 194.6 296.5ZM130.2 218.4C131.7 218.4 132.9 217.2 132.9 215.7 132.9 214.2 131.7 213 130.2 213 128.8 213 127.6 214.2 127.6 215.7 127.6 217.2 128.8 218.4 130.2 218.4ZM153.6 130.2C155.1 130.2 156.3 129 156.3 127.5 156.3 126 155.1 124.8 153.6 124.8 152.1 124.8 150.9 126 150.9 127.5 150.9 129 152.1 130.2 153.6 130.2ZM184.2 115.5C185.7 115.5 186.9 114.3 186.9 112.8 186.9 111.3 185.7 110.1 184.2 110.1 182.7 110.1 181.5 111.3 181.5 112.8 181.5 114.3 182.7 115.5 184.2 115.5ZM266.1 178.5C268.2 178.5 269.9 176.8 269.9 174.7 269.9 172.6 268.2 170.9 266.1 170.9 264 170.9 262.4 172.6 262.4 174.7 262.4 176.8 264 178.5 266.1 178.5ZM196 139.2C198.1 139.2 199.8 137.5 199.8 135.4 199.8 133.4 198.1 131.7 196 131.7 193.9 131.7 192.3 133.4 192.3 135.4 192.3 137.5 193.9 139.2 196 139.2ZM124.9 262.2C126.2 262.2 127.4 261 127.4 259.6 127.4 258.3 126.2 257.1 124.9 257.1 123.5 257.1 122.3 258.3 122.3 259.6 122.3 261 123.5 262.2 124.9 262.2ZM145.2 171.1C148.4 171.1 151.1 168.4 151.1 165.1 151.1 161.9 148.4 159.2 145.2 159.2 141.9 159.2 139.2 161.9 139.2 165.1 139.2 168.4 141.9 171.1 145.2 171.1ZM163.3 134C165.7 134 167.6 132.1 167.6 129.7 167.6 127.3 165.7 125.4 163.3 125.4 160.9 125.4 159 127.3 159 129.7 159 132.1 160.9 134 163.3 134ZM209 282.7C211.4 282.7 213.3 280.7 213.3 278.4 213.3 276 211.4 274 209 274 206.6 274 204.7 276 204.7 278.4 204.7 280.7 206.6 282.7 209 282.7ZM122.3 192C124.7 192 126.7 190 126.7 187.6 126.7 185.3 124.7 183.3 122.3 183.3 120 183.3 118 185.3 118 187.6 118 190 120 192 122.3 192ZM274.4 172.2C276.8 172.2 278.7 170.2 278.7 167.8 278.7 165.5 276.8 163.5 274.4 163.5 272 163.5 270.1 165.5 270.1 167.8 270.1 170.2 272 172.2 274.4 172.2ZM229.6 271.5C232.9 271.5 235.6 268.9 235.6 265.6 235.6 262.3 232.9 259.6 229.6 259.6 226.4 259.6 223.7 262.3 223.7 265.6 223.7 268.9 226.4 271.5 229.6 271.5ZM222.1 141.9C225.4 141.9 228 139.3 228 136 228 132.7 225.4 130 222.1 130 218.8 130 216.2 132.7 216.2 136 216.2 139.3 218.8 141.9 222.1 141.9ZM155.2 255.7C159.1 255.7 162.2 252.5 162.2 248.7 162.2 244.8 159.1 241.6 155.2 241.6 151.4 241.6 148.2 244.8 148.2 248.7 148.2 252.5 151.4 255.7 155.2 255.7ZM272.8 226.9C276.6 226.9 279.8 223.7 279.8 219.9 279.8 216 276.6 212.8 272.8 212.8 268.9 212.8 265.8 216 265.8 219.9 265.8 223.7 268.9 226.9 272.8 226.9ZM247.4 267.6C252 267.6 255.7 263.9 255.7 259.3 255.7 254.7 252 251 247.4 251 242.9 251 239.2 254.7 239.2 259.3 239.2 263.9 242.9 267.6 247.4 267.6ZM136.7 191.6C141.3 191.6 145 187.9 145 183.3 145 178.8 141.3 175 136.7 175 132.2 175 128.5 178.8 128.5 183.3 128.5 187.9 132.2 191.6 136.7 191.6ZM234.1 118.9C236.1 118.9 237.7 117.3 237.7 115.3 237.7 113.3 236.1 111.7 234.1 111.7 232.1 111.7 230.5 113.3 230.5 115.3 230.5 117.3 232.1 118.9 234.1 118.9ZM201.8 272.6C203.8 272.6 205.4 271 205.4 269 205.4 267 203.8 265.4 201.8 265.4 199.8 265.4 198.2 267 198.2 269 198.2 271 199.8 272.6 201.8 272.6ZM119.5 136.9C121.4 136.9 123.1 135.3 123.1 133.3 123.1 131.3 121.4 129.7 119.5 129.7 117.5 129.7 115.9 131.3 115.9 133.3 115.9 135.3 117.5 136.9 119.5 136.9ZM175.9 305C177.9 305 179.5 303.4 179.5 301.4 179.5 299.4 177.9 297.8 175.9 297.8 173.9 297.8 172.3 299.4 172.3 301.4 172.3 303.4 173.9 305 175.9 305ZM273.5 179.9C274.6 179.9 275.5 179 275.5 177.9 275.5 176.8 274.6 175.9 273.5 175.9 272.4 175.9 271.5 176.8 271.5 177.9 271.5 179 272.4 179.9 273.5 179.9ZM263.8 145.7C264.9 145.7 265.8 144.8 265.8 143.7 265.8 142.6 264.9 141.7 263.8 141.7 262.7 141.7 261.8 142.6 261.8 143.7 261.8 144.8 262.7 145.7 263.8 145.7ZM272.6 247.8C274.8 247.8 276.6 246 276.6 243.8 276.6 241.6 274.8 239.8 272.6 239.8 270.4 239.8 268.6 241.6 268.6 243.8 268.6 246 270.4 247.8 272.6 247.8ZM281.4 251.2C282.5 251.2 283.4 250.3 283.4 249.2 283.4 248.1 282.5 247.2 281.4 247.2 280.3 247.2 279.4 248.1 279.4 249.2 279.4 250.3 280.3 251.2 281.4 251.2ZM295.2 202.9C296.3 202.9 297.2 202.1 297.2 201 297.2 199.9 296.3 199 295.2 199 294.2 199 293.3 199.9 293.3 201 293.3 202.1 294.2 202.9 295.2 202.9ZM282.3 227.8C283.4 227.8 284.3 226.9 284.3 225.8 284.3 224.7 283.4 223.8 282.3 223.8 281.2 223.8 280.3 224.7 280.3 225.8 280.3 226.9 281.2 227.8 282.3 227.8ZM150.2 148.6C151.3 148.6 152.2 147.7 152.2 146.6 152.2 145.5 151.3 144.6 150.2 144.6 149.1 144.6 148.2 145.5 148.2 146.6 148.2 147.7 149.1 148.6 150.2 148.6ZM196.2 104.5C197.3 104.5 198.2 103.6 198.2 102.5 198.2 101.4 197.3 100.5 196.2 100.5 195.1 100.5 194.2 101.4 194.2 102.5 194.2 103.6 195.1 104.5 196.2 104.5ZM160.8 268.5C161.9 268.5 162.8 267.6 162.8 266.5 162.8 265.4 161.9 264.5 160.8 264.5 159.7 264.5 158.8 265.4 158.8 266.5 158.8 267.6 159.7 268.5 160.8 268.5ZM188.2 291.2C191.1 291.2 193.4 288.9 193.4 286 193.4 283.1 191.1 280.8 188.2 280.8 185.4 280.8 183 283.1 183 286 183 288.9 185.4 291.2 188.2 291.2ZM198.2 281.2C200 281.2 201.5 279.7 201.5 278 201.5 276.2 200 274.7 198.2 274.7 196.5 274.7 195 276.2 195 278 195 279.7 196.5 281.2 198.2 281.2ZM198.9 288.9C200 288.9 200.9 288 200.9 286.9 200.9 285.8 200 284.9 198.9 284.9 197.8 284.9 196.9 285.8 196.9 286.9 196.9 288 197.8 288.9 198.9 288.9ZM247.8 293.3C248.9 293.3 249.8 292.4 249.8 291.3 249.8 290.2 248.9 289.3 247.8 289.3 246.7 289.3 245.8 290.2 245.8 291.3 245.8 292.4 246.7 293.3 247.8 293.3ZM129.2 196.8C130.3 196.8 131.1 195.9 131.1 194.8 131.1 193.8 130.3 192.9 129.2 192.9 128.1 192.9 127.2 193.8 127.2 194.8 127.2 195.9 128.1 196.8 129.2 196.8ZM273 118.2C275.1 118.2 276.9 116.4 276.9 114.2 276.9 112 275.1 110.2 273 110.2 270.8 110.2 269 112 269 114.2 269 116.4 270.8 118.2 273 118.2ZM248.9 132C251 132 252.6 130.3 252.6 128.2 252.6 126.2 251 124.5 248.9 124.5 246.8 124.5 245.1 126.2 245.1 128.2 245.1 130.3 246.8 132 248.9 132ZM264.3 111.5C265.4 111.5 266.3 110.6 266.3 109.5 266.3 108.4 265.4 107.5 264.3 107.5 263.2 107.5 262.4 108.4 262.4 109.5 262.4 110.6 263.2 111.5 264.3 111.5Z;
			M175.2 122.4C178.1 122.4 180.4 120.1 180.4 117.2 180.4 114.3 178.1 112 175.2 112 172.3 112 170 114.3 170 117.2 170 120.1 172.3 122.4 175.2 122.4ZM139.2 316.4C142.1 316.4 144.4 314.1 144.4 311.2 144.4 308.3 142.1 306 139.2 306 136.3 306 134 308.3 134 311.2 134 314.1 136.3 316.4 139.2 316.4ZM129.5 272C132 272 134 270 134 267.5 134 265 132 263 129.5 263 127 263 125 265 125 267.5 125 270 127 272 129.5 272ZM314.5 102C317 102 319 100 319 97.5 319 95 317 93 314.5 93 312 93 310 95 310 97.5 310 100 312 102 314.5 102ZM290.5 307C293 307 295 305 295 302.5 295 300 293 298 290.5 298 288 298 286 300 286 302.5 286 305 288 307 290.5 307ZM177.5 338C180 338 182 336 182 333.5 182 331 180 329 177.5 329 175 329 173 331 173 333.5 173 336 175 338 177.5 338ZM84.5 150C87 150 89 148 89 145.5 89 143 87 141 84.5 141 82 141 80 143 80 145.5 80 148 82 150 84.5 150ZM117.5 227C120 227 122 225 122 222.5 122 220 120 218 117.5 218 115 218 113 220 113 222.5 113 225 115 227 117.5 227ZM320.5 194C323 194 325 192 325 189.5 325 187 323 185 320.5 185 318 185 316 187 316 189.5 316 192 318 194 320.5 194ZM233.5 308C236 308 238 306 238 303.5 238 301 236 299 233.5 299 231 299 229 301 229 303.5 229 306 231 308 233.5 308ZM210.5 110C213 110 215 108 215 105.5 215 103 213 101 210.5 101 208 101 206 103 206 105.5 206 108 208 110 210.5 110ZM87.2 213.4C90.1 213.4 92.4 211.1 92.4 208.2 92.4 205.3 90.1 203 87.2 203 84.3 203 82 205.3 82 208.2 82 211.1 84.3 213.4 87.2 213.4ZM265.2 258.4C268.1 258.4 270.4 256.1 270.4 253.2 270.4 250.3 268.1 248 265.2 248 262.3 248 260 250.3 260 253.2 260 256.1 262.3 258.4 265.2 258.4ZM107 108.9C109.1 108.9 110.9 107.1 110.9 105 110.9 102.8 109.1 101 107 101 104.8 101 103 102.8 103 105 103 107.1 104.8 108.9 107 108.9ZM291.2 190.5C293 190.5 294.5 189 294.5 187.2 294.5 185.5 293 184 291.2 184 289.4 184 288 185.5 288 187.2 288 189 289.4 190.5 291.2 190.5ZM336.2 327.5C338 327.5 339.5 326 339.5 324.2 339.5 322.5 338 321 336.2 321 334.4 321 333 322.5 333 324.2 333 326 334.4 327.5 336.2 327.5ZM163.2 307.5C165 307.5 166.5 306 166.5 304.2 166.5 302.5 165 301 163.2 301 161.4 301 160 302.5 160 304.2 160 306 161.4 307.5 163.2 307.5ZM98.2 260.5C100 260.5 101.5 259 101.5 257.2 101.5 255.5 100 254 98.2 254 96.4 254 95 255.5 95 257.2 95 259 96.4 260.5 98.2 260.5ZM168.2 72.5C170 72.5 171.5 71 171.5 69.2 171.5 67.5 170 66 168.2 66 166.4 66 165 67.5 165 69.2 165 71 166.4 72.5 168.2 72.5ZM275 100.9C277.1 100.9 278.9 99.1 278.9 97 278.9 94.8 277.1 93 275 93 272.8 93 271 94.8 271 97 271 99.1 272.8 100.9 275 100.9ZM117 208.9C119.1 208.9 120.9 207.1 120.9 205 120.9 202.8 119.1 201 117 201 114.8 201 113 202.8 113 205 113 207.1 114.8 208.9 117 208.9ZM186.3 302.6C190.8 302.6 194.5 298.9 194.5 294.3 194.5 289.7 190.8 286 186.3 286 181.7 286 178 289.7 178 294.3 178 298.9 181.7 302.6 186.3 302.6ZM256.3 145.6C260.8 145.6 264.5 141.9 264.5 137.3 264.5 132.7 260.8 129 256.3 129 251.7 129 248 132.7 248 137.3 248 141.9 251.7 145.6 256.3 145.6ZM63.9 265.8C65.5 265.8 66.8 264.5 66.8 262.9 66.8 261.3 65.5 260 63.9 260 62.3 260 61 261.3 61 262.9 61 264.5 62.3 265.8 63.9 265.8ZM256.9 303.8C258.5 303.8 259.8 302.5 259.8 300.9 259.8 299.3 258.5 298 256.9 298 255.3 298 254 299.3 254 300.9 254 302.5 255.3 303.8 256.9 303.8ZM369.9 240.8C371.5 240.8 372.8 239.5 372.8 237.9 372.8 236.3 371.5 235 369.9 235 368.3 235 367 236.3 367 237.9 367 239.5 368.3 240.8 369.9 240.8ZM360.9 124.8C362.5 124.8 363.8 123.5 363.8 121.9 363.8 120.3 362.5 119 360.9 119 359.3 119 358 120.3 358 121.9 358 123.5 359.3 124.8 360.9 124.8ZM244.9 106.8C246.5 106.8 247.8 105.5 247.8 103.9 247.8 102.3 246.5 101 244.9 101 243.3 101 242 102.3 242 103.9 242 105.5 243.3 106.8 244.9 106.8ZM221.9 31.8C223.5 31.8 224.8 30.5 224.8 28.9 224.8 27.3 223.5 26 221.9 26 220.3 26 219 27.3 219 28.9 219 30.5 220.3 31.8 221.9 31.8ZM132.9 143.8C134.5 143.8 135.8 142.5 135.8 140.9 135.8 139.3 134.5 138 132.9 138 131.3 138 130 139.3 130 140.9 130 142.5 131.3 143.8 132.9 143.8ZM147.9 353.8C149.5 353.8 150.8 352.5 150.8 350.9 150.8 349.3 149.5 348 147.9 348 146.3 348 145 349.3 145 350.9 145 352.5 146.3 353.8 147.9 353.8ZM57.2 154.3C58.3 154.3 59.3 153.4 59.3 152.2 59.3 151 58.3 150 57.2 150 56 150 55 151 55 152.2 55 153.4 56 154.3 57.2 154.3ZM362.5 217.1C363.4 217.1 364.1 216.4 364.1 215.5 364.1 214.7 363.4 214 362.5 214 361.7 214 361 214.7 361 215.5 361 216.4 361.7 217.1 362.5 217.1ZM127.5 79.1C128.4 79.1 129.1 78.4 129.1 77.5 129.1 76.7 128.4 76 127.5 76 126.7 76 126 76.7 126 77.5 126 78.4 126.7 79.1 127.5 79.1ZM104.5 339.1C105.4 339.1 106.1 338.4 106.1 337.5 106.1 336.7 105.4 336 104.5 336 103.7 336 103 336.7 103 337.5 103 338.4 103.7 339.1 104.5 339.1ZM251.5 321.1C252.4 321.1 253.1 320.4 253.1 319.5 253.1 318.7 252.4 318 251.5 318 250.7 318 250 318.7 250 319.5 250 320.4 250.7 321.1 251.5 321.1ZM314.5 203.1C315.4 203.1 316.1 202.4 316.1 201.5 316.1 200.7 315.4 200 314.5 200 313.7 200 313 200.7 313 201.5 313 202.4 313.7 203.1 314.5 203.1ZM221.5 75.1C222.4 75.1 223.1 74.4 223.1 73.5 223.1 72.7 222.4 72 221.5 72 220.7 72 220 72.7 220 73.5 220 74.4 220.7 75.1 221.5 75.1ZM88.5 237.1C89.4 237.1 90.1 236.4 90.1 235.5 90.1 234.7 89.4 234 88.5 234 87.7 234 87 234.7 87 235.5 87 236.4 87.7 237.1 88.5 237.1ZM137.5 295.1C138.4 295.1 139.1 294.4 139.1 293.5 139.1 292.7 138.4 292 137.5 292 136.7 292 136 292.7 136 293.5 136 294.4 136.7 295.1 137.5 295.1ZM267.5 338.1C268.4 338.1 269.1 337.4 269.1 336.5 269.1 335.7 268.4 335 267.5 335 266.7 335 266 335.7 266 336.5 266 337.4 266.7 338.1 267.5 338.1ZM194.2 51.3C195.3 51.3 196.3 50.4 196.3 49.2 196.3 48 195.3 47 194.2 47 193 47 192 48 192 49.2 192 50.4 193 51.3 194.2 51.3ZM347.2 269.3C348.3 269.3 349.3 268.4 349.3 267.2 349.3 266 348.3 265 347.2 265 346 265 345 266 345 267.2 345 268.4 346 269.3 347.2 269.3ZM77.2 325.3C78.3 325.3 79.3 324.4 79.3 323.2 79.3 322 78.3 321 77.2 321 76 321 75 322 75 323.2 75 324.4 76 325.3 77.2 325.3ZM100.2 130.3C101.3 130.3 102.3 129.4 102.3 128.2 102.3 127 101.3 126 100.2 126 99 126 98 127 98 128.2 98 129.4 99 130.3 100.2 130.3ZM229.2 87.3C230.3 87.3 231.3 86.4 231.3 85.2 231.3 84 230.3 83 229.2 83 228 83 227 84 227 85.2 227 86.4 228 87.3 229.2 87.3ZM296.2 209.3C297.3 209.3 298.3 208.4 298.3 207.2 298.3 206 297.3 205 296.2 205 295 205 294 206 294 207.2 294 208.4 295 209.3 296.2 209.3ZM118.2 316.3C119.3 316.3 120.3 315.4 120.3 314.2 120.3 313 119.3 312 118.2 312 117 312 116 313 116 314.2 116 315.4 117 316.3 118.2 316.3ZM294 132C297.9 132 301 128.9 301 125 301 121.1 297.9 118 294 118 290.1 118 287 121.1 287 125 287 128.9 290.1 132 294 132ZM135.8 60.6C137.9 60.6 139.5 58.9 139.5 56.8 139.5 54.7 137.9 53 135.8 53 133.7 53 132 54.7 132 56.8 132 58.9 133.7 60.6 135.8 60.6ZM58.5 131C59.9 131 61 129.9 61 128.5 61 127.1 59.9 126 58.5 126 57.1 126 56 127.1 56 128.5 56 129.9 57.1 131 58.5 131ZM257.5 363C258.9 363 260 361.9 260 360.5 260 359.1 258.9 358 257.5 358 256.1 358 255 359.1 255 360.5 255 361.9 256.1 363 257.5 363ZM129.8 125.6C131.9 125.6 133.5 123.9 133.5 121.8 133.5 119.7 131.9 118 129.8 118 127.7 118 126 119.7 126 121.8 126 123.9 127.7 125.6 129.8 125.6ZM292.8 246.6C294.9 246.6 296.5 244.9 296.5 242.8 296.5 240.7 294.9 239 292.8 239 290.7 239 289 240.7 289 242.8 289 244.9 290.7 246.6 292.8 246.6ZM49.8 226.6C51.9 226.6 53.5 224.9 53.5 222.8 53.5 220.7 51.9 219 49.8 219 47.7 219 46 220.7 46 222.8 46 224.9 47.7 226.6 49.8 226.6ZM357.7 152.4C359.2 152.4 360.4 151.2 360.4 149.7 360.4 148.2 359.2 147 357.7 147 356.2 147 355 148.2 355 149.7 355 151.2 356.2 152.4 357.7 152.4ZM285.7 155.4C287.2 155.4 288.4 154.2 288.4 152.7 288.4 151.2 287.2 150 285.7 150 284.2 150 283 151.2 283 152.7 283 154.2 284.2 155.4 285.7 155.4ZM311.7 253.4C313.2 253.4 314.4 252.2 314.4 250.7 314.4 249.2 313.2 248 311.7 248 310.2 248 309 249.2 309 250.7 309 252.2 310.2 253.4 311.7 253.4ZM222.7 348.4C224.2 348.4 225.4 347.2 225.4 345.7 225.4 344.2 224.2 343 222.7 343 221.2 343 220 344.2 220 345.7 220 347.2 221.2 348.4 222.7 348.4ZM109.7 239.4C111.2 239.4 112.4 238.2 112.4 236.7 112.4 235.2 111.2 234 109.7 234 108.2 234 107 235.2 107 236.7 107 238.2 108.2 239.4 109.7 239.4ZM101.7 79.4C103.2 79.4 104.4 78.2 104.4 76.7 104.4 75.2 103.2 74 101.7 74 100.2 74 99 75.2 99 76.7 99 78.2 100.2 79.4 101.7 79.4ZM158.7 38.4C160.2 38.4 161.4 37.2 161.4 35.7 161.4 34.2 160.2 33 158.7 33 157.2 33 156 34.2 156 35.7 156 37.2 157.2 38.4 158.7 38.4ZM298.8 168.6C300.9 168.6 302.5 166.9 302.5 164.8 302.5 162.7 300.9 161 298.8 161 296.7 161 295 162.7 295 164.8 295 166.9 296.7 168.6 298.8 168.6ZM199.8 88.6C201.9 88.6 203.5 86.9 203.5 84.8 203.5 82.7 201.9 81 199.8 81 197.7 81 196 82.7 196 84.8 196 86.9 197.7 88.6 199.8 88.6ZM51.5 283C52.9 283 54 281.9 54 280.5 54 279.1 52.9 278 51.5 278 50.1 278 49 279.1 49 280.5 49 281.9 50.1 283 51.5 283ZM120.9 167.9C124.2 167.9 126.9 165.2 126.9 161.9 126.9 158.7 124.2 156 120.9 156 117.7 156 115 158.7 115 161.9 115 165.2 117.7 167.9 120.9 167.9ZM150.3 108.6C152.7 108.6 154.6 106.7 154.6 104.3 154.6 101.9 152.7 100 150.3 100 147.9 100 146 101.9 146 104.3 146 106.7 147.9 108.6 150.3 108.6ZM223.3 326.6C225.7 326.6 227.6 324.7 227.6 322.3 227.6 319.9 225.7 318 223.3 318 220.9 318 219 319.9 219 322.3 219 324.7 220.9 326.6 223.3 326.6ZM32.3 177.6C34.7 177.6 36.6 175.7 36.6 173.3 36.6 170.9 34.7 169 32.3 169 29.9 169 28 170.9 28 173.3 28 175.7 29.9 177.6 32.3 177.6ZM333.3 145.6C335.7 145.6 337.6 143.7 337.6 141.3 337.6 138.9 335.7 137 333.3 137 330.9 137 329 138.9 329 141.3 329 143.7 330.9 145.6 333.3 145.6ZM259.9 281.9C263.2 281.9 265.9 279.2 265.9 275.9 265.9 272.7 263.2 270 259.9 270 256.7 270 254 272.7 254 275.9 254 279.2 256.7 281.9 259.9 281.9ZM221.9 124.9C225.2 124.9 227.9 122.2 227.9 118.9 227.9 115.7 225.2 113 221.9 113 218.7 113 216 115.7 216 118.9 216 122.2 218.7 124.9 221.9 124.9ZM87 298C90.9 298 94 294.9 94 291 94 287.1 90.9 284 87 284 83.1 284 80 287.1 80 291 80 294.9 83.1 298 87 298ZM322 233C325.9 233 329 229.9 329 226 329 222.1 325.9 219 322 219 318.1 219 315 222.1 315 226 315 229.9 318.1 233 322 233ZM328.3 298.6C332.8 298.6 336.5 294.9 336.5 290.3 336.5 285.7 332.8 282 328.3 282 323.7 282 320 285.7 320 290.3 320 294.9 323.7 298.6 328.3 298.6ZM69.3 188.6C73.8 188.6 77.5 184.9 77.5 180.3 77.5 175.7 73.8 172 69.3 172 64.7 172 61 175.7 61 180.3 61 184.9 64.7 188.6 69.3 188.6ZM235.6 55.2C237.6 55.2 239.2 53.6 239.2 51.6 239.2 49.6 237.6 48 235.6 48 233.6 48 232 49.6 232 51.6 232 53.6 233.6 55.2 235.6 55.2ZM210.6 292.2C212.6 292.2 214.2 290.6 214.2 288.6 214.2 286.6 212.6 285 210.6 285 208.6 285 207 286.6 207 288.6 207 290.6 208.6 292.2 210.6 292.2ZM68.6 78.2C70.6 78.2 72.2 76.6 72.2 74.6 72.2 72.6 70.6 71 68.6 71 66.6 71 65 72.6 65 74.6 65 76.6 66.6 78.2 68.6 78.2ZM170.6 378.2C172.6 378.2 174.2 376.6 174.2 374.6 174.2 372.6 172.6 371 170.6 371 168.6 371 167 372.6 167 374.6 167 376.6 168.6 378.2 170.6 378.2ZM339 180C340.1 180 341 179.1 341 178 341 176.9 340.1 176 339 176 337.9 176 337 176.9 337 178 337 179.1 337.9 180 339 180ZM332 120C333.1 120 334 119.1 334 118 334 116.9 333.1 116 332 116 330.9 116 330 116.9 330 118 330 119.1 330.9 120 332 120ZM282 268.9C284.1 268.9 285.9 267.1 285.9 265 285.9 262.8 284.1 261 282 261 279.8 261 278 262.8 278 265 278 267.1 279.8 268.9 282 268.9ZM296 275C297.1 275 298 274.1 298 273 298 271.9 297.1 271 296 271 294.9 271 294 271.9 294 273 294 274.1 294.9 275 296 275ZM343 195C344.1 195 345 194.1 345 193 345 191.9 344.1 191 343 191 341.9 191 341 191.9 341 193 341 194.1 341.9 195 343 195ZM343 231C344.1 231 345 230.1 345 229 345 227.9 344.1 227 343 227 341.9 227 341 227.9 341 229 341 230.1 341.9 231 343 231ZM86 98C87.1 98 88 97.1 88 96 88 94.9 87.1 94 86 94 84.9 94 84 94.9 84 96 84 97.1 84.9 98 86 98ZM195 25C196.1 25 197 24.1 197 23 197 21.9 196.1 21 195 21 193.9 21 193 21.9 193 23 193 24.1 193.9 25 195 25ZM132 331C133.1 331 134 330.1 134 329 134 327.9 133.1 327 132 327 130.9 327 130 327.9 130 329 130 330.1 130.9 331 132 331ZM191.2 364.4C194.1 364.4 196.4 362.1 196.4 359.2 196.4 356.3 194.1 354 191.2 354 188.3 354 186 356.3 186 359.2 186 362.1 188.3 364.4 191.2 364.4ZM204.2 311.5C206 311.5 207.5 310 207.5 308.2 207.5 306.5 206 305 204.2 305 202.4 305 201 306.5 201 308.2 201 310 202.4 311.5 204.2 311.5ZM206 330C207.1 330 208 329.1 208 328 208 326.9 207.1 326 206 326 204.9 326 204 326.9 204 328 204 329.1 204.9 330 206 330ZM292 331C293.1 331 294 330.1 294 329 294 327.9 293.1 327 292 327 290.9 327 290 327.9 290 329 290 330.1 290.9 331 292 331ZM98 199C99.1 199 100 198.1 100 197 100 195.9 99.1 195 98 195 96.9 195 96 195.9 96 197 96 198.1 96.9 199 98 199ZM314 72.9C316.1 72.9 317.9 71.1 317.9 69 317.9 66.8 316.1 65 314 65 311.8 65 310 66.8 310 69 310 71.1 311.8 72.9 314 72.9ZM265.8 74.6C267.9 74.6 269.5 72.9 269.5 70.8 269.5 68.7 267.9 67 265.8 67 263.7 67 262 68.7 262 70.8 262 72.9 263.7 74.6 265.8 74.6ZM287 61C288.1 61 289 60.1 289 59 289 57.9 288.1 57 287 57 285.9 57 285 57.9 285 59 285 60.1 285.9 61 287 61Z;
			M168.9 146.2C171.8 146.2 174.1 143.9 174.1 141 174.1 138.1 171.8 135.8 168.9 135.8 166 135.8 163.7 138.1 163.7 141 163.7 143.9 166 146.2 168.9 146.2ZM168.9 264.7C171.8 264.7 174.1 262.3 174.1 259.5 174.1 256.6 171.8 254.2 168.9 254.2 166 254.2 163.7 256.6 163.7 259.5 163.7 262.3 166 264.7 168.9 264.7ZM147.7 240.6C150.2 240.6 152.2 238.6 152.2 236.1 152.2 233.6 150.2 231.6 147.7 231.6 145.2 231.6 143.2 233.6 143.2 236.1 143.2 238.6 145.2 240.6 147.7 240.6ZM260.2 131.5C262.7 131.5 264.7 129.5 264.7 127 264.7 124.5 262.7 122.5 260.2 122.5 257.7 122.5 255.7 124.5 255.7 127 255.7 129.5 257.7 131.5 260.2 131.5ZM241.1 278.4C243.6 278.4 245.6 276.3 245.6 273.9 245.6 271.4 243.6 269.4 241.1 269.4 238.7 269.4 236.6 271.4 236.6 273.9 236.6 276.3 238.7 278.4 241.1 278.4ZM176.1 286.6C178.6 286.6 180.6 284.6 180.6 282.1 180.6 279.7 178.6 277.6 176.1 277.6 173.6 277.6 171.6 279.7 171.6 282.1 171.6 284.6 173.6 286.6 176.1 286.6ZM132.2 172.9C134.7 172.9 136.7 170.9 136.7 168.4 136.7 165.9 134.7 163.9 132.2 163.9 129.7 163.9 127.7 165.9 127.7 168.4 127.7 170.9 129.7 172.9 132.2 172.9ZM139.1 215.4C141.5 215.4 143.5 213.4 143.5 210.9 143.5 208.4 141.5 206.4 139.1 206.4 136.6 206.4 134.6 208.4 134.6 210.9 134.6 213.4 136.6 215.4 139.1 215.4ZM271.7 199.5C274.2 199.5 276.2 197.5 276.2 195 276.2 192.5 274.2 190.5 271.7 190.5 269.2 190.5 267.2 192.5 267.2 195 267.2 197.5 269.2 199.5 271.7 199.5ZM215.3 272.6C217.7 272.6 219.8 270.6 219.8 268.1 219.8 265.6 217.7 263.6 215.3 263.6 212.8 263.6 210.8 265.6 210.8 268.1 210.8 270.6 212.8 272.6 215.3 272.6ZM207.7 139.4C210.2 139.4 212.2 137.4 212.2 134.9 212.2 132.4 210.2 130.4 207.7 130.4 205.2 130.4 203.2 132.4 203.2 134.9 203.2 137.4 205.2 139.4 207.7 139.4ZM126.5 210.7C129.4 210.7 131.7 208.3 131.7 205.5 131.7 202.6 129.4 200.2 126.5 200.2 123.6 200.2 121.3 202.6 121.3 205.5 121.3 208.3 123.6 210.7 126.5 210.7ZM264.2 240.6C267 240.6 269.4 238.2 269.4 235.3 269.4 232.5 267 230.1 264.2 230.1 261.3 230.1 258.9 232.5 258.9 235.3 258.9 238.2 261.3 240.6 264.2 240.6ZM154.7 142.3C156.9 142.3 158.6 140.5 158.6 138.3 158.6 136.1 156.9 134.4 154.7 134.4 152.5 134.4 150.7 136.1 150.7 138.3 150.7 140.5 152.5 142.3 154.7 142.3ZM269.7 187.6C271.5 187.6 273 186.2 273 184.4 273 182.6 271.5 181.2 269.7 181.2 267.9 181.2 266.5 182.6 266.5 184.4 266.5 186.2 267.9 187.6 269.7 187.6ZM274.8 261.8C276.5 261.8 278 260.4 278 258.6 278 256.8 276.5 255.3 274.8 255.3 273 255.3 271.5 256.8 271.5 258.6 271.5 260.4 273 261.8 274.8 261.8ZM167.6 275.5C169.4 275.5 170.9 274 170.9 272.2 170.9 270.5 169.4 269 167.6 269 165.8 269 164.4 270.5 164.4 272.2 164.4 274 165.8 275.5 167.6 275.5ZM136.4 235.9C138.1 235.9 139.6 234.4 139.6 232.6 139.6 230.9 138.1 229.4 136.4 229.4 134.6 229.4 133.1 230.9 133.1 232.6 133.1 234.4 134.6 235.9 136.4 235.9ZM202.5 125.4C204.3 125.4 205.7 123.9 205.7 122.1 205.7 120.3 204.3 118.9 202.5 118.9 200.7 118.9 199.3 120.3 199.3 122.1 199.3 123.9 200.7 125.4 202.5 125.4ZM255 142.3C257.2 142.3 258.9 140.5 258.9 138.3 258.9 136.1 257.2 134.4 255 134.4 252.8 134.4 251 136.1 251 138.3 251 140.5 252.8 142.3 255 142.3ZM137.8 203.5C140 203.5 141.7 201.7 141.7 199.5 141.7 197.3 140 195.6 137.8 195.6 135.6 195.6 133.8 197.3 133.8 199.5 133.8 201.7 135.6 203.5 137.8 203.5ZM186 277.6C190.5 277.6 194.2 273.9 194.2 269.4 194.2 264.8 190.5 261.1 186 261.1 181.4 261.1 177.7 264.8 177.7 269.4 177.7 273.9 181.4 277.6 186 277.6ZM239.5 149.1C244.1 149.1 247.8 145.4 247.8 140.8 247.8 136.3 244.1 132.6 239.5 132.6 235 132.6 231.3 136.3 231.3 140.8 231.3 145.4 235 149.1 239.5 149.1ZM143.5 248.1C145.1 248.1 146.4 246.8 146.4 245.2 146.4 243.7 145.1 242.4 143.5 242.4 142 242.4 140.7 243.7 140.7 245.2 140.7 246.8 142 248.1 143.5 248.1ZM232 280.2C233.6 280.2 234.9 278.9 234.9 277.3 234.9 275.7 233.6 274.4 232 274.4 230.4 274.4 229.1 275.7 229.1 277.3 229.1 278.9 230.4 280.2 232 280.2ZM285.5 237C287.1 237 288.4 235.7 288.4 234.1 288.4 232.5 287.1 231.2 285.5 231.2 284 231.2 282.7 232.5 282.7 234.1 282.7 235.7 284 237 285.5 237ZM286.6 161C288.2 161 289.5 159.7 289.5 158.1 289.5 156.5 288.2 155.2 286.6 155.2 285 155.2 283.7 156.5 283.7 158.1 283.7 159.7 285 161 286.6 161ZM239.9 130C241.5 130 242.8 128.8 242.8 127.2 242.8 125.6 241.5 124.3 239.9 124.3 238.3 124.3 237 125.6 237 127.2 237 128.8 238.3 130 239.9 130ZM210.4 127.9C212 127.9 213.3 126.6 213.3 125 213.3 123.4 212 122.1 210.4 122.1 208.8 122.1 207.5 123.4 207.5 125 207.5 126.6 208.8 127.9 210.4 127.9ZM152.9 158.5C154.5 158.5 155.8 157.2 155.8 155.6 155.8 154 154.5 152.7 152.9 152.7 151.3 152.7 150 154 150 155.6 150 157.2 151.3 158.5 152.9 158.5ZM165.8 283.8C167.4 283.8 168.7 282.5 168.7 280.9 168.7 279.3 167.4 278 165.8 278 164.2 278 163 279.3 163 280.9 163 282.5 164.2 283.8 165.8 283.8ZM101.2 162.4C102.3 162.4 103.3 161.5 103.3 160.3 103.3 159.1 102.3 158.1 101.2 158.1 100 158.1 99 159.1 99 160.3 99 161.5 100 162.4 101.2 162.4ZM307.5 219.1C308.3 219.1 309 218.4 309 217.5 309 216.7 308.3 216 307.5 216 306.6 216 305.9 216.7 305.9 217.5 305.9 218.4 306.6 219.1 307.5 219.1ZM133.1 100.1C134 100.1 134.7 99.4 134.7 98.5 134.7 97.7 134 97 133.1 97 132.3 97 131.6 97.7 131.6 98.5 131.6 99.4 132.3 100.1 133.1 100.1ZM131.3 300.1C132.2 300.1 132.9 299.4 132.9 298.5 132.9 297.7 132.2 297 131.3 297 130.5 297 129.8 297.7 129.8 298.5 129.8 299.4 130.5 300.1 131.3 300.1ZM218 277.7C218.8 277.7 219.5 277.1 219.5 276.2 219.5 275.4 218.8 274.7 218 274.7 217.1 274.7 216.4 275.4 216.4 276.2 216.4 277.1 217.1 277.7 218 277.7ZM279.8 210.3C280.6 210.3 281.3 209.6 281.3 208.8 281.3 207.9 280.6 207.3 279.8 207.3 278.9 207.3 278.3 207.9 278.3 208.8 278.3 209.6 278.9 210.3 279.8 210.3ZM219.8 114.2C220.6 114.2 221.3 113.5 221.3 112.7 221.3 111.8 220.6 111.1 219.8 111.1 218.9 111.1 218.2 111.8 218.2 112.7 218.2 113.5 218.9 114.2 219.8 114.2ZM122.3 217.9C123.2 217.9 123.9 217.2 123.9 216.3 123.9 215.5 123.2 214.8 122.3 214.8 121.5 214.8 120.8 215.5 120.8 216.3 120.8 217.2 121.5 217.9 122.3 217.9ZM159 261.1C159.9 261.1 160.5 260.4 160.5 259.5 160.5 258.7 159.9 258 159 258 158.2 258 157.5 258.7 157.5 259.5 157.5 260.4 158.2 261.1 159 261.1ZM247.4 301.5C248.3 301.5 249 300.8 249 300 249 299.1 248.3 298.4 247.4 298.4 246.6 298.4 245.9 299.1 245.9 300 245.9 300.8 246.6 301.5 247.4 301.5ZM209 118.9C210.2 118.9 211.1 117.9 211.1 116.7 211.1 115.5 210.2 114.6 209 114.6 207.8 114.6 206.8 115.5 206.8 116.7 206.8 117.9 207.8 118.9 209 118.9ZM296.7 250.3C297.9 250.3 298.8 249.3 298.8 248.1 298.8 246.9 297.9 246 296.7 246 295.5 246 294.5 246.9 294.5 248.1 294.5 249.3 295.5 250.3 296.7 250.3ZM144.6 255C145.8 255 146.8 254 146.8 252.8 146.8 251.6 145.8 250.6 144.6 250.6 143.4 250.6 142.5 251.6 142.5 252.8 142.5 254 143.4 255 144.6 255ZM136 160.3C137.2 160.3 138.2 159.3 138.2 158.1 138.2 156.9 137.2 156 136 156 134.8 156 133.8 156.9 133.8 158.1 133.8 159.3 134.8 160.3 136 160.3ZM218 127.5C219.1 127.5 220.1 126.6 220.1 125.4 220.1 124.2 219.1 123.2 218 123.2 216.8 123.2 215.8 124.2 215.8 125.4 215.8 126.6 216.8 127.5 218 127.5ZM269.7 208.5C270.9 208.5 271.9 207.6 271.9 206.4 271.9 205.2 270.9 204.2 269.7 204.2 268.5 204.2 267.6 205.2 267.6 206.4 267.6 207.6 268.5 208.5 269.7 208.5ZM147.1 267.6C148.3 267.6 149.3 266.6 149.3 265.4 149.3 264.2 148.3 263.2 147.1 263.2 146 263.2 145 264.2 145 265.4 145 266.6 146 267.6 147.1 267.6ZM256.2 161.4C260.1 161.4 263.3 158.2 263.3 154.3 263.3 150.5 260.1 147.3 256.2 147.3 252.4 147.3 249.2 150.5 249.2 154.3 249.2 158.2 252.4 161.4 256.2 161.4ZM165.7 122.5C167.7 122.5 169.4 120.8 169.4 118.7 169.4 116.6 167.7 114.9 165.7 114.9 163.6 114.9 161.9 116.6 161.9 118.7 161.9 120.8 163.6 122.5 165.7 122.5ZM123.2 167.3C124.6 167.3 125.8 166.2 125.8 164.8 125.8 163.4 124.6 162.3 123.2 162.3 121.8 162.3 120.7 163.4 120.7 164.8 120.7 166.2 121.8 167.3 123.2 167.3ZM242.2 291.9C243.6 291.9 244.7 290.7 244.7 289.3 244.7 288 243.6 286.8 242.2 286.8 240.8 286.8 239.7 288 239.7 289.3 239.7 290.7 240.8 291.9 242.2 291.9ZM160.1 152.9C162.2 152.9 163.9 151.2 163.9 149.1 163.9 147 162.2 145.3 160.1 145.3 158 145.3 156.3 147 156.3 149.1 156.3 151.2 158 152.9 160.1 152.9ZM275.8 237.9C277.9 237.9 279.6 236.2 279.6 234.1 279.6 232 277.9 230.3 275.8 230.3 273.7 230.3 272.1 232 272.1 234.1 272.1 236.2 273.7 237.9 275.8 237.9ZM113.7 217.3C115.8 217.3 117.5 215.7 117.5 213.6 117.5 211.5 115.8 209.8 113.7 209.8 111.6 209.8 109.9 211.5 109.9 213.6 109.9 215.7 111.6 217.3 113.7 217.3ZM284.8 175.9C286.3 175.9 287.5 174.7 287.5 173.2 287.5 171.8 286.3 170.5 284.8 170.5 283.3 170.5 282.1 171.8 282.1 173.2 282.1 174.7 283.3 175.9 284.8 175.9ZM261.5 168.4C262.9 168.4 264.2 167.2 264.2 165.7 264.2 164.2 262.9 163 261.5 163 260 163 258.8 164.2 258.8 165.7 258.8 167.2 260 168.4 261.5 168.4ZM281.6 244.7C283.1 244.7 284.3 243.5 284.3 242 284.3 240.5 283.1 239.3 281.6 239.3 280.1 239.3 278.9 240.5 278.9 242 278.9 243.5 280.1 244.7 281.6 244.7ZM194.6 296.5C196.1 296.5 197.3 295.3 197.3 293.8 197.3 292.3 196.1 291.1 194.6 291.1 193.1 291.1 191.9 292.3 191.9 293.8 191.9 295.3 193.1 296.5 194.6 296.5ZM130.2 218.4C131.7 218.4 132.9 217.2 132.9 215.7 132.9 214.2 131.7 213 130.2 213 128.8 213 127.6 214.2 127.6 215.7 127.6 217.2 128.8 218.4 130.2 218.4ZM153.6 130.2C155.1 130.2 156.3 129 156.3 127.5 156.3 126 155.1 124.8 153.6 124.8 152.1 124.8 150.9 126 150.9 127.5 150.9 129 152.1 130.2 153.6 130.2ZM184.2 115.5C185.7 115.5 186.9 114.3 186.9 112.8 186.9 111.3 185.7 110.1 184.2 110.1 182.7 110.1 181.5 111.3 181.5 112.8 181.5 114.3 182.7 115.5 184.2 115.5ZM266.1 178.5C268.2 178.5 269.9 176.8 269.9 174.7 269.9 172.6 268.2 170.9 266.1 170.9 264 170.9 262.4 172.6 262.4 174.7 262.4 176.8 264 178.5 266.1 178.5ZM196 139.2C198.1 139.2 199.8 137.5 199.8 135.4 199.8 133.4 198.1 131.7 196 131.7 193.9 131.7 192.3 133.4 192.3 135.4 192.3 137.5 193.9 139.2 196 139.2ZM124.9 262.2C126.2 262.2 127.4 261 127.4 259.6 127.4 258.3 126.2 257.1 124.9 257.1 123.5 257.1 122.3 258.3 122.3 259.6 122.3 261 123.5 262.2 124.9 262.2ZM145.2 171.1C148.4 171.1 151.1 168.4 151.1 165.1 151.1 161.9 148.4 159.2 145.2 159.2 141.9 159.2 139.2 161.9 139.2 165.1 139.2 168.4 141.9 171.1 145.2 171.1ZM163.3 134C165.7 134 167.6 132.1 167.6 129.7 167.6 127.3 165.7 125.4 163.3 125.4 160.9 125.4 159 127.3 159 129.7 159 132.1 160.9 134 163.3 134ZM209 282.7C211.4 282.7 213.3 280.7 213.3 278.4 213.3 276 211.4 274 209 274 206.6 274 204.7 276 204.7 278.4 204.7 280.7 206.6 282.7 209 282.7ZM122.3 192C124.7 192 126.7 190 126.7 187.6 126.7 185.3 124.7 183.3 122.3 183.3 120 183.3 118 185.3 118 187.6 118 190 120 192 122.3 192ZM274.4 172.2C276.8 172.2 278.7 170.2 278.7 167.8 278.7 165.5 276.8 163.5 274.4 163.5 272 163.5 270.1 165.5 270.1 167.8 270.1 170.2 272 172.2 274.4 172.2ZM229.6 271.5C232.9 271.5 235.6 268.9 235.6 265.6 235.6 262.3 232.9 259.6 229.6 259.6 226.4 259.6 223.7 262.3 223.7 265.6 223.7 268.9 226.4 271.5 229.6 271.5ZM222.1 141.9C225.4 141.9 228 139.3 228 136 228 132.7 225.4 130 222.1 130 218.8 130 216.2 132.7 216.2 136 216.2 139.3 218.8 141.9 222.1 141.9ZM155.2 255.7C159.1 255.7 162.2 252.5 162.2 248.7 162.2 244.8 159.1 241.6 155.2 241.6 151.4 241.6 148.2 244.8 148.2 248.7 148.2 252.5 151.4 255.7 155.2 255.7ZM272.8 226.9C276.6 226.9 279.8 223.7 279.8 219.9 279.8 216 276.6 212.8 272.8 212.8 268.9 212.8 265.8 216 265.8 219.9 265.8 223.7 268.9 226.9 272.8 226.9ZM247.4 267.6C252 267.6 255.7 263.9 255.7 259.3 255.7 254.7 252 251 247.4 251 242.9 251 239.2 254.7 239.2 259.3 239.2 263.9 242.9 267.6 247.4 267.6ZM136.7 191.6C141.3 191.6 145 187.9 145 183.3 145 178.8 141.3 175 136.7 175 132.2 175 128.5 178.8 128.5 183.3 128.5 187.9 132.2 191.6 136.7 191.6ZM234.1 118.9C236.1 118.9 237.7 117.3 237.7 115.3 237.7 113.3 236.1 111.7 234.1 111.7 232.1 111.7 230.5 113.3 230.5 115.3 230.5 117.3 232.1 118.9 234.1 118.9ZM201.8 272.6C203.8 272.6 205.4 271 205.4 269 205.4 267 203.8 265.4 201.8 265.4 199.8 265.4 198.2 267 198.2 269 198.2 271 199.8 272.6 201.8 272.6ZM119.5 136.9C121.4 136.9 123.1 135.3 123.1 133.3 123.1 131.3 121.4 129.7 119.5 129.7 117.5 129.7 115.9 131.3 115.9 133.3 115.9 135.3 117.5 136.9 119.5 136.9ZM175.9 305C177.9 305 179.5 303.4 179.5 301.4 179.5 299.4 177.9 297.8 175.9 297.8 173.9 297.8 172.3 299.4 172.3 301.4 172.3 303.4 173.9 305 175.9 305ZM273.5 179.9C274.6 179.9 275.5 179 275.5 177.9 275.5 176.8 274.6 175.9 273.5 175.9 272.4 175.9 271.5 176.8 271.5 177.9 271.5 179 272.4 179.9 273.5 179.9ZM263.8 145.7C264.9 145.7 265.8 144.8 265.8 143.7 265.8 142.6 264.9 141.7 263.8 141.7 262.7 141.7 261.8 142.6 261.8 143.7 261.8 144.8 262.7 145.7 263.8 145.7ZM272.6 247.8C274.8 247.8 276.6 246 276.6 243.8 276.6 241.6 274.8 239.8 272.6 239.8 270.4 239.8 268.6 241.6 268.6 243.8 268.6 246 270.4 247.8 272.6 247.8ZM281.4 251.2C282.5 251.2 283.4 250.3 283.4 249.2 283.4 248.1 282.5 247.2 281.4 247.2 280.3 247.2 279.4 248.1 279.4 249.2 279.4 250.3 280.3 251.2 281.4 251.2ZM295.2 202.9C296.3 202.9 297.2 202.1 297.2 201 297.2 199.9 296.3 199 295.2 199 294.2 199 293.3 199.9 293.3 201 293.3 202.1 294.2 202.9 295.2 202.9ZM282.3 227.8C283.4 227.8 284.3 226.9 284.3 225.8 284.3 224.7 283.4 223.8 282.3 223.8 281.2 223.8 280.3 224.7 280.3 225.8 280.3 226.9 281.2 227.8 282.3 227.8ZM150.2 148.6C151.3 148.6 152.2 147.7 152.2 146.6 152.2 145.5 151.3 144.6 150.2 144.6 149.1 144.6 148.2 145.5 148.2 146.6 148.2 147.7 149.1 148.6 150.2 148.6ZM196.2 104.5C197.3 104.5 198.2 103.6 198.2 102.5 198.2 101.4 197.3 100.5 196.2 100.5 195.1 100.5 194.2 101.4 194.2 102.5 194.2 103.6 195.1 104.5 196.2 104.5ZM160.8 268.5C161.9 268.5 162.8 267.6 162.8 266.5 162.8 265.4 161.9 264.5 160.8 264.5 159.7 264.5 158.8 265.4 158.8 266.5 158.8 267.6 159.7 268.5 160.8 268.5ZM188.2 291.2C191.1 291.2 193.4 288.9 193.4 286 193.4 283.1 191.1 280.8 188.2 280.8 185.4 280.8 183 283.1 183 286 183 288.9 185.4 291.2 188.2 291.2ZM198.2 281.2C200 281.2 201.5 279.7 201.5 278 201.5 276.2 200 274.7 198.2 274.7 196.5 274.7 195 276.2 195 278 195 279.7 196.5 281.2 198.2 281.2ZM198.9 288.9C200 288.9 200.9 288 200.9 286.9 200.9 285.8 200 284.9 198.9 284.9 197.8 284.9 196.9 285.8 196.9 286.9 196.9 288 197.8 288.9 198.9 288.9ZM247.8 293.3C248.9 293.3 249.8 292.4 249.8 291.3 249.8 290.2 248.9 289.3 247.8 289.3 246.7 289.3 245.8 290.2 245.8 291.3 245.8 292.4 246.7 293.3 247.8 293.3ZM129.2 196.8C130.3 196.8 131.1 195.9 131.1 194.8 131.1 193.8 130.3 192.9 129.2 192.9 128.1 192.9 127.2 193.8 127.2 194.8 127.2 195.9 128.1 196.8 129.2 196.8ZM273 118.2C275.1 118.2 276.9 116.4 276.9 114.2 276.9 112 275.1 110.2 273 110.2 270.8 110.2 269 112 269 114.2 269 116.4 270.8 118.2 273 118.2ZM248.9 132C251 132 252.6 130.3 252.6 128.2 252.6 126.2 251 124.5 248.9 124.5 246.8 124.5 245.1 126.2 245.1 128.2 245.1 130.3 246.8 132 248.9 132ZM264.3 111.5C265.4 111.5 266.3 110.6 266.3 109.5 266.3 108.4 265.4 107.5 264.3 107.5 263.2 107.5 262.4 108.4 262.4 109.5 262.4 110.6 263.2 111.5 264.3 111.5Z"/>		
		</path>
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
    table.insert(screen.ClickAreas, {mode = "all", id = "ButtonPress", param = "cargo", x1 = 961, x2 = 1152, y1 = 1015, y2 = 1075} )
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
      <text class=f30mx x=150 y=165>Coming Soon</text>
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
    output = output .. [[<text class="f30mxx" style="fill-opacity:0.2" x="960" y="1000">Damage Report v]]..VERSION..[[, by CredenceH - GitHub: LocuraDU.</text>]]
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
        <text class=f50mx x=864 y=50>SYS</text>
        <text class=f50mx x=1056 y=50>CRGO</text>]]

        --[[
        <text class=f50mx x=672 y=50>FUEL</text>
        <text class=f50mx x=864 y=50>FLGT</text>
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
system.print("----------------------------------------")
system.print("DAMAGE REPORT v" .. VERSION)
system.print("GitHub/LocuraDU")
system.print("----------------------------------------")
-- PrintConsole("DAMAGE REPORT v"..VERSION.." STARTED", true)
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
