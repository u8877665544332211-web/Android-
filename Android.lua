
--[[
    Android 16 Virtual OS
    Roblox Studio - LocalScript
    StarterPlayer > StarterPlayerScripts

    가상 OS 시뮬레이션입니다.
    실제 기기의 전원, Wi-Fi, 블루투스 등을 제어하지 않습니다.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 기존 GUI 제거
local old = playerGui:FindFirstChild("Android16")
if old then
    old:Destroy()
end

-- 설정값
local state = {
    page = "Home",
    dark = true,
    wifi = true,
    bluetooth = false,
    airplane = false,
    sound = true,
    brightness = 1,
    navigationMode = "Gesture",
    quick = false,
    poweredOff = false,
    rebooting = false,
}

local COLORS = {
    background = Color3.fromRGB(15, 17, 24),
    panel = Color3.fromRGB(30, 33, 43),
    panel2 = Color3.fromRGB(43, 47, 59),
    text = Color3.fromRGB(245, 246, 250),
    subtext = Color3.fromRGB(165, 170, 185),
    blue = Color3.fromRGB(150, 190, 255),
    accent = Color3.fromRGB(90, 130, 220),
}

-- GUI 생성
local gui = Instance.new("ScreenGui")
gui.Name = "Android16"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = COLORS.background
root.BorderSizePixel = 0
root.Parent = gui

local scale = Instance.new("UIScale")
scale.Scale = 0.88
scale.Parent = root

local camera = workspace.CurrentCamera
local function updateScale()
    if camera then
        local size = camera.ViewportSize
        scale.Scale = math.clamp(math.min(size.X / 430, size.Y / 850), 0.65, 1)
    end
end

updateScale()
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- 공통 UI 함수
local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 16)
    c.Parent = obj
    return c
end

local function makeFrame(parent, name, size, position, color, radius)
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = size
    f.Position = position
    f.BackgroundColor3 = color or COLORS.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    if radius then
        corner(f, radius)
    end
    return f
end

local function makeText(parent, text, size, position, textSize, color)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Size = size
    t.Position = position
    t.Font = Enum.Font.Gotham
    t.Text = text
    t.TextSize = textSize or 16
    t.TextColor3 = color or COLORS.text
    t.TextWrapped = true
    t.Parent = parent
    return t
end

local function makeButton(parent, text, size, position, callback, color)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = color or COLORS.panel2
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = COLORS.text
    b.TextSize = 15
    b.Font = Enum.Font.GothamMedium
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 14)

    b.Activated:Connect(function()
        if callback then
            callback()
        end
    end)

    return b
end

local function clear(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if not child:IsA("UIListLayout")
            and not child:IsA("UIGridLayout")
            and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

-- 배경화면
local wallpaper = Instance.new("Frame")
wallpaper.Name = "Wallpaper"
wallpaper.Size = UDim2.fromScale(1, 1)
wallpaper.BackgroundColor3 = Color3.fromRGB(25, 35, 75)
wallpaper.BorderSizePixel = 0
wallpaper.Parent = root

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 65, 130)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 45, 90)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 17, 38)),
})
gradient.Rotation = 135
gradient.Parent = wallpaper

-- 페이지 영역
local pages = Instance.new("Frame")
pages.Name = "Pages"
pages.Size = UDim2.fromScale(1, 1)
pages.BackgroundTransparency = 1
pages.Parent = root

-- 시스템 UI 영역
local system = Instance.new("Frame")
system.Name = "System"
system.Size = UDim2.fromScale(1, 1)
system.BackgroundTransparency = 1
system.Parent = root

-- 전방 선언
local showHome
local showLock
local showSettings
local showApp
local showQuick
local showPowerMenu
local powerOff
local restartDevice
local renderNavigation

-- 현재 페이지 초기화
local function newPage(name)
    clear(pages)
    state.page = name

    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Parent = pages

    return page
end

-- 상태 표시줄
local status = makeFrame(system, "StatusBar",
    UDim2.new(1, 0, 0, 32),
    UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(0, 0, 0), 0)

status.BackgroundTransparency = 0.65

local statusText = makeText(status, "9:41     ●  ●  ▰",
    UDim2.new(1, -30, 1, 0),
    UDim2.new(0, 15, 0, 0), 13, COLORS.text)

statusText.TextXAlignment = Enum.TextXAlignment.Left

-- 내비게이션
local nav = makeFrame(system, "Navigation",
    UDim2.new(1, 0, 0, 35),
    UDim2.new(0, 0, 1, -35),
    Color3.fromRGB(0, 0, 0), 0)

