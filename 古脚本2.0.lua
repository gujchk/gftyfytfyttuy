--[[
古脚本 - 通用Roblox脚本中心
版本: 2.0
作者: 古脚本团队
兼容: Delta注入器、Synapse X、Script-Ware等主流注入器
GitHub: https://github.com/yourusername/guscript

功能说明:
- 玩家功能: 步行速度、跳跃高度、重力设置、夜视、透视、隐身道具、穿墙
- 通用功能: 最强透视、飞行、甩人、反挂机、铁拳、键盘、动画中心等
- ESP功能: 人物显示
- 其他功能: 死亡笔记等

使用方法:
1. 使用Delta注入器或其他兼容的注入器
2. 复制整个脚本内容
3. 在Roblox游戏中执行脚本
4. 打开/关闭UI界面：
   - 电脑端：使用RightShift键
   - 手机端：点击屏幕右上角的开关按钮（☰图标）

注意事项:
- 部分功能需要特定游戏环境
- 使用前请确保注入器已正确配置
- 建议在单人游戏或测试环境中使用
--]]
function initLibrary()
    local folderName = "古脚本配置文件夹"

    -- Delta注入器兼容性检查
    if isfolder and makefolder then
        if not isfolder(folderName) then
            makefolder(folderName)
        end

        local gameConfigFolder = folderName .. "/" .. game.PlaceId

        if not isfolder(gameConfigFolder) then
            makefolder(gameConfigFolder)
        end
    end

    local inputService = game:GetService("UserInputService")
    local tweenService = game:GetService("TweenService")
    local runService = game:GetService("RunService")
    local coreGui = game:GetService("CoreGui")

    local utility = {}

    function utility.create(class, properties)
        properties = properties or {}

        local obj = Instance.new(class)

        local forcedProperties = {
            AutoButtonColor = false
        }

        -- 先设置强制属性，然后用户属性可以覆盖它们
        for prop, v in pairs(forcedProperties) do
            local success = pcall(function()
                obj[prop] = v
            end)
            -- 可以选择性地处理错误
        end

        -- 然后设置用户提供的属性
        for prop, v in pairs(properties) do
            local success = pcall(function()
                obj[prop] = v
            end)
            -- 可以选择性地处理错误
        end
        
        return obj
    end

    function utility.change_color(color, amount)
        local r = math.clamp(math.floor(color.r * 255) + amount, 0, 255)
        local g = math.clamp(math.floor(color.g * 255) + amount, 0, 255)
        local b = math.clamp(math.floor(color.b * 255) + amount, 0, 255)

        return Color3.fromRGB(r, g, b)
    end

    function utility.get_rgb(color)
        local r = math.floor(color.r * 255)
        local g = math.floor(color.g * 255)
        local b = math.floor(color.b * 255)

        return r, g, b
    end

    function utility.tween(obj, info, properties, callback)
        local anim = tweenService:Create(obj, TweenInfo.new(unpack(info)), properties)
        anim:Play()

        if callback then
            anim.Completed:Connect(callback)
        end
    end

    function utility.drag(obj, dragSpeed)
        local start, objPosition, dragging
        local connection
        local originalTransparency = obj.BackgroundTransparency or 0

        -- 支持鼠标和触摸设备
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                start = input.Position
                objPosition = obj.Position
                
                -- 拖拽时的视觉反馈（稍微降低不透明度，让用户知道正在拖拽）
                local currentTransparency = obj.BackgroundTransparency or 0
                if currentTransparency < 0.5 then
                    utility.tween(obj, {0.1}, {BackgroundTransparency = math.min(currentTransparency + 0.1, 0.3)})
                end
            end
        end)

        obj.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                dragging = false
                
                -- 恢复原始透明度
                utility.tween(obj, {0.1}, {BackgroundTransparency = originalTransparency})
            end
        end)

        -- 直接更新位置，避免tween的性能开销（支持鼠标和触摸）
        inputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - start
                local newX = objPosition.X.Offset + delta.X
                local newY = objPosition.Y.Offset + delta.Y
                
                -- 边界限制，防止窗口移出屏幕
                local screenSize = game:GetService("CoreGui").AbsoluteSize
                local objSize = obj.AbsoluteSize
                newX = math.clamp(newX, 0, screenSize.X - objSize.X)
                newY = math.clamp(newY, 0, screenSize.Y - objSize.Y)
                
                obj.Position = UDim2.new(
                    objPosition.X.Scale, newX,
                    objPosition.Y.Scale, newY
                )
            end
        end)
    end

    function utility.get_center(sizeX, sizeY)
        return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
    end

    function utility.hex_to_rgb(hex)
        -- 验证输入格式
        if type(hex) ~= "string" then
            return Color3.fromRGB(0, 0, 0)
        end
        
        -- 移除可能的空格
        hex = hex:gsub("%s", "")
        
        -- 如果是3位颜色代码，转换为6位
        if hex:match("^#[0-9A-Fa-f]{3}$") then
            hex = hex:gsub("#([0-9A-Fa-f])([0-9A-Fa-f])([0-9A-Fa-f])", "#%1%1%2%2%3%3")
        end
        
        -- 确保是有效的6位十六进制颜色代码
        local r, g, b = hex:match("^#[0-9A-Fa-f]([0-9A-Fa-f])([0-9A-Fa-f])([0-9A-Fa-f])[0-9A-Fa-f][0-9A-Fa-f]$")
        
        if r and g and b then
            return Color3.fromRGB(tonumber("0x" .. r .. r), tonumber("0x" .. g .. g), tonumber("0x" .. b .. b))
        end
        
        -- 默认返回黑色
        return Color3.fromRGB(0, 0, 0)
    end

    function utility.rgb_to_hex(color)
        return string.format("#%02X%02X%02X", math.clamp(color.R * 255, 0, 255), math.clamp(color.G * 255, 0, 255), math.clamp(color.B * 255, 0, 255))
    end

    function utility.table(tbl)
        local oldtbl = tbl or {}
        local newtbl = {}
        local formattedtbl = {}

        for option, v in next, oldtbl do
            newtbl[option:lower()] = v
        end

        setmetatable(formattedtbl, {
            __newindex = function(t, k, v)
                rawset(newtbl, k:lower(), v)
            end,
            __index = function(t, k, v)
                return newtbl[k:lower()]
            end
        })

        return formattedtbl
    end

    local library = utility.table{
        flags = {}, 
        toggled = true,
        color = Color3.fromRGB(100, 50, 200),  -- 紫色主题色
        keybind = Enum.KeyCode.RightShift, 
        dragSpeed = 0.1
    }    

    local coloredGradients = {}

    function library:SetColor(color)
        for _, obj in next, coloredGradients do
            obj.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, utility.change_color(color, -49))
            }
        end

        library.color = color
    end

    local gui = utility.create("ScreenGui")

    -- 键盘快捷键（与按钮状态同步）
    inputService.InputBegan:Connect(function(input)
        if input.KeyCode == library.keybind then
            library.toggled = not library.toggled
            gui.Enabled = library.toggled
            if library.updateToggleButton then
                library.updateToggleButton(library.toggled)
            end
        end
    end)

    -- Delta注入器及其他注入器兼容性处理
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif protect_gui then
        protect_gui(gui)
    end

    gui.Parent = coreGui

    -- 创建手机端开关按钮（始终可见）
    local toggleButtonGui = utility.create("ScreenGui", {
        Name = "古脚本开关按钮",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Delta注入器兼容性处理
    if syn and syn.protect_gui then
        syn.protect_gui(toggleButtonGui)
    elseif protect_gui then
        protect_gui(toggleButtonGui)
    end
    
    toggleButtonGui.Parent = coreGui
    
    -- 开关按钮容器（手机端优化：更大尺寸，更容易点击，可移动）
    local toggleButton = utility.create("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 70, 0, 70),  -- 增大尺寸，方便手机点击
        Position = UDim2.new(1, -80, 0, 10),  -- 右上角位置
        BackgroundColor3 = Color3.fromRGB(60, 30, 100),  -- 紫色主题
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(100, 50, 200),  -- 亮紫色边框
        Text = "",
        ZIndex = 1000,
        Parent = toggleButtonGui
    })
    
    -- 按钮拖拽功能（手机端可移动）
    local buttonDragging = false
    local buttonStartPos = nil
    local buttonStartMousePos = nil
    local buttonHasMoved = false  -- 检测是否移动，避免与点击冲突
    
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            buttonDragging = true
            buttonHasMoved = false
            buttonStartPos = toggleButton.Position
            buttonStartMousePos = input.Position
        end
    end)
    
    toggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- 如果没有移动，则执行点击操作
            if not buttonHasMoved then
                library.toggled = not library.toggled
                gui.Enabled = library.toggled
                library.updateToggleButton(library.toggled)
            end
            buttonDragging = false
            buttonHasMoved = false
        end
    end)
    
    inputService.InputChanged:Connect(function(input)
        if buttonDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - buttonStartMousePos
            -- 如果移动距离超过5像素，认为是拖拽
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                buttonHasMoved = true
                local newX = math.clamp(buttonStartPos.X.Offset + delta.X, 0, game:GetService("CoreGui").AbsoluteSize.X - 70)
                local newY = math.clamp(buttonStartPos.Y.Offset + delta.Y, 0, game:GetService("CoreGui").AbsoluteSize.Y - 70)
                toggleButton.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    
    -- 按钮圆角
    local corner = utility.create("UICorner", {
        CornerRadius = UDim.new(0, 15),
        Parent = toggleButton
    })
    
    -- 按钮边框（使用兼容方式）
    local border = nil
    local success, result = pcall(function()
        border = utility.create("UIStroke", {
            Color = Color3.fromRGB(255, 0, 0),
            Thickness = 2,
            Parent = toggleButton
        })
        return border
    end)
    if not success then
        -- 如果不支持UIStroke，使用BorderColor3
        toggleButton.BorderSizePixel = 2
        toggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    end
    
    -- 按钮发光效果背景
    local glowFrame = utility.create("Frame", {
        Name = "Glow",
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        BackgroundColor3 = Color3.fromRGB(100, 50, 200),
        BackgroundTransparency = 0.7,
        ZIndex = 999,
        Parent = toggleButton
    })
    
    local glowGradient = utility.create("UIGradient", {
        Rotation = 45,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 200))
        },
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0.8)
        },
        Parent = glowFrame
    })
    
    local glowCorner = utility.create("UICorner", {
        CornerRadius = UDim.new(0, 20),
        Parent = glowFrame
    })
    
    -- 按钮图标（显示"菜单"或"关闭"）
    local icon = utility.create("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "☰",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 32,
        Font = Enum.Font.GothamBold,
        ZIndex = 1001,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.fromRGB(100, 50, 200),
        Parent = toggleButton
    })
    
    -- 按钮背景渐变（更漂亮的渐变）
    local buttonGradient = utility.create("UIGradient", {
        Rotation = 135,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 70, 220)),  -- 亮紫色
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 50, 200)),  -- 紫色
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(60, 30, 100)),  -- 深紫色
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 200))    -- 蓝紫色
        },
        Parent = toggleButton
    })
    
    -- 按钮内部高光效果
    local highlight = utility.create("Frame", {
        Name = "Highlight",
        Size = UDim2.new(1, -4, 0.5, 0),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 0.8,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 1002,
        Parent = toggleButton
    })
    
    local highlightCorner = utility.create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = highlight
    })
    
    local highlightGradient = utility.create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        },
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.7),
            NumberSequenceKeypoint.new(1, 1)
        },
        Parent = highlight
    })
    
    -- 按钮状态更新函数（存储在library中以便全局访问）
    library.updateToggleButton = function(isVisible)
        if isVisible then
            icon.Text = "✕"
            toggleButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)  -- 亮紫色
            if border then
                border.Color = Color3.fromRGB(150, 100, 255)  -- 更亮的紫色
                border.Thickness = 3
            else
                toggleButton.BorderColor3 = Color3.fromRGB(150, 100, 255)
                toggleButton.BorderSizePixel = 3
            end
            -- 更新发光效果
            utility.tween(glowFrame, {0.3}, {
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1, 15, 1, 15),
                Position = UDim2.new(0, -7.5, 0, -7.5)
            })
        else
            icon.Text = "☰"
            toggleButton.BackgroundColor3 = Color3.fromRGB(60, 30, 100)  -- 深紫色
            if border then
                border.Color = Color3.fromRGB(100, 50, 200)  -- 紫色边框
                border.Thickness = 2
            else
                toggleButton.BorderColor3 = Color3.fromRGB(100, 50, 200)
                toggleButton.BorderSizePixel = 2
            end
            -- 更新发光效果
            utility.tween(glowFrame, {0.3}, {
                BackgroundTransparency = 0.7,
                Size = UDim2.new(1, 10, 1, 10),
                Position = UDim2.new(0, -5, 0, -5)
            })
        end
    end
    
    -- 初始状态
    library.updateToggleButton(library.toggled)
    
    -- 按钮点击事件（仅用于鼠标，触摸设备使用InputEnded处理）
    toggleButton.MouseButton1Click:Connect(function()
        if not buttonHasMoved then
            library.toggled = not library.toggled
            gui.Enabled = library.toggled
            library.updateToggleButton(library.toggled)
        end
    end)
    
    -- 按钮按下效果（手机端优化）
    toggleButton.MouseButton1Down:Connect(function()
        utility.tween(toggleButton, {0.1}, {Size = UDim2.new(0, 65, 0, 65)})
    end)
    
    toggleButton.MouseButton1Up:Connect(function()
        utility.tween(toggleButton, {0.1}, {Size = UDim2.new(0, 70, 0, 70)})
    end)
    
    -- 触摸设备支持已通过InputEnded处理，无需TouchTap
    
    -- 按钮悬停效果（紫色主题）
    toggleButton.MouseEnter:Connect(function()
        utility.tween(toggleButton, {0.2}, {BackgroundColor3 = Color3.fromRGB(80, 40, 130)})
    end)
    
    toggleButton.MouseLeave:Connect(function()
        if library.toggled then
            utility.tween(toggleButton, {0.2}, {BackgroundColor3 = Color3.fromRGB(100, 50, 200)})
        else
            utility.tween(toggleButton, {0.2}, {BackgroundColor3 = Color3.fromRGB(60, 30, 100)})
        end
    end)
    
    -- 同步键盘快捷键状态（移除旧的，因为已经在上面处理了）

    local flags = {toggles = {}, boxes = {}, sliders = {}, dropdowns = {}, multidropdowns = {}, keybinds = {}, colorpickers = {}}

    function library:LoadConfig(file)
        if not readfile then
            warn("古脚本: 当前注入器不支持文件读取功能")
            return
        end
        local success, result = pcall(function()
            local str = readfile(gameConfigFolder .. "/" .. file .. ".cfg")
            local tbl = loadstring(str)()
            return tbl
        end)
        if not success then
            warn("古脚本: 加载配置失败 - " .. tostring(result))
            return
        end
        local tbl = result
        
        for flag, value in next, tbl.toggles do
            flags.toggles[flag](value)
        end

        for flag, value in next, tbl.boxes do
            flags.boxes[flag](value)
        end

        for flag, value in next, tbl.sliders do
            flags.sliders[flag](value)
        end

        for flag, value in next, tbl.dropdowns do
            flags.dropdowns[flag](value)
        end

        for flag, value in next, tbl.multidropdowns do
            flags.multidropdowns[flag](value)
        end

        for flag, value in next, tbl.keybinds do
            flags.keybinds[flag](value)
        end

        for flag, value in next, tbl.colorpickers do
            flags.colorpickers[flag](value)
        end
    end

    function library:SaveConfig(name)
        if not writefile then
            warn("古脚本: 当前注入器不支持文件写入功能")
            return
        end
        -- 使用table来构建配置，提高效率
        local configTable = {}
        
        -- 处理toggles
        local togglesTable = {}
        for flag, _ in next, flags.toggles do
            table.insert(togglesTable, string.format("['%s']=%s", flag, tostring(library.flags[flag])))
        end
        table.insert(configTable, string.format("toggles={%s}", table.concat(togglesTable, ",")))
        
        -- 处理boxes
        local configstr = "},boxes={"

        count = 0
        for flag, _ in next, flags.boxes do
            count = count + 1
            configstr = configstr .. "['" .. flag .. "']='" .. tostring(library.flags[flag]) .. "',"
        end

        configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},sliders={"

        count = 0
        for flag, _ in next, flags.sliders do
            count = count + 1
            configstr = configstr .. "['" .. flag .. "']=" .. tostring(library.flags[flag]) .. ","
        end

        configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},dropdowns={"

        count = 0
        for flag, _ in next, flags.dropdowns do
            count = count + 1
            configstr = configstr .. "['" .. flag .. "']='" .. tostring(library.flags[flag]) .. "',"
        end

        configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},multidropdowns={"

        count = 0
        for flag, _ in next, flags.multidropdowns do
            count = count + 1
            configstr = configstr .. "['" .. flag .. "']={['" .. table.concat(library.flags[flag], "', '") .. "']},"
        end

        configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},keybinds={"

        count = 0
        for flag, _ in next, flags.keybinds do
            count = count + 1
            configstr = configstr .. "['" .. flag .. "']=" .. tostring(library.flags[flag]) .. ","
        end

        configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},colorpickers={"

        count = 0
        for flag, _ in next, flags.colorpickers do
            count = count + 1
            configstr = configstr .. "['" .. flag .. "']=Color3.new(" .. tostring(library.flags[flag]) .. "),"
        end

        configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "}}"

        local success, err = pcall(function()
            writefile(gameConfigFolder .. "/" .. name .. ".cfg", "return " .. configstr)
        end)
        if not success then
            warn("古脚本: 保存配置失败 - " .. tostring(err))
        end
    end

    function library:Load(opts)
        local options = utility.table(opts)
        local name = options.name or "古脚本UI库"
        local sizeX = options.sizeX or 466
        local sizeY = options.sizeY or 350
        local color = options.color or Color3.fromRGB(255, 255, 255)
        local dragSpeed = options.dragSpeed or 0

        library.color = color

        local topbar = utility.create("Frame", {
            ZIndex = 2,
            Size = UDim2.new(0, sizeX, 0, 26),
            Position = utility.get_center(sizeX, sizeY),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(30, 15, 50),  -- 深紫色背景
            Parent = gui
        })
        
        -- 添加紫色/蓝色渐变背景
        local topbarGradient = utility.create("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 30, 100)),  -- 深紫色
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 100, 200)),  -- 蓝紫色
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 50))  -- 更深紫色
            },
            Parent = topbar
        })

        utility.drag(topbar, dragSpeed)

        utility.create("TextLabel", {
            ZIndex = 3,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            FontSize = Enum.FontSize.Size14,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = topbar
        })
        
        local main = utility.create("Frame", {
            Size = UDim2.new(1, 0, 0, sizeY),
            BorderColor3 = Color3.fromRGB(100, 50, 200),  -- 紫色边框
            BackgroundColor3 = Color3.fromRGB(25, 12, 40),  -- 深紫色背景
            Parent = topbar
        })
        
        -- 主背景渐变
        local mainGradient = utility.create("UIGradient", {
            Rotation = 45,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 70)),  -- 紫色
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 60, 120)),  -- 蓝紫色
                ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 12, 40))  -- 深紫色
            },
            Parent = main
        })

        local tabs = utility.create("Frame", {
            ZIndex = 2,
            Size = UDim2.new(1, -8, 1, -64),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 4, 0, 58),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = main
        })
        
        local tabToggles = utility.create("Frame", {
            ZIndex = 2,
            Size = UDim2.new(1, 0, 0, 26),
            BorderColor3 = Color3.fromRGB(100, 50, 200),  -- 紫色边框
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = Color3.fromRGB(35, 18, 60),  -- 深紫色背景
            Parent = main
        })
        
        -- 标签栏渐变
        local tabTogglesGradient = utility.create("UIGradient", {
            Rotation = 0,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 25, 90)),  -- 紫色
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 18, 60))  -- 深紫色
            },
            Parent = tabToggles
        })

        local tabTogglesHolder = utility.create("Frame", {
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            Parent = tabToggles
        })

        utility.create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            Parent = tabTogglesHolder
        })

        local windowTypes = utility.table({count = 0})

        function windowTypes:Show()
            library.toggled = true
            gui.Enabled = true
            if library.updateToggleButton then
                library.updateToggleButton(true)
            end
        end

        function windowTypes:Hide()
            library.toggled = false
            gui.Enabled = false
            if library.updateToggleButton then
                library.updateToggleButton(false)
            end
        end

        function windowTypes:Tab(name)
            windowTypes.count = windowTypes.count + 1
            name = name or "标签"

            local toggled = windowTypes.count == 1

            local tabToggle = utility.create("TextButton", {
                ZIndex = 3,
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                FontSize = Enum.FontSize.Size14,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = name,
                Font = toggled and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                Parent = tabTogglesHolder
            })
            
            tabToggle.Size = UDim2.new(0, tabToggle.TextBounds.X + 12, 1, 0)

            local tab = utility.create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Visible = toggled,
                Parent = tabs
            })
            
            local column1 = utility.create("ScrollingFrame", {
                Size = UDim2.new(0.5, -2, 1, 0),
                BackgroundTransparency = 1,
                Active = true,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Parent = tab
            })

            local column1List = utility.create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = column1
            })

            column1List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                column1.CanvasSize = UDim2.new(0, 0, 0, column1List.AbsoluteContentSize.Y)
            end)

            local column2 = utility.create("ScrollingFrame", {
                Size = UDim2.new(0.5, -2, 1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 2, 0, 0),
                Active = true,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                CanvasPosition = Vector2.new(0, 150),
                Parent = tab
            })

            local column2List = utility.create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = column2
            })

            column2List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                column2.CanvasSize = UDim2.new(0, 0, 0, column2List.AbsoluteContentSize.Y)
            end)

            local function openTab()
                for _, obj in next, tabTogglesHolder:GetChildren() do
                    if obj:IsA("TextButton") then
                        obj.Font = Enum.Font.Gotham
                    end
                end

                tabToggle.Font = Enum.Font.GothamSemibold

                for _, obj in next, tabs:GetChildren() do
                    obj.Visible = false
                end

                tab.Visible = true
            end

            tabToggle.MouseButton1Click:Connect(openTab)

            local tabTypes = utility.table()

            function tabTypes:Open()
                openTab()
            end
        
            function tabTypes:Section(opts)
                local options = utility.table(opts)
                local name = options.name or "分区"
                local column = options.column or 1
                
                local columnFrame = column == 1 and column1 or column == 2 and column2
                
                local sectionHolder = utility.create("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = columnFrame
                })
                
                local section = utility.create("Frame", {
                    ZIndex = 2,
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderColor3 = Color3.fromRGB(100, 50, 200),  -- 紫色边框
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = Color3.fromRGB(30, 15, 50),  -- 深紫色背景
                    Parent = sectionHolder
                })
                
                -- Section背景渐变
                local sectionGradient = utility.create("UIGradient", {
                    Rotation = 135,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 70)),  -- 紫色
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 50))  -- 深紫色
                    },
                    Parent = section
                })
                
                local sectionTopbar = utility.create("Frame", {
                    ZIndex = 3,
                    Size = UDim2.new(1, 0, 0, 24),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(50, 25, 90),  -- 紫色顶部栏
                    Parent = section
                })
                
                -- Section顶部栏渐变
                local sectionTopbarGradient = utility.create("UIGradient", {
                    Rotation = 0,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 30, 100)),  -- 亮紫色
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 25, 90))  -- 紫色
                    },
                    Parent = sectionTopbar
                })

                utility.create("TextLabel", {
                    ZIndex = 3,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    FontSize = Enum.FontSize.Size14,
                    TextSize = 13,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = name,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sectionTopbar
                })

                local sectionContent = utility.create("Frame", {
                    Size = UDim2.new(1, -12, 1, -36),
                    Position = UDim2.new(0, 6, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = section
                })
                
                local sectionContentList = utility.create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    Parent = sectionContent
                })

                sectionContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    sectionHolder.Size = UDim2.new(1, 0, 0, sectionContentList.AbsoluteContentSize.Y + 38)
                end)

                local sectionTypes = utility.table()

                function sectionTypes:Show()
                    sectionHolder.Visible = true
                end

                function sectionTypes:Hide()
                    sectionHolder.Visible = false
                end

                function sectionTypes:Label(text)
                    local label = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 0, 14),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        Text = text,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = sectionContent
                    })

                    local labelTypes = utility.table()

                    function labelTypes:Show()
                        label.Visible = true
                    end

                    function labelTypes:Hide()
                        label.Visible = false
                    end

                    function labelTypes:Set(str)
                        label.Text = str
                    end

                    return labelTypes
                end

                function sectionTypes:SpecialLabel(text)
                    local specialLabel = utility.create("TextLabel", {
                        ZIndex = 5,
                        Size = UDim2.new(1, 0, 0, 14),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        Text = text,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.Gotham,
                        Parent = sectionContent
                    })

                    utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0.5, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = specialLabel
                    })
                    
                    local lineBlock = utility.create("Frame", {
                        ZIndex = 4,
                        Size = UDim2.new(0, specialLabel.TextBounds.X + 6, 0, 1),
                        Position = UDim2.new(0.5, -((specialLabel.TextBounds.X + 6) / 2), 0.5, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
                        Parent = specialLabel
                    })

                    specialLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                        lineBlock.Size = UDim2.new(0, specialLabel.TextBounds.X + 6, 0, 1)
                        lineBlock.Position = UDim2.new(0.5, -((specialLabel.TextBounds.X + 6) / 2), 0.5, 1)
                    end)

                    local specialLabelTypes = utility.table()

                    function specialLabelTypes:Show()
                        specialLabel.Visible = true
                    end

                    function specialLabelTypes:Hide()
                        specialLabel.Visible = false
                    end

                    function specialLabelTypes:Set(str)
                        specialLabel.Text = str
                    end

                    return specialLabelTypes
                end

                function sectionTypes:Button(opts)
                    local options = utility.table(opts)
                    local name = options.name
                    local callback = options.callback

                    local button = utility.create("TextButton", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Font = Enum.Font.Gotham,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Text = "",
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = sectionContent
                    })
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                        },
                        Parent = button
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 4,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = button
                    })

                    local buttonTypes = utility.table()

                    button.MouseButton1Click:Connect(function()
                        callback(buttonTypes)
                    end)

                    function buttonTypes:Show()
                        button.Visible = true
                    end
                    
                    function buttonTypes:Hide()
                        button.Visible = false
                    end
                    
                    function buttonTypes:SetName(str)
                        title.Text = str
                    end

                    function buttonTypes:SetCallback(func)
                        callback = func
                    end
                    
                    return buttonTypes
                end

                function sectionTypes:Toggle(opts)
                    local options = utility.table(opts)
                    local name = options.name or "开关"
                    local flag = options.flag 
                    local callback = options.callback or function() end

                    local toggled = false

                    if flag then
                        library.flags[flag] = toggled
                    end

                    callback(toggled)

                    local toggle = utility.create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = sectionContent
                    })
                    
                    local icon = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 14, 1, -2),
                        BorderColor3 = Color3.fromRGB(37, 37, 37),
                        Position = UDim2.new(0, 0, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = toggle
                    })

                    local iconGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                        },
                        Parent = icon
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 7, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = icon
                    })

                    local function toggleToggle()
                        toggled = not toggled

                        if toggled then
                            table.insert(coloredGradients, iconGradient)
                        else
                            table.remove(coloredGradients, table.find(coloredGradients, iconGradient))
                        end

                        local textColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                        local gradientColor
                        if toggled then
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, library.color), 
                                ColorSequenceKeypoint.new(1, utility.change_color(library.color, -47))
                            }
                        else
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                            }
                        end

                        iconGradient.Color = gradientColor
                        title.TextColor3 = textColor

                        if flag then
                            library.flags[flag] = toggled
                        end

                        callback(toggled)
                    end

                    toggle.MouseButton1Click:Connect(toggleToggle)

                    local toggleTypes = utility.table()

                    function toggleTypes:Show()
                        toggle.Visible = true
                    end
                    
                    function toggleTypes:Hide()
                        toggle.Visible = false
                    end
                    
                    function toggleTypes:SetName(str)
                        title.Text = str
                    end

                    function toggleTypes:Toggle(bool)
                        if toggled ~= bool then
                            toggleToggle()
                        end
                    end

                    if flag then
                        flags.toggles[flag] = function(bool)
                            if toggled ~= bool then
                                toggleToggle()
                            end
                        end
                    end

                    return toggleTypes
                end

                function sectionTypes:Box(opts)
                    local options = utility.table(opts)
                    local name = options.name or "输入框"
                    local placeholder = options.placeholder or "输入框"
                    local default = options.default or ""
                    local boxType = options.type or "string"
                    local flag = options.flag
                    local callback = options.callback or function() end

                    boxType = boxType:lower()

                    if boxType == "number" then
                        default = default:gsub("%D+", "")

                        if flag then
                            library.flags[flag] = tonumber(default)
                        end
        
                        callback(tonumber(default))
                    else
                        if flag then
                            library.flags[flag] = default
                        end

                        callback(default)
                    end

                    local boxHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectionContent
                    })
                    
                    local box = utility.create("TextBox", {
                        ZIndex = 4,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 1, -16),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = default,
                        Font = Enum.Font.Gotham,
                        PlaceholderText = placeholder,
                        Parent = boxHolder
                    })

                    local bg = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = box
                    })

                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = bg
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 0, 16),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = boxHolder
                    })

                    box:GetPropertyChangedSignal("Text"):Connect(function()
                        if boxType == "number" then
                            box.Text = box.Text:gsub("%D+", "")
                        end
                    end)

                    local boxTypes = utility.table()

                    function boxTypes:Show()
                        boxHolder.Visible = true
                    end
                    
                    function boxTypes:Hide()
                        boxHolder.Visible = false
                    end
                    
                    function boxTypes:SetName(str)
                        title.Text = str
                    end

                    function boxTypes:SetPlaceholder(str)
                        box.PlaceholderText = str
                    end

                    function boxTypes:Set(str)
                        if boxType == "string" then
                            box.Text = str

                            if flag then
                                library.flags[flag] = str
                            end

                            callback(str)
                        else
                            str = str:gsub("%D+", "")
                            box.Text = str

                            if flag then
                                library.flags[flag] = str
                            end

                            callback(tonumber(str))
                        end
                    end

                    box.FocusLost:Connect(function()
                        boxTypes:Set(box.Text)
                    end)

                    function boxTypes:SetType(str)
                        if str:lower() == "number" or str:lower() == "string" then
                            boxType = str:lower()
                        end
                    end

                    if flag then
                        flags.boxes[flag] = function(str)
                            if boxType == "string" then
                                box.Text = str

                                if flag then
                                    library.flags[flag] = str
                                end

                                callback(str)
                            else
                                str = str:gsub("%D+", "")
                                box.Text = str

                                if flag then
                                    library.flags[flag] = str
                                end

                                callback(tonumber(str))
                            end
                        end
                    end

                    return boxTypes
                end

                function sectionTypes:Slider(opts)
                    local options = utility.table(opts)
                    local min = options.min or 0
                    local max = options.max or 100
                    local valueText = options.valueText or "滑块: [VALUE]/" .. tostring(max)
                    local default = options.default or math.clamp(0, min, max)
                    local decimals = options.decimals or 0.1
                    local flag = options.flag
                    local callback = options.callback or function() end

                    decimals = math.floor(10^decimals)

                    if flag then
                        library.flags[flag] = default
                    end

                    callback(default)

                    local value = default

                    local sliding = false

                    local slider = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 1, -13),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectionContent
                    })
                    
                    local fill = utility.create("Frame", {
                        ZIndex = 4,
                        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = slider
                    })
                    
                    local fillGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, library.color), 
                            ColorSequenceKeypoint.new(1, utility.change_color(library.color, -47))
                        },
                        Parent = fill
                    })

                    table.insert(coloredGradients, fillGradient)
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                        },
                        Parent = slider
                    })

                    local title = utility.create("TextLabel", {
                        ZIndex = 5,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = valueText:gsub("%[VALUE%]", tostring(default)),
                        Font = Enum.Font.Gotham,
                        Parent = slider
                    })

                    local function slide(input)
                        local sizeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(sizeX, 0, 1, 0)

                        value = math.floor((((max - min) * sizeX) + min) * decimals) / decimals
                        title.Text = valueText:gsub("%[VALUE%]", tostring(value))

                        if flag then 
                            library.flags[flag] = value
                        end

                        callback(value)
                    end

                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            slide(input)
                        end
                    end)

                    slider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = false
                        end
                    end)

                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if sliding then
                                slide(input)
                            end
                        end
                    end)

                    local sliderTypes = utility.table()

                    function sliderTypes:Show()
                        slider.Visible = true
                    end

                    function sliderTypes:Hide()
                        slider.Visible = false
                    end

                    function sliderTypes:SetValueText(str)
                        valueText = str
                        title.Text = valueText:gsub("%[VALUE%]", tostring(value))
                    end

                    function sliderTypes:Set(num)
                        num = math.floor(math.clamp(num, min, max) * decimals) / decimals
                        value = num
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        
                        if flag then 
                            library.flags[flag] = value
                        end

                        callback(value)
                    end

                    function sliderTypes:SetMin(num)
                        min = num
                        value = math.floor(math.clamp(value, min, max) * decimals) / decimals
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)

                        if flag then 
                            library.flags[flag] = value
                        end

                        callback(value)
                    end

                    function sliderTypes:SetMax(num)
                        max = num
                        value = math.floor(math.clamp(value, min, max) * decimals) / decimals
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)

                        if flag then 
                            library.flags[flag] = value
                        end

                        callback(value)
                    end

                    if flag then
                        flags.sliders[flag] = function(num)
                            sliderTypes:Set(num)
                        end
                    end

                    return sliderTypes
                end

                function sectionTypes:ToggleSlider(opts)
                    local options = utility.table(opts)
                    local name = options.name or "开关滑块"
                    local min = options.min or 0
                    local max = options.max or 100
                    local valueText = options.valueText or "开关滑块: [VALUE]/" .. tostring(max)
                    local default = options.default or math.clamp(0, min, max)
                    local decimals = options.decimals or 0
                    local toggleFlag = options.toggleFlag
                    local sliderFlag = options.sliderFlag
                    local toggleCallback = options.toggleCallback or function() end
                    local sliderCallback = options.sliderCallback or function() end

                    decimals = math.floor(10^decimals)

                    local value = default
                    local toggled = false
                    local sliding = false

                    if sliderFlag then
                        library.flags[sliderFlag] = default
                    end

                    sliderCallback(default)

                    if toggleFlag then
                        library.flags[toggleFlag] = toggled
                    end

                    toggleCallback(toggled)

                    local toggleSliderHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectionContent
                    })
                    
                    local slider = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 1, -16),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = toggleSliderHolder
                    })
                    
                    local fill = utility.create("Frame", {
                        ZIndex = 4,
                        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = slider
                    })
                    
                    local fillGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, library.color), 
                            ColorSequenceKeypoint.new(1, utility.change_color(library.color, -47))
                        },
                        Parent = fill
                    })

                    table.insert(coloredGradients, fillGradient)
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = slider
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 5,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = valueText:gsub("%[VALUE%]", tostring(default)),
                        Font = Enum.Font.Gotham,
                        Parent = slider
                    })

                    local toggle = utility.create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = toggleSliderHolder
                    })
                    
                    local icon = utility.create("TextButton", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 14, 1, -2),
                        BorderColor3 = Color3.fromRGB(37, 37, 37),
                        Position = UDim2.new(0, 0, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Text = "",
                        Parent = toggle
                    })
                    
                    local iconGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                        },
                        Parent = icon
                    })
                    
                    local toggleTitle = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 7, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = icon
                    })

                    local function toggleToggle()
                        toggled = not toggled

                        if toggled then
                            table.insert(coloredGradients, iconGradient)
                        else
                            table.remove(coloredGradients, table.find(coloredGradients, iconGradient))
                        end

                        local textColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                        local gradientColor
                        if toggled then
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, library.color), 
                                ColorSequenceKeypoint.new(1, utility.change_color(library.color, -47))
                            }
                        else
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                            }
                        end

                        iconGradient.Color = gradientColor
                        toggleTitle.TextColor3 = textColor

                        if toggleFlag then
                            library.flags[toggleFlag] = toggled
                        end

                        toggleCallback(toggled)
                    end

                    toggle.MouseButton1Click:Connect(toggleToggle)

                    local function slide(input)
                        local sizeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(sizeX, 0, 1, 0)

                        value = math.floor((((max - min) * sizeX) + min) * decimals) / decimals
                        title.Text = valueText:gsub("%[VALUE%]", tostring(value))

                        if sliderFlag then 
                            library.flags[sliderFlag] = value
                        end

                        sliderCallback(value)
                    end

                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            slide(input)
                        end
                    end)

                    slider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = false
                        end
                    end)

                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if sliding then
                                slide(input)
                            end
                        end
                    end)

                    local toggleSliderTypes = utility.table()

                    function toggleSliderTypes:Show()
                        toggleSliderHolder.Visible = true
                    end

                    function toggleSliderTypes:Hide()
                        toggleSliderHolder.Visible = false
                    end

                    function toggleSliderTypes:SetValueText(str)
                        valueText = str
                        title.Text = valueText:gsub("%[VALUE%]", tostring(value))
                    end

                    function toggleSliderTypes:Set(num)
                        num = math.floor(math.clamp(num, min, max) * decimals) / decimals
                        value = num
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        title.Text = valueText:gsub("%[VALUE%]", tostring(value))
                        
                        if sliderFlag then 
                            library.flags[sliderFlag] = value
                        end

                        sliderCallback(value)
                    end

                    function toggleSliderTypes:SetMin(num)
                        min = num
                        value = math.floor(math.clamp(value, min, max) * decimals) / decimals
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        title.Text = valueText:gsub("%[VALUE%]", tostring(value))

                        if sliderFlag then 
                            library.flags[sliderFlag] = value
                        end

                        sliderCallback(value)
                    end

                    function toggleSliderTypes:SetMax(num)
                        max = num
                        value = math.floor(math.clamp(value, min, max) * decimals) / decimals
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        title.Text = valueText:gsub("%[VALUE%]", tostring(value))

                        if sliderFlag then 
                            library.flags[sliderFlag] = value
                        end

                        sliderCallback(value)
                    end

                    function toggleSliderTypes:Toggle(bool)
                        if toggled ~= bool then
                            toggleToggle()
                        end
                    end

                    if toggleFlag then
                        flags.toggles[toggleFlag] = function(bool)
                            if toggled ~= bool then
                                toggleToggle()
                            end
                        end
                    end

                    if sliderFlag then
                        flags.sliders[sliderFlag] = function(num)
                            toggleSliderTypes:Set(num)
                        end
                    end

                    return toggleSliderTypes
                end

                function sectionTypes:Dropdown(opts)
                    local options = utility.table(opts)
                    local name = options.name or "下拉框"
                    local content = options.content or {}
                    local multiChoice = options.multiChoice or false
                    local default = (options.default and table.find(content, options.default)) or (multiChoice and {} or nil)
                    local flag = options.flag
                    local callback = options.callback or function() end

                    if flag then
                        library.flags[flag] = default
                    end
                    callback(default)

                    local opened = false

                    local current = default
                    local chosen = {}

                    local dropdownHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 36),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectionContent
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 0, 16),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = dropdownHolder
                    })
                    
                    local open = utility.create("TextButton", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 0, 20),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Text = "",
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = dropdownHolder
                    })
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = open
                    })
                    
                    local value = utility.create("TextLabel", {
                        ZIndex = 4,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = (multiChoice and (#default > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180))) or default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
                        Text = multiChoice and (#default > 0 and table.concat(default, ", ") or "无") or (default or "无"),
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = open
                    })
                    
                    local icon = utility.create("ImageLabel", {
                        ZIndex = 4,
                        Size = UDim2.new(0, 14, 0, 14),
                        Rotation = 180,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -16, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Image = "http://www.roblox.com/asset/?id=8747047318",
                        Parent = open
                    })
                    
                    local contentFrame = utility.create("Frame", {
                        ZIndex = 10,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 0),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 1, 3),
                        BackgroundColor3 = Color3.fromRGB(33, 33, 33),
                        Parent = open
                    })
                    
                    local contentHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 1, -4),
                        Position = UDim2.new(0, 0, 0, 2),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = contentFrame
                    })

                    local contentList = utility.create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = contentHolder
                    })

                    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        contentFrame.Size = UDim2.new(1, 0, 0, contentList.AbsoluteContentSize.Y + 4)
                    end)

                    local function openDropdown()
                        opened = not opened
                        icon.Rotation = opened and 0 or 180
                        contentFrame.Visible = opened
                        dropdownHolder.Size = UDim2.new(1, 0, 0, opened and dropdownHolder.AbsoluteSize.Y + contentFrame.AbsoluteSize.Y + 3 or 36)
                    end

                    local function selectObj(obj, padding, bool)
                        for i, v in next, contentHolder:GetChildren() do
                            if v:IsA("TextButton") then
                                v:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 6)
                                v.Font = Enum.Font.Gotham
                            end
                        end

                        obj.Font = bool and Enum.Font.GothamSemibold or Enum.Font.Gotham
                        padding.PaddingLeft = bool and UDim.new(0, 10) or UDim.new(0, 6)
                        value.TextColor3 = bool and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                    end

                    local function multiSelectObj(obj, padding, bool)
                        obj.Font = bool and Enum.Font.GothamSemibold or Enum.Font.Gotham
                        padding.PaddingLeft = bool and UDim.new(0, 10) or UDim.new(0, 6)
                    end
                    
                    open.MouseButton1Click:Connect(openDropdown)

                    for _, opt in next, content do
                        local option = utility.create("TextButton", {
                            Name = opt,
                            ZIndex = 11,
                            Size = UDim2.new(1, 0, 0, 14),
                            BackgroundTransparency = 1,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            FontSize = Enum.FontSize.Size12,
                            TextSize = 12,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            Text = tostring(opt),
                            Font = current == opt and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = contentHolder
                        })
                        
                        local optionPadding = utility.create("UIPadding", {
                            PaddingLeft = current == opt and UDim.new(0, 10) or UDim.new(0, 6),
                            Parent = option
                        })

                        option.MouseButton1Click:Connect(function()
                            if not multiChoice then
                                if current ~= opt then
                                    current = opt
                                    selectObj(option, optionPadding, true)
                                    value.Text = opt
                                    
                                    if flag then
                                        library.flags[flag] = opt
                                    end

                                    callback(opt)
                                else
                                    current = nil
                                    selectObj(option, optionPadding, false)
                                    value.Text = "无"

                                    if flag then
                                        library.flags[flag] = nil
                                    end

                                    callback(nil)
                                end
                            else
                                if not table.find(chosen, opt) then
                                    table.insert(chosen, opt)

                                    multiSelectObj(option, optionPadding, true)
                                    value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    value.Text = table.concat(chosen, ", ")
                                    
                                    if flag then
                                        library.flags[flag] = chosen
                                    end

                                    callback(chosen)
                                else
                                    table.remove(chosen, table.find(chosen, opt))

                                    multiSelectObj(option, optionPadding, false)
                                    value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                    value.Text = #chosen > 0 and table.concat(chosen, ", ") or "无"

                                    if flag then
                                        library.flags[flag] = chosen
                                    end

                                    callback(chosen)
                                end
                            end
                        end)
                    end

                    local dropdownTypes = utility.table()

                    function dropdownTypes:Show()
                        dropdownHolder.Visible = true
                    end

                    function dropdownTypes:Hide()
                        dropdownHolder.Visible = false
                    end

                    function dropdownTypes:SetName(str)
                        title.Text = str
                    end

                    function dropdownTypes:Set(opt)
                        if opt then
                            if typeof(opt) == "string" then
                                if table.find(content, opt) then
                                    if not multiChoice then
                                        current = opt
                                        selectObj(contentHolder:FindFirstChild(opt), contentHolder:FindFirstChild(opt):FindFirstChildOfClass("UIPadding"), true)
                                        value.Text = opt
                                        
                                        if flag then
                                            library.flags[flag] = opt
                                        end

                                        callback(opt)
                                    else
                                        table.insert(chosen, opt)

                                        multiSelectObj(contentHolder:FindFirstChild(opt), contentHolder:FindFirstChild(opt):FindFirstChildOfClass("UIPadding"), true)
                                        value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        value.Text = table.concat(chosen, ", ")
                                        
                                        if flag then
                                            library.flags[flag] = chosen
                                        end

                                        callback(chosen)
                                    end
                                end
                            elseif multiChoice then
                                table.clear(chosen)
                                chosen = opt

                                for i, v in next, opt do
                                    if contentHolder:FindFirstChild(v) then
                                        multiSelectObj(contentHolder:FindFirstChild(v), contentHolder:FindFirstChild(v):FindFirstChildOfClass("UIPadding"), true)

                                        value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        value.Text = table.concat(chosen, ", ")
                                    end
                                end
                            end
                        else
                            if not multiChoice then
                                current = nil

                                for i, v in next, contentHolder:GetChildren() do
                                    if v:IsA("TextButton") then
                                        v:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 6)
                                        v.Font = Enum.Font.Gotham
                                    end
                                end

                                value.Text = "无"
                                value.TextColor3 = Color3.fromRGB(180, 180, 180)

                                if flag then
                                    library.flags[flag] = nil
                                end

                                callback(nil)
                            elseif multiChoice then
                                table.clear(chosen)

                                for i, v in next, contentHolder:GetChildren() do
                                    if v:IsA("TextButton") then
                                        v:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 6)
                                        v.Font = Enum.Font.GothamSemiBold
                                    end
                                end

                                value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                value.Text = "无"

                                if flag then
                                    library.flags[flag] = chosen
                                end

                                callback(chosen)
                            end
                        end
                    end

                    function dropdownTypes:Add(opt)
                        table.insert(content, opt)

                        local option = utility.create("TextButton", {
                            Name = opt,
                            ZIndex = 11,
                            Size = UDim2.new(1, 0, 0, 14),
                            BackgroundTransparency = 1,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            FontSize = Enum.FontSize.Size12,
                            TextSize = 12,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            Text = tostring(opt),
                            Font = current == opt and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = contentHolder
                        })
                        
                        local optionPadding = utility.create("UIPadding", {
                            PaddingLeft = current == opt and UDim.new(0, 10) or UDim.new(0, 6),
                            Parent = option
                        })

                        option.MouseButton1Click:Connect(function()
                            if not multiChoice then
                                if current ~= opt then
                                    current = opt
                                    selectObj(option, optionPadding, true)
                                    value.Text = opt
                                    
                                    if flag then
                                        library.flags[flag] = opt
                                    end

                                    callback(opt)
                                else
                                    current = nil
                                    selectObj(option, optionPadding, false)
                                    value.Text = "无"

                                    if flag then
                                        library.flags[flag] = nil
                                    end

                                    callback(nil)
                                end
                            else
                                if not table.find(chosen, opt) then
                                    table.insert(chosen, opt)

                                    multiSelectObj(option, optionPadding, true)
                                    value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    value.Text = table.concat(chosen, ", ")
                                    
                                    if flag then
                                        library.flags[flag] = chosen
                                    end

                                    callback(chosen)
                                else
                                    table.remove(chosen, table.find(chosen, opt))

                                    multiSelectObj(option, optionPadding, false)
                                    value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                    value.Text = #chosen > 0 and table.concat(chosen, ", ") or "无"

                                    if flag then
                                        library.flags[flag] = chosen
                                    end

                                    callback(chosen)
                                end
                            end
                        end)
                    end

                    function dropdownTypes:Remove(opt)
                        if table.find(content, opt) then
                            if not multiChoice then
                                if current == opt then
                                    dropdownTypes:Set(nil)
                                end

                                if contentHolder:FindFirstChild(opt) then
                                    contentHolder:FindFirstChild(opt):Destroy()
                                end
                            else
                                if table.find(chosen, opt) then
                                    table.remove(chosen, table.find(chosen, opt))
                                    value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                    value.Text = #chosen > 0 and table.concat(chosen, ", ") or "无"
                                end

                                if contentHolder:FindFirstChild(opt) then
                                    contentHolder:FindFirstChild(opt):Destroy()
                                end
                            end
                        end
                    end

                    function dropdownTypes:Refresh(tbl)
                        content = tbl
                        for _, opt in next, contentHolder:GetChildren() do
                            if opt:IsA("TextButton") then
                                opt:Destroy()
                            end
                        end

                        dropdownTypes:Set(nil)

                        for _, opt in next, content do
                            local option = utility.create("TextButton", {
                                Name = opt,
                                ZIndex = 11,
                                Size = UDim2.new(1, 0, 0, 14),
                                BackgroundTransparency = 1,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                FontSize = Enum.FontSize.Size12,
                                TextSize = 12,
                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                Text = tostring(opt),
                                Font = current == opt and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Parent = contentHolder
                            })
                            
                            local optionPadding = utility.create("UIPadding", {
                                PaddingLeft = current == opt and UDim.new(0, 10) or UDim.new(0, 6),
                                Parent = option
                            })
        
                            option.MouseButton1Click:Connect(function()
                                if not multiChoice then
                                    if current ~= opt then
                                        current = opt
                                        selectObj(option, optionPadding, true)
                                        value.Text = opt
                                        
                                        if flag then
                                            library.flags[flag] = opt
                                        end
        
                                        callback(opt)
                                    else
                                        current = nil
                                        selectObj(option, optionPadding, false)
                                        value.Text = "无"
        
                                        if flag then
                                            library.flags[flag] = nil
                                        end
        
                                        callback(nil)
                                    end
                                else
                                    if not table.find(chosen, opt) then
                                        table.insert(chosen, opt)
        
                                        multiSelectObj(option, optionPadding, true)
                                        value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        value.Text = table.concat(chosen, ", ")
                                        
                                        if flag then
                                            library.flags[flag] = chosen
                                        end
        
                                        callback(chosen)
                                    else
                                        table.remove(chosen, table.find(chosen, opt))
        
                                        multiSelectObj(option, optionPadding, false)
                                        value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                        value.Text = #chosen > 0 and table.concat(chosen, ", ") or "无"
        
                                        if flag then
                                            library.flags[flag] = chosen
                                        end
        
                                        callback(chosen)
                                    end
                                end
                            end)
                        end
                    end

                    if flag then
                        if not multiChoice then
                            flags.dropdowns[flag] = function(opt)
                                dropdownTypes:Set(opt)
                            end
                        else
                            flags.multidropdowns[flag] = function(opt)
                                dropdownTypes:Set(opt)
                            end
                        end
                    end

                    return dropdownTypes
                end

                function sectionTypes:Keybind(opts)
                    local options = utility.table(opts)
                    local name = options.name or "按键绑定"
                    local default = options.default
                    local blacklist = options.blacklist or {}
                    local flag = options.flag
                    local callback = options.callback or function() end

                    if flag then
                        library.flags[flag] = default
                    end

                    local keys = {
                        [Enum.KeyCode.LeftShift] = "左Shift";
                        [Enum.KeyCode.RightShift] = "右Shift";
                        [Enum.KeyCode.LeftControl] = "左Ctrl";
                        [Enum.KeyCode.RightControl] = "右Ctrl";
                        [Enum.KeyCode.LeftAlt] = "左Alt";
                        [Enum.KeyCode.RightAlt] = "右Alt";
                        [Enum.KeyCode.CapsLock] = "大写锁定";
                        [Enum.KeyCode.One] = "1";
                        [Enum.KeyCode.Two] = "2";
                        [Enum.KeyCode.Three] = "3";
                        [Enum.KeyCode.Four] = "4";
                        [Enum.KeyCode.Five] = "5";
                        [Enum.KeyCode.Six] = "6";
                        [Enum.KeyCode.Seven] = "7";
                        [Enum.KeyCode.Eight] = "8";
                        [Enum.KeyCode.Nine] = "9";
                        [Enum.KeyCode.Zero] = "0";
                        [Enum.KeyCode.KeypadOne] = "小键盘1";
                        [Enum.KeyCode.KeypadTwo] = "小键盘2";
                        [Enum.KeyCode.KeypadThree] = "小键盘3";
                        [Enum.KeyCode.KeypadFour] = "小键盘4";
                        [Enum.KeyCode.KeypadFive] = "小键盘5";
                        [Enum.KeyCode.KeypadSix] = "小键盘6";
                        [Enum.KeyCode.KeypadSeven] = "小键盘7";
                        [Enum.KeyCode.KeypadEight] = "小键盘8";
                        [Enum.KeyCode.KeypadNine] = "小键盘9";
                        [Enum.KeyCode.KeypadZero] = "小键盘0";
                        [Enum.KeyCode.Minus] = "-";
                        [Enum.KeyCode.Equals] = "=";
                        [Enum.KeyCode.Tilde] = "~";
                        [Enum.KeyCode.LeftBracket] = "[";
                        [Enum.KeyCode.RightBracket] = "]";
                        [Enum.KeyCode.RightParenthesis] = ")";
                        [Enum.KeyCode.LeftParenthesis] = "(";
                        [Enum.KeyCode.Semicolon] = ";";
                        [Enum.KeyCode.Quote] = "'";
                        [Enum.KeyCode.BackSlash] = "\\";
                        [Enum.KeyCode.Comma] = ";";
                        [Enum.KeyCode.Period] = ".";
                        [Enum.KeyCode.Slash] = "/";
                        [Enum.KeyCode.Asterisk] = "*";
                        [Enum.KeyCode.Plus] = "+";
                        [Enum.KeyCode.Period] = ".";
                        [Enum.KeyCode.Backquote] = "`";
                        [Enum.UserInputType.MouseButton1] = "鼠标左键";
                        [Enum.UserInputType.MouseButton2] = "鼠标右键";
                        [Enum.UserInputType.MouseButton3] = "鼠标中键"
                    }

                    local keyChosen = default

                    local keybind = utility.create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = sectionContent
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = keybind
                    })
                    
                    local value = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 0, 0, 0),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = default and (keys[default] or tostring(default):gsub("Enum.KeyCode.", "")) or "无",
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = keybind
                    })

                    keybind.MouseButton1Click:Connect(function()
                        value.Text = "..."
                        value.TextColor3 = Color3.fromRGB(255, 255, 255)

                        local binding
                        binding = inputService.InputBegan:Connect(function(input)
                            local key = keys[input.KeyCode] or keys[input.UserInputType]
                            value.Text = (keys[key] or tostring(input.KeyCode):gsub("Enum.KeyCode.", ""))
                            value.TextColor3 = Color3.fromRGB(180, 180, 180)

                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if not table.find(blacklist, input.KeyCode) then
                                    keyChosen = input.KeyCode

                                    if flag then
                                        library.flags[flag] = input.KeyCode
                                    end

                                    binding:Disconnect()
                                else
                                    keyChosen = nil
                                    value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                    value.Text = "无"
                                        
                                    if flag then
                                        library.flags[flag] = nil
                                    end

                                    binding:Disconnect()
                                end
                            else
                                if not table.find(blacklist, input.UserInputType) then
                                    keyChosen = input.UserInputType

                                    if flag then
                                        library.flags[flag] = input.UserInputType
                                    end

                                    binding:Disconnect()
                                else
                                    keyChosen = nil
                                    value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                    value.Text = "无"
                                    
                                    if flag then
                                        library.flags[flag] = nil
                                    end

                                    binding:Disconnect()
                                end
                            end
                        end)
                    end)

                    inputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == keyChosen then
                                callback(keyChosen)
                            end
                        else
                            if input.UserInputType == keyChosen then
                                callback(keyChosen)
                            end
                        end
                    end)

                    local keybindTypes = utility.table()

                    function keybindTypes:Show()
                        keybind.Visible = true
                    end

                    function keybindTypes:Hide()
                        keybind.Visible = false
                    end

                    function keybindTypes:SetName(str)
                        title.Text = str
                    end

                    function keybindTypes:Set(newKey)
                        if typeof(newKey) == "EnumItem" then
                            if not table.find(blacklist, newKey) then
                                local key = keys[newKey]
                                value.Text = (keys[key] or tostring(newKey):gsub("Enum.KeyCode.", ""))
                                value.TextColor3 = Color3.fromRGB(180, 180, 180)
            
                                keyChosen = newKey
            
                                if flag then
                                    library.flags[flag] = newKey
                                end
                            else
                                keyChosen = nil
                                value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                value.Text = "无"

                                if flag then
                                    library.flags[flag] = nil
                                end
                            end
                        end
                    end

                    if flag then
                        flags.keybinds[flag] = function(key)
                            keybindTypes:Set(key)
                        end
                    end

                    return keybindTypes
                end

                function sectionTypes:ToggleKeybind(opts)
                    local options = utility.table(opts)
                    local name = options.name or "开关按键绑定"
                    local default = options.default
                    local blacklist = options.blacklist or {}
                    local toggleFlag = options.toggleFlag
                    local keybindFlag = options.keybindFlag
                    local toggleCallback = options.toggleCallback or function() end
                    local keybindCallback = options.keybindCallback or function() end

                    local keys = {
                        [Enum.KeyCode.LeftShift] = "左Shift";
                        [Enum.KeyCode.RightShift] = "右Shift";
                        [Enum.KeyCode.LeftControl] = "左Ctrl";
                        [Enum.KeyCode.RightControl] = "右Ctrl";
                        [Enum.KeyCode.LeftAlt] = "左Alt";
                        [Enum.KeyCode.RightAlt] = "右Alt";
                        [Enum.KeyCode.CapsLock] = "大写锁定";
                        [Enum.KeyCode.One] = "1";
                        [Enum.KeyCode.Two] = "2";
                        [Enum.KeyCode.Three] = "3";
                        [Enum.KeyCode.Four] = "4";
                        [Enum.KeyCode.Five] = "5";
                        [Enum.KeyCode.Six] = "6";
                        [Enum.KeyCode.Seven] = "7";
                        [Enum.KeyCode.Eight] = "8";
                        [Enum.KeyCode.Nine] = "9";
                        [Enum.KeyCode.Zero] = "0";
                        [Enum.KeyCode.KeypadOne] = "小键盘1";
                        [Enum.KeyCode.KeypadTwo] = "小键盘2";
                        [Enum.KeyCode.KeypadThree] = "小键盘3";
                        [Enum.KeyCode.KeypadFour] = "小键盘4";
                        [Enum.KeyCode.KeypadFive] = "小键盘5";
                        [Enum.KeyCode.KeypadSix] = "小键盘6";
                        [Enum.KeyCode.KeypadSeven] = "小键盘7";
                        [Enum.KeyCode.KeypadEight] = "小键盘8";
                        [Enum.KeyCode.KeypadNine] = "小键盘9";
                        [Enum.KeyCode.KeypadZero] = "小键盘0";
                        [Enum.KeyCode.Minus] = "-";
                        [Enum.KeyCode.Equals] = "=";
                        [Enum.KeyCode.Tilde] = "~";
                        [Enum.KeyCode.LeftBracket] = "[";
                        [Enum.KeyCode.RightBracket] = "]";
                        [Enum.KeyCode.RightParenthesis] = ")";
                        [Enum.KeyCode.LeftParenthesis] = "(";
                        [Enum.KeyCode.Semicolon] = ";";
                        [Enum.KeyCode.Quote] = "'";
                        [Enum.KeyCode.BackSlash] = "\\";
                        [Enum.KeyCode.Comma] = ";";
                        [Enum.KeyCode.Period] = ".";
                        [Enum.KeyCode.Slash] = "/";
                        [Enum.KeyCode.Asterisk] = "*";
                        [Enum.KeyCode.Plus] = "+";
                        [Enum.KeyCode.Period] = ".";
                        [Enum.KeyCode.Backquote] = "`";
                        [Enum.UserInputType.MouseButton1] = "鼠标左键";
                        [Enum.UserInputType.MouseButton2] = "鼠标右键";
                        [Enum.UserInputType.MouseButton3] = "鼠标中键"
                    }

                    local toggled = false
                    local keyChosen = default

                    if toggleFlag then
                        library.flags[toggleFlag] = toggled
                    end

                    if keybindFlag then
                        library.flags[keybindFlag] = default
                    end

                    local toggleKeybind = utility.create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = sectionContent
                    })

                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 21, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = toggleKeybind
                    })

                    local icon = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 14, 1, -2),
                        BorderColor3 = Color3.fromRGB(37, 37, 37),
                        Position = UDim2.new(0, 0, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = toggleKeybind
                    })
                    
                    local iconGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = icon
                    })
                    
                    local value = utility.create("TextButton", {
                        ZIndex = 3,
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = default and (keys[default] or tostring(default):gsub("Enum.KeyCode.", "")) or "无",
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = toggleKeybind
                    })

                    value.Size = UDim2.new(0, value.TextBounds.X, 1, 0)
                    value.Position = UDim2.new(1, -value.TextBounds.X, 0, 0)

                    local function toggleToggle()
                        toggled = not toggled

                        if toggled then
                            table.insert(coloredGradients, iconGradient)
                        else
                            table.remove(coloredGradients, table.find(coloredGradients, iconGradient))
                        end

                        local textColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                        local gradientColor
                        if toggled then
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, library.color), 
                                ColorSequenceKeypoint.new(1, utility.change_color(library.color, -47))
                            }
                        else
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                            }
                        end

                        iconGradient.Color = gradientColor
                        title.TextColor3 = textColor

                        if toggleFlag then
                            library.flags[toggleFlag] = toggled
                        end

                        toggleCallback(toggled)
                    end

                    toggleKeybind.MouseButton1Click:Connect(toggleToggle)

                    value.MouseButton1Click:Connect(function()
                        value.Text = "..."
                        value.Size = UDim2.new(0, value.TextBounds.X, 1, 0)
                        value.Position = UDim2.new(1, -value.TextBounds.X, 0, 0)
                        value.TextColor3 = Color3.fromRGB(255, 255, 255)
                    
                        local binding
                        binding = inputService.InputBegan:Connect(function(input)
                            local key = keys[input.KeyCode] or keys[input.UserInputType]
                            value.Text = (keys[key] or tostring(input.KeyCode):gsub("Enum.KeyCode.", ""))
                            value.Size = UDim2.new(0, value.TextBounds.X, 1, 0)
                            value.Position = UDim2.new(1, -value.TextBounds.X, 0, 0)
                            value.TextColor3 = Color3.fromRGB(180, 180, 180)
                    
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if not table.find(blacklist, input.KeyCode) then
                                    keyChosen = input.KeyCode
                    
                                    if keybindFlag then
                                        library.flags[keybindFlag] = input.KeyCode
                                    end
                    
                                    binding:Disconnect()
                                else
                                    keyChosen = nil
                                    value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                    value.Text = "无"
                                    value.Size = UDim2.new(0, value.TextBounds.X, 1, 0)
                                    value.Position = UDim2.new(1, -value.TextBounds.X, 0, 0)
                                        
                                    if keybindFlag then
                                        library.flags[keybindFlag] = nil
                                    end
                    
                                    binding:Disconnect()
                                end
                            else
                                if not table.find(blacklist, input.UserInputType) then
                                    keyChosen = input.UserInputType
                    
                                    if keybindFlag then
                                        library.flags[keybindFlag] = input.UserInputType
                                    end
                    
                                    binding:Disconnect()
                                else
                                    keyChosen = nil
                                    value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                    value.Text = "无"
                                    value.Size = UDim2.new(0, value.TextBounds.X, 1, 0)
                                    value.Position = UDim2.new(1, -value.TextBounds.X, 0, 0)
                                    
                                    if keybindFlag then
                                        library.flags[keybindFlag] = nil
                                    end
                    
                                    binding:Disconnect()
                                end
                            end
                        end)
                    end)
                    
                    inputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == keyChosen then
                                toggleToggle()
                                keybindCallback(keyChosen)
                            end
                        else
                            if input.UserInputType == keyChosen then
                                toggleToggle()
                                keybindCallback(keyChosen)
                            end
                        end
                    end)
                    
                    local toggleKeybindTypes = utility.table()
                    
                    function toggleKeybindTypes:Show()
                        keybind.Visible = true
                    end
                    
                    function toggleKeybindTypes:Hide()
                        keybind.Visible = false
                    end
                    
                    function toggleKeybindTypes:SetName(str)
                        title.Text = str
                    end

                    function toggleKeybindTypes:Toggle(bool)
                        if toggled ~= bool then
                            toggleToggle()
                        end
                    end
                    
                    function toggleKeybindTypes:Set(newKey)
                        if typeof(newKey) == "EnumItem" then
                            if not table.find(blacklist, newKey) then
                                local key = keys[newKey]
                                value.Text = (keys[key] or tostring(newKey):gsub("Enum.KeyCode.", ""))
                                value.Size = UDim2.new(0, value.TextBounds.X, 1, 0)
                                value.Position = UDim2.new(1, -value.TextBounds.X, 0, 0)
                                value.TextColor3 = Color3.fromRGB(180, 180, 180)
                    
                                keyChosen = newKey
                    
                                if keybindFlag then
                                    library.flags[keybindFlag] = newKey
                                end
                            else
                                keyChosen = nil
                                value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                value.Text = "无"
                    
                                if keybindFlag then
                                    library.flags[keybindFlag] = nil
                                end
                            end
                        end
                    end
                    
                    if keybindFlag then
                        flags.keybinds[keybindFlag] = function(key)
                            toggleKeybindTypes:Set(key)
                        end
                    end

                    if toggleFlag then
                        flags.toggles[toggleFlag] = function(bool)
                            toggleKeybindTypes:Toggle(bool)
                        end
                    end
                    
                    return toggleKeybindTypes
                end

                function sectionTypes:ColorPicker(opts)
                    local options = utility.table(opts)
                    local name = options.name or "颜色选择器"
                    local default = options.default or Color3.fromRGB(255, 255, 255)
                    local flag = options.flag
                    local callback = options.callback or function() end

                    local open = false
                    local hue, sat, val = default:ToHSV()

                    local slidingHue = false
                    local slidingSaturation = false

                    local hsv = Color3.fromHSV(hue, sat, val)

                    if flag then
                        library.flags[flag] = default
                    end

                    callback(default)

                    local colorPickerHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 16),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Parent = sectionContent
                    })

                    local colorPicker = utility.create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = colorPickerHolder
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = colorPicker
                    })
                    
                    local icon = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 22, 0, 14),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(1, -22, 0, 1),
                        BackgroundColor3 = default,
                        Parent = colorPicker
                    })
                    
                    local iconGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 105, 105))
                        },
                        Parent = icon
                    })
                    
                    local picker = utility.create("Frame", {
                        ZIndex = 12,
                        Visible = false,
                        Size = UDim2.new(1, -8, 0, 183),
                        ClipsDescendants = true,
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 12, 1, 3),
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                        Parent = colorPicker
                    })
                    
                    local saturationFrame = utility.create("ImageLabel", {
                        ZIndex = 13,
                        Size = UDim2.new(1, -29, 0, 130),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 5, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(255, 0, 4),
                        Image = "http://www.roblox.com/asset/?id=8630797271",
                        Parent = picker
                    })
                    
                    local saturationPicker = utility.create("Frame", {
                        ZIndex = 15,
                        Size = UDim2.new(0, 4, 0, 4),
                        Position = UDim2.new(0, 5, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 1,
                        Parent = saturationFrame
                    })
                    
                    local hueFrame = utility.create("ImageLabel", {
                        ZIndex = 13,
                        Size = UDim2.new(0, 14, 0, 130),
                        ClipsDescendants = true,
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -19, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(255, 0, 4),
                        ScaleType = Enum.ScaleType.Crop,
                        Image = "http://www.roblox.com/asset/?id=8630799159",
                        Parent = picker
                    })
                    
                    local huePicker = utility.create("Frame", {
                        ZIndex = 15,
                        Size = UDim2.new(1, 0, 0, 2),
                        Position = UDim2.new(0, 0, 0, 10),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 1,
                        Parent = hueFrame
                    })
                    
                    local rgb = utility.create("TextBox", {
                        ZIndex = 14,
                        Size = UDim2.new(1, -10, 0, 16),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 1, -42),
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = table.concat({utility.get_rgb(default)}, ", "),
                        ClearTextOnFocus = false,
                        Font = Enum.Font.Gotham,
                        PlaceholderText = "红,  绿,  蓝",
                        Parent = picker
                    })
                    
                    local bg = utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = rgb
                    })
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = bg
                    })
                    
                    local hex = utility.create("TextBox", {
                        ZIndex = 14,
                        Size = UDim2.new(1, -10, 0, 16),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 1, -21),
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = utility.rgb_to_hex(default),
                        ClearTextOnFocus = false,
                        Font = Enum.Font.Gotham,
                        PlaceholderText = utility.rgb_to_hex(default),
                        Parent = picker
                    })
                    
                    local bg = utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = hex
                    })
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = bg
                    })

                    local function openPicker()
                        open = not open
                        picker.Visible = open
                        colorPickerHolder.Size = UDim2.new(1, 0, 0, open and colorPicker.AbsoluteSize.Y + picker.AbsoluteSize.Y + 3 or 16)
                    end

                    colorPicker.MouseButton1Click:connect(openPicker)

                    local function updateHue(input)
                        local sizeY = 1 - math.clamp((input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 2)
                        huePicker.Position = UDim2.new(0, 0, 0, posY)

                        hue = sizeY

                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))

                        hsv = Color3.fromHSV(hue, sat, val)
                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv

                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end

                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end

                    hueFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingHue = true
                            updateHue(input)
                        end
                    end)

                    hueFrame.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingHue = false
                        end
                    end)

                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if slidingHue then
                                updateHue(input)
                            end
                        end
                    end)

                    local function updateSatVal(input)
                        local sizeX = math.clamp((input.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X, 0, 1)
                        local sizeY = 1 - math.clamp((input.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)
                        local posX = math.clamp(((input.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X) * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)

                        saturationPicker.Position = UDim2.new(0, posX, 0, posY)

                        sat = sizeX
                        val = sizeY

                        hsv = Color3.fromHSV(hue, sat, val)

                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))

                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv

                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end

                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end

                    saturationFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingSaturation = true
                            updateSatVal(input)
                        end
                    end)

                    saturationFrame.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingSaturation = false
                        end
                    end)

                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if slidingSaturation then
                                updateSatVal(input)
                            end
                        end
                    end)

                    local colorPickerTypes = utility.table()

                    function colorPickerTypes:Show()
                        colorPickerHolder.Visible = true
                    end
                    
                    function colorPickerTypes:Hide()
                        colorPickerHolder.Visible = false
                    end
                    
                    function colorPickerTypes:SetName(str)
                        title.Text = str
                    end

                    function colorPickerTypes:SetRGB(color)
                        hue, sat, val = color:ToHSV()
                        hsv = Color3.fromHSV(hue, sat, val)

                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv
                        saturationPicker.Position = UDim2.new(0, (math.clamp(sat * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)), 0, (math.clamp((1 - val) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)))
                        huePicker.Position = UDim2.new(0, 0, 0, math.clamp((1 - hue) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 4))

                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))

                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end

                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end

                    function colorPickerTypes:SetHex(hexValue)
                        color = utility.hex_to_rgb(hexValue)
                        
                        hue, sat, val = color:ToHSV()
                        hsv = Color3.fromHSV(hue, sat, val)

                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv
                        saturationPicker.Position = UDim2.new(0, (math.clamp(sat * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)), 0, (math.clamp((1 - val) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)))
                        huePicker.Position = UDim2.new(0, 0, 0, math.clamp((1 - hue) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 4))

                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))

                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end

                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end

                    rgb.FocusLost:Connect(function()
                        local _, amount = rgb.Text:gsub(", ", "")
                        if amount == 2 then
                            local values = rgb.Text:split(", ")
                            local r, g, b = math.clamp(tonumber(values[1]) or 0, 0, 255), math.clamp(tonumber(values[2]) or 0, 0, 255), math.clamp(tonumber(values[3]) or 0, 0, 255)
                            colorPickerTypes:SetRGB(Color3.fromRGB(r, g, b))
                        else
                            rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        end
                    end)
                        
                    hex.FocusLost:Connect(function()
                        if hex.Text:find("#") and hex.Text:len() == 7 then
                            colorPickerTypes:SetHex(hex.Text)
                        else
                            hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                        end
                    end)

                    hex:GetPropertyChangedSignal("Text"):Connect(function()
                        if hex.Text == "" then
                            hex.Text = "#"
                        end
                    end)

                    if flag then
                        flags.colorpickers[flag] = function(color)
                            colorPickerTypes:SetRGB(color)
                        end
                    end

                    return colorPickerTypes
                end

                function sectionTypes:ToggleColorPicker(opts)
                    local options = utility.table(opts)
                    local name = options.name or "开关颜色选择器"
                    local default = options.default or Color3.fromRGB(255, 255, 255)
                    local toggleFlag = options.toggleFlag
                    local colorPickerFlag = options.colorPickerFlag
                    local toggleCallback = options.toggleCallback or function() end
                    local colorPickerCallback = options.colorPickerCallback or function() end

                    local open = false
                    local toggled = false
                    local hue, sat, val = default:ToHSV()

                    local slidingHue = false
                    local slidingSaturation = false

                    local hsv = Color3.fromHSV(hue, sat, val)

                    if colorPickerFlag then
                        library.flags[colorPickerFlag] = default
                    end

                    colorPickerCallback(default)

                    if toggleFlag then
                        library.flags[toggleFlag] = toggled
                    end

                    toggleCallback(false)

                    local toggleColorPickerHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 16),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Parent = sectionContent
                    })

                    local colorPicker = utility.create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = toggleColorPickerHolder
                    })

                    local icon = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 14, 1, -2),
                        BorderColor3 = Color3.fromRGB(37, 37, 37),
                        Position = UDim2.new(0, 0, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = colorPicker
                    })
                    
                    local iconGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = icon
                    })

                    local colorPickerIcon = utility.create("TextButton", {
                        ZIndex = 3,
                        Text = "",
                        Size = UDim2.new(0, 22, 0, 14),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(1, -22, 0, 1),
                        BackgroundColor3 = default,
                        Parent = colorPicker
                    })
                    
                    local colorPickerIconGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 105, 105))
                        },
                        Parent = colorPickerIcon
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 7, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = icon
                    })
                    
                    local picker = utility.create("Frame", {
                        ZIndex = 12,
                        Visible = false,
                        Size = UDim2.new(1, -8, 0, 183),
                        ClipsDescendants = true,
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 12, 1, 3),
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                        Parent = colorPicker
                    })
                    
                    local saturationFrame = utility.create("ImageLabel", {
                        ZIndex = 13,
                        Size = UDim2.new(1, -29, 0, 130),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 5, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(255, 0, 4),
                        Image = "http://www.roblox.com/asset/?id=8630797271",
                        Parent = picker
                    })
                    
                    local saturationPicker = utility.create("Frame", {
                        ZIndex = 15,
                        Size = UDim2.new(0, 4, 0, 4),
                        Position = UDim2.new(0, 5, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 1,
                        Parent = saturationFrame
                    })
                    
                    local hueFrame = utility.create("ImageLabel", {
                        ZIndex = 13,
                        Size = UDim2.new(0, 14, 0, 130),
                        ClipsDescendants = true,
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -19, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(255, 0, 4),
                        ScaleType = Enum.ScaleType.Crop,
                        Image = "http://www.roblox.com/asset/?id=8630799159",
                        Parent = picker
                    })
                    
                    local huePicker = utility.create("Frame", {
                        ZIndex = 15,
                        Size = UDim2.new(1, 0, 0, 2),
                        Position = UDim2.new(0, 0, 0, 10),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 1,
                        Parent = hueFrame
                    })
                    
                    local rgb = utility.create("TextBox", {
                        ZIndex = 14,
                        Size = UDim2.new(1, -10, 0, 16),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 1, -42),
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = table.concat({utility.get_rgb(default)}, ", "),
                        ClearTextOnFocus = false,
                        Font = Enum.Font.Gotham,
                        PlaceholderText = "红,  绿,  蓝",
                        Parent = picker
                    })
                    
                    local bg = utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = rgb
                    })
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = bg
                    })
                    
                    local hex = utility.create("TextBox", {
                        ZIndex = 14,
                        Size = UDim2.new(1, -10, 0, 16),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 1, -21),
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = utility.rgb_to_hex(default),
                        ClearTextOnFocus = false,
                        Font = Enum.Font.Gotham,
                        PlaceholderText = utility.rgb_to_hex(default),
                        Parent = picker
                    })
                    
                    local bg = utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = hex
                    })
                    
                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(32, 32, 32), Color3.fromRGB(17, 17, 17)),
                        Parent = bg
                    })

                    local function toggleToggle()
                        toggled = not toggled

                        if toggled then
                            table.insert(coloredGradients, iconGradient)
                        else
                            table.remove(coloredGradients, table.find(coloredGradients, iconGradient))
                        end

                        local textColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                        local gradientColor
                        if toggled then
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, library.color), 
                                ColorSequenceKeypoint.new(1, utility.change_color(library.color, -47))
                            }
                        else
                            gradientColor = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 32)), 
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))
                            }
                        end

                        iconGradient.Color = gradientColor
                        title.TextColor3 = textColor

                        if toggleFlag then
                            library.flags[toggleFlag] = toggled
                        end

                        toggleCallback(toggled)
                    end

                    colorPicker.MouseButton1Click:Connect(toggleToggle)

                    local function openPicker()
                        open = not open
                        picker.Visible = open
                        toggleColorPickerHolder.Size = UDim2.new(1, 0, 0, open and colorPicker.AbsoluteSize.Y + picker.AbsoluteSize.Y + 3 or 16)
                    end
                    
                    colorPickerIcon.MouseButton1Click:connect(openPicker)
                    
                    local function updateHue(input)
                        local sizeY = 1 - math.clamp((input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 2)
                        huePicker.Position = UDim2.new(0, 0, 0, posY)
                    
                        hue = sizeY
                    
                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    
                        hsv = Color3.fromHSV(hue, sat, val)
                        saturationFrame.BackgroundColor3 = hsv
                        colorPickerIcon.BackgroundColor3 = hsv
                    
                        if colorPickerFlag then 
                            library.flags[colorPickerFlag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end
                    
                        colorPickerCallback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end
                    
                    hueFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingHue = true
                            updateHue(input)
                        end
                    end)
                    
                    hueFrame.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingHue = false
                        end
                    end)
                    
                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if slidingHue then
                                updateHue(input)
                            end
                        end
                    end)
                    
                    local function updateSatVal(input)
                        local sizeX = math.clamp((input.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X, 0, 1)
                        local sizeY = 1 - math.clamp((input.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)
                        local posX = math.clamp(((input.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X) * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)
                    
                        saturationPicker.Position = UDim2.new(0, posX, 0, posY)
                    
                        sat = sizeX
                        val = sizeY
                    
                        hsv = Color3.fromHSV(hue, sat, val)
                    
                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    
                        saturationFrame.BackgroundColor3 = hsv
                        colorPickerIcon.BackgroundColor3 = hsv
                    
                        if colorPickerFlag then 
                            library.flags[colorPickerFlag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end
                    
                        colorPickerCallback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end
                    
                    saturationFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingSaturation = true
                            updateSatVal(input)
                        end
                    end)
                    
                    saturationFrame.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingSaturation = false
                        end
                    end)
                    
                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if slidingSaturation then
                                updateSatVal(input)
                            end
                        end
                    end)
                    
                    local toggleColorPickerTypes = utility.table()
                    
                    function toggleColorPickerTypes:Show()
                        toggleColorPickerHolder.Visible = true
                    end
                    
                    function toggleColorPickerTypes:Hide()
                        toggleColorPickerHolder.Visible = false
                    end
                    
                    function toggleColorPickerTypes:SetName(str)
                        title.Text = str
                    end

                    function toggleColorPickerTypes:Toggle(bool)
                        if toggled ~= bool then
                            toggleToggle()
                        end
                    end
                    
                    function toggleColorPickerTypes:SetRGB(color)
                        hue, sat, val = color:ToHSV()
                        hsv = Color3.fromHSV(hue, sat, val)
                    
                        saturationFrame.BackgroundColor3 = hsv
                        colorPickerIcon.BackgroundColor3 = hsv
                        saturationPicker.Position = UDim2.new(0, (math.clamp(sat * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)), 0, (math.clamp((1 - val) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)))
                        huePicker.Position = UDim2.new(0, 0, 0, math.clamp((1 - hue) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 4))
                    
                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    
                        if colorPickerFlag then 
                            library.flags[colorPickerFlag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end
                    
                        colorPickerCallback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end
                    
                    function toggleColorPickerTypes:SetHex(hexValue)
                        color = utility.hex_to_rgb(hexValue)
                        
                        hue, sat, val = color:ToHSV()
                        hsv = Color3.fromHSV(hue, sat, val)
                    
                        saturationFrame.BackgroundColor3 = hsv
                        colorPickerIcon.BackgroundColor3 = hsv
                        saturationPicker.Position = UDim2.new(0, (math.clamp(sat * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)), 0, (math.clamp((1 - val) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)))
                        huePicker.Position = UDim2.new(0, 0, 0, math.clamp((1 - hue) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 4))
                    
                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    
                        if colorPickerFlag then 
                            library.flags[colorPickerFlag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end
                    
                        colorPickerCallback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end
                    
                    rgb.FocusLost:Connect(function()
                        local _, amount = rgb.Text:gsub(", ", "")
                        if amount == 2 then
                            local values = rgb.Text:split(", ")
                            local r, g, b = math.clamp(tonumber(values[1]) or 0, 0, 255), math.clamp(tonumber(values[2]) or 0, 0, 255), math.clamp(tonumber(values[3]) or 0, 0, 255)
                            toggleColorPickerTypes:SetRGB(Color3.fromRGB(r, g, b))
                        else
                            rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        end
                    end)
                        
                    hex.FocusLost:Connect(function()
                        if hex.Text:find("#") and hex.Text:len() == 7 then
                            toggleColorPickerTypes:SetHex(hex.Text)
                        else
                            hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                        end
                    end)
                    
                    hex:GetPropertyChangedSignal("Text"):Connect(function()
                        if hex.Text == "" then
                            hex.Text = "#"
                        end
                    end)
                    
                    if colorPickerFlag then
                        flags.colorpickers[colorPickerFlag] = function(color)
                            toggleColorPickerTypes:SetRGB(color)
                        end
                    end

                    if toggleFlag then
                        flags.toggles[toggleFlag] = function(bool)
                            toggleColorPickerTypes:Toggle(bool)
                        end
                    end
                    
                    return toggleColorPickerTypes
                end

                return sectionTypes
            end

            return tabTypes
        end

        return windowTypes
    end

    return library
end

-- 安全的HTTP请求函数（Delta注入器兼容）
local function safeHttpGet(url, useCache)
    local success, result = pcall(function()
        if useCache then
            return game:HttpGet(url, true)
        else
            return game:HttpGet(url)
        end
    end)
    if success then
        return result
    else
        warn("古脚本: HTTP请求失败 - " .. tostring(result))
        return nil
    end
end

-- 安全的脚本加载函数
local function safeLoadScript(url, useCache)
    local scriptContent = safeHttpGet(url, useCache)
    if scriptContent then
        local success, err = pcall(function()
            loadstring(scriptContent)()
        end)
        if not success then
            warn("古脚本: 脚本执行失败 - " .. tostring(err))
        end
    end
end

-- 初始化古脚本UI库
local Library = initLibrary()
local Window = Library:Load({
    name = "古脚本",
    sizeX = 500,
    sizeY = 400,
    color = Color3.fromRGB(100, 50, 200)  -- 紫色主题
})

-- 创建"主要"标签页
local MainTab = Window:Tab("主要")

-- 创建"玩家"section
local PlayerSection = MainTab:Section({
    name = "玩家",
    column = 1
})

-- 步行速度（可关闭）
local walkSpeedConnection = nil
local walkSpeedEnabled = false

PlayerSection:Toggle({
    name = "启用步行速度",
    flag = "WalkSpeedEnabled",
    callback = function(enabled)
        walkSpeedEnabled = enabled
        if enabled then
            if walkSpeedConnection then
                walkSpeedConnection:Disconnect()
            end
            walkSpeedConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = library.flags["WalkSpeed"] or 16
                end
            end)
        else
            if walkSpeedConnection then
                walkSpeedConnection:Disconnect()
                walkSpeedConnection = nil
            end
        end
    end
})

PlayerSection:Slider({
    name = "步行速度",
    flag = "WalkSpeed",
    min = 16,
    max = 400,
    default = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.WalkSpeed or 16,
    valueText = "步行速度: [VALUE]",
    callback = function(Speed)
        if walkSpeedEnabled then
            task.spawn(function() 
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = Speed 
                end
            end)
        end
    end
})

-- 跳跃高度（可关闭）
local jumpPowerConnection = nil
local jumpPowerEnabled = false

PlayerSection:Toggle({
    name = "启用跳跃高度",
    flag = "JumpPowerEnabled",
    callback = function(enabled)
        jumpPowerEnabled = enabled
        if enabled then
            if jumpPowerConnection then
                jumpPowerConnection:Disconnect()
            end
            jumpPowerConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.JumpPower = library.flags["JumpPower"] or 50
                end
            end)
        else
            if jumpPowerConnection then
                jumpPowerConnection:Disconnect()
                jumpPowerConnection = nil
            end
        end
    end
})

PlayerSection:Slider({
    name = "跳跃高度",
    flag = "JumpPower",
    min = 50,
    max = 400,
    default = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.JumpPower or 50,
    valueText = "跳跃高度: [VALUE]",
    callback = function(Jump)
        if jumpPowerEnabled then
            task.spawn(function() 
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.JumpPower = Jump 
                end
            end)
        end
    end
})

-- 重力设置（可关闭）
local gravityConnection = nil
local gravityEnabled = false

PlayerSection:Toggle({
    name = "启用重力设置",
    flag = "GravityEnabled",
    callback = function(enabled)
        gravityEnabled = enabled
        if enabled then
            if gravityConnection then
                gravityConnection:Disconnect()
            end
            gravityConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local gravityValue = tonumber(library.flags["Gravity"]) or 196.2
                game.Workspace.Gravity = gravityValue
            end)
        else
            if gravityConnection then
                gravityConnection:Disconnect()
                gravityConnection = nil
            end
        end
    end
})

