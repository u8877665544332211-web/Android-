
--==================================================
-- ANDROID 16 VIRTUAL OS v3
-- Roblox Studio / LocalScript
-- StarterPlayer > StarterPlayerScripts
-- Mobile / Tablet / PC
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("Android16")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "Android16"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local state = {
    page = "Lock",
    dark = false,
    wifi = true,
    bluetooth = false,
    airplane = false,
    sound = true,
    brightness = 1,
    wallpaper = 1,
    quick = false
}

local wallpapers = {
    Color3.fromRGB(90,110,190),
    Color3.fromRGB(170,100,160),
    Color3.fromRGB(40,130,140),
    Color3.fromRGB(30,35,55)
}

local function tween(obj,props,time)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.25,Enum.EasingStyle.Quint),
        props
    ):Play()
end

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

local function bg()
    return state.dark
        and Color3.fromRGB(25,27,34)
        or Color3.fromRGB(240,239,247)
end

local function fg()
    return state.dark
        and Color3.new(1,1,1)
        or Color3.fromRGB(30,30,40)
end

local root = make("Frame",{
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = wallpapers[1],
    BorderSizePixel = 0
},gui)

local function clear()
    for _,v in ipairs(root:GetChildren()) do
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

local function basePage(name)
    clear()
    state.page = name

    root.BackgroundColor3 = bg()

    local title = label(
        root,
        name,
        UDim2.new(1,-40,0,55),
        UDim2.fromOffset(20,45),
        Enum.Font.GothamBold
    )

    title.TextSize = 29
    title.TextXAlignment = Enum.TextXAlignment.Left

    return root
end

local function nav()
    local bar = make("Frame",{
        Size = UDim2.new(1,0,0,55),
        Position = UDim2.new(0,0,1,-55),
        BackgroundTransparency = 1
    },root)

    local home = make("TextButton",{
        Size = UDim2.new(0,100,0,35),
        Position = UDim2.new(0.5,-50,0,5),
        BackgroundColor3 = fg(),
        BackgroundTransparency = 0.2,
        Text = ""
    },bar)

    round(home,30)

    home.Activated:Connect(function()
        showHome()
    end)
end

local function makeScroll()
    local scroll = make("ScrollingFrame",{
        Size = UDim2.new(1,-30,1,-150),
        Position = UDim2.fromOffset(15,115),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0,0,0,0)
    },root)

    make("UIListLayout",{
        Padding = UDim.new(0,10),
        SortOrder = Enum.SortOrder.LayoutOrder
    },scroll)

    return scroll
end

local function settingRow(parent,title,callback)
    local b = button(
        parent,
        title.."   ›",
        UDim2.new(1,0,0,65),
        UDim2.new(),
        callback
    )

    b.TextXAlignment = Enum.TextXAlignment.Left
    return b
end

-- FORWARD DECLARATIONS

local showHome
local showDrawer
local showSettings
local showNetwork
local showBluetooth
local showDisplay
local showSound
local showWallpaper
local showBattery
local showStorage
local showDeviceInfo
local showLock
local showInfo

--==================================================
-- HOME
--==================================================

showHome = function()
    state.page = "Home"
    clear()

    root.BackgroundColor3 = wallpapers[state.wallpaper]

    local clock = label(
        root,
        os.date("%H:%M"),
        UDim2.new(1,0,0,100),
        UDim2.new(0,0,0.16,0)
    )

    clock.TextSize = 72
    clock.TextColor3 = Color3.new(1,1,1)
    clock.Font = Enum.Font.GothamLight

    local date = label(
        root,
        os.date("%Y년 %m월 %d일"),
        UDim2.new(1,0,0,40),
        UDim2.new(0,0,0.27,0)
    )

    date.TextColor3 = Color3.new(1,1,1)

    -- APP ICON CONTAINER

    local apps = make("Frame",{
        Size = UDim2.new(1,-30,0,110),
        Position = UDim2.new(0,15,1,-145),
        BackgroundTransparency = 1
    },root)

    make("UIGridLayout",{
        CellSize = UDim2.fromOffset(75,100),
        CellPadding = UDim2.fromOffset(15,0),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    },apps)

    local appList = {
        {"⚙","설정",showSettings},
        {"▦","앱 목록",showDrawer},
        {"◈","배경화면",showWallpaper}
    }

    for _,app in ipairs(appList) do
        local holder = make("Frame",{
            Size = UDim2.fromOffset(75,100),
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

    nav()
end

--==================================================
-- APP DRAWER
--==================================================

showDrawer = function()
    basePage("앱")

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
    },root)

    round(search,25)

    local scroll = make("ScrollingFrame",{
        Size = UDim2.new(1,-30,1,-220),
        Position = UDim2.fromOffset(15,175),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    },root)

    local grid = make("UIGridLayout",{
        CellSize = UDim2.new(0,90,0,100),
        CellPadding = UDim2.fromOffset(10,10)
    },scroll)

    local appData = {
        {"⚙","설정",showSettings},
        {"◈","배경화면",showWallpaper},
        {"ℹ","기기 정보",showDeviceInfo}
    }

    local function renderApps(query)
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

    renderApps("")

    search:GetPropertyChangedSignal("Text"):Connect(function()
        renderApps(search.Text)
    end)

    nav()