nav.BackgroundTransparency = 0.65

local gestureBar = makeButton(nav, "",
    UDim2.new(0, 110, 0, 5),
    UDim2.new(0.5, -55, 0.5, -2),
    nil, Color3.fromRGB(245, 245, 245))
corner(gestureBar, 10)

local function goBack()
    if state.page == "Home" then
        return
    elseif state.page == "Settings" then
        showHome()
    else
        showSettings()
    end
end

renderNavigation = function()
    clear(nav)

    if state.navigationMode == "Gesture" then
        local bar = makeButton(nav, "",
            UDim2.new(0, 110, 0, 5),
            UDim2.new(0.5, -55, 0.5, -2),
            nil, Color3.fromRGB(245, 245, 245))
        corner(bar, 10)
    else
        makeButton(nav, "‹",
            UDim2.new(0, 55, 0, 30),
            UDim2.new(0.18, 0, 0, 2),
            goBack, COLORS.panel2)

        makeButton(nav, "●",
            UDim2.new(0, 55, 0, 30),
            UDim2.new(0.5, -27, 0, 2),
            showHome, COLORS.panel2)

        makeButton(nav, "▢",
            UDim2.new(0, 55, 0, 30),
            UDim2.new(0.82, -55, 0, 2),
            showHome, COLORS.panel2)
    end
end

renderNavigation()

-- 홈 화면
showHome = function()
    local page = newPage("Home")

    local clock = makeText(page, "9:41",
        UDim2.new(1, 0, 0, 75),
        UDim2.new(0, 0, 0.17, 0),
        58, COLORS.text)
    clock.Font = Enum.Font.GothamLight

    makeText(page, "MONDAY, NOVEMBER 9",
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 0, 0.27, 0),
        13, COLORS.subtext)

    local search = makeButton(page, "⌕     검색",
        UDim2.new(0.86, 0, 0, 48),
        UDim2.new(0.07, 0, 0.66, 0),
        function()
            showApp("검색")
        end, COLORS.panel)
    search.TextXAlignment = Enum.TextXAlignment.Left
    search.TextSize = 17

    local apps = {
        {"⚙", "설정"},
        {"▦", "앱"},
        {"▣", "파일"},
        {"◉", "카메라"},
    }

    for i, app in ipairs(apps) do
        local x = 0.08 + (i - 1) * 0.225
        makeButton(page, app[1] .. "\n" .. app[2],
            UDim2.new(0.19, 0, 0, 70),
            UDim2.new(x, 0, 0.82, 0),
            function()
                if app[2] == "설정" then
                    showSettings()
                else
                    showApp(app[2])
                end
            end, COLORS.panel)
    end

    makeText(page, "Android 16",
        UDim2.new(1, 0, 0, 20),
        UDim2.new(0, 0, 0.94, -20),
        11, COLORS.subtext)

    renderNavigation()
end

-- 일반 앱 화면
showApp = function(appName)
    local page = newPage(appName)

    makeText(page, appName,
        UDim2.new(0.85, 0, 0, 50),
        UDim2.new(0.075, 0, 0, 55),
        25, COLORS.text).TextXAlignment = Enum.TextXAlignment.Left

    makeText(page, appName .. " 앱\n\n이 앱은 가상 OS에서 실행 중입니다.",
        UDim2.new(0.85, 0, 0, 130),
        UDim2.new(0.075, 0, 0.25, 0),
        17, COLORS.subtext)

    makeButton(page, "홈으로",
        UDim2.new(0.85, 0, 0, 48),
        UDim2.new(0.075, 0, 0.75, 0),
        showHome, COLORS.panel2)

    renderNavigation()
end

