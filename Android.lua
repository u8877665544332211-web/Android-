
--========================================================
-- ANDROID 16 VIRTUAL OS v5
-- Roblox Studio | Mobile / Tablet / PC
-- StarterPlayerScripts > LocalScript
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CLEANUP
local old = playerGui:FindFirstChild("Android16")
if old then old:Destroy() end

--========================================================
-- STATE
--========================================================

local state = {
    page = "Lock",
    dark = false,

    wifi = true,
    bluetooth = false,
    airplane = false,
    sound = true,

    brightness = 1,
    wallpaper = 1,

    quick = false,
    navigationMode = "Gesture"
}

local wallpapers = {
    Color3.fromRGB(90,110,190),
    Color3.fromRGB(170,100,160),
    Color3.fromRGB(40,130,140),
    Color3.fromRGB(30,35,55)
}

local function bg()
    return state.dark
        and Color3.fromRGB(27,28,35)
        or Color3.fromRGB(240,239,247)
end

local function fg()
    return state.dark
        and Color3.new(1,1,1)
        or Color3.fromRGB(30,30,40)
end

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "Android16"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1,1)
root.BackgroundColor3 = wallpapers[1]
root.BorderSizePixel = 0
root.Parent = gui

-- Wallpaper layer
local wallpaper = Instance.new("Frame")
wallpaper.Name = "Wallpaper"
wallpaper.Size = UDim2.fromScale(1,1)
wallpaper.BackgroundColor3 = wallpapers[1]
wallpaper.BorderSizePixel = 0
wallpaper.Parent = root

-- Application layer
local pages = Instance.new("Frame")
pages.Name = "Pages"
pages.Size = UDim2.fromScale(1,1)
pages.BackgroundTransparency = 1
pages.Parent = root

-- Persistent system layer
local system = Instance.new("Frame")
system.Name = "SystemUI"
system.Size = UDim2.fromScale(1,1)
system.BackgroundTransparency = 1
system.ZIndex = 50
system.Parent = root

--========================================================
-- HELPERS
--========================================================

local function make(class,props,parent)
    local obj = Instance.new(class)

    for k,v in pairs(props) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function round(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r or 20)
    c.Parent = obj
end

local function tween(obj,props,duration)
    TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.25,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        props
    ):Play()
end

local function clearPage()
    for _,v in ipairs(pages:GetChildren()) do
        v:Destroy()
    end
end

local function label(parent,text,size,pos,font)
    return make("TextLabel",{
        Size = size,
        Position = pos,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = fg(),
        TextSize = 17,
        Font = font or Enum.Font.Gotham,
        TextWrapped = true
    },parent)
end

local function button(parent,text,size,pos,callback)
    local b = make("TextButton",{
        Size = size,
        Position = pos,
        BackgroundColor3 = state.dark
            and Color3.fromRGB(58,60,72)
            or Color3.fromRGB(220,220,235),
        Text = text,
        TextColor3 = fg(),
        TextSize = 16,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = true
    },parent)

    round(b,18)

    if callback then
        b.Activated:Connect(callback)
    end

    return b
end

local function pageBase(title)
    clearPage()
    state.page = title

    local page = make("Frame",{
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = bg(),
        BorderSizePixel = 0
    },pages)

    local heading = label(
        page,
        title,
        UDim2.new(1,-40,0,60),
        UDim2.fromOffset(20,45),
        Enum.Font.GothamBold
    )

    heading.TextSize = 29
    heading.TextXAlignment = Enum.TextXAlignment.Left

    return page
end

local function scrollList(parent)
    local scroll = make("ScrollingFrame",{
        Size = UDim2.new(1,-30,1,-160),
        Position = UDim2.fromOffset(15,115),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    },parent)

    make("UIListLayout",{
        Padding = UDim.new(0,10),
        SortOrder = Enum.SortOrder.LayoutOrder
    },scroll)

    return scroll
end

