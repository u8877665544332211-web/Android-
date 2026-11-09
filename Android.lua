
--[[
    NOVA BROWSER
    Original Roblox Virtual Browser
    Mobile + PC compatible

    설치:
    StarterPlayer > StarterPlayerScripts > LocalScript

    참고:
    Roblox GUI로 구현한 가상 브라우저입니다.
    실제 웹사이트 HTML을 직접 렌더링하지는 않습니다.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 기존 브라우저 제거
local old = playerGui:FindFirstChild("NovaBrowser")
if old then old:Destroy() end

-- 설정
local C = {
    bg = Color3.fromRGB(12, 14, 25),
    panel = Color3.fromRGB(23, 26, 43),
    panel2 = Color3.fromRGB(34, 38, 60),
    accent = Color3.fromRGB(119, 105, 255),
    accent2 = Color3.fromRGB(65, 165, 255),
    text = Color3.fromRGB(245, 245, 255),
    muted = Color3.fromRGB(150, 155, 180),
    red = Color3.fromRGB(220, 75, 90),
    green = Color3.fromRGB(75, 190, 140),
}

local state = {
    url = "nova://home",
    history = {},
    historyIndex = 0,
    bookmarks = {},
    tabs = {},
    activeTab = 1,
    dark = true,
    loading = false,
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "NovaBrowser"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 200
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = C.bg
root.BorderSizePixel = 0
root.Parent = gui

local uiScale = Instance.new("UIScale")
uiScale.Parent = root

local camera = workspace.CurrentCamera
local function updateScale()
    if camera then
        local v = camera.ViewportSize
        uiScale.Scale = math.clamp(math.min(v.X / 430, v.Y / 850), 0.68, 1)
    end
end

updateScale()
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- UI 유틸리티
local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.accent
    s.Thickness = thickness or 1
    s.Transparency = 0.5
    s.Parent = obj
end

local function frame(parent, size, pos, color, radius)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = color or C.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    if radius then corner(f, radius) end
    return f
end

local function label(parent, text, size, pos, textSize, color)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Size = size
    t.Position = pos
    t.Text = text
    t.TextColor3 = color or C.text
    t.TextSize = textSize or 15
    t.Font = Enum.Font.Gotham
    t.TextWrapped = true
    t.Parent = parent
    return t
end

local function button(parent, text, size, pos, callback, color)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = color or C.panel2
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = C.text
    b.TextSize = 15
    b.Font = Enum.Font.GothamMedium
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 12)

    b.Activated:Connect(function()
        if callback then callback() end
    end)

    return b
end

local function clear(parent)
    for _, child in ipairs(parent:GetChildren()) do
        child:Destroy()
    end
end

-- 메인 배경
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 24)),
})
bgGradient.Rotation = 135
bgGradient.Parent = root

-- 상단 브랜드 영역
local header = frame(root,
    UDim2.new(1, 0, 0, 58),
    UDim2.new(0, 0, 0, 0),
    C.bg)

header.BackgroundTransparency = 0.1

local logo = label(header, "✦ NOVA",
    UDim2.new(0.6, 0, 1, 0),
    UDim2.new(0.05, 0, 0, 0),
    22, C.text)
logo.Font = Enum.Font.GothamBold
logo.TextXAlignment = Enum.TextXAlignment.Left

label(header, "BROWSER",
    UDim2.new(0.3, 0, 0, 20),
    UDim2.new(0.05, 0, 0.68, -10),
    9, C.accent2).TextXAlignment = Enum.TextXAlignment.Left

local tabButton = button(header, "▢ 1",
    UDim2.new(0, 55, 0, 38),
    UDim2.new(1, -115, 0.5, -19),
    function()
        showTabs()
    end)

local menuButton = button(header, "⋮",
    UDim2.new(0, 42, 0, 38),
    UDim2.new(1, -55, 0.5, -19),
    function()
        showMenu()
    end)

-- 주소창 영역
local addressBar = frame(root,
    UDim2.new(0.92, 0, 0, 48),
    UDim2.new(0.04, 0, 0, 65),
    C.panel, 15)

stroke(addressBar, C.accent, 1)

local lockIcon = label(addressBar, "⌕",
    UDim2.new(0, 35, 1, 0),
    UDim2.new(0, 5, 0, 0),
    21, C.accent2)