PlayerSection:Box({
    name = "重力设置",
    flag = "Gravity",
    placeholder = "输入重力值",
    default = tostring(game.Workspace.Gravity),
    boxType = "number",
    callback = function(Gravity)
        if gravityEnabled then
            local gravityValue = tonumber(Gravity) or 196.2
            task.spawn(function() 
                game.Workspace.Gravity = gravityValue 
            end)
        end
    end
})

-- 夜视
PlayerSection:Toggle({
    name = "夜视",
    flag = "Light",
    callback = function(Light)
        task.spawn(function() 
            while task.wait() do 
                if Light then 
                    game.Lighting.Ambient = Color3.new(1, 1, 1) 
                else 
                    game.Lighting.Ambient = Color3.new(0, 0, 0) 
                end 
            end 
        end)
    end
})

-- 透视（可关闭开关）
local espConnection = nil
local espPlayerAddedConnection = nil
local espPlayerRemovingConnection = nil
local espHeartbeatConnection = nil

PlayerSection:Toggle({
    name = "透视",
    flag = "ESP",
    callback = function(enabled)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        
        if enabled then
            local highlight = Instance.new("Highlight") 
            highlight.Name = "Highlight"
            
            local function addHighlight(player)
                if not player or not player.Character then return end
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then return end
                
                if not humanoidRootPart:FindFirstChild("Highlight") then 
                    local highlightClone = highlight:Clone() 
                    highlightClone.Adornee = player.Character 
                    highlightClone.Parent = humanoidRootPart
                    highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                    highlightClone.Name = "Highlight"
                end
            end
            
            -- 为现有玩家添加高亮
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Players.LocalPlayer then
                    pcall(function()
                        if v.Character then
                            addHighlight(v)
                        else
                            v.CharacterAdded:Connect(function()
                                addHighlight(v)
                            end)
                        end
                    end)
                end
            end
            
            -- 新玩家加入时添加高亮
            espPlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
                pcall(function()
                    if player.Character then
                        addHighlight(player)
                    else
                        player.CharacterAdded:Connect(function()
                            addHighlight(player)
                        end)
                    end
                end)
            end)
            
            -- 玩家离开时移除高亮
            espPlayerRemovingConnection = Players.PlayerRemoving:Connect(function(playerRemoved)
                pcall(function()
                    if playerRemoved.Character and playerRemoved.Character:FindFirstChild("HumanoidRootPart") then
                        local highlightObj = playerRemoved.Character.HumanoidRootPart:FindFirstChild("Highlight")
                        if highlightObj then
                            highlightObj:Destroy()
                        end
                    end
                end)
            end)
            
            -- 持续检查并添加高亮
            espHeartbeatConnection = RunService.Heartbeat:Connect(function()
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= Players.LocalPlayer then
                        pcall(function()
                            if v.Character then
                                addHighlight(v)
                            end
                        end)
                    end
                end
            end)
        else
            -- 关闭透视：移除所有高亮
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local highlightObj = v.Character.HumanoidRootPart:FindFirstChild("Highlight")
                        if highlightObj then
                            highlightObj:Destroy()
                        end
                    end)
                end
            end
            
            -- 断开所有连接
            if espPlayerAddedConnection then
                espPlayerAddedConnection:Disconnect()
                espPlayerAddedConnection = nil
            end
            if espPlayerRemovingConnection then
                espPlayerRemovingConnection:Disconnect()
                espPlayerRemovingConnection = nil
            end
            if espHeartbeatConnection then
                espHeartbeatConnection:Disconnect()
                espHeartbeatConnection = nil
            end
        end
    end
})