local function settingRow(parent,title,callback)
    local b = button(
        parent,
        "   "..title.."   ›",
        UDim2.new(1,0,0,65),
        UDim2.new(),
        callback
    )

    b.TextXAlignment = Enum.TextXAlignment.Left
    return b
end

--========================================================
-- FORWARD DECLARATIONS
--========================================================

local showHome
local showLock
local showSettings
local showDrawer
local showNetwork
local showBluetooth
local showDisplay
local showSound
local showWallpaper
local showBattery
local showStorage
local showDeviceInfo
local showInfo
local showNavigation
local showRecent

local toggleQuick

--========================================================
-- NAVIGATION BAR
--========================================================

local function navigation()
    local bar = make("Frame",{
        Name = "NavigationBar",
        Size = UDim2.new(1,0,0,45),
        Position = UDim2.new(0,0,1,-45),
        BackgroundTransparency = 1,
        ZIndex = 10
    },pages)

    if state.navigationMode == "Gesture" then

        -- GESTURE BAR

        local gestureBar = make("Frame",{
            Size = UDim2.fromOffset(110,5),
            Position = UDim2.new(0.5,-55,1,-15),
            BackgroundColor3 = Color3.fromRGB(130,130,140),
            BorderSizePixel = 0
        },bar)

        round(gestureBar,10)

    else

        -- THREE BUTTON NAVIGATION

        local back = button(
            bar,
            "‹",
            UDim2.fromOffset(50,40),
            UDim2.new(0.15,0,0,0),
            function()
                if state.page ~= "Home" then
                    showHome()
                end
            end
        )

        local home = button(
            bar,
            "○",
            UDim2.fromOffset(50,40),
            UDim2.new(0.5,-25,0,0),
            showHome
        )

        local recent = button(
            bar,
            "Ⅱ",
            UDim2.fromOffset(50,40),
            UDim2.new(0.75,-25,0,0),
            showRecent
        )
    end
end

--========================================================
-- HOME
--========================================================

showHome = function()
    clearPage()
    state.page = "Home"

    wallpaper.Visible = true
    wallpaper.BackgroundColor3 = wallpapers[state.wallpaper]

    local page = make("Frame",{
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1
    },pages)

    local clock = label(
        page,
        os.date("%H:%M"),
        UDim2.new(1,0,0,100),
        UDim2.new(0,0,0.16,0)
    )

    clock.TextSize = 72
    clock.TextColor3 = Color3.new(1,1,1)
    clock.Font = Enum.Font.GothamLight

    local date = label(
        page,
        os.date("%Y년 %m월 %d일"),
        UDim2.new(1,0,0,40),
        UDim2.new(0,0,0.27,0)
    )

    date.TextColor3 = Color3.new(1,1,1)

    local apps = make("Frame",{
        Size = UDim2.new(1,-30,0,110),
        Position = UDim2.new(0,15,1,-145),
        BackgroundTransparency = 1
    },page)

    make("UIGridLayout",{
        CellSize = UDim2.fromOffset(75,100),
        CellPadding = UDim2.fromOffset(15,0),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    },apps)

    local appData = {
        {"⚙","설정",showSettings},
        {"▦","앱 목록",showDrawer},
        {"◈","배경화면",showWallpaper}
    }

    for _,app in ipairs(appData) do
        local holder = make("Frame",{
            BackgroundTransparency = 1
        },apps)

        local icon = button(
            holder,
            app[1],
            UDim2.fromOffset(65,65),
            UDim2.fromOffset(5,0),
            app[3]
        )

        icon.TextSize = 30

        local title = label(
            holder,
            app[2],
            UDim2.new(1,0,0,25),
            UDim2.fromOffset(0,70)
        )

        title.TextSize = 12
        title.TextColor3 = Color3.new(1,1,1)
    end

    navigation()
end

--========================================================
-- APP DRAWER
--========================================================