-- 설정 화면
showSettings = function()
    local page = newPage("Settings")

    makeText(page, "설정",
        UDim2.new(0.85, 0, 0, 45),
        UDim2.new(0.075, 0, 0, 45),
        27, COLORS.text).TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, 0.78, 0)
    scroll.Position = UDim2.new(0.05, 0, 0.14, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 680)
    scroll.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 9)
    layout.Parent = scroll

    local function settingButton(title, description, callback)
        local b = makeButton(scroll,
            title .. "\n" .. description,
            UDim2.new(1, 0, 0, 65),
            UDim2.new(0, 0, 0, 0),
            callback, COLORS.panel)
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.TextSize = 15
        return b
    end

    settingButton("네트워크 및 인터넷", "Wi-Fi · 비행기 모드",
        function()
            local p = newPage("Network")
            makeText(p, "네트워크 및 인터넷",
                UDim2.new(0.9, 0, 0, 50),
                UDim2.new(0.05, 0, 0, 50), 23)

            makeButton(p, "Wi-Fi: " .. tostring(state.wifi),
                UDim2.new(0.9, 0, 0, 55),
                UDim2.new(0.05, 0, 0.2, 0),
                function()
                    state.wifi = not state.wifi
                    showSettings()
                end)

            makeButton(p, "비행기 모드: " .. tostring(state.airplane),
                UDim2.new(0.9, 0, 0, 55),
                UDim2.new(0.05, 0, 0.3, 0),
                function()
                    state.airplane = not state.airplane
                    showSettings()
                end)

            renderNavigation()
        end)

    settingButton("연결된 기기", "블루투스",
        function()
            state.bluetooth = not state.bluetooth
            showSettings()
        end)

    settingButton("디스플레이", "밝기 · 다크 모드",
        function()
            local p = newPage("Display")
            makeText(p, "디스플레이",
                UDim2.new(0.9, 0, 0, 50),
                UDim2.new(0.05, 0, 0, 50), 24)

            makeText(p, "밝기",
                UDim2.new(0.9, 0, 0, 30),
                UDim2.new(0.05, 0, 0.2, 0), 16)

            local slider = Instance.new("TextButton")
            slider.Size = UDim2.new(0.9, 0, 0, 50)
            slider.Position = UDim2.new(0.05, 0, 0.27, 0)
            slider.Text = "밝기 조절: " .. math.floor(state.brightness * 100) .. "%"
            slider.TextColor3 = COLORS.text
            slider.BackgroundColor3 = COLORS.panel
            slider.Parent = p
            corner(slider, 12)

            slider.Activated:Connect(function()
                state.brightness = state.brightness + 0.25
                if state.brightness > 1 then
                    state.brightness = 0.25
                end
                slider.Text = "밝기 조절: " .. math.floor(state.brightness * 100) .. "%"
                wallpaper.BackgroundTransparency = 1 - state.brightness
            end)

            makeButton(p, "다크 모드: " .. tostring(state.dark),
                UDim2.new(0.9, 0, 0, 50),
                UDim2.new(0.05, 0, 0.42, 0),
                function()
                    state.dark = not state.dark
                    showSettings()
                end)

            renderNavigation()
        end)

    settingButton("소리 및 진동", "소리 설정",
        function()
            state.sound = not state.sound
            showSettings()
        end)

    settingButton("배터리", "배터리 사용량 및 상태",
        function()
            showApp("배터리")
        end)

    settingButton("저장공간", "내부 저장공간",
        function()
            showApp("저장공간")
        end)

    settingButton("배경화면 및 스타일", "배경화면 설정",
        function()
            local p = newPage("Wallpaper")
            makeText(p, "배경화면",
                UDim2.new(0.9, 0, 0, 50),
                UDim2.new(0.05, 0, 0, 50), 24)

            local choices = {
                Color3.fromRGB(25, 35, 75),
                Color3.fromRGB(65, 30, 90),
                Color3.fromRGB(20, 80, 80),
                Color3.fromRGB(90, 45, 40),
            }

            for i, color in ipairs(choices) do
                makeButton(p, "배경화면 " .. i,
                    UDim2.new(0.9, 0, 0, 55),
                    UDim2.new(0.05, 0, 0.15 + (i - 1) * 0.14, 0),
                    function()
                        wallpaper.BackgroundColor3 = color
                    end, color)
            end

            renderNavigation()
        end)

    settingButton("시스템", "언어 · 날짜 및 시간",
        function()
            showApp("시스템")
        end)

    settingButton("시스템 내비게이션", "제스처 또는 버튼 방식 변경",
        function()
            local p = newPage("NavigationSettings")
            makeText(p, "시스템 내비게이션",
                UDim2.new(0.9, 0, 0, 50),
                UDim2.new(0.05, 0, 0, 50), 23)

            makeButton(p, "제스처 내비게이션",
                UDim2.new(0.9, 0, 0, 55),
                UDim2.new(0.05, 0, 0.2, 0),
                function()
                    state.navigationMode = "Gesture"
                    renderNavigation()
                    showSettings()
                end)

            makeButton(p, "버튼 내비게이션",
                UDim2.new(0.9, 0, 0, 55),
                UDim2.new(0.05, 0, 0.31, 0),
                function()
                    state.navigationMode = "Buttons"
                    renderNavigation()
                    showSettings()
                end)

            renderNavigation()
        end)

    settingButton("휴대전화 정보", "Android 16 · 가상 기기",
        function()
            local p = newPage("About")
            makeText(p, "기기 정보",
                UDim2.new(0.9, 0, 0, 50),
                UDim2.new(0.05, 0, 0, 50), 24)

            makeText(p,
                "기기 이름: Android Virtual Device\n모델: Virtual Android 16\nAndroid 버전: 16\n보안 업데이트: 2026-11-01",
                UDim2.new(0.9, 0, 0, 160),
                UDim2.new(0.05, 0, 0.2, 0), 16, COLORS.subtext)

            renderNavigation()
        end)

    renderNavigation()
