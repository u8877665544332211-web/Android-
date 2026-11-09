
--[[
    ANDROID 16 VIRTUAL OS
    Roblox Studio
    LocalScript > StarterPlayerScripts
    Mobile / Tablet / PC
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local old = guiParent:FindFirstChild("Android16")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "Android16"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = guiParent

local state = {
    unlocked = false,
    page = "Lock",
    dark = false,
    wifi = true,
    bluetooth = false,
    airplane = false,
    sound = true,
    brightness = 1,
    wallpaper = 1,
    drawer = false,
    quick = false
}

local wallpapers = {
    Color3.fromRGB(90,110,190),
    Color3.fromRGB(170,100,160),
    Color3.fromRGB(40,130,140),
    Color3.fromRGB(30,35,55)
}

local function tween(obj,props,time)
    TweenService:Create(obj,
        TweenInfo.new(time or 0.25,Enum.EasingStyle.Quint),
        props
    ):Play()
end

local function make(class,props,parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r or 20)
    c.Parent = obj
end

local function bg()
    return state.dark and Color3.fromRGB(25,27,34)
        or Color3.fromRGB(240,239,247)
end

local function fg()
    return state.dark and Color3.new(1,1,1)
        or Color3.fromRGB(30,30,40)
end

local root = make("Frame",{
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = wallpapers[1],
    BorderSizePixel = 0
},gui)

local gradient = make("UIGradient",{
    Rotation = 45,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(120,130,230)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(30,35,90))
    })
},root)

local function clear()
    for _,v in ipairs(root:GetChildren()) do
        if not v:IsA("UIGradient") then
            v:Destroy()
        end
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
    b.Activated:Connect(callback)
    return b
end

local function basePage(name)
    clear()
    state.page = name

    root.BackgroundColor3 = bg()

    local title = label(root,name,UDim2.new(1,-40,0,55),
        UDim2.fromOffset(20,45),Enum.Font.GothamBold)
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
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.2,
        Text = "",
        AutoButtonColor = false
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
    local b = button(parent,title.."   ›",
        UDim2.new(1,0,0,65),UDim2.new(),callback)
    b.TextXAlignment = Enum.TextXAlignment.Left
    return b
end

-- HOME

function showHome()
    state.page = "Home"
    state.drawer = false
    clear()

    root.BackgroundColor3 = wallpapers[state.wallpaper]

    local clock = label(root,os.date("%H:%M"),
        UDim2.new(1,0,0,100),UDim2.new(0,0,0.16,0))
    clock.TextSize = 72
    clock.TextColor3 = Color3.new(1,1,1)
    clock.Font = Enum.Font.GothamLight

    local date = label(root,os.date("%Y년 %m월 %d일"),
        UDim2.new(1,0,0,40),UDim2.new(0,0,0.27,0))
    date.TextColor3 = Color3.new(1,1,1)

    local apps = make("Frame",{
        Size = UDim2.new(1,-30,0,120),
        Position = UDim2.new(0,15,1,-155),
        BackgroundTransparency = 1
    },root)

    make("UIGridLayout",{
        CellSize = UDim2.new(0,65,0,90),
        CellPadding = UDim2.new(0,12,0,0),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    },apps)

    local list = {
        {"⚙","설정",showSettings},
        {"▦","앱 목록",showDrawer},
        {"◈","배경화면",function()
            state.wallpaper = state.wallpaper % #wallpapers + 1
            showHome()
        end}
    }

    for _,v in ipairs(list) do
        local holder = make("Frame",{
            BackgroundTransparency = 1
        },apps)

        local b = button(holder,v[1],
            UDim2.fromOffset(60,60),UDim2.new(),v[3])
        b.TextSize = 27

        local t = label(holder,v[2],
            UDim2.new(1,0,0,25),UDim2.fromOffset(0,62))
        t.TextSize = 12
        t.TextColor3 = Color3.new(1,1,1)
    end

    nav()
end

-- APP DRAWER