-- 隐身道具
PlayerSection:Button({
    name = "隐身道具",
    callback = function()
        safeLoadScript("https://gist.githubusercontent.com/skid123skidlol/cd0d2dce51b3f20ad1aac941da06a1a1/raw/f58b98cce7d51e53ade94e7bb460e4f24fb7e0ff/%257BFE%257D%2520Invisible%2520Tool%2520(can%2520hold%2520tools)", true)
    end
})

-- 穿墙
local NoClipConnection = nil
local Clipon = false
PlayerSection:Toggle({
    name = "穿墙(可用)",
    flag = "NoClip",
    callback = function(NC)
        local Workspace = game:GetService("Workspace") 
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        
        if NC then 
            Clipon = true 
            if NoClipConnection then
                NoClipConnection:Disconnect()
            end
            NoClipConnection = RunService.Stepped:Connect(function() 
                if Clipon and Players.LocalPlayer.Character then
                    pcall(function()
                        for _, part in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then 
                                part.CanCollide = false 
                            end
                        end
                    end)
                end 
            end)
        else 
            Clipon = false 
            if NoClipConnection then
                NoClipConnection:Disconnect()
                NoClipConnection = nil
            end
        end 
    end
})

-- 创建"通用"section
local GeneralSection = MainTab:Section({
    name = "通用",
    column = 1
})