end

-- 빠른 설정창
local quickPanel = makeFrame(system, "QuickPanel",
    UDim2.new(1, 0, 0, 300),
    UDim2.new(0, 0, 0, -310),
    COLORS.background, 0)

local quickTitle = makeText(quickPanel, "빠른 설정",
    UDim2.new(0.9, 0, 0, 35),
    UDim2.new(0.05, 0, 0, 15), 22)
quickTitle.TextXAlignment = Enum.TextXAlignment.Left

local function quickButton(label, x, y, callback)
    return makeButton(quickPanel, label,
        UDim2.new(0.44, 0, 0, 58),
        UDim2.new(x, 0, 0, y),
        callback, COLORS.panel2)
end

quickButton("Wi-Fi", 0.04, 65, function()
    state.wifi = not state.wifi
end)

quickButton("Bluetooth", 0.52, 65, function()
    state.bluetooth = not state.bluetooth
end)

quickButton("비행기 모드", 0.04, 135, function()
    state.airplane = not state.airplane
end)

quickButton("소리", 0.52, 135, function()
    state.sound = not state.sound
end)

quickButton("설정", 0.04, 205, function()
    state.quick = false
    TweenService:Create(quickPanel, TweenInfo.new(0.2),
        {Position = UDim2.new(0, 0, 0, -310)}):Play()
    showSettings()
end)

quickButton("전원", 0.52, 205, function()
    state.quick = false
    TweenService:Create(quickPanel, TweenInfo.new(0.2),
        {Position = UDim2.new(0, 0, 0, -310)}):Play()
    showPowerMenu()
end)

showQuick = function()
    if state.poweredOff or state.rebooting then
        return
    end

    state.quick = not state.quick

    local target = state.quick
        and UDim2.new(0, 0, 0, 0)
        or UDim2.new(0, 0, 0, -310)

    TweenService:Create(quickPanel,
        TweenInfo.new(0.22, Enum.EasingStyle.Quart),
        {Position = target}):Play()
end

-- 전원 메뉴
local powerOverlay

local function removePowerOverlay()
    if powerOverlay then
        powerOverlay:Destroy()
        powerOverlay = nil
    end
end

showPowerMenu = function()
    removePowerOverlay()

    powerOverlay = makeFrame(system, "PowerMenu",
        UDim2.fromScale(1, 1),
        UDim2.fromScale(0, 0),
        Color3.fromRGB(0, 0, 0), 0)
    powerOverlay.BackgroundTransparency = 0.25
    powerOverlay.ZIndex = 50

    local panel = makeFrame(powerOverlay, "Menu",
        UDim2.new(0.82, 0, 0, 230),
        UDim2.new(0.09, 0, 0.5, -115),
        COLORS.panel, 22)
    panel.ZIndex = 51

    local title = makeText(panel, "전원 메뉴",
        UDim2.new(0.9, 0, 0, 40),
        UDim2.new(0.05, 0, 0, 12), 21)
    title.ZIndex = 52

    local off = makeButton(panel, "전원 끄기",
        UDim2.new(0.9, 0, 0, 48),
        UDim2.new(0.05, 0, 0, 65),
        function()
            removePowerOverlay()
            powerOff()
        end, Color3.fromRGB(130, 55, 55))
    off.ZIndex = 52

    local restart = makeButton(panel, "재시작",
        UDim2.new(0.9, 0, 0, 48),
        UDim2.new(0.05, 0, 0, 123),
        function()
            removePowerOverlay()
            restartDevice()
        end, COLORS.accent)
    restart.ZIndex = 52

    local cancel = makeButton(panel, "취소",
        UDim2.new(0.9, 0, 0, 35),
        UDim2.new(0.05, 0, 0, 181),
        removePowerOverlay, COLORS.panel2)
    cancel.ZIndex = 52
end