showDrawer = function()
    local page = pageBase("앱")

    local search = make("TextBox",{
        Size = UDim2.new(1,-30,0,50),
        Position = UDim2.fromOffset(15,110),
        BackgroundColor3 = state.dark
            and Color3.fromRGB(55,55,65)
            or Color3.fromRGB(220,220,235),
        PlaceholderText = "앱 검색",
        Text = "",
        TextColor3 = fg(),
        TextSize = 16,
        Font = Enum.Font.Gotham
    },page)

    round(search,25)

    local scroll = make("ScrollingFrame",{
        Size = UDim2.new(1,-30,1,-220),
        Position = UDim2.fromOffset(15,175),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    },page)

    local grid = make("UIGridLayout",{
        CellSize = UDim2.fromOffset(90,100),
        CellPadding = UDim2.fromOffset(10,10)
    },scroll)

    local appData = {
        {"⚙","설정",showSettings},
        {"◈","배경화면",showWallpaper},
        {"ℹ","기기 정보",showDeviceInfo}
    }

    local function render(query)
        for _,v in ipairs(scroll:GetChildren()) do
            if v:IsA("GuiObject") and v ~= grid then
                v:Destroy()
            end
        end

        for _,app in ipairs(appData) do
            if query == "" or string.find(app[2],query,1,true) then
                local holder = make("Frame",{
                    BackgroundTransparency = 1
                },scroll)

                local icon = button(
                    holder,
                    app[1],
                    UDim2.fromOffset(65,65),
                    UDim2.new(),
                    app[3]
                )

                icon.TextSize = 28

                local title = label(
                    holder,
                    app[2],
                    UDim2.new(1,0,0,25),
                    UDim2.fromOffset(0,68)
                )

                title.TextSize = 12
            end
        end
    end

    render("")

    search:GetPropertyChangedSignal("Text"):Connect(function()
        render(search.Text)
    end)

    navigation()
end

--========================================================
-- RECENT APPS
--========================================================

showRecent = function()
    local page = pageBase("최근 앱")

    local apps = {
        {"설정",showSettings},
        {"앱 목록",showDrawer},
        {"배경화면",showWallpaper}
    }

    for i,app in ipairs(apps) do
        local b = button(
            page,
            app[1].." 열기",
            UDim2.new(1,-40,0,65),
            UDim2.new(0,20,0,120+(i-1)*80),
            app[2]
        )
    end

    navigation()
end

--========================================================
-- SETTINGS
--========================================================

showSettings = function()
    local page = pageBase("설정")
    local scroll = scrollList(page)

    settingRow(scroll,"네트워크 및 인터넷",showNetwork)
    settingRow(scroll,"연결된 기기",showBluetooth)
    settingRow(scroll,"디스플레이",showDisplay)
    settingRow(scroll,"소리 및 진동",showSound)
    settingRow(scroll,"배경화면",showWallpaper)
    settingRow(scroll,"시스템 내비게이션",showNavigation)
    settingRow(scroll,"배터리",showBattery)
    settingRow(scroll,"저장공간",showStorage)
    settingRow(scroll,"기기 정보",showDeviceInfo)

    navigation()
end

--========================================================
-- NETWORK
--========================================================

showNetwork = function()
    local page = pageBase("네트워크 및 인터넷")
    local scroll = scrollList(page)

    settingRow(scroll,
        "비행기 모드 : "..(state.airplane and "켜짐" or "꺼짐"),
        function()
            state.airplane = not state.airplane
            state.wifi = not state.airplane
            showNetwork()
        end
    )

    settingRow(scroll,
        "Wi-Fi : "..(state.wifi and "켜짐" or "꺼짐"),
        function()
            if not state.airplane then
                state.wifi = not state.wifi
            end
            showNetwork()
        end
    )

    settingRow(scroll,"인터넷 정보",function()
        showInfo("네트워크","Roblox 내부 가상 네트워크 설정입니다.")
    end)

    navigation()
end

--========================================================
-- BLUETOOTH
--========================================================

