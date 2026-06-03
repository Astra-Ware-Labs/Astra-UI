local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local function create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

local function checkFS()
    return (writefile and readfile and isfolder and isfile and makefolder)
end

local Icons = {
    Close = "rbxassetid://73433330733472"
}

local AstraUI = {}
AstraUI.Theme = {
    Main = Color3.fromRGB(18, 18, 18),
    Container = Color3.fromRGB(21, 21, 21),
    Element = Color3.fromRGB(25, 25, 25),
    Hover = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 170),
    DarkText = Color3.fromRGB(25, 25, 25)
}

function AstraUI:CreateWindow(config)
    local targetGui = pcall(function() return CoreGui.Name end) and CoreGui or Player:WaitForChild("PlayerGui")
    if targetGui:FindFirstChild("AstraUI") then targetGui.AstraUI:Destroy() end

    local ScreenGui = create("ScreenGui", {Name = "AstraUI", Parent = targetGui, ResetOnSpawn = false})
    
    local MainFrame = create("Frame", {
        Name = "Main", 
        Parent = ScreenGui, 
        Size = UDim2.new(0, 600, 0, 400), 
        Position = UDim2.new(0.5, -300, 0.5, -200), 
        BackgroundColor3 = AstraUI.Theme.Main, 
        ClipsDescendants = true,
        Visible = not config.KeySystem
    })
    create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})

    -- Key System Logic
    if config.KeySystem then
        local keySettings = config.KeySettings or {Title = "AstraUI", SubTitle = "Key System", Key = "1234", SaveKey = true}
        local KeyFrame = create("Frame", {
            Name = "KeyFrame", Parent = ScreenGui, Size = UDim2.new(0, 350, 0, 180),
            Position = UDim2.new(0.5, -175, 0.5, -90), BackgroundColor3 = AstraUI.Theme.Main, ClipsDescendants = true
        })
        create("UICorner", {Parent = KeyFrame, CornerRadius = UDim.new(0, 10)})

        local KeyTitle = create("TextLabel", {Parent = KeyFrame, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1, Text = keySettings.Title, Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = AstraUI.Theme.Text})
        local KeySub = create("TextLabel", {Parent = KeyFrame, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, Text = keySettings.SubTitle, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = AstraUI.Theme.SubText})

        local KeyInputFrame = create("Frame", {Parent = KeyFrame, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 65), BackgroundColor3 = AstraUI.Theme.Container})
        create("UICorner", {Parent = KeyInputFrame, CornerRadius = UDim.new(0, 6)})
        local KeyInput = create("TextBox", {Parent = KeyInputFrame, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = "Enter Key...", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = AstraUI.Theme.Text, ClearTextOnFocus = false})

        local SubmitBtn = create("TextButton", {Parent = KeyFrame, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 115), BackgroundColor3 = AstraUI.Theme.Element, Text = "Submit Key", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = AstraUI.Theme.Text, AutoButtonColor = false})
        create("UICorner", {Parent = SubmitBtn, CornerRadius = UDim.new(0, 6)})

        SubmitBtn.MouseEnter:Connect(function() tween(SubmitBtn, {BackgroundColor3 = AstraUI.Theme.Hover}) end)
        SubmitBtn.MouseLeave:Connect(function() tween(SubmitBtn, {BackgroundColor3 = AstraUI.Theme.Element}) end)

        local function Unlock()
            tween(KeyFrame, {Size = UDim2.new(0, 350, 0, 0)}, 0.3)
            task.wait(0.3)
            KeyFrame:Destroy()
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.4)
        end

        local savedKeyPath = "AstraUI_SavedKey.txt"
        if keySettings.SaveKey and checkFS() and isfile(savedKeyPath) then
            if readfile(savedKeyPath) == keySettings.Key then
                KeyFrame:Destroy()
                MainFrame.Visible = true
            end
        end

        SubmitBtn.MouseButton1Click:Connect(function()
            if KeyInput.Text == keySettings.Key then
                if keySettings.SaveKey and checkFS() then writefile(savedKeyPath, keySettings.Key) end
                Unlock()
            else
                KeyInput.Text = "Invalid Key!"
                task.wait(1)
                KeyInput.Text = ""
            end
        end)
    end

    local TopBar = create("Frame", {Parent = MainFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
    
    local hasWindowIcon = config.Icon and config.Icon ~= ""
    local TitleIcon
    
    if hasWindowIcon then
        TitleIcon = create("ImageLabel", {
            Parent = TopBar,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 15, 0.5, -10),
            BackgroundTransparency = 1,
            Image = config.Icon,
            ImageColor3 = AstraUI.Theme.Text
        })
    end
    
    local Title = create("TextLabel", {
        Parent = TopBar, 
        Size = UDim2.new(0, 100, 1, 0), 
        Position = hasWindowIcon and UDim2.new(0, 42, 0, 0) or UDim2.new(0, 15, 0, 0), 
        BackgroundTransparency = 1, 
        Text = config.Name or "Astra UI", 
        Font = Enum.Font.GothamBold, 
        TextSize = 16, 
        TextColor3 = AstraUI.Theme.Text, 
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local CloseBtn = create("ImageButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Icons.Close,
        ImageColor3 = AstraUI.Theme.SubText
    })

    local TabContainer = create("ScrollingFrame", {
        Parent = TopBar, 
        Size = UDim2.new(1, -185, 0, 28), 
        Position = UDim2.new(0, 145, 0.5, -14), 
        BackgroundColor3 = AstraUI.Theme.Container,
        BackgroundTransparency = 0, 
        ScrollBarThickness = 0, 
        CanvasSize = UDim2.new(0, 0, 0, 0), 
        AutomaticCanvasSize = Enum.AutomaticSize.X, 
        ScrollingDirection = Enum.ScrollingDirection.X
    })
    create("UICorner", {Parent = TabContainer, CornerRadius = UDim.new(0, 6)})

    create("UIListLayout", {
        Parent = TabContainer, 
        FillDirection = Enum.FillDirection.Horizontal, 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        Padding = UDim.new(0, 4), 
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})

    local ContentContainer = create("Frame", {
        Parent = MainFrame, 
        Size = UDim2.new(1, -20, 1, -55), 
        Position = UDim2.new(0, 10, 0, 45), 
        BackgroundTransparency = 1
    })

    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {ImageColor3 = Color3.fromRGB(255, 80, 80)}) end)
    CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {ImageColor3 = AstraUI.Theme.SubText}) end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Window = {Tabs = {}, CurrentTab = nil, ScreenGui = ScreenGui, Flags = {}}

    function Window:SaveConfig(folder, file)
        if not checkFS() then return end
        if not isfolder(folder) then makefolder(folder) end
        local save = {}
        for flag, data in pairs(Window.Flags) do save[flag] = data.Value end
        writefile(folder.."/"..file..".json", HttpService:JSONEncode(save))
    end

    function Window:LoadConfig(folder, file)
        if not checkFS() then return end
        local path = folder.."/"..file..".json"
        if isfile(path) then
            local s, res = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
            if s and type(res) == "table" then
                for flag, val in pairs(res) do
                    if Window.Flags[flag] then Window.Flags[flag].Set(val) end
                end
            end
        end
    end

    function Window:CreateTab(name, icon)
        local TabBtn = create("TextButton", {
            Parent = TabContainer, 
            Size = UDim2.new(0, 0, 1, -8), 
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = AstraUI.Theme.Accent, 
            BackgroundTransparency = 1,
            Text = "", 
            AutoButtonColor = false
        })
        create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(1, 0)}) 
        create("UIPadding", {Parent = TabBtn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})
        
        create("UIListLayout", {
            Parent = TabBtn,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6)
        })

        local TabIcon
        if icon and icon ~= "" then
            TabIcon = create("ImageLabel", {
                Parent = TabBtn,
                Size = UDim2.new(0, 14, 0, 14),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = AstraUI.Theme.SubText,
                LayoutOrder = 1
            })
        end
        
        local TabText = create("TextLabel", {
            Parent = TabBtn,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = AstraUI.Theme.SubText,
            LayoutOrder = 2
        })

        local ContentScroll = create("ScrollingFrame", {
            Parent = ContentContainer, 
            Size = UDim2.new(1, 0, 1, 0), 
            BackgroundTransparency = 1, 
            ScrollBarThickness = 2, 
            ScrollBarImageColor3 = AstraUI.Theme.Accent, 
            Visible = false, 
            AutomaticCanvasSize = Enum.AutomaticSize.Y, 
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        create("UIPadding", {Parent = ContentScroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10)})
        create("UIListLayout", {Parent = ContentScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

        TabBtn.MouseEnter:Connect(function() 
            if Window.CurrentTab ~= name then 
                tween(TabText, {TextColor3 = AstraUI.Theme.Text}) 
                if TabIcon then tween(TabIcon, {ImageColor3 = AstraUI.Theme.Text}) end
            end 
        end)
        TabBtn.MouseLeave:Connect(function() 
            if Window.CurrentTab ~= name then 
                tween(TabText, {TextColor3 = AstraUI.Theme.SubText}) 
                if TabIcon then tween(TabIcon, {ImageColor3 = AstraUI.Theme.SubText}) end
            end 
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for tName, tData in pairs(Window.Tabs) do
                tData.Content.Visible = false
                tween(tData.Btn, {BackgroundTransparency = 1})
                tween(tData.Text, {TextColor3 = AstraUI.Theme.SubText})
                if tData.Icon then tween(tData.Icon, {ImageColor3 = AstraUI.Theme.SubText}) end
            end
            ContentScroll.Visible = true
            tween(TabBtn, {BackgroundTransparency = 0})
            tween(TabText, {TextColor3 = AstraUI.Theme.Main})
            if TabIcon then tween(TabIcon, {ImageColor3 = AstraUI.Theme.Main}) end
            Window.CurrentTab = name
        end)

        Window.Tabs[name] = {Btn = TabBtn, Text = TabText, Content = ContentScroll, Icon = TabIcon}

        if not Window.CurrentTab then 
            ContentScroll.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabText.TextColor3 = AstraUI.Theme.Main
            if TabIcon then TabIcon.ImageColor3 = AstraUI.Theme.Main end
            Window.CurrentTab = name
        end

        local Tab = {}
        
        function Tab:CreateSection(secName)
            local SecFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1})
            create("TextLabel", {Parent = SecFrame, Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = secName, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = AstraUI.Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left})
        end

        function Tab:CreateInput(iConfig)
            local InpFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = AstraUI.Theme.Container})
            create("UICorner", {Parent = InpFrame, CornerRadius = UDim.new(0, 6)})
            create("TextLabel", {Parent = InpFrame, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = iConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local TextBox = create("TextBox", {Parent = InpFrame, Size = UDim2.new(0.5, -20, 0, 30), Position = UDim2.new(0.5, 10, 0.5, -15), BackgroundColor3 = AstraUI.Theme.Element, Text = "", PlaceholderText = iConfig.Placeholder or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = AstraUI.Theme.Text, ClearTextOnFocus = false})
            create("UICorner", {Parent = TextBox, CornerRadius = UDim.new(0, 4)})
            
            TextBox.FocusLost:Connect(function()
                if iConfig.Callback then iConfig.Callback(TextBox.Text) end
            end)
        end

        function Tab:CreateToggle(tConfig)
            local TglFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = AstraUI.Theme.Container})
            create("UICorner", {Parent = TglFrame, CornerRadius = UDim.new(0, 6)})
            create("TextLabel", {Parent = TglFrame, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = tConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local TglBtn = create("TextButton", {Parent = TglFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
            local TglBg = create("Frame", {Parent = TglFrame, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = tConfig.CurrentValue and AstraUI.Theme.Accent or AstraUI.Theme.Element})
            create("UICorner", {Parent = TglBg, CornerRadius = UDim.new(1, 0)})
            local TglCirc = create("Frame", {Parent = TglBg, Size = UDim2.new(0, 16, 0, 16), Position = tConfig.CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = tConfig.CurrentValue and AstraUI.Theme.Main or AstraUI.Theme.Text})
            create("UICorner", {Parent = TglCirc, CornerRadius = UDim.new(1, 0)})

            local state = tConfig.CurrentValue or false
            
            local function updateToggle(newState)
                state = newState
                tween(TglBg, {BackgroundColor3 = state and AstraUI.Theme.Accent or AstraUI.Theme.Element})
                tween(TglCirc, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = state and AstraUI.Theme.Main or AstraUI.Theme.Text})
                if tConfig.Flag then Window.Flags[tConfig.Flag].Value = state end
                if tConfig.Callback then tConfig.Callback(state) end
            end

            if tConfig.Flag then 
                Window.Flags[tConfig.Flag] = { Value = state, Set = updateToggle }
            end

            TglBtn.MouseButton1Click:Connect(function()
                updateToggle(not state)
            end)
        end

        function Tab:CreateSlider(sConfig)
            local SldFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = AstraUI.Theme.Container})
            create("UICorner", {Parent = SldFrame, CornerRadius = UDim.new(0, 6)})
            local sVal = sConfig.CurrentValue or sConfig.Range[1]
            
            create("TextLabel", {Parent = SldFrame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = sConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            local ValLabel = create("TextLabel", {Parent = SldFrame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = tostring(sVal) .. (sConfig.Suffix and " " .. sConfig.Suffix or ""), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right})
            
            local SldBg = create("Frame", {Parent = SldFrame, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 1, -15), BackgroundColor3 = AstraUI.Theme.Element})
            create("UICorner", {Parent = SldBg, CornerRadius = UDim.new(1, 0)})
            local SldFill = create("Frame", {Parent = SldBg, Size = UDim2.new((sVal - sConfig.Range[1]) / (sConfig.Range[2] - sConfig.Range[1]), 0, 1, 0), BackgroundColor3 = AstraUI.Theme.Accent})
            create("UICorner", {Parent = SldFill, CornerRadius = UDim.new(1, 0)})
            local SldBtn = create("TextButton", {Parent = SldBg, Size = UDim2.new(1, 0, 1, 10), Position = UDim2.new(0, 0, 0, -5), BackgroundTransparency = 1, Text = ""})

            local function setSlider(value)
                value = math.clamp(value, sConfig.Range[1], sConfig.Range[2])
                local exactPos = (value - sConfig.Range[1]) / (sConfig.Range[2] - sConfig.Range[1])
                tween(SldFill, {Size = UDim2.new(exactPos, 0, 1, 0)}, 0.1)
                ValLabel.Text = tostring(value) .. (sConfig.Suffix and " " .. sConfig.Suffix or "")
                if sConfig.Flag then Window.Flags[sConfig.Flag].Value = value end
                if sConfig.Callback then sConfig.Callback(value) end
            end

            if sConfig.Flag then
                Window.Flags[sConfig.Flag] = { Value = sVal, Set = setSlider }
            end

            local draggingSld = false
            local function updateSld(input)
                local pos = math.clamp((input.Position.X - SldBg.AbsolutePosition.X) / SldBg.AbsoluteSize.X, 0, 1)
                local value = pos * (sConfig.Range[2] - sConfig.Range[1]) + sConfig.Range[1]
                value = math.floor(value / (sConfig.Increment or 1) + 0.5) * (sConfig.Increment or 1)
                setSlider(value)
            end

            SldBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSld = true updateSld(input) end
            end)
            SldBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSld = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSld and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSld(input) end
            end)
        end

        function Tab:CreateButton(bConfig)
            local BtnFrame = create("TextButton", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = AstraUI.Theme.Container, Text = "", AutoButtonColor = false})
            create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 6)})
            create("TextLabel", {Parent = BtnFrame, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = bConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            BtnFrame.MouseEnter:Connect(function() tween(BtnFrame, {BackgroundColor3 = AstraUI.Theme.Hover}) end)
            BtnFrame.MouseLeave:Connect(function() tween(BtnFrame, {BackgroundColor3 = AstraUI.Theme.Container}) end)
            BtnFrame.MouseButton1Down:Connect(function() tween(BtnFrame, {BackgroundColor3 = AstraUI.Theme.Element}) end)
            BtnFrame.MouseButton1Up:Connect(function() tween(BtnFrame, {BackgroundColor3 = AstraUI.Theme.Hover}) if bConfig.Callback then bConfig.Callback() end end)
        end

        function Tab:CreateLabel(text)
            local LblFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = AstraUI.Theme.Container})
            create("UICorner", {Parent = LblFrame, CornerRadius = UDim.new(0, 6)})
            create("TextLabel", {Parent = LblFrame, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left})
        end

        function Tab:CreateDropdown(dConfig)
            local DropdownFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = AstraUI.Theme.Container, ClipsDescendants = true})
            create("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0, 6)})
            
            local DropdownBtn = create("TextButton", {Parent = DropdownFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = ""})
            create("TextLabel", {Parent = DropdownFrame, Size = UDim2.new(0.5, 0, 0, 40), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = dConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local SelectedLabel = create("TextLabel", {Parent = DropdownFrame, Size = UDim2.new(0.5, -40, 0, 40), Position = UDim2.new(0.5, 10, 0, 0), BackgroundTransparency = 1, Text = dConfig.CurrentOption or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = AstraUI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right})
            local DropdownIcon = create("TextLabel", {Parent = DropdownFrame, Size = UDim2.new(0, 20, 0, 40), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Text = "+", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.SubText})
            
            local OptionsContainer = create("Frame", {Parent = DropdownFrame, Size = UDim2.new(1, -20, 1, -45), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1})
            local OptionsLayout = create("UIListLayout", {Parent = OptionsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
            
            local isOpen = false
            local optionsCount = dConfig.Options and #dConfig.Options or 0
            local dropdownOpenHeight = 40 + (optionsCount * 34) + 5
            
            DropdownBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                DropdownIcon.Text = isOpen and "-" or "+"
                tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, isOpen and dropdownOpenHeight or 40)}, 0.2)
            end)

            local currentOption = dConfig.CurrentOption
            local function setOption(opt)
                currentOption = opt
                SelectedLabel.Text = opt
                if dConfig.Flag then Window.Flags[dConfig.Flag].Value = opt end
                if dConfig.Callback then dConfig.Callback(opt) end
            end

            if dConfig.Flag then Window.Flags[dConfig.Flag] = { Value = currentOption, Set = setOption } end
            
            local function BuildOptions(options)
                for _, child in ipairs(OptionsContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local OptBtn = create("TextButton", {Parent = OptionsContainer, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = AstraUI.Theme.Element, Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = AstraUI.Theme.Text, AutoButtonColor = false})
                    create("UICorner", {Parent = OptBtn, CornerRadius = UDim.new(0, 4)})
                    OptBtn.MouseEnter:Connect(function() tween(OptBtn, {BackgroundColor3 = AstraUI.Theme.Hover}) end)
                    OptBtn.MouseLeave:Connect(function() tween(OptBtn, {BackgroundColor3 = AstraUI.Theme.Element}) end)
                    OptBtn.MouseButton1Click:Connect(function()
                        setOption(opt)
                        isOpen = false
                        DropdownIcon.Text = "+"
                        tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
                    end)
                end
                optionsCount = #options
                dropdownOpenHeight = 40 + (optionsCount * 34) + 5
                if isOpen then DropdownFrame.Size = UDim2.new(1, 0, 0, dropdownOpenHeight) end
            end
            
            if dConfig.Options then BuildOptions(dConfig.Options) end
            return { Refresh = function(newOptions) BuildOptions(newOptions) end }
        end

        function Tab:CreateMultiDropdown(dConfig)
            local DropdownFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = AstraUI.Theme.Container, ClipsDescendants = true})
            create("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0, 6)})
            
            local DropdownBtn = create("TextButton", {Parent = DropdownFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = ""})
            create("TextLabel", {Parent = DropdownFrame, Size = UDim2.new(0.5, 0, 0, 40), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = dConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local selected = dConfig.CurrentOptions or {}
            local function getLabelText() return #selected == 0 and "None" or table.concat(selected, ", ") end

            local SelectedLabel = create("TextLabel", {Parent = DropdownFrame, Size = UDim2.new(0.5, -40, 0, 40), Position = UDim2.new(0.5, 10, 0, 0), BackgroundTransparency = 1, Text = getLabelText(), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = AstraUI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd})
            local DropdownIcon = create("TextLabel", {Parent = DropdownFrame, Size = UDim2.new(0, 20, 0, 40), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Text = "+", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.SubText})
            
            local OptionsContainer = create("Frame", {Parent = DropdownFrame, Size = UDim2.new(1, -20, 1, -45), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1})
            local OptionsLayout = create("UIListLayout", {Parent = OptionsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
            
            local isOpen = false
            local optionsCount = dConfig.Options and #dConfig.Options or 0
            local dropdownOpenHeight = 40 + (optionsCount * 34) + 5
            
            DropdownBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                DropdownIcon.Text = isOpen and "-" or "+"
                tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, isOpen and dropdownOpenHeight or 40)}, 0.2)
            end)

            local function setOptions(newSelected)
                selected = newSelected
                SelectedLabel.Text = getLabelText()
                if dConfig.Flag then Window.Flags[dConfig.Flag].Value = selected end
                if dConfig.Callback then dConfig.Callback(selected) end
            end

            if dConfig.Flag then Window.Flags[dConfig.Flag] = { Value = selected, Set = setOptions } end
            
            local function BuildOptions(options)
                for _, child in ipairs(OptionsContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for i, opt in ipairs(options) do
                    local isSelected = table.find(selected, opt) ~= nil
                    local OptBtn = create("TextButton", {Parent = OptionsContainer, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = isSelected and AstraUI.Theme.Hover or AstraUI.Theme.Element, Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = AstraUI.Theme.Text, AutoButtonColor = false})
                    create("UICorner", {Parent = OptBtn, CornerRadius = UDim.new(0, 4)})
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        local idx = table.find(selected, opt)
                        if idx then table.remove(selected, idx) else table.insert(selected, opt) end
                        tween(OptBtn, {BackgroundColor3 = table.find(selected, opt) and AstraUI.Theme.Hover or AstraUI.Theme.Element})
                        setOptions(selected)
                    end)
                end
                optionsCount = #options
                dropdownOpenHeight = 40 + (optionsCount * 34) + 5
                if isOpen then DropdownFrame.Size = UDim2.new(1, 0, 0, dropdownOpenHeight) end
            end
            
            if dConfig.Options then BuildOptions(dConfig.Options) end
            return { Refresh = function(newOptions) BuildOptions(newOptions) end }
        end

        function Tab:CreateColorPicker(cConfig)
            local CPFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = AstraUI.Theme.Container, ClipsDescendants = true})
            create("UICorner", {Parent = CPFrame, CornerRadius = UDim.new(0, 6)})
            
            local CPBtn = create("TextButton", {Parent = CPFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = ""})
            create("TextLabel", {Parent = CPFrame, Size = UDim2.new(0.5, 0, 0, 40), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = cConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local currentColor = cConfig.Color or Color3.fromRGB(1, 1, 1)
            local ColorDisplay = create("Frame", {Parent = CPFrame, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -34, 0, 8), BackgroundColor3 = currentColor})
            create("UICorner", {Parent = ColorDisplay, CornerRadius = UDim.new(0, 4)})

            local SlidersContainer = create("Frame", {Parent = CPFrame, Size = UDim2.new(1, -20, 0, 100), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1})
            create("UIListLayout", {Parent = SlidersContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})

            local isOpen = false
            CPBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                tween(CPFrame, {Size = UDim2.new(1, 0, 0, isOpen and 145 or 40)}, 0.2)
            end)

            local function setColor(c)
                currentColor = c
                ColorDisplay.BackgroundColor3 = c
                if cConfig.Flag then Window.Flags[cConfig.Flag].Value = {R = c.R*255, G = c.G*255, B = c.B*255} end
                if cConfig.Callback then cConfig.Callback(c) end
            end

            if cConfig.Flag then
                Window.Flags[cConfig.Flag] = { Value = {R = currentColor.R*255, G = currentColor.G*255, B = currentColor.B*255}, Set = function(val) setColor(Color3.fromRGB(val.R, val.G, val.B)) end }
            end

            local channels = {{"Red", currentColor.R, Color3.fromRGB(255,0,0)}, {"Green", currentColor.G, Color3.fromRGB(0,255,0)}, {"Blue", currentColor.B, Color3.fromRGB(0,0,255)}}
            local sliderValues = {R = currentColor.R, G = currentColor.G, B = currentColor.B}

            for _, ch in ipairs(channels) do
                local SldBg = create("Frame", {Parent = SlidersContainer, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = AstraUI.Theme.Element})
                create("UICorner", {Parent = SldBg, CornerRadius = UDim.new(0, 4)})
                local SldFill = create("Frame", {Parent = SldBg, Size = UDim2.new(ch[2], 0, 1, 0), BackgroundColor3 = ch[3]})
                create("UICorner", {Parent = SldFill, CornerRadius = UDim.new(0, 4)})
                local SldTxt = create("TextLabel", {Parent = SldBg, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = ch[1] .. ": " .. math.floor(ch[2]*255), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
                local SldBtn = create("TextButton", {Parent = SldBg, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

                local dragging = false
                local function updateSld(input)
                    local pos = math.clamp((input.Position.X - SldBg.AbsolutePosition.X) / SldBg.AbsoluteSize.X, 0, 1)
                    tween(SldFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                    SldTxt.Text = ch[1] .. ": " .. math.floor(pos * 255)
                    sliderValues[string.sub(ch[1], 1, 1)] = pos
                    setColor(Color3.new(sliderValues.R, sliderValues.G, sliderValues.B))
                end

                SldBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true updateSld(input) end end)
                SldBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSld(input) end end)
            end
        end

        function Tab:CreateCard(cConfig)
            local CardFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = AstraUI.Theme.Container})
            create("UICorner", {Parent = CardFrame, CornerRadius = UDim.new(0, 8)})
            create("UIPadding", {Parent = CardFrame, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
            create("UIListLayout", {Parent = CardFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            
            if cConfig.Title and cConfig.Title ~= "" then
                create("TextLabel", {Parent = CardFrame, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = cConfig.Title, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = AstraUI.Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left})
            end
            
            if cConfig.Content and cConfig.Content ~= "" then
                create("TextLabel", {Parent = CardFrame, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = cConfig.Content, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = AstraUI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true})
            end
            
            local Card = {}
            function Card:Update(title, content)
                local titleLbl = CardFrame:FindFirstChildOfClass("TextLabel")
                if titleLbl and title then titleLbl.Text = title end
            end
            return Card
        end

        return Tab
    end

    function Window:Notify(nConfig)
        local NGui = targetGui:FindFirstChild("AstraNotify")
        if not NGui then
            NGui = create("ScreenGui", {Name = "AstraNotify", Parent = targetGui, ResetOnSpawn = false})
        end
        local NFrame = create("Frame", {Parent = NGui, Size = UDim2.new(0, 250, 0, 70), Position = UDim2.new(1, 10, 1, -80), BackgroundColor3 = AstraUI.Theme.Container})
        create("UICorner", {Parent = NFrame, CornerRadius = UDim.new(0, 6)})
        create("Frame", {Parent = NFrame, Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = AstraUI.Theme.Accent})
        create("TextLabel", {Parent = NFrame, Size = UDim2.new(1, -15, 0, 25), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = nConfig.Title or "Notification", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = AstraUI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        create("TextLabel", {Parent = NFrame, Size = UDim2.new(1, -15, 0, 30), Position = UDim2.new(0, 10, 0, 30), BackgroundTransparency = 1, Text = nConfig.Content or "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = AstraUI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
        
        local currentY = 10
        for _, v in pairs(NGui:GetChildren()) do
            if v ~= NFrame then tween(v, {Position = UDim2.new(1, -260, 1, -currentY - 80)}) currentY = currentY + 80 end
        end
        tween(NFrame, {Position = UDim2.new(1, -260, 1, -currentY - 70)})
        
        task.delay(nConfig.Duration or 3, function()
            tween(NFrame, {Position = UDim2.new(1, 10, 1, NFrame.Position.Y.Offset)})
            task.wait(0.3)
            NFrame:Destroy()
        end)
    end

    return Window
end

return AstraUI