local address = Instance.new("TextBox")
address.Size = UDim2.new(1, -90, 1, 0)
address.Position = UDim2.new(0, 40, 0, 0)
address.BackgroundTransparency = 1
address.Text = "nova://home"
address.PlaceholderText = "검색 또는 주소 입력"
address.TextColor3 = C.text
address.PlaceholderColor3 = C.muted
address.TextSize = 14
address.Font = Enum.Font.Gotham
address.ClearTextOnFocus = false
address.TextXAlignment = Enum.TextXAlignment.Left
address.Parent = addressBar

local goButton = button(addressBar, "↵",
    UDim2.new(0, 38, 0, 36),
    UDim2.new(1, -42, 0.5, -18),
    nil, C.accent)

-- 페이지 영역
local content = frame(root,
    UDim2.new(0.92, 0, 1, -205),
    UDim2.new(0.04, 0, 0, 125),
    C.bg, 15)

content.BackgroundTransparency = 1

local pageFrame = Instance.new("ScrollingFrame")
pageFrame.Size = UDim2.fromScale(1, 1)
pageFrame.BackgroundTransparency = 1
pageFrame.BorderSizePixel = 0
pageFrame.ScrollBarThickness = 3
pageFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
pageFrame.Parent = content

-- 하단 도구 모음
local bottom = frame(root,
    UDim2.new(0.92, 0, 0, 58),
    UDim2.new(0.04, 0, 1, -72),
    C.panel, 18)

local backButton
local forwardButton
local homeButton
local bookmarkButton
local refreshButton

-- 페이지 관리
local function addHistory(url)
    for i = #state.history, state.historyIndex + 1, -1 do
        table.remove(state.history, i)
    end

    table.insert(state.history, url)
    state.historyIndex = #state.history
end

local function setURL(url)
    state.url = url
    address.Text = url
    state.tabs[state.activeTab] = url
end

local function makeCard(parent, title, description, callback)
    local card = button(parent,
        title .. "\n" .. description,
        UDim2.new(1, -8, 0, 78),
        UDim2.new(0, 4, 0, 0),
        callback, C.panel)

    card.TextXAlignment = Enum.TextXAlignment.Left
    card.TextSize = 15
    return card
end

local function showHomePage()
    clear(pageFrame)
    setURL("nova://home")

    label(pageFrame, "WELCOME TO",
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 0, 0, 25),
        12, C.muted)

    local title = label(pageFrame, "NOVA.",
        UDim2.new(1, 0, 0, 75),
        UDim2.new(0, 0, 0, 45),
        55, C.text)
    title.Font = Enum.Font.GothamBold

    label(pageFrame, "A different way to explore.",
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0, 115),
        14, C.muted)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -8, 0, 52)
    searchBox.Position = UDim2.new(0, 4, 0, 170)
    searchBox.BackgroundColor3 = C.panel
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "검색어를 입력하세요"
    searchBox.PlaceholderColor3 = C.muted
    searchBox.Text = ""
    searchBox.TextColor3 = C.text
    searchBox.TextSize = 15
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = pageFrame
    corner(searchBox, 15)

    searchBox.FocusLost:Connect(function(enter)
        if enter and searchBox.Text ~= "" then
            navigate(searchBox.Text)
        end
    end)

    label(pageFrame, "QUICK ACCESS",
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 5, 0, 245),
        12, C.accent2)

    local quickSites = {
        {"◈ Roblox", "nova://roblox"},
        {"▣ History", "nova://history"},
        {"★ Bookmarks", "nova://bookmarks"},
        {"⚙ Settings", "nova://settings"},
    }

    for i, item in ipairs(quickSites) do
        local y = 280 + (i - 1) * 80
        makeCard(pageFrame, item[1], item[2], function()
            navigate(item[2])
        end).Position = UDim2.new(0, 4, 0, y)
    end

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 620)
end

-- 검색 결과 페이지
local function showSearch(query)
    clear(pageFrame)
    setURL("nova://search/" .. query)

    label(pageFrame, "검색 결과",
        UDim2.new(1, 0, 0, 45),
        UDim2.new(0, 5, 0, 15),
        23, C.text)

    label(pageFrame, '"' .. query .. '" 검색",
        UDim2.new(1, 0, 0, 35),
        UDim2.new(0, 5, 0, 55),
        14, C.muted)

    makeCard(pageFrame, "NOVA 검색",
        "이 브라우저는 자체 검색 UI를 사용합니다.",
        function() end).Position = UDim2.new(0, 4, 0, 110)

    makeCard(pageFrame, "검색 기능 안내",
        "실제 검색 엔진 연결은 지원되지 않습니다.",
        function() end).Position = UDim2.new(0, 4, 0, 200)

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
end