showBluetooth = function()
    local page = pageBase("연결된 기기")
    local scroll = scrollList(page)

    settingRow(scroll,
        "블루투스 : "..(state.bluetooth and "켜짐" or "꺼짐"),
        function()
            state.bluetooth = not state.bluetooth
            showBluetooth()
        end
    )

    settingRow(scroll,"새 기기 연결",function()
        showInfo("기기 연결","가상 블루투스 기기 검색 기능입니다.")
    end)

    navigation()
end

--========================================================
-- DISPLAY
--========================================================

showDisplay = function()
    local page = pageBase("디스플레이")

    button(
        page,
        "다크 모드 : "..(state.dark and "켜짐" or "꺼짐"),
        UDim2.new(1,-30,0,60),
        UDim2.fromOffset(15,120),
        function()
            state.dark = not state.dark
            showDisplay()
        end
    )

    local brightness = label(
        page,
        "밝기 "..math.floor(state.brightness*100).."%",
        UDim2.new(1,-30,0,35),
        UDim2.fromOffset(15,205)
    )

    brightness.TextXAlignment = Enum.TextXAlignment.Left

    local slider = make("Frame",{
        Size = UDim2.new(1,-50,0,8),
        Position = UDim2.fromOffset(25,260),
        BackgroundColor3 = Color3.fromRGB(150,150,160)
    },page)

    round(slider,10)

    local fill = make("Frame",{
        Size = UDim2.new(state.brightness,0,1,0),
        BackgroundColor3 = Color3.fromRGB(150,130,240)
    },slider)

    round(fill,10)

    local drag = make("TextButton",{
        Size = UDim2.new(1,0,0,40),
        Position = UDim2.new(0,0,0,-16),
        BackgroundTransparency = 1,
        Text = ""
    },slider)

    local function setBrightness(value)
        state.brightness = math.clamp(value,0,1)
        fill.Size = UDim2.new(state.brightness,0,1,0)
        brightness.Text = "밝기 "..math.floor(state.brightness*100).."%"
        Lighting.Brightness = state.brightness*2
    end

    drag.Activated:Connect(function()
        setBrightness(state.brightness >= 1 and 0.5 or 1)
    end)

    navigation()
end

--========================================================
-- SOUND
--========================================================

showSound = function()
    local page = pageBase("소리 및 진동")
    local scroll = scrollList(page)

    settingRow(scroll,
        "소리 : "..(state.sound and "켜짐" or "꺼짐"),
        function()
            state.sound = not state.sound
            showSound()
        end
    )

    settingRow(scroll,"진동",function()
        showInfo("진동","실제 기기의 진동 설정은 변경할 수 없습니다.")
    end)

    navigation()
end

--========================================================
-- WALLPAPER
--========================================================

showWallpaper = function()
    local page = pageBase("배경화면")

    for i,color in ipairs(wallpapers) do
        local b = make("TextButton",{
            Size = UDim2.new(0.42,0,0,110),
            Position = UDim2.new(
                i%2 == 0 and 0.53 or 0.05,
                0,
                math.floor((i-1)/2)*0.24+0.2,
                0
            ),
            BackgroundColor3 = color,
            Text = i == state.wallpaper and "선택됨" or "적용",
            TextColor3 = Color3.new(1,1,1),
            TextSize = 16
        },page)

        round(b,20)

        b.Activated:Connect(function()
            state.wallpaper = i
            wallpaper.BackgroundColor3 = color
            showWallpaper()
        end)
    end

    navigation()
end

--========================================================
-- BATTERY
--========================================================

showBattery = function()
    local page = pageBase("배터리")

    label(page,"배터리 상태",
        UDim2.new(1,-30,0,50),
        UDim2.fromOffset(15,130),
        Enum.Font.GothamBold)

    label(page,
        "실제 기기 배터리 정보는 Roblox에서 접근할 수 없습니다.",
        UDim2.new(1,-40,0,100),
        UDim2.fromOffset(20,190)
    )

    navigation()
end

--========================================================
-- STORAGE
--========================================================