function showDrawer()
    basePage("앱")
    state.drawer = true

    local search = make("TextBox",{
        Size = UDim2.new(1,-30,0,50),
        Position = UDim2.fromOffset(15,110),
        BackgroundColor3 = state.dark
            and Color3.fromRGB(55,55,65)
            or Color3.fromRGB(220,220,235),
        PlaceholderText = "앱 검색",
        Text = "",
        TextColor3 = fg(),
        PlaceholderColor3 = Color3.fromRGB(130,130,140),
        TextSize = 16
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
        {"◈","배경화면",function()
            state.wallpaper = state.wallpaper % #wallpapers + 1
            showHome()
        end},
        {"ℹ","기기 정보",function()
            showDeviceInfo()
        end}
    }

    local function renderApps(query)
        for _,v in ipairs(scroll:GetChildren()) do
            if v:IsA("GuiObject") and v ~= grid then v:Destroy() end
        end

        for _,app in ipairs(appData) do
            if query == "" or string.find(app[2],query,1,true) then
                local holder = make("Frame",{
                    BackgroundTransparency = 1
                },scroll)

                local b = button(holder,app[1],
                    UDim2.fromOffset(65,65),UDim2.new(),app[3])
                b.TextSize = 28

                local t = label(holder,app[2],
                    UDim2.new(1,0,0,25),UDim2.fromOffset(0,68))
                t.TextSize = 12
            end
        end
    end

    renderApps("")
    search:GetPropertyChangedSignal("Text"):Connect(function()
        renderApps(search.Text)
    end)

    nav()
end

-- SETTINGS

function showSettings()
    basePage("설정")

    local scroll = makeScroll()

    settingRow(scroll,"네트워크 및 인터넷",function()
        showNetwork()
    end)

    settingRow(scroll,"연결된 기기",function()
        showBluetooth()
    end)

    settingRow(scroll,"디스플레이",function()
        showDisplay()
    end)

    settingRow(scroll,"소리 및 진동",function()
        showSound()
    end)

    settingRow(scroll,"배경화면",function()
        showWallpaper()
    end)

    settingRow(scroll,"배터리",function()
        showBattery()
    end)

    settingRow(scroll,"저장공간",function()
        showStorage()
    end)

    settingRow(scroll,"기기 정보",function()
        showDeviceInfo()
    end)

    nav()
end

function showNetwork()
    basePage("네트워크 및 인터넷")
    local scroll = makeScroll()

    settingRow(scroll,"비행기 모드 : "..(state.airplane and "켜짐" or "꺼짐"),function()
        state.airplane = not state.airplane
        state.wifi = not state.airplane
        showNetwork()
    end)

    settingRow(scroll,"Wi-Fi : "..(state.wifi and "켜짐" or "꺼짐"),function()
        if not state.airplane then state.wifi = not state.wifi end
        showNetwork()
    end)

    settingRow(scroll,"인터넷 연결 정보",function()
        showInfo("네트워크","Roblox 내부 가상 네트워크 설정입니다.")
    end)

    nav()
end

function showBluetooth()
    basePage("연결된 기기")
    local scroll = makeScroll()

    settingRow(scroll,"블루투스 : "..(state.bluetooth and "켜짐" or "꺼짐"),function()
        state.bluetooth = not state.bluetooth
        showBluetooth()
    end)

    settingRow(scroll,"새 기기 연결",function()
        showInfo("기기 연결","가상 블루투스 기기 검색 기능입니다.")
    end)

    nav()
end

function showDisplay()
    basePage("디스플레이")

    local dark = button(root,
        "다크 모드 : "..(state.dark and "켜짐" or "꺼짐"),
        UDim2.new(1,-30,0,60),UDim2.fromOffset(15,120),function()
            state.dark = not state.dark
            showDisplay()
        end)

    local brightness = make("TextLabel",{
        Size = UDim2.new(1,-30,0,35),
        Position = UDim2.fromOffset(15,205),
        BackgroundTransparency = 1,
        Text = "밝기 "..math.floor(state.brightness*100).."%",
        TextColor3 = fg(),
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left
    },root)

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
        Size = UDim2.new(1,0,0,35),
        Position = UDim2.new(0,0,0,-13),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    },slider)

    local function setBrightness(x)
        local value = math.clamp(x,0,1)
        state.brightness = value
        fill.Size = UDim2.new(value,0,1,0)
        brightness.Text = "밝기 "..math.floor(value*100).."%"
        Lighting.Brightness = value*2
    end

    drag.Activated:Connect(function()
        setBrightness(1-state.brightness)
    end)

    nav()
end

function showSound()
    basePage("소리 및 진동")
    local scroll = makeScroll()

    settingRow(scroll,"소리 : "..(state.sound and "켜짐" or "꺼짐"),function()
        state.sound = not state.sound
        showSound()
    end)

    settingRow(scroll,"진동",function()
        showInfo("진동","Roblox에서는 실제 기기 진동 설정을 변경할 수 없습니다.")
    end)

    nav()