-- 最强透视
GeneralSection:Button({
    name = "最强透视",
    callback = function()
        safeLoadScript("https://pastebin.com/raw/uw2P2fbY")
    end
})

-- 飞行v3
GeneralSection:Button({
    name = "飞行v3",
    callback = function()
        safeLoadScript('https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt')
    end
})

-- 甩人
GeneralSection:Button({
    name = "甩人",
    callback = function()
        safeLoadScript("https://pastebin.com/raw/zqyDSUWX")
    end
})

-- 反挂机v2
GeneralSection:Button({
    name = "反挂机v2",
    callback = function()
        safeLoadScript("https://pastebin.com/raw/9fFu43FF")
    end
})

-- 铁拳
GeneralSection:Button({
    name = "铁拳",
    callback = function()
        safeLoadScript('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt')
    end
})

-- 键盘
GeneralSection:Button({
    name = "键盘",
    callback = function()
        safeLoadScript("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt")
    end
})

-- 动画中心
GeneralSection:Button({
    name = "动画中心",
    callback = function()
        safeLoadScript("https://raw.githubusercontent.com/GamingScripter/Animation-Hub/main/Animation%20Gui", true)
    end
})

-- 立即死亡
GeneralSection:Button({
    name = "立即死亡",
    callback = function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.Health = 0
        end
    end
})