end

--==================================================
-- SETTINGS
--==================================================

showSettings = function()
    basePage("설정")

    local scroll = makeScroll()

    settingRow(scroll,"네트워크 및 인터넷",showNetwork)
    settingRow(scroll,"연결된 기기",showBluetooth)
    settingRow(scroll,"디스플레이",showDisplay)
    settingRow(scroll,"소리 및 진동",showSound)
    settingRow(scroll,"배경화면",showWallpaper)
    settingRow(scroll,"배터리",showBattery)
    settingRow(scroll,"저장공간",showStorage)
    settingRow(scroll,"기기 정보",showDeviceInfo)

    nav()
end

showNetwork = function()
    basePage("네트워크 및 인터넷")
    local scroll = makeScroll()

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

    settingRow(scroll,"인터넷 연결 정보",function()
        showInfo("네트워크","Roblox 내부 가상 네트워크 설정입니다.")
    end)

    nav()
end

showBluetooth = function()
    basePage("연결된 기기")
    local scroll = makeScroll()

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

    nav()
end

showDisplay = function()
    basePage("디스플레이")

    button(
        root,
        "다크 모드 : "..(state.dark and "켜짐" or "꺼짐"),
        UDim2.new(1,-30,0,60),
        UDim2.fromOffset(15,120),
        function()
            state.dark = not state.dark
            showDisplay()
        end
    )

    local brightness = label(
        root,
        "밝기 "..math.floor(state.brightness*100).."%",
        UDim2.new(1,-30,0,35),
        UDim2.fromOffset(15,205)
    )

    brightness.TextXAlignment = Enum.TextXAlignment.Left

    local slider = make("Frame",{
        Size = UDim2.new(1,-50,0,8),
        Position = UDim2.fromOffset(25,260),
        BackgroundColor3 = Color3.fromRGB(150,150,160)
    },root)

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

    local function setBrightness(x)
        state.brightness = math.clamp(x,0,1)
        fill.Size = UDim2.new(state.brightness,0,1,0)
        brightness.Text = "밝기 "..math.floor(state.brightness*100).."%"
        Lighting.Brightness = state.brightness*2
    end

    drag.Activated:Connect(function()
        setBrightness(state.brightness >= 1 and 0.5 or 1)
    end)

    nav()
end

showSound = function()
    basePage("소리 및 진동")
    local scroll = makeScroll()

    settingRow(scroll,
        "소리 : "..(state.sound and "켜짐" or "꺼짐"),
        function()
            state.sound = not state.sound
            showSound()
        end
    )

    settingRow(scroll,"진동",function()
        showInfo("진동","실제 기기 진동 설정은 변경할 수 없습니다.")
    end)

    nav()
end

showWallpaper = function()
    basePage("배경화면")

    for i,color in ipairs(wallpapers) do
        local b = make("TextButton",{
            Size = UDim2.new(0.42,0,0,110),
            Position = UDim2.new(
                i%2==0 and 0.53 or 0.05,0,
                math.floor((i-1)/2)*0.24+0.2,0
            ),
            BackgroundColor3 = color,
            Text = i == state.wallpaper and "선택됨" or "적용",
            TextColor3 = Color3.new(1,1,1),
            TextSize = 16
        },root)

        round(b,20)

        b.Activated:Connect(function()
            state.wallpaper = i
            showWallpaper()
        end)
    end

    nav()
end

showBattery = function()
    basePage("배터리")

    label(root,"배터리 상태",UDim2.new(1,-30,0,50),
        UDim2.fromOffset(15,130),Enum.Font.GothamBold)

    label(root,
        "실제 기기 배터리 정보는 Roblox에서 접근할 수 없습니다.",
        UDim2.new(1,-40,0,100),
        UDim2.fromOffset(20,190)
    )

    nav()