end

function showWallpaper()
    basePage("배경화면")

    for i,color in ipairs(wallpapers) do
        local b = make("TextButton",{
            Size = UDim2.new(0.42,0,0,110),
            Position = UDim2.new(i%2==0 and 0.53 or 0.05,0,
                math.floor((i-1)/2)*0.24+0.2,0),
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

function showBattery()
    basePage("배터리")

    label(root,"배터리 상태",UDim2.new(1,-30,0,50),
        UDim2.fromOffset(15,130),Enum.Font.GothamBold)

    label(root,"실제 기기 배터리 정보는 Roblox에서 접근할 수 없습니다.",
        UDim2.new(1,-40,0,100),UDim2.fromOffset(20,190))

    nav()
end

function showStorage()
    basePage("저장공간")

    label(root,"가상 OS 저장공간",UDim2.new(1,-30,0,50),
        UDim2.fromOffset(15,130),Enum.Font.GothamBold)

    label(root,"실제 휴대폰 저장공간이 아닌 Roblox 내부 화면입니다.",
        UDim2.new(1,-40,0,100),UDim2.fromOffset(20,190))

    nav()
end

function showDeviceInfo()
    basePage("기기 정보")

    label(root,"Android 16",UDim2.new(1,-30,0,65),
        UDim2.fromOffset(15,130),Enum.Font.GothamBold)

    label(root,"Roblox Virtual Device\n\n모델 : Pixel Virtual\n버전 : Android 16\n시스템 : Roblox Luau",
        UDim2.new(1,-40,0,180),UDim2.fromOffset(20,200))

    nav()
end

function showInfo(title,message)
    basePage(title)
    label(root,message,UDim2.new(1,-40,0,120),
        UDim2.fromOffset(20,140))
    nav()
end

-- LOCK SCREEN

function showLock()
    clear()
    state.page = "Lock"
    root.BackgroundColor3 = wallpapers[state.wallpaper]

    local time = label(root,os.date("%H:%M"),
        UDim2.new(1,0,0,110),UDim2.new(0,0,0.24,0))
    time.TextSize = 76
    time.TextColor3 = Color3.new(1,1,1)
    time.Font = Enum.Font.GothamLight

    local d = label(root,os.date("%Y년 %m월 %d일"),
        UDim2.new(1,0,0,45),UDim2.new(0,0,0.35,0))
    d.TextColor3 = Color3.new(1,1,1)

    local unlock = button(root,"위로 밀어 잠금 해제",
        UDim2.new(0.8,0,0,60),UDim2.new(0.1,0,0.82,0),function()
            state.unlocked = true
            showHome()
        end)

    unlock.BackgroundColor3 = Color3.fromRGB(240,240,255)
    unlock.TextColor3 = Color3.fromRGB(30,30,50)
end

-- QUICK SETTINGS

local quick = make("Frame",{
    Size = UDim2.new(1,0,0,290),
    Position = UDim2.new(0,0,0,-310),
    BackgroundColor3 = Color3.fromRGB(225,225,240),
    BorderSizePixel = 0,
    ZIndex = 20
},root)
round(quick,25)

local quickTitle = make("TextLabel",{
    Size = UDim2.new(1,-30,0,45),
    Position = UDim2.fromOffset(15,10),
    BackgroundTransparency = 1,
    Text = "빠른 설정",
    TextColor3 = Color3.fromRGB(30,30,40),
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
},quick)

local function qbutton(text,x,y,callback)
    return button(quick,text,UDim2.new(0.46,0,0,65),
        UDim2.new(x,0,0,y),callback)
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

-- GESTURES

local touchStart

UIS.InputBegan:Connect(function(input,processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
    end

    if input.KeyCode == Enum.KeyCode.Escape then
        if state.quick then
            toggleQuick()
        elseif state.page == "Settings" then
            showHome()
        elseif state.page == "Home" then
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

-- START

Lighting.Brightness = 2
showLock()

task.spawn(function()
    while gui.Parent do
        task.wait(1)
        if state.page == "Lock" or state.page == "Home" then
            for _,v in ipairs(root:GetChildren()) do
                if v:IsA("TextLabel") and v.Text:match("^%d%d:%d%d$") then
                    v.Text = os.date("%H:%M")
                end
            end
        end
    end
end)

print("Android 16 Virtual OS v2 Loaded")