showStorage = function()
    local page = pageBase("저장공간")

    label(page,"가상 OS 저장공간",
        UDim2.new(1,-30,0,50),
        UDim2.fromOffset(15,130),
        Enum.Font.GothamBold)

    label(page,
        "실제 휴대폰 저장공간이 아닌 Roblox 내부 화면입니다.",
        UDim2.new(1,-40,0,100),
        UDim2.fromOffset(20,190)
    )

    navigation()
end

--========================================================
-- DEVICE INFO
--========================================================

showDeviceInfo = function()
    local page = pageBase("기기 정보")

    label(page,"Android 16",
        UDim2.new(1,-30,0,65),
        UDim2.fromOffset(15,130),
        Enum.Font.GothamBold)

    label(page,
        "Roblox Virtual Device\n\n모델 : Pixel Virtual\n버전 : Android 16\n시스템 : Roblox Luau",
        UDim2.new(1,-40,0,180),
        UDim2.fromOffset(20,200)
    )

    navigation()
end

--========================================================
-- NAVIGATION SETTINGS
--========================================================

showNavigation = function()
    local page = pageBase("시스템 내비게이션")

    local info = label(
        page,
        "원하는 내비게이션 방식을 선택하세요.",
        UDim2.new(1,-40,0,50),
        UDim2.fromOffset(20,115)
    )

    info.TextXAlignment = Enum.TextXAlignment.Left

    local gesture = button(
        page,
        "제스처 내비게이션",
        UDim2.new(1,-30,0,65),
        UDim2.fromOffset(15,180),
        function()
            state.navigationMode = "Gesture"
            showNavigation()
        end
    )

    local buttons = button(
        page,
        "3버튼 내비게이션",
        UDim2.new(1,-30,0,65),
        UDim2.fromOffset(15,260),
        function()
            state.navigationMode = "Buttons"
            showNavigation()
        end
    )

    if state.navigationMode == "Gesture" then
        gesture.Text = "✓ 제스처 내비게이션"
    else
        buttons.Text = "✓ 3버튼 내비게이션"
    end

    navigation()
end

--========================================================
-- INFO
--========================================================

showInfo = function(title,message)
    local page = pageBase(title)

    label(page,message,
        UDim2.new(1,-40,0,120),
        UDim2.fromOffset(20,140)
    )

    navigation()
end

--========================================================
-- LOCK SCREEN
--========================================================

showLock = function()
    clearPage()
    state.page = "Lock"

    wallpaper.Visible = true
    wallpaper.BackgroundColor3 = wallpapers[state.wallpaper]

    local page = make("Frame",{
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1
    },pages)

    local clock = label(
        page,
        os.date("%H:%M"),
        UDim2.new(1,0,0,110),
        UDim2.new(0,0,0.24,0)
    )

    clock.TextSize = 76
    clock.TextColor3 = Color3.new(1,1,1)
    clock.Font = Enum.Font.GothamLight

    local date = label(
        page,
        os.date("%Y년 %m월 %d일"),
        UDim2.new(1,0,0,45),
        UDim2.new(0,0,0.35,0)
    )

    date.TextColor3 = Color3.new(1,1,1)

    button(
        page,
        "잠금 해제",
        UDim2.new(0.8,0,0,60),
        UDim2.new(0.1,0,0.82,0),
        showHome
    )
end

--========================================================
-- QUICK SETTINGS
--========================================================

local quick = make("Frame",{
    Name = "QuickPanel",
    Size = UDim2.new(1,0,0,290),
    Position = UDim2.new(0,0,0,-310),
    BackgroundColor3 = Color3.fromRGB(225,225,240),
    BorderSizePixel = 0,
    ZIndex = 60
},system)

round(quick,25)

make("TextLabel",{
    Size = UDim2.new(1,-30,0,45),
    Position = UDim2.fromOffset(15,10),
    BackgroundTransparency = 1,
    Text = "빠른 설정",
    TextColor3 = Color3.fromRGB(30,30,40),
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 61
},quick)