end

showStorage = function()
    basePage("저장공간")

    label(root,"가상 OS 저장공간",
        UDim2.new(1,-30,0,50),
        UDim2.fromOffset(15,130),
        Enum.Font.GothamBold)

    label(root,
        "실제 휴대폰 저장공간이 아닌 Roblox 내부 화면입니다.",
        UDim2.new(1,-40,0,100),
        UDim2.fromOffset(20,190)
    )

    nav()
end

showDeviceInfo = function()
    basePage("기기 정보")

    label(root,"Android 16",
        UDim2.new(1,-30,0,65),
        UDim2.fromOffset(15,130),
        Enum.Font.GothamBold)

    label(root,
        "Roblox Virtual Device\n\n모델 : Pixel Virtual\n버전 : Android 16\n시스템 : Roblox Luau",
        UDim2.new(1,-40,0,180),
        UDim2.fromOffset(20,200)
    )

    nav()
end

showInfo = function(title,message)
    basePage(title)

    label(root,message,
        UDim2.new(1,-40,0,120),
        UDim2.fromOffset(20,140)
    )

    nav()
end

--==================================================
-- LOCK SCREEN
--==================================================

showLock = function()
    clear()
    state.page = "Lock"

    root.BackgroundColor3 = wallpapers[state.wallpaper]

    local time = label(root,os.date("%H:%M"),
        UDim2.new(1,0,0,110),
        UDim2.new(0,0,0.24,0))

    time.TextSize = 76
    time.TextColor3 = Color3.new(1,1,1)
    time.Font = Enum.Font.GothamLight

    local date = label(root,os.date("%Y년 %m월 %d일"),
        UDim2.new(1,0,0,45),
        UDim2.new(0,0,0.35,0))

    date.TextColor3 = Color3.new(1,1,1)

    local unlock = button(root,
        "위로 밀어 잠금 해제",
        UDim2.new(0.8,0,0,60),
        UDim2.new(0.1,0,0.82,0),
        showHome
    )

    unlock.BackgroundColor3 = Color3.fromRGB(240,240,255)
    unlock.TextColor3 = Color3.fromRGB(30,30,50)
end

--==================================================
-- QUICK SETTINGS
--==================================================

local quick = make("Frame",{
    Size = UDim2.new(1,0,0,290),
    Position = UDim2.new(0,0,0,-310),
    BackgroundColor3 = Color3.fromRGB(225,225,240),
    BorderSizePixel = 0,
    ZIndex = 20
},root)

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
    ZIndex = 21
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
    state.wifi = not state.wifi
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
    tween(quick,{Position=UDim2.new(0,0,0,-310)})
    state.quick = false
    showSettings()
end)

local handle = make("TextButton",{
    Size = UDim2.new(0,100,0,25),
    Position = UDim2.new(0.5,-50,0,0),
    BackgroundColor3 = Color3.new(1,1,1),
    BackgroundTransparency = 0.4,
    Text = "",
    ZIndex = 30
},root)

round(handle,20)

local function toggleQuick()
    state.quick = not state.quick

    tween(quick,{
        Position = state.quick
            and UDim2.new(0,0,0,10)
            or UDim2.new(0,0,0,-310)
    })
end

handle.Activated:Connect(toggleQuick)

--==================================================
-- TOUCH GESTURES
--==================================================

local touchStart

UIS.InputBegan:Connect(function(input,processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
    end

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
    if input.UserInputType == Enum.UserInputType.Touch and touchStart then
        local delta = input.Position.Y-touchStart.Y

        if delta > 70 then
            state.quick = true
            tween(quick,{Position=UDim2.new(0,0,0,10)})
        elseif delta < -70 and state.quick then
            state.quick = false
            tween(quick,{Position=UDim2.new(0,0,0,-310)})
        end

        touchStart = nil
    end
end)

--==================================================
-- START
--==================================================

Lighting.Brightness = 2
showHome()

-- Clock update

task.spawn(function()
    while gui.Parent do
        task.wait(1)

        for _,v in ipairs(root:GetChildren()) do
            if v:IsA("TextLabel") then
                if v.Text:match("^%d%d:%d%d$") then
                    v.Text = os.date("%H:%M")
                end
            end
        end
    end
end)

print("Android 16 Virtual OS v3 Loaded")