-- 爬墙
GeneralSection:Button({
    name = "爬墙",
    callback = function()
        safeLoadScript("https://pastebin.com/raw/zXk4Rq2r")
    end
})

-- 转起来
GeneralSection:Button({
    name = "转起来",
    callback = function()
        safeLoadScript('https://pastebin.com/raw/r97d7dS0', true)
    end
})

-- 子弹追踪
GeneralSection:Button({
    name = "子弹追踪",
    callback = function()
        safeLoadScript("https://pastebin.com/raw/1AJ69eRG")
    end
})

-- 飞车
GeneralSection:Button({
    name = "飞车",
    callback = function()
        safeLoadScript("https://pastebin.com/raw/63T0fkBm")
    end
})

-- 吸人
GeneralSection:Button({
    name = "吸人",
    callback = function()
        safeLoadScript("https://shz.al/~HHAKS")
    end
})

-- 无限跳跃
GeneralSection:Button({
    name = "无限跳跃",
    callback = function()
        safeLoadScript("https://pastebin.com/raw/V5PQy3y0", true)
    end
})

-- 创建"ESP"section
local ESPSection = MainTab:Section({
    name = "ESP",
    column = 2
})

-- 人物显示
ESPSection:Toggle({
    name = "人物显示",
    flag = "RWXS",
    callback = function(RWXS)
        getgenv().enabled = RWXS 
        getgenv().filluseteamcolor = true 
        getgenv().outlineuseteamcolor = true 
        getgenv().fillcolor = Color3.new(1, 0, 0) 
        getgenv().outlinecolor = Color3.new(1, 1, 1) 
        getgenv().filltrans = 0.5 
        getgenv().outlinetrans = 0.5 
        safeLoadScript("https://raw.githubusercontent.com/Vcsk/RobloxScripts/main/Highlight-ESP.lua")
    end
})

-- 创建"其他"section
local OtherSection = MainTab:Section({
    name = "其他",
    column = 2
})

-- 死亡笔记
OtherSection:Button({
    name = "死亡笔记",
    callback = function()
        safeLoadScript("https://raw.githubusercontent.com/krlpl/dfhj/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0.txt")
    end
})