-- 북마크 페이지
local function showBookmarks()
    clear(pageFrame)
    setURL("nova://bookmarks")

    label(pageFrame, "북마크",
        UDim2.new(1, 0, 0, 45),
        UDim2.new(0, 5, 0, 15), 24)

    for i, url in ipairs(state.bookmarks) do
        local b = makeCard(pageFrame, "★ " .. url,
            "저장된 페이지",
            function()
                navigate(url)
            end)
        b.Position = UDim2.new(0, 4, 0, 70 + (i - 1) * 85)
    end

    if #state.bookmarks == 0 then
        label(pageFrame, "저장된 북마크가 없습니다.",
            UDim2.new(1, 0, 0, 50),
            UDim2.new(0, 0, 0, 100), 14, C.muted)
    end

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 100 + #state.bookmarks * 85)
end

-- 방문 기록
local function showHistory()
    clear(pageFrame)
    setURL("nova://history")

    label(pageFrame, "방문 기록",
        UDim2.new(1, 0, 0, 45),
        UDim2.new(0, 5, 0, 15), 24)

    for i = #state.history, 1, -1 do
        local url = state.history[i]
        local b = makeCard(pageFrame, url,
            "방문 기록",
            function()
                navigate(url)
            end)
        b.Position = UDim2.new(0, 4, 0, 70 + (#state.history - i) * 85)
    end

    if #state.history == 0 then
        label(pageFrame, "방문 기록이 없습니다.",
            UDim2.new(1, 0, 0, 50),
            UDim2.new(0, 0, 0, 100), 14, C.muted)
    end

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 100 + #state.history * 85)
end

-- 설정 페이지
local function showSettings()
    clear(pageFrame)
    setURL("nova://settings")

    label(pageFrame, "브라우저 설정",
        UDim2.new(1, 0, 0, 45),
        UDim2.new(0, 5, 0, 15), 24)

    makeCard(pageFrame, "테마 변경",
        state.dark and "현재: 다크 모드" or "현재: 라이트 모드",
        function()
            state.dark = not state.dark
            root.BackgroundColor3 = state.dark and C.bg or Color3.fromRGB(235, 238, 248)
            showSettings()
        end).Position = UDim2.new(0, 4, 0, 80)

    makeCard(pageFrame, "방문 기록 삭제",
        "저장된 방문 기록을 모두 삭제합니다.",
        function()
            state.history = {}
            state.historyIndex = 0
            showSettings()
        end).Position = UDim2.new(0, 4, 0, 170)

    makeCard(pageFrame, "북마크 초기화",
        "저장된 북마크를 모두 삭제합니다.",
        function()
            state.bookmarks = {}
            showSettings()
        end).Position = UDim2.new(0, 4, 0, 260)

    makeCard(pageFrame, "브라우저 정보",
        "NOVA Browser · Version 1.0",
        function()
            navigate("nova://about")
        end).Position = UDim2.new(0, 4, 0, 350)

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 470)
end

-- 정보 페이지
local function showAbout()
    clear(pageFrame)
    setURL("nova://about")

    label(pageFrame, "NOVA Browser",
        UDim2.new(1, 0, 0, 60),
        UDim2.new(0, 0, 0, 70), 30)

    label(pageFrame,
        "Version 1.0\n\nOriginal Roblox virtual browser.\n\nDesigned for touch and desktop controls.",
        UDim2.new(0.9, 0, 0, 150),
        UDim2.new(0.05, 0, 0, 140), 15, C.muted)

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
end

-- 페이지 이동
navigate = function(input)
    if not input or input == "" then return end

    input = string.gsub(input, "^%s*(.-)%s*$", "%1")

    if not string.find(input, "://", 1, true) then
        if string.find(input, "%.") then
            input = "https://" .. input
        else
            addHistory(input)
            showSearch(input)
            return
        end
    end

    addHistory(input)

    if input == "nova://home" then
        showHomePage()
    elseif input == "nova://bookmarks" then
        showBookmarks()
    elseif input == "nova://history" then
        showHistory()
    elseif input == "nova://settings" then
        showSettings()
    elseif input == "nova://about" then
        showAbout()
    elseif input == "nova://roblox" then
        clear(pageFrame)
        setURL(input)

        label(pageFrame, "ROBLOX",
            UDim2.new(1, 0, 0, 60),
            UDim2.new(0, 0, 0, 60), 35, C.text)

        label(pageFrame,
            "Roblox 페이지 바로가기\n\n실제 웹페이지는 표시되지 않습니다.",
            UDim2.new(1, 0, 0, 80),
            UDim2.new(0, 0, 0, 130), 15, C.muted)

        makeCard(pageFrame, "Roblox 웹사이트",
            "외부 브라우저에서 열기",
            function()
                local ok = pcall(function()
                    game:GetService("GuiService"):OpenBrowserWindow("https://www.roblox.com")
                end)
                if not ok then
                    warn("외부 브라우저 열기를 지원하지 않습니다.")
                end
            end).Position = UDim2.new(0, 4, 0, 240)

        pageFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
    else
        clear(pageFrame)
        setURL(input)

        label(pageFrame, "페이지를 표시할 수 없습니다.",
            UDim2.new(1, 0, 0, 50),
            UDim2.new(0, 0, 0, 80), 19)

        label(pageFrame,
            "주소: " .. input ..
            "\n\nNOVA는 실제 웹 HTML 렌더링을 지원하지 않습니다.",
            UDim2.new(0.9, 0, 0, 100),
            UDim2.new(0.05, 0, 0, 145), 13, C.muted)

        pageFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
    end
end

-- 탭 화면
function showTabs()
    clear(pageFrame)
    setURL("nova://tabs")

    label(pageFrame, "열린 탭",
        UDim2.new(1, 0, 0, 45),
        UDim2.new(0, 5, 0, 15), 24)

    for i, url in ipairs(state.tabs) do
        local b = makeCard(pageFrame,
            "탭 " .. i,
            url,
            function()
                state.activeTab = i
                navigate(url)
                tabButton.Text = "▢ " .. #state.tabs
            end)

        b.Position = UDim2.new(0, 4, 0, 75 + (i - 1) * 85)
    end

    button(pageFrame, "+ 새 탭",
        UDim2.new(1, -8, 0, 50),
        UDim2.new(0, 4, 0, 75 + #state.tabs * 85),
        function()
            table.insert(state.tabs, "nova://home")
            state.activeTab = #state.tabs
            tabButton.Text = "▢ " .. #state.tabs
            showHomePage()
        end, C.accent)

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 150 + #state.tabs * 85)
end

-- 메뉴
function showMenu()
    clear(pageFrame)
    setURL("nova://menu")

    label(pageFrame, "메뉴",
        UDim2.new(1, 0, 0, 45),
        UDim2.new(0, 5, 0, 15), 24)

    local items = {
        {"홈", "nova://home"},
        {"북마크", "nova://bookmarks"},
        {"방문 기록", "nova://history"},
        {"설정", "nova://settings"},
        {"브라우저 정보", "nova://about"},
    }

    for i, item in ipairs(items) do
        local b = makeCard(pageFrame, item[1], item[2], function()
            navigate(item[2])
        end)
        b.Position = UDim2.new(0, 4, 0, 75 + (i - 1) * 85)
    end

    pageFrame.CanvasSize = UDim2.new(0, 0, 0, 520)
end

-- 주소창 실행
goButton.Activated:Connect(function()
    navigate(address.Text)
end)

address.FocusLost:Connect(function(enter)
    if enter then
        navigate(address.Text)
    end
end)

-- 하단 버튼
backButton = button(bottom, "‹",
    UDim2.new(0.18, 0, 0.75, 0),
    UDim2.new(0.02, 0, 0.12, 0),
    function()
        if state.historyIndex > 1 then
            state.historyIndex -= 1
            navigate(state.history[state.historyIndex])
        end
    end)

forwardButton = button(bottom, "›",
    UDim2.new(0.18, 0, 0.75, 0),
    UDim2.new(0.21, 0, 0.12, 0),
    function()
        if state.historyIndex < #state.history then
            state.historyIndex += 1
            navigate(state.history[state.historyIndex])
        end
    end)

homeButton = button(bottom, "⌂",
    UDim2.new(0.18, 0, 0.75, 0),
    UDim2.new(0.41, 0, 0.12, 0),
    function()
        navigate("nova://home")
    end, C.accent)

bookmarkButton = button(bottom, "☆",
    UDim2.new(0.18, 0, 0.75, 0),
    UDim2.new(0.61, 0, 0.12, 0),
    function()
        if not table.find(state.bookmarks, state.url) then
            table.insert(state.bookmarks, state.url)
            bookmarkButton.Text = "★"
        else
            bookmarkButton.Text = "☆"
        end
    end)

refreshButton = button(bottom, "⟳",
    UDim2.new(0.18, 0, 0.75, 0),
    UDim2.new(0.81, 0, 0.12, 0),
    function()
        navigate(state.url)
    end)

-- 초기 탭
table.insert(state.tabs, "nova://home")
state.activeTab = 1

-- 시작 화면
showHomePage()

print("NOVA Browser loaded successfully.")