local function qbutton(text,x,y,callback)
    return button(
        quick,
        text,
        UDim2.new(0.46,0,0,65),
        UDim2.new(x,0,0,y),
        callback
    )
end

qbutton("Wi-Fi",0.03,65,function()
    if not state.airplane then
        state.wifi = not state.wifi
    end
end)

qbutton("Bluetooth",0.51,65,function()
    state.bluetooth = not state.bluetooth
end)

qbutton("다크 모드",0.03,140,function()
    state.dark = not state.dark
    quick.BackgroundColor3 = bg()
end)

qbutton("비행기 모드",0.51,140,function()
    state.airplane = not state.airplane
    state.wifi = not state.airplane
end)

qbutton("설정",0.03,215,function()
    state.quick = false

    tween(quick,{
        Position = UDim2.new(0,0,0,-310)
    })

    showSettings()
end)

--========================================================
-- QUICK SETTINGS HANDLE
--========================================================

local handle = make("TextButton",{
    Name = "QuickHandle",
    Size = UDim2.new(0,100,0,25),
    Position = UDim2.new(0.5,-50,0,0),
    BackgroundColor3 = Color3.new(1,1,1),
    BackgroundTransparency = 0.4,
    Text = "",
    ZIndex = 70
},system)

round(handle,20)

toggleQuick = function()
    state.quick = not state.quick

    tween(quick,{
        Position = state.quick
            and UDim2.new(0,0,0,10)
            or UDim2.new(0,0,0,-310)
    })
end

handle.Activated:Connect(toggleQuick)

--========================================================
-- TOUCH GESTURES
--========================================================

local touchStart = nil
local touchStartTime = 0

UIS.InputBegan:Connect(function(input,processed)

    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
        touchStartTime = os.clock()
    end

    if processed then return end

    if input.KeyCode == Enum.KeyCode.Escape then

        if state.quick then
            toggleQuick()

        elseif state.page ~= "Home" then
            showHome()

        else
            showDrawer()
        end
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType ~= Enum.UserInputType.Touch
        or not touchStart then
        return
    end

    local startPos = touchStart
    local endPos = input.Position

    local deltaY = endPos.Y - startPos.Y
    local deltaX = math.abs(endPos.X-startPos.X)

    local camera = workspace.CurrentCamera

    if not camera then
        touchStart = nil
        return
    end

    local screenHeight = camera.ViewportSize.Y
    local duration = os.clock()-touchStartTime

    -- Ignore mostly horizontal gestures
    if deltaX > math.abs(deltaY)*0.8 then
        touchStart = nil
        return
    end

    -- QUICK SETTINGS: TOP TO BOTTOM

    if startPos.Y < 100 and deltaY > 70 then

        if not state.quick then
            state.quick = true

            tween(quick,{
                Position = UDim2.new(0,0,0,10)
            })
        end

    -- CLOSE QUICK SETTINGS

    elseif state.quick and deltaY < -70 then

        state.quick = false

        tween(quick,{
            Position = UDim2.new(0,0,0,-310)
        })

    -- GESTURE NAVIGATION

    elseif state.navigationMode == "Gesture"
        and startPos.Y > screenHeight-100
        and deltaY < -70
        and state.page ~= "Lock" then

        if duration > 0.8 then
            showRecent()
        else
            showHome()
        end
    end

    touchStart = nil
end)

--========================================================
-- START
--========================================================

Lighting.Brightness = 2

wallpaper.BackgroundColor3 = wallpapers[state.wallpaper]

showLock()

-- CLOCK UPDATE

task.spawn(function()
    while gui.Parent do
        task.wait(1)

        for _,obj in ipairs(pages:GetDescendants()) do
            if obj:IsA("TextLabel") then
                if obj.Text:match("^%d%d:%d%d$") then
                    obj.Text = os.date("%H:%M")
                end
            end
        end
    end
end)

print("Android 16 Virtual OS v5 Loaded")