-- 전원 끄기 화면
powerOff = function()
    state.poweredOff = true
    state.rebooting = false
    state.quick = false

    quickPanel.Position = UDim2.new(0, 0, 0, -310)
    clear(pages)

    local screen = makeFrame(system, "PowerOffScreen",
        UDim2.fromScale(1, 1),
        UDim2.fromScale(0, 0),
        Color3.new(0, 0, 0), 0)
    screen.ZIndex = 100

    local label = makeText(screen, "전원이 꺼졌습니다",
        UDim2.new(1, 0, 0, 50),
        UDim2.new(0, 0, 0.43, 0),
        19, Color3.fromRGB(190, 190, 190))
    label.ZIndex = 101

    local hint = makeText(screen, "화면을 터치하면 다시 켜집니다",
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0.51, 0),
        12, Color3.fromRGB(100, 100, 100))
    hint.ZIndex = 101

    local wake = Instance.new("TextButton")
    wake.Size = UDim2.fromScale(1, 1)
    wake.BackgroundTransparency = 1
    wake.Text = ""
    wake.ZIndex = 110
    wake.Parent = screen

    wake.Activated:Connect(function()
        if not state.poweredOff then
            return
        end

        state.poweredOff = false
        screen:Destroy()
        showLock()
    end)
end

-- 부팅 화면
restartDevice = function()
    if state.rebooting then
        return
    end

    state.rebooting = true
    state.poweredOff = false
    state.quick = false
    quickPanel.Position = UDim2.new(0, 0, 0, -310)

    clear(pages)

    local boot = makeFrame(system, "BootScreen",
        UDim2.fromScale(1, 1),
        UDim2.fromScale(0, 0),
        Color3.new(0, 0, 0), 0)
    boot.ZIndex = 100

    local logo = makeText(boot, "G",
        UDim2.new(1, 0, 0, 100),
        UDim2.new(0, 0, 0.32, 0),
        78, Color3.fromRGB(230, 230, 230))
    logo.Font = Enum.Font.GothamBold
    logo.ZIndex = 101

    local android = makeText(boot, "Android",
        UDim2.new(1, 0, 0, 40),
        UDim2.new(0, 0, 0.48, 0),
        27, Color3.fromRGB(230, 230, 230))
    android.ZIndex = 101

    local powered = makeText(boot, "Powered by Android",
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 0, 0.54, 0),
        12, Color3.fromRGB(130, 130, 130))
    powered.ZIndex = 101

    local dots = makeText(boot, "●  ○  ○",
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0.72, 0),
        14, COLORS.blue)
    dots.ZIndex = 101

    task.spawn(function()
        for i = 1, 8 do
            if not boot.Parent then
                return
            end

            dots.Text = (i % 3 == 1 and "●  ○  ○")
                or (i % 3 == 2 and "○  ●  ○")
                or "○  ○  ●"

            task.wait(0.45)
        end

        if boot.Parent then
            boot:Destroy()
            state.rebooting = false
            showLock()
        end
    end)
end

-- 잠금 화면
showLock = function()
    local page = newPage("LockScreen")

    local lockClock = makeText(page, "9:41",
        UDim2.new(1, 0, 0, 85),
        UDim2.new(0, 0, 0.27, 0),
        62, COLORS.text)
    lockClock.Font = Enum.Font.GothamLight

    makeText(page, "MONDAY, NOVEMBER 9",
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 0, 0.37, 0),
        13, COLORS.subtext)

    makeButton(page, "위로 밀어서 잠금 해제",
        UDim2.new(0.8, 0, 0, 50),
        UDim2.new(0.1, 0, 0.78, 0),
        showHome, COLORS.panel)

    renderNavigation()
end

-- 터치 제스처
local touchStart = nil
local touchStartTime = 0

UIS.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
        touchStartTime = tick()
    end
end)

UIS.InputEnded:Connect(function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if not touchStart then
        return
    end

    local finish = input.Position
    local delta = finish - touchStart
    local start = touchStart
    touchStart = nil

    if state.poweredOff or state.rebooting then
        return
    end

    -- 상단에서 아래로 스와이프: 빠른 설정
    if start.Y < 55 and delta.Y > 65 then
        showQuick()
        return
    end

    -- 제스처 내비게이션
    if state.navigationMode == "Gesture" and start.Y > 0 then
        local viewport = camera and camera.ViewportSize or Vector2.new(400, 800)

        if start.Y > viewport.Y - 75 and delta.Y < -65 then
            if state.page == "LockScreen" then
                showHome()
            elseif math.abs(delta.X) < 100 then
                showHome()
            end
        end
    end
end)

-- 초기 실행
restartDevice()

print("Android 16 Virtual OS loaded.")
