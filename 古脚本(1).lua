-- Roblox 手机端 UI 工具库 - 带开关界面
-- 专为 Delta 注入器优化
-- 支持界面隐藏/显示
-- 紫色主题设计
-- 作者：古脚本
-- 版本：1.5.0
-- 
-- 使用说明：
-- 1. 下载 Delta 注入器（手机端）
-- 2. 打开 Roblox 应用
-- 3. 运行 Delta 注入器，选择此脚本
-- 4. 脚本会自动注入到 Roblox 中
-- 5. 使用屏幕上的浮动控制面板操作
-- 
-- 功能特点：
-- - 紫色主题 UI 设计，视觉效果统一
-- - 可拖拽的浮动控制面板，操作便捷
-- - 支持隐藏/显示所有界面，节省屏幕空间
-- - 平滑的动画效果，提升用户体验
-- - 手机端触摸优化，支持各种触摸操作
-- - 响应式设计，适配不同屏幕尺寸
-- - 专为 Delta 注入器优化，确保稳定运行
-- - 完整的调试系统，方便开发和维护
-- - 模块化设计，易于扩展和定制

-- 服务
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- 检测当前注入器
local function 检测注入器()
    local 注入器信息 = {
        name = "未知",
        version = "未知",
        isSupported = false
    }
    
    -- 检测Delta（推荐注入器）
    if getgenv and getgenv()._G and getgenv()._G.Delta then
        注入器信息.name = "Delta"
        注入器信息.version = getgenv()._G.Delta.Version or "未知"
        注入器信息.isSupported = true
        return 注入器信息
    end
    
    -- 检测其他常见注入器
    if syn then
        注入器信息.name = "Synapse X"
        注入器信息.isSupported = true
        return 注入器信息
    end
    
    if krnl_secure_load then
        注入器信息.name = "KRNL"
        注入器信息.isSupported = true
        return 注入器信息
    end
    
    if PROTOSMASHER_LOADED then
        注入器信息.name = "ProtoSmasher"
        注入器信息.isSupported = true
        return 注入器信息
    end
    
    if identifyexecutor and identifyexecutor() == "Script-Ware" then
        注入器信息.name = "Script-Ware"
        注入器信息.isSupported = true
        return 注入器信息
    end
    
    return 注入器信息
end

-- 注入器信息
local 当前注入器 = 检测注入器()
local 是Delta注入器 = 当前注入器.name == "Delta"

-- 优化Delta注入器性能
if 是Delta注入器 then
    -- Delta注入器特定优化
    print("🎯 Delta注入器已检测到，应用最佳优化配置")
    print("📱 手机端模式已启用")
end

-- 全局变量
local 本地玩家 = Players.LocalPlayer
local 当前设备 = UserInputService.TouchEnabled and "手机" or "电脑"
local 触摸位置 = nil
local 调试模式 = false
local 界面状态 = {
    主界面显示 = true,
    开关面板显示 = true,
    所有窗口 = {},
    所有连接 = {}
}

-- 配置常量（避免硬编码）
local 配置常量 = {
    颜色 = {
        背景深色 = Color3.fromRGB(30, 15, 50), -- 深紫色背景
        背景浅色 = Color3.fromRGB(35, 18, 60), -- 浅紫色背景
        按钮正常 = Color3.fromRGB(50, 25, 90), -- 紫色按钮
        按钮按下 = Color3.fromRGB(60, 30, 110), -- 按下状态
        按钮成功 = Color3.fromRGB(70, 180, 100),
        按钮警告 = Color3.fromRGB(220, 160, 50),
        按钮错误 = Color3.fromRGB(220, 80, 70),
        文字白色 = Color3.fromRGB(255, 255, 255),
        文字灰色 = Color3.fromRGB(180, 180, 180)
    },
    尺寸 = {
        开关面板按钮 = 45,
        开关面板间距 = 5,
        最小间距 = 5,
        标题栏高度 = 40,
        按钮圆角 = 10,
        窗口圆角 = 16
    },
    动画 = {
        平滑度 = 0.1,
        开关速度 = 0.3,
        通知入场 = 0.3
    }
}

-- UI 工具库
local UI库 = {
    -- 库信息
    版本 = "1.5.0", -- 更新版本号
    作者 = "古脚本",
    邮箱 = "guscript@example.com",
    设备类型 = 当前设备,
    创建日期 = "2024年",
    
    -- 全局主题色设置
    主题色 = Color3.fromRGB(138, 43, 226), -- 紫色主题
    
    -- 设置主题色
    设置主题色 = function(颜色)
        UI库.主题色 = 颜色
        UI库.打印调试信息("主题色已设置为: " .. UI库.颜色.转格式(颜色))
    end,
    
    -- 获取主题色变体
    获取主题色变体 = function(亮度偏移)
        亮度偏移 = 亮度偏移 or 0
        local 颜色 = UI库.主题色
        local 红, 绿, 蓝 = 颜色.R * 255, 颜色.G * 255, 颜色.B * 255
        
        -- 调整亮度
        红 = math.clamp(红 + 亮度偏移, 0, 255)
        绿 = math.clamp(绿 + 亮度偏移, 0, 255)
        蓝 = math.clamp(蓝 + 亮度偏移, 0, 255)
        
        return Color3.fromRGB(红, 绿, 蓝)
    end,
    
    -- 作者信息函数
    显示作者信息 = function()
        print("🎨 UI库作者: " .. UI库.作者)
        print("📅 版本: " .. UI库.版本)
        print("🌐 网站: " .. UI库.作者网站)
        print("📧 邮箱: " .. UI库.邮箱)
        print("🎨 主题色: " .. UI库.颜色.转格式(UI库.主题色))
    end,
    
    -- 调试函数
    启用调试 = function()
        调试模式 = true
        print("📱 UI库调试模式已启用")
        print("📊 设备类型:", 当前设备)
        print("🎮 玩家:", 本地玩家.Name)
        UI库.显示作者信息()
    end,
    
    打印调试信息 = function(信息)
        if 调试模式 then
            print("🔍 UI调试:", 信息)
        end
    end,
    
    -- 颜色处理
    颜色 = {
        相加 = function(颜色1, 颜色2)
            local 红 = math.min((颜色1.R + 颜色2.R) * 255, 255)
            local 绿 = math.min((颜色1.G + 颜色2.G) * 255, 255)
            local 蓝 = math.min((颜色1.B + 颜色2.B) * 255, 255)
            return Color3.fromRGB(红, 绿, 蓝)
        end,
        
        相减 = function(颜色1, 颜色2)
            local 红 = math.max((颜色1.R - 颜色2.R) * 255, 0)
            local 绿 = math.max((颜色1.G - 颜色2.G) * 255, 0)
            local 蓝 = math.max((颜色1.B - 颜色2.B) * 255, 0)
            return Color3.fromRGB(红, 绿, 蓝)
        end,
        
        转格式 = function(颜色)
            local 红 = math.floor(math.min(颜色.R * 255, 255))
            local 绿 = math.floor(math.min(颜色.G * 255, 255))
            local 蓝 = math.floor(math.min(颜色.B * 255, 255))
            return string.format("rgb(%d, %d, %d)", 红, 绿, 蓝)
        end,
        
        随机色 = function()
            return Color3.fromRGB(
                math.random(50, 200),
                math.random(50, 200),
                math.random(50, 200)
            )
        end,
        
        十六进制转颜色 = function(十六进制)
            十六进制 = 十六进制:gsub("#", "")
            local 红 = tonumber(十六进制:sub(1, 2), 16) or 255
            local 绿 = tonumber(十六进制:sub(3, 4), 16) or 255
            local 蓝 = tonumber(十六进制:sub(5, 6), 16) or 255
            return Color3.fromRGB(红, 绿, 蓝)
        end,
        
        -- 新增：字符串转颜色（支持rgb和十六进制）
        字符串转颜色 = function(颜色字符串)
            if type(颜色字符串) ~= "string" then
                return 颜色字符串 -- 如果已经是Color3，直接返回
            end
            
            -- 移除空格
            颜色字符串 = 颜色字符串:gsub("%s+", "")
            
            -- 处理十六进制格式
            if 颜色字符串:sub(1, 1) == "#" then
                return UI库.颜色.十六进制转颜色(颜色字符串)
            end
            
            -- 处理rgb格式
            local 红, 绿, 蓝 = 颜色字符串:match("rgb%((%d+),(%d+),(%d+)%)")
            if 红 and 绿 and 蓝 then
                return Color3.fromRGB(tonumber(红), tonumber(绿), tonumber(蓝))
            end
            
            -- 如果都不匹配，返回白色
            warn("❌ 无法解析颜色字符串: " .. 颜色字符串)
            return Color3.new(1, 1, 1)
        end,
        
        -- 古脚本主题色（现在使用全局主题色）
        古脚本蓝 = function() return UI库.主题色 end,
        古脚本绿 = function() return UI库.获取主题色变体(50) end,
        古脚本红 = function() return Color3.fromRGB(220, 20, 60) end,
        古脚本紫 = function() return Color3.fromRGB(138, 43, 226) end,
        古脚本橙 = function() return Color3.fromRGB(255, 140, 0) end
    }
}

-- 创建 UI 元素
UI库.创建 = function(类别, 属性表, 圆角半径, 阴影)
    local 实例 = Instance.new(类别)
    
    -- 设置属性
    for 属性名, 属性值 in pairs(属性表) do
        if 属性名 ~= "Parent" then
            if typeof(属性值) == "Instance" then
                属性值.Parent = 实例
            else
                实例[属性名] = 属性值
            end
        end
    end
    
    -- 添加圆角
    if 圆角半径 then
        local 圆角 = Instance.new("UICorner")
        圆角.CornerRadius = UDim.new(0, 圆角半径)
        圆角.Parent = 实例
    end
    
    -- 设置父级
    if 属性表.Parent then
        实例.Parent = 属性表.Parent
    end
    
    UI库.打印调试信息("创建 " .. 类别 .. " 元素")
    
    return 实例
end

-- 触摸拖拽函数（手机端优化） - 已增强
UI库.设为可触摸拖拽 = function(目标对象, 拖拽区域, 配置)
    if not 目标对象 or not 拖拽区域 then
        warn("❌ 拖拽函数缺少必要参数")
        return function() end
    end
    
    -- 默认配置
    local 配置表 = 配置 or {}
    local 平滑度 = 配置表.平滑度 or 配置常量.动画.平滑度
    local 限制边界 = 配置表.限制边界 or true
    local 最小间距 = 配置表.最小间距 or 配置常量.尺寸.最小间距
    local 拖拽时置顶 = 配置表.拖拽时置顶 or true
    local 启用平滑移动 = 配置表.启用平滑移动 or true  -- 新增选项
    
    local 正在拖拽 = false
    local 偏移量 = Vector2.new(0, 0)
    local 屏幕尺寸 = workspace.CurrentCamera.ViewportSize
    local 连接列表 = {}
    
    -- 触摸开始
    local 触摸开始连接 = 拖拽区域.InputBegan:Connect(function(输入)
        if 输入.UserInputType == Enum.UserInputType.Touch then
            正在拖拽 = true
            触摸位置 = 输入.Position
            偏移量 = Vector2.new(
                触摸位置.X - 目标对象.AbsolutePosition.X,
                触摸位置.Y - 目标对象.AbsolutePosition.Y
            )
            
            if 拖拽时置顶 then
                目标对象.ZIndex = 100
            end
            
            UI库.打印调试信息("开始拖拽")
        end
    end)
    table.insert(连接列表, 触摸开始连接)
    
    -- 触摸移动
    local 触摸移动连接 = 拖拽区域.InputChanged:Connect(function(输入)
        if 正在拖拽 and 输入.UserInputType == Enum.UserInputType.Touch then
            触摸位置 = 输入.Position
            local 目标X = 触摸位置.X - 偏移量.X
            local 目标Y = 触摸位置.Y - 偏移量.Y
            
            -- 边界限制
            if 限制边界 then
                local 对象尺寸 = 目标对象.AbsoluteSize
                目标X = math.clamp(目标X, 最小间距, 屏幕尺寸.X - 对象尺寸.X - 最小间距)
                目标Y = math.clamp(目标Y, 最小间距, 屏幕尺寸.Y - 对象尺寸.Y - 最小间距)
            end
            
            -- 平滑移动或直接移动
            if 启用平滑移动 then
                TweenService:Create(目标对象, TweenInfo.new(平滑度, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(0, 目标X, 0, 目标Y)
                }):Play()
            else
                -- 直接移动，无延迟
                目标对象.Position = UDim2.new(0, 目标X, 0, 目标Y)
            end
        end
    end)
    table.insert(连接列表, 触摸移动连接)
    
    -- 触摸结束
    local 触摸结束连接 = UserInputService.TouchEnded:Connect(function(输入)
        正在拖拽 = false
        目标对象.ZIndex = 1
        
        UI库.打印调试信息("结束拖拽")
    end)
    table.insert(连接列表, 触摸结束连接)
    
    -- 返回清理函数
    local 清理函数 = function()
        for _, 连接 in ipairs(连接列表) do
            连接:Disconnect()
        end
        UI库.打印调试信息("拖拽功能已清理")
    end
    
    table.insert(界面状态.所有连接, 清理函数)
    
    return 清理函数
end

-- 创建开关面板（浮动控制面板）
UI库.创建开关面板 = function(配置)
    local 默认配置 = {
        位置 = UDim2.new(0.02, 0, 0.4, 0),
        大小 = UDim2.new(0, 55, 0, 180),
        圆角 = 15,
        背景颜色 = 配置常量.颜色.背景浅色,
        按钮大小 = 配置常量.尺寸.开关面板按钮,
        图标颜色 = Color3.fromRGB(220, 220, 220),
        背景透明度 = 0.85
    }
    
    -- 合并配置
    for 键, 值 in pairs(配置 or {}) do
        默认配置[键] = 值
    end
    
    -- 创建开关面板容器
    local 开关面板 = UI库.创建("Frame", {
        Size = 默认配置.大小,
        Position = 默认配置.位置,
        BackgroundColor3 = 默认配置.背景颜色,
        BackgroundTransparency = 默认配置.背景透明度,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true
    }, 默认配置.圆角)
    
    开关面板.Parent = CoreGui
    
    -- 让面板可拖拽
    UI库.设为可触摸拖拽(开关面板, 开关面板, {
        平滑度 = 0.05,
        限制边界 = true,
        最小间距 = 配置常量.尺寸.开关面板间距,
        启用平滑移动 = true  -- 可根据需要调整
    })
    
    -- 主开关按钮 - 修复点击事件冲突
    local 主开关按钮 = UI库.创建("TextButton", {
        Size = UDim2.new(1, -10, 0, 默认配置.按钮大小),
        Position = UDim2.new(0, 5, 0, 5),
        Text = "📱",  -- 手机图标
        TextSize = 24,
        TextColor3 = 默认配置.图标颜色,
        BackgroundColor3 = 配置常量.颜色.按钮正常,
        BorderSizePixel = 0,
        Parent = 开关面板
    }, 10)
    
    -- 隐藏/显示所有界面按钮
    local 隐藏显示按钮 = UI库.创建("TextButton", {
        Size = UDim2.new(1, -10, 0, 默认配置.按钮大小),
        Position = UDim2.new(0, 5, 0, 55),
        Text = "👁",  -- 眼睛图标
        TextSize = 24,
        TextColor3 = 默认配置.图标颜色,
        BackgroundColor3 = 配置常量.颜色.按钮正常,
        BorderSizePixel = 0,
        Parent = 开关面板
    }, 10)
    
    -- 关闭所有界面按钮
    local 关闭按钮 = UI库.创建("TextButton", {
        Size = UDim2.new(1, -10, 0, 默认配置.按钮大小),
        Position = UDim2.new(0, 5, 0, 105),
        Text = "❌",  -- 关闭图标
        TextSize = 24,
        TextColor3 = 默认配置.图标颜色,
        BackgroundColor3 = 配置常量.颜色.按钮错误,
        BorderSizePixel = 0,
        Parent = 开关面板
    }, 10)
    
    -- 添加古脚本标识
    local 作者标识 = UI库.创建("TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, 25),
        Text = "古脚本 UI",
        TextColor3 = UI库.颜色.古脚本蓝(),
        TextSize = 12,
        BackgroundTransparency = 1,
        Parent = 开关面板
    })
    
    -- 面板控制函数
    local 面板控制器 = {
        面板 = 开关面板,
        当前状态 = true,
        
        切换所有界面 = function(显示)
            for _, 窗口信息 in ipairs(界面状态.所有窗口) do
                if 窗口信息.窗口 and 窗口信息.窗口.Parent then
                    窗口信息.窗口.Visible = 显示
                    if 显示 then
                        TweenService:Create(窗口信息.窗口, TweenInfo.new(0.3), {
                            BackgroundTransparency = 窗口信息.背景透明度 or 0
                        }):Play()
                    else
                        TweenService:Create(窗口信息.窗口, TweenInfo.new(0.3), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end
            end
            界面状态.主界面显示 = 显示
            隐藏显示按钮.Text = 显示 and "👁" or "🔲"
            
            -- 发送通知
            UI库.发送通知({
                标题 = 显示 and "界面已显示" or "界面已隐藏",
                内容 = 显示 and "所有功能界面已显示" or "所有功能界面已隐藏",
                类型 = 显示 and "成功" or "警告"
            })
        end,
        
        切换开关面板 = function()
            if 开关面板.Size == 默认配置.大小 then
                -- 缩小为小圆点
                TweenService:Create(开关面板, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 20, 0, 20),
                    BackgroundTransparency = 0.5
                }):Play()
                
                -- 隐藏按钮文字
                task.delay(0.15, function()
                    主开关按钮.Visible = false
                    隐藏显示按钮.Visible = false
                    关闭按钮.Visible = false
                    作者标识.Visible = false
                end)
            else
                -- 恢复原大小
                TweenService:Create(开关面板, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = 默认配置.大小,
                    BackgroundTransparency = 默认配置.背景透明度
                }):Play()
                
                -- 显示按钮文字
                task.delay(0.15, function()
                    主开关按钮.Visible = true
                    隐藏显示按钮.Visible = true
                    关闭按钮.Visible = true
                    作者标识.Visible = true
                end)
            end
        end,
        
        关闭所有界面 = function()
            for _, 窗口信息 in ipairs(界面状态.所有窗口) do
                if 窗口信息.窗口 and 窗口信息.窗口.Parent then
                    窗口信息.窗口:Destroy()
                end
            end
            界面状态.所有窗口 = {}
            
            -- 清理所有连接
            for _, 清理函数 in ipairs(界面状态.所有连接) do
                pcall(清理函数)
            end
            界面状态.所有连接 = {}
            
            UI库.发送通知({
                标题 = "清理完成",
                内容 = "所有界面已关闭",
                类型 = "信息"
            })
        end,
        
        隐藏 = function()
            开关面板.Visible = false
        end,
        
        显示 = function()
            开关面板.Visible = true
        end
    }
    
    -- 修复点击事件冲突
    local 主开关按钮上次点击时间 = 0
    local 主开关按钮点击次数 = 0
    
    主开关按钮.MouseButton1Click:Connect(function()
        local 当前时间 = tick()
        
        if 当前时间 - 主开关按钮上次点击时间 < 0.5 then
            主开关按钮点击次数 = 主开关按钮点击次数 + 1
        else
            主开关按钮点击次数 = 1
        end
        
        主开关按钮上次点击时间 = 当前时间
        
        -- 双击检测
        if 主开关按钮点击次数 == 2 then
            面板控制器.切换所有界面(not 界面状态.主界面显示)
            主开关按钮点击次数 = 0
        else
            -- 单次点击切换开关面板
            面板控制器.切换开关面板()
        end
    end)
    
    隐藏显示按钮.MouseButton1Click:Connect(function()
        面板控制器.切换所有界面(not 界面状态.主界面显示)
    end)
    
    关闭按钮.MouseButton1Click:Connect(function()
        面板控制器.关闭所有界面()
    end)
    
    -- 添加双击提示
    local 提示 = UI库.创建("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, 5),
        Text = "双击切换显示",
        TextColor3 = 配置常量.颜色.文字灰色,
        TextSize = 12,
        BackgroundTransparency = 1,
        Parent = 开关面板
    })
    
    -- 添加触摸反馈
    for _, 按钮 in pairs({主开关按钮, 隐藏显示按钮, 关闭按钮}) do
        按钮.MouseButton1Down:Connect(function()
            按钮.BackgroundColor3 = 按钮 == 关闭按钮 and Color3.fromRGB(150, 40, 40) or 配置常量.颜色.按钮按下
        end)
        
        按钮.MouseButton1Up:Connect(function()
            按钮.BackgroundColor3 = 按钮 == 关闭按钮 and 配置常量.颜色.按钮错误 or 配置常量.颜色.按钮正常
        end)
        
        按钮.MouseLeave:Connect(function()
            按钮.BackgroundColor3 = 按钮 == 关闭按钮 and 配置常量.颜色.按钮错误 or 配置常量.颜色.按钮正常
        end)
    end
    
    -- 添加到窗口列表
    table.insert(界面状态.所有窗口, {
        窗口 = 开关面板,
        名称 = "开关面板",
        背景透明度 = 默认配置.背景透明度
    })
    
    return 面板控制器
end

-- 创建功能窗口（带开关控制）- 已修复销毁问题
UI库.创建功能窗口 = function(配置)
    local 默认配置 = {
        标题 = "功能窗口",
        大小 = UDim2.new(0, 320, 0, 400),
        位置 = UDim2.new(0.5, -160, 0.5, -200),
        可拖拽 = true,
        可关闭 = true,
        可隐藏 = true,
        圆角 = 配置常量.尺寸.窗口圆角,
        背景颜色 = 配置常量.颜色.背景深色,
        标题栏颜色 = Color3.fromRGB(50, 25, 90), -- 紫色标题栏
        标题颜色 = 配置常量.颜色.文字白色,
        背景透明度 = 0,
        默认显示 = true,
        显示作者标识 = true
    }
    
    -- 合并配置
    for 键, 值 in pairs(配置 or {}) do
        默认配置[键] = 值
    end
    
    -- 创建主窗口
    local 窗口 = UI库.创建("Frame", {
        Size = 默认配置.大小,
        Position = 默认配置.位置,
        BackgroundColor3 = 默认配置.背景颜色,
        BackgroundTransparency = 默认配置.背景透明度,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = 默认配置.默认显示
    }, 默认配置.圆角)
    
    窗口.Parent = CoreGui
    
    -- 标题栏
    local 标题栏
    if 默认配置.可拖拽 or 默认配置.标题 then
        标题栏 = UI库.创建("Frame", {
            Size = UDim2.new(1, 0, 0, 配置常量.尺寸.标题栏高度),
            BackgroundColor3 = 默认配置.标题栏颜色,
            Parent = 窗口
        }, 默认配置.圆角)
        
        -- 标题文字
        if 默认配置.标题 then
            UI库.创建("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Text = 默认配置.标题,
                TextColor3 = 默认配置.标题颜色,
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = 标题栏
            })
        end
        
        -- 控制按钮容器
        local 按钮容器 = UI库.创建("Frame", {
            Size = UDim2.new(0, 60, 1, 0),
            Position = UDim2.new(1, -60, 0, 0),
            BackgroundTransparency = 1,
            Parent = 标题栏
        })
        
        -- 最小化按钮（隐藏窗口）
        if 默认配置.可隐藏 then
            local 最小化按钮 = UI库.创建("TextButton", {
                Size = UDim2.new(0, 25, 0, 25),
                Position = UDim2.new(0, 5, 0.5, -12.5),
                Text = "_",
                TextColor3 = 配置常量.颜色.文字白色,
                TextSize = 16,
                BackgroundColor3 = Color3.fromRGB(60, 30, 110), -- 紫色最小化按钮
                BorderSizePixel = 0,
                Parent = 按钮容器
            }, 6)
            
            最小化按钮.MouseButton1Click:Connect(function()
                if 窗口.Visible then
                    -- 隐藏窗口
                    local 隐藏动画 = TweenService:Create(窗口, TweenInfo.new(0.2), {
                        BackgroundTransparency = 1
                    })
                    隐藏动画:Play()
                    隐藏动画.Completed:Connect(function()
                        窗口.Visible = false
                    end)
                else
                    -- 显示窗口
                    窗口.Visible = true
                    local 显示动画 = TweenService:Create(窗口, TweenInfo.new(0.2), {
                        BackgroundTransparency = 默认配置.背景透明度
                    })
                    显示动画:Play()
                end
            end)
        end
        
        -- 关闭按钮
        if 默认配置.可关闭 then
            local 关闭按钮 = UI库.创建("TextButton", {
                Size = UDim2.new(0, 25, 0, 25),
                Position = UDim2.new(1, -30, 0.5, -12.5),
                Text = "X",
                TextColor3 = 配置常量.颜色.文字白色,
                TextSize = 16,
                BackgroundColor3 = 配置常量.颜色.按钮错误,
                BorderSizePixel = 0,
                Parent = 按钮容器
            }, 6)
            
            关闭按钮.MouseButton1Click:Connect(function()
                -- 防止重复点击
                if 窗口:FindFirstChild("正在销毁") then return end
                窗口:SetAttribute("正在销毁", true)
                
                -- 淡出动画
                local 淡出动画 = TweenService:Create(窗口, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                })
                淡出动画:Play()
                淡出动画.Completed:Connect(function()
                    if 窗口 and 窗口.Parent then
                        窗口:Destroy()
                    end
                    
                    -- 从窗口列表中移除
                    for i, 窗口信息 in ipairs(界面状态.所有窗口) do
                        if 窗口信息.窗口 == 窗口 then
                            table.remove(界面状态.所有窗口, i)
                            break
                        end
                    end
                end)
            end)
        end
    end
    
    -- 内容区域
    local 内容区域 = UI库.创建("Frame", {
        Size = UDim2.new(1, 0, 1, -配置常量.尺寸.标题栏高度),
        Position = UDim2.new(0, 0, 0, 配置常量.尺寸.标题栏高度),
        BackgroundTransparency = 1,
        Parent = 窗口
    })
    
    -- 拖拽功能
    if 默认配置.可拖拽 and 标题栏 then
        UI库.设为可触摸拖拽(窗口, 标题栏, {
            平滑度 = 0.05,
            限制边界 = true,
            最小间距 = 10
        })
    end
    
    -- 添加作者标识（在窗口右下角）
    if 默认配置.显示作者标识 then
        local 作者标识 = UI库.创建("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 1, -25),
            Text = "古脚本 UI v" .. UI库.版本,
            TextColor3 = UI库.颜色.古脚本蓝(),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            Parent = 窗口
        })
        
        -- 添加点击事件显示作者信息
        作者标识.MouseButton1Click:Connect(function()
            UI库.发送通知({
                标题 = "古脚本 UI 库",
                内容 = "作者: " .. UI库.作者 .. "\n版本: " .. UI库.版本 .. "\n网站: " .. UI库.作者网站,
                类型 = "信息",
                显示时长 = 5
            })
        end)
    end
    
    -- 添加到窗口列表
    table.insert(界面状态.所有窗口, {
        窗口 = 窗口,
        名称 = 默认配置.标题,
        背景透明度 = 默认配置.背景透明度,
        原始背景色 = 默认配置.背景颜色
    })
    
    -- 返回窗口对象和控制函数
    local 窗口对象 = {
        主窗口 = 窗口,
        标题栏 = 标题栏,
        内容区域 = 内容区域,
        
        显示 = function()
            if 窗口 and 窗口.Parent then
                窗口.Visible = true
                local 显示动画 = TweenService:Create(窗口, TweenInfo.new(0.3), {
                    BackgroundTransparency = 默认配置.背景透明度
                })
                显示动画:Play()
            end
        end,
        
        隐藏 = function()
            if 窗口 and 窗口.Parent then
                local 隐藏动画 = TweenService:Create(窗口, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1
                })
                隐藏动画:Play()
                隐藏动画.Completed:Connect(function()
                    if 窗口 and 窗口.Parent then
                        窗口.Visible = false
                    end
                end)
            end
        end,
        
        切换显示 = function()
            if 窗口 and 窗口.Parent then
                if 窗口.Visible then
                    窗口对象.隐藏()
                else
                    窗口对象.显示()
                end
            end
        end,
        
        销毁 = function()
            if 窗口 and 窗口.Parent then
                if 窗口:FindFirstChild("正在销毁") then return end
                窗口:SetAttribute("正在销毁", true)
                窗口:Destroy()
                
                -- 从窗口列表中移除
                for i, 窗口信息 in ipairs(界面状态.所有窗口) do
                    if 窗口信息.窗口 == 窗口 then
                        table.remove(界面状态.所有窗口, i)
                        break
                    end
                end
            end
        end,
        
        设置标题 = function(新标题)
            if 标题栏 and 标题栏.Parent then
                local 标题标签 = 标题栏:FindFirstChildOfClass("TextLabel")
                if 标题标签 then
                    标题标签.Text = 新标题
                end
            end
        end,
        
        设置背景色 = function(新颜色)
            if 窗口 and 窗口.Parent then
                窗口.BackgroundColor3 = UI库.颜色.字符串转颜色(新颜色)
                
                -- 更新窗口列表中的信息
                for i, 窗口信息 in ipairs(界面状态.所有窗口) do
                    if 窗口信息.窗口 == 窗口 then
                        界面状态.所有窗口[i].原始背景色 = 窗口.BackgroundColor3
                        break
                    end
                end
            end
        end
    }
    
    return 窗口对象
end

-- 创建功能按钮 - 已添加禁用状态和动画效果
UI库.创建功能按钮 = function(配置)
    local 默认配置 = {
        文本 = "功能按钮",
        父级 = nil,
        点击回调 = function() end,
        开关功能 = false,  -- 是否开关功能
        初始状态 = false,  -- 开关初始状态
        大小 = UDim2.new(0, 140, 0, 45),
        位置 = UDim2.new(0, 10, 0, 10),
        圆角 = 配置常量.尺寸.按钮圆角,
        正常颜色 = Color3.fromRGB(70, 120, 200),
        按下颜色 = Color3.fromRGB(50, 100, 170),
        开启颜色 = Color3.fromRGB(70, 180, 100),
        文字颜色 = 配置常量.颜色.文字白色,
        文字大小 = 16,
        使用古脚本颜色 = false,  -- 是否使用古脚本主题色
        禁用 = false,  -- 新增：是否禁用
        禁用颜色 = Color3.fromRGB(100, 100, 100),  -- 新增：禁用时的颜色
        启用缩放动画 = true  -- 新增：是否启用缩放动画
    }
    
    -- 合并配置
    for 键, 值 in pairs(配置 or {}) do
        默认配置[键] = 值
    end
    
    -- 如果使用古脚本颜色，则使用主题色
    if 默认配置.使用古脚本颜色 then
        默认配置.正常颜色 = UI库.颜色.古脚本蓝()
        默认配置.按下颜色 = UI库.获取主题色变体(-30)
        默认配置.开启颜色 = UI库.颜色.古脚本绿()
    end
    
    local 按钮 = UI库.创建("TextButton", {
        Size = 默认配置.大小,
        Position = 默认配置.位置,
        Text = 默认配置.文本,
        TextColor3 = 默认配置.文字颜色,
        TextSize = 默认配置.文字大小,
        BackgroundColor3 = 默认配置.禁用 and 默认配置.禁用颜色 or 
                         (默认配置.开关功能 and 默认配置.初始状态 and 默认配置.开启颜色 or 默认配置.正常颜色),
        BorderSizePixel = 0,
        AutoButtonColor = false, -- 禁用默认按钮颜色变化
        Parent = 默认配置.父级
    }, 默认配置.圆角)
    
    local 当前状态 = 默认配置.初始状态
    local 禁用状态 = 默认配置.禁用
    
    -- 设置禁用状态函数
    local 设置禁用状态 = function(禁用)
        禁用状态 = 禁用
        if 禁用 then
            按钮.BackgroundColor3 = 默认配置.禁用颜色
            按钮.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.正常颜色
            按钮.TextColor3 = 默认配置.文字颜色
        end
    end
    
    -- 按钮反馈 - 鼠标事件
    按钮.MouseButton1Down:Connect(function()
        if 禁用状态 then return end
        
        if 默认配置.启用缩放动画 then
            -- 缩放动画效果
            TweenService:Create(按钮, TweenInfo.new(0.1), {
                Size = 默认配置.大小 * 0.95
            }):Play()
        end
        
        按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.按下颜色
    end)
    
    按钮.MouseButton1Up:Connect(function()
        if 禁用状态 then return end
        
        if 默认配置.启用缩放动画 then
            TweenService:Create(按钮, TweenInfo.new(0.1), {
                Size = 默认配置.大小
            }):Play()
        end
        
        按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.正常颜色
    end)
    
    按钮.MouseLeave:Connect(function()
        if 禁用状态 then return end
        
        if 默认配置.启用缩放动画 then
            TweenService:Create(按钮, TweenInfo.new(0.1), {
                Size = 默认配置.大小
            }):Play()
        end
        
        按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.正常颜色
    end)
    
    -- 按钮反馈 - 触摸事件（手机端支持）
    按钮.TouchSensitive = true
    
    按钮.TouchTap:Connect(function()
        if 禁用状态 then return end
        
        -- 模拟鼠标点击效果
        if 默认配置.启用缩放动画 then
            TweenService:Create(按钮, TweenInfo.new(0.1), {
                Size = 默认配置.大小 * 0.95
            }):Play()
            
            wait(0.1)
            
            TweenService:Create(按钮, TweenInfo.new(0.1), {
                Size = 默认配置.大小
            }):Play()
        end
        
        -- 触发点击回调
        按钮.MouseButton1Click:Fire()
    end)
    
    按钮.TouchLongPress:Connect(function(holdTime) 
        if 禁用状态 then return end
        
        -- 长按效果（可选）
        按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.按下颜色
    end)
    
    UserInputService.TouchEnded:Connect(function(input) 
        if 禁用状态 then return end
        
        -- 触摸结束时恢复正常颜色
        if input.UserInputType == Enum.UserInputType.Touch then
            按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.正常颜色
        end
    end)
    
    按钮.MouseButton1Click:Connect(function()
        if 禁用状态 then return end
        
        if 默认配置.开关功能 then
            -- 切换开关状态
            当前状态 = not 当前状态
            按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.正常颜色
            
            -- 添加状态指示器
            local 状态文本 = 当前状态 and " [ON]" or " [OFF]"
            if not 按钮:FindFirstChild("状态指示器") then
                local 指示器 = UI库.创建("TextLabel", {
                    Name = "状态指示器",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Text = 当前状态 and "ON" or "OFF",
                    TextColor3 = 当前状态 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100),
                    TextSize = 12,
                    BackgroundTransparency = 1,
                    Parent = 按钮
                })
            else
                local 指示器 = 按钮:FindFirstChild("状态指示器")
                指示器.Text = 当前状态 and "ON" or "OFF"
                指示器.TextColor3 = 当前状态 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            end
        end
        
        -- 执行回调函数
        默认配置.点击回调(当前状态)
    end)
    
    -- 返回按钮对象和控制函数
    local 按钮对象 = {
        按钮 = 按钮,
        状态 = 当前状态,
        
        启用 = function()
            设置禁用状态(false)
        end,
        
        禁用 = function()
            设置禁用状态(true)
        end,
        
        切换状态 = function()
            if 默认配置.开关功能 then
                当前状态 = not 当前状态
                按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.正常颜色
                return 当前状态
            end
            return nil
        end,
        
        设置文本 = function(新文本)
            按钮.Text = 新文本
        end,
        
        设置颜色 = function(新颜色)
            默认配置.正常颜色 = UI库.颜色.字符串转颜色(新颜色)
            if not 禁用状态 then
                按钮.BackgroundColor3 = 当前状态 and 默认配置.开启颜色 or 默认配置.正常颜色
            end
        end
    }
    
    return 按钮对象
end

-- 创建古脚本特色按钮（带古脚本标识）
UI库.创建古脚本按钮 = function(配置)
    local 默认配置 = {
        文本 = "古脚本功能",
        父级 = nil,
        点击回调 = function() end,
        大小 = UDim2.new(0, 160, 0, 50),
        位置 = UDim2.new(0, 10, 0, 10),
        圆角 = 12,
        显示古脚本图标 = true,
        启用缩放动画 = true
    }
    
    -- 合并配置
    for 键, 值 in pairs(配置 or {}) do
        默认配置[键] = 值
    end
    
    local 按钮对象 = UI库.创建功能按钮({
        文本 = 默认配置.文本,
        父级 = 默认配置.父级,
        点击回调 = 默认配置.点击回调,
        大小 = 默认配置.大小,
        位置 = 默认配置.位置,
        圆角 = 默认配置.圆角,
        使用古脚本颜色 = true,
        启用缩放动画 = 默认配置.启用缩放动画
    })
    
    -- 添加古脚本图标
    if 默认配置.显示古脚本图标 then
        local 图标 = UI库.创建("TextLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 5, 0.5, -10),
            Text = "🎨",
            TextSize = 16,
            TextColor3 = 配置常量.颜色.文字白色,
            BackgroundTransparency = 1,
            Parent = 按钮对象.按钮
        })
        
        -- 调整文字位置
        local 文字标签 = 按钮对象.按钮:FindFirstChildOfClass("TextLabel")
        if 文字标签 and 文字标签.Name ~= "状态指示器" then
            文字标签.Position = UDim2.new(0, 25, 0, 0)
            文字标签.Size = UDim2.new(1, -25, 1, 0)
        end
    end
    
    return 按钮对象
end

-- 通知系统 - 已添加图标支持
UI库.发送通知 = function(配置)
    local 默认配置 = {
        标题 = "通知",
        内容 = "这是一条通知",
        类型 = "信息", -- 信息/成功/警告/错误
        显示时长 = 3,
        位置 = UDim2.new(0.5, -150, 0.9, -80),
        可关闭 = true,
        显示作者 = false,  -- 是否显示古脚本标识
        显示图标 = true   -- 新增：是否显示图标
    }
    
    -- 合并配置
    for 键, 值 in pairs(配置 or {}) do
        默认配置[键] = 值
    end
    
    -- 颜色和图标映射
    local 类型映射 = {
        信息 = {
            颜色 = UI库.颜色.古脚本蓝(),
            图标 = "ℹ️"
        },
        成功 = {
            颜色 = UI库.颜色.古脚本绿(),
            图标 = "✅"
        },
        警告 = {
            颜色 = UI库.颜色.古脚本橙(),
            图标 = "⚠️"
        },
        错误 = {
            颜色 = UI库.颜色.古脚本红(),
            图标 = "❌"
        }
    }
    
    local 通知类型 = 类型映射[默认配置.类型] or 类型映射.信息
    
    -- 创建通知
    local 通知 = UI库.创建("Frame", {
        Size = UDim2.new(0, 300, 0, 80),
        Position = 默认配置.位置,
        BackgroundColor3 = 通知类型.颜色,
        BorderSizePixel = 0,
        Parent = CoreGui
    }, 12)
    
    -- 标题区域
    local 标题区域 = UI库.创建("Frame", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        Parent = 通知
    })
    
    -- 图标
    if 默认配置.显示图标 then
        UI库.创建("TextLabel", {
            Size = UDim2.new(0, 25, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            Text = 通知类型.图标,
            TextColor3 = 配置常量.颜色.文字白色,
            TextSize = 16,
            BackgroundTransparency = 1,
            Parent = 标题区域
        })
    end
    
    -- 标题
    local 标题文字 = 默认配置.标题
    if 默认配置.显示作者 then
        标题文字 = "古脚本 | " .. 标题文字
    end
    
    local 标题偏移 = 默认配置.显示图标 and 30 or 10
    UI库.创建("TextLabel", {
        Size = UDim2.new(1, -标题偏移, 1, 0),
        Position = UDim2.new(0, 标题偏移, 0, 0),
        Text = 标题文字,
        TextColor3 = 配置常量.颜色.文字白色,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Parent = 标题区域
    })
    
    -- 内容
    UI库.创建("TextLabel", {
        Size = UDim2.new(1, -20, 1, -30),
        Position = UDim2.new(0, 10, 0, 30),
        Text = 默认配置.内容,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Parent = 通知
    })
    
    -- 添加古脚本标识
    if 默认配置.显示作者 then
        local 作者标识 = UI库.创建("TextLabel", {
            Size = UDim2.new(0, 60, 0, 20),
            Position = UDim2.new(1, -65, 1, -25),
            Text = "by 古脚本",
            TextColor3 = Color3.fromRGB(200, 200, 255),
            TextSize = 12,
            BackgroundTransparency = 1,
            Parent = 通知
        })
    end
    
    -- 自动消失
    local 自动消失任务
    if 默认配置.显示时长 and 默认配置.显示时长 > 0 then
        自动消失任务 = task.delay(默认配置.显示时长, function()
            if 通知 and 通知.Parent then
                local 淡出动画 = TweenService:Create(通知, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1,
                    Position = 默认配置.位置 + UDim2.new(0, 0, 0, -50)
                })
                淡出动画:Play()
                淡出动画.Completed:Connect(function()
                    通知:Destroy()
                end)
            end
        end)
    end
    
    -- 入场动画
    通知.Position = 默认配置.位置 + UDim2.new(0, 0, 0, 100)
    通知.BackgroundTransparency = 1
    
    local 入场动画 = TweenService:Create(通知, TweenInfo.new(配置常量.动画.通知入场, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = 默认配置.位置,
        BackgroundTransparency = 0
    })
    入场动画:Play()
    
    -- 返回通知对象和控制函数
    local 通知对象 = {
        通知 = 通知,
        
        关闭 = function()
            if 自动消失任务 then
                task.cancel(自动消失任务)
            end
            
            if 通知 and 通知.Parent then
                local 淡出动画 = TweenService:Create(通知, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1,
                    Position = 默认配置.位置 + UDim2.new(0, 0, 0, -50)
                })
                淡出动画:Play()
                淡出动画.Completed:Connect(function()
                    通知:Destroy()
                end)
            end
        end,
        
        设置内容 = function(新内容)
            if 通知 and 通知.Parent then
                local 内容标签 = 通知:FindFirstChildOfClass("TextLabel")
                if 内容标签 then
                    内容标签.Text = 新内容
                end
            end
        end
    }
    
    return 通知对象
end

-- 创建滑动区域
UI库.创建滑动区域 = function(父级, 配置)
    local 默认配置 = {
        大小 = UDim2.new(1, 0, 1, 0),
        位置 = UDim2.new(0, 0, 0, 0),
        背景透明度 = 1,
        滚动条尺寸 = 8,
        间距 = 10
    }
    
    -- 合并配置
    for 键, 值 in pairs(配置 or {}) do
        默认配置[键] = 值
    end
    
    local 滚动框 = Instance.new("ScrollingFrame")
    滚动框.Size = 默认配置.大小
    滚动框.Position = 默认配置.位置
    滚动框.BackgroundTransparency = 默认配置.背景透明度
    滚动框.ScrollBarThickness = 默认配置.滚动条尺寸
    滚动框.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
    滚动框.BorderSizePixel = 0
    滚动框.ScrollingDirection = Enum.ScrollingDirection.Y
    滚动框.Parent = 父级
    
    local UI列表布局 = Instance.new("UIListLayout")
    UI列表布局.Parent = 滚动框
    UI列表布局.Padding = UDim.new(0, 默认配置.间距)
    
    -- 自动调整内容大小
    UI列表布局:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        滚动框.CanvasSize = UDim2.new(0, 0, 0, UI列表布局.AbsoluteContentSize.Y)
    end)
    
    return 滚动框
end

-- 初始化函数
UI库.初始化 = function(配置)
    local 默认配置 = {
        显示开关面板 = true,
        显示欢迎通知 = true,
        调试模式 = false,
        显示作者信息 = true,
        主题色 = nil  -- 可选的初始主题色
    }
    
    -- 合并配置
    for 键, 值 in pairs(配置 or {}) do
        默认配置[键] = 值
    end
    
    调试模式 = 默认配置.调试模式
    
    -- 设置主题色
    if 默认配置.主题色 then
        UI库.设置主题色(UI库.颜色.字符串转颜色(默认配置.主题色))
    end
    
    -- 显示作者信息
    if 默认配置.显示作者信息 then
        UI库.显示作者信息()
    end
    
    -- 创建开关面板
    local 开关面板控制器
    if 默认配置.显示开关面板 then
        开关面板控制器 = UI库.创建开关面板()
    end
    
    -- 发送欢迎通知
    if 默认配置.显示欢迎通知 then
        task.wait(1)
        UI库.发送通知({
            标题 = "古脚本 UI 库已加载",
            内容 = "版本 " .. UI库.版本 .. " | 设备: " .. UI库.设备类型 .. "\n作者: " .. UI库.作者 .. "\n主题色: " .. UI库.颜色.转格式(UI库.主题色),
            类型 = "成功",
            显示时长 = 4,
            显示作者 = true,
            显示图标 = true
        })
    end
    
    UI库.打印调试信息("UI库初始化完成")
    UI库.打印调试信息("版本: " .. UI库.版本)
    UI库.打印调试信息("设备: " .. UI库.设备类型)
    UI库.打印调试信息("主题色: " .. UI库.颜色.转格式(UI库.主题色))
    
    return {
        开关面板 = 开关面板控制器,
        库 = UI库,
        界面状态 = 界面状态
    }
end

-- 演示函数 - 已增强颜色处理演示
UI库.演示 = function()
    local 初始化结果 = UI库.初始化({
        显示开关面板 = true,
        显示欢迎通知 = true,
        调试模式 = true,
        显示作者信息 = true
    })
    
    -- 创建演示窗口
    local 演示窗口 = UI库.创建功能窗口({
        标题 = "古脚本 UI 演示",
        大小 = UDim2.new(0, 340, 0, 500), -- 增加高度以容纳更多内容
        位置 = UDim2.new(0.5, -170, 0.5, -250),
        显示作者标识 = true
    })
    
    -- 创建滑动区域
    local 滑动区域 = UI库.创建滑动区域(演示窗口.内容区域, {
        大小 = UDim2.new(1, -20, 1, -20),
        位置 = UDim2.new(0, 10, 0, 10)
    })
    
    -- 添加功能按钮示例
    local 功能1按钮 = UI库.创建古脚本按钮({
        文本 = "飞行功能",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 10),
        点击回调 = function()
            UI库.发送通知({
                标题 = "飞行功能",
                内容 = "古脚本飞行功能已激活",
                类型 = "成功",
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    local 功能2按钮 = UI库.创建功能按钮({
        文本 = "穿墙模式",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 65),
        开关功能 = true,
        初始状态 = false,
        使用古脚本颜色 = true,
        点击回调 = function(状态)
            UI库.发送通知({
                标题 = "穿墙模式",
                内容 = 状态 and "穿墙模式已开启" or "穿墙模式已关闭",
                类型 = 状态 and "成功" or "信息",
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    local 功能3按钮 = UI库.创建功能按钮({
        文本 = "无限跳跃",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 120),
        开关功能 = false,
        使用古脚本颜色 = true,
        点击回调 = function()
            UI库.发送通知({
                标题 = "无限跳跃",
                内容 = "无限跳跃功能已激活",
                类型 = "成功",
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    local 功能4按钮 = UI库.创建功能按钮({
        文本 = "发送测试通知",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 175),
        开关功能 = false,
        使用古脚本颜色 = true,
        点击回调 = function()
            UI库.发送通知({
                标题 = "测试通知",
                内容 = "这是一个测试通知消息",
                类型 = "信息",
                显示时长 = 2,
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    local 功能5按钮 = UI库.创建功能按钮({
        文本 = "隐藏此窗口",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 230),
        开关功能 = false,
        使用古脚本颜色 = true,
        点击回调 = function()
            演示窗口.隐藏()
            UI库.发送通知({
                标题 = "窗口已隐藏",
                内容 = "双击开关面板按钮或点击眼睛按钮可重新显示",
                类型 = "警告",
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    -- 新增：颜色处理演示按钮
    local 颜色演示按钮 = UI库.创建功能按钮({
        文本 = "随机颜色演示",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 285),
        开关功能 = false,
        使用古脚本颜色 = true,
        点击回调 = function()
            -- 生成随机颜色
            local 随机颜色 = UI库.颜色.随机色()
            
            -- 设置窗口背景色
            演示窗口.设置背景色(随机颜色)
            
            -- 发送通知显示颜色信息
            UI库.发送通知({
                标题 = "颜色处理演示",
                内容 = "窗口背景色已设置为: " .. UI库.颜色.转格式(随机颜色) .. 
                      "\nRGB: (" .. math.floor(随机颜色.R * 255) .. ", " .. 
                      math.floor(随机颜色.G * 255) .. ", " .. 
                      math.floor(随机颜色.B * 255) .. ")",
                类型 = "信息",
                显示时长 = 3,
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    -- 新增：切换主题色按钮
    local 主题色按钮 = UI库.创建功能按钮({
        文本 = "切换主题色",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 340),
        开关功能 = false,
        使用古脚本颜色 = true,
        点击回调 = function()
            -- 预定义的主题色列表
            local 主题色列表 = {
                Color3.fromRGB(65, 105, 225),   -- 古脚本蓝
                Color3.fromRGB(50, 205, 50),    -- 古脚本绿
                Color3.fromRGB(138, 43, 226),   -- 古脚本紫
                Color3.fromRGB(255, 140, 0),    -- 古脚本橙
                Color3.fromRGB(220, 20, 60)     -- 古脚本红
            }
            
            -- 随机选择一个主题色（排除当前主题色）
            local 新主题色
            repeat
                新主题色 = 主题色列表[math.random(#主题色列表)]
            until 新主题色 ~= UI库.主题色
            
            -- 设置新主题色
            UI库.设置主题色(新主题色)
            
            -- 更新按钮颜色
            功能1按钮.设置颜色(UI库.颜色.古脚本蓝())
            功能2按钮.设置颜色(UI库.颜色.古脚本蓝())
            功能3按钮.设置颜色(UI库.颜色.古脚本蓝())
            功能4按钮.设置颜色(UI库.颜色.古脚本蓝())
            功能5按钮.设置颜色(UI库.颜色.古脚本蓝())
            颜色演示按钮.设置颜色(UI库.颜色.古脚本蓝())
            主题色按钮.设置颜色(UI库.颜色.古脚本蓝())
            
            UI库.发送通知({
                标题 = "主题色已切换",
                内容 = "新的主题色: " .. UI库.颜色.转格式(新主题色),
                类型 = "成功",
                显示时长 = 3,
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    -- 添加关于古脚本的信息
    local 关于按钮 = UI库.创建古脚本按钮({
        文本 = "关于古脚本",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 45),
        位置 = UDim2.new(0, 10, 0, 395),
        点击回调 = function()
            UI库.发送通知({
                标题 = "关于古脚本",
                内容 = "作者: " .. UI库.作者 .. "\n版本: " .. UI库.版本 .. "\n网站: " .. UI库.作者网站 .. "\n邮箱: " .. UI库.邮箱 .. "\n当前主题色: " .. UI库.颜色.转格式(UI库.主题色),
                类型 = "信息",
                显示时长 = 6,
                显示作者 = true,
                显示图标 = true
            })
        end
    })
    
    -- 添加说明文字
    local 说明文字 = UI库.创建("TextLabel", {
        Size = UDim2.new(1, -20, 0, 120),
        Position = UDim2.new(0, 10, 0, 450),
        Text = "古脚本 UI 库使用说明：\n1. 拖动左上角面板可移动\n2. 点击眼睛按钮切换显示/隐藏\n3. 双击手机图标也可切换\n4. 点击右下角作者标识查看信息\n5. 颜色演示：点击随机颜色按钮可改变窗口背景色\n6. 主题色：点击切换主题色按钮可改变全局主题",
        TextColor3 = 配置常量.颜色.文字灰色,
        TextSize = 14,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Parent = 滑动区域
    })
    
    演示窗口.显示()
    
    return 初始化结果
end

-- 定义 Notify 函数
function Notify(Title1, Text1, Icon1, Time1)
    UI库.发送通知({
        标题 = Title1,
        内容 = Text1,
        类型 = Icon1,
        显示时长 = Time1
    })
end

-- HttpGet辅助函数（带错误处理）
local function 加载远程脚本(网址, 功能名称)
    local 成功, 结果 = pcall(function()
        local 脚本内容 = game:HttpGet(网址, true)
        loadstring(脚本内容)()
        return true
    end)
    
    if 成功 then
        UI库.发送通知({
            标题 = 功能名称,
            内容 = 功能名称 .. "功能已激活",
            类型 = "成功",
            显示时长 = 3
        })
    else
        UI库.发送通知({
            标题 = "加载失败",
            内容 = "无法加载" .. 功能名称 .. "功能: " .. tostring(结果),
            类型 = "错误",
            显示时长 = 5
        })
    end
end

-- 初始化通用脚本中心
local function 初始化通用脚本中心()
    -- 创建主窗口
    local 通用脚本窗口 = UI库.创建功能窗口({
        标题 = "通用脚本中心",
        大小 = UDim2.new(0, 350, 0, 500),
        位置 = UDim2.new(0.5, -175, 0.5, -250),
        可拖拽 = true,
        可关闭 = true,
        可隐藏 = true,
        背景颜色 = 配置常量.颜色.背景深色,
        标题栏颜色 = Color3.fromRGB(50, 25, 90),
        默认显示 = true
    })
    
    -- 创建滑动区域
    local 滑动区域 = UI库.创建("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -配置常量.尺寸.标题栏高度),
        Position = UDim2.new(0, 5, 0, 配置常量.尺寸.标题栏高度),
        BackgroundTransparency = 1,
        ScrollBarThickness = 8,
        ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150),
        BorderSizePixel = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = 通用脚本窗口.内容区域
    })
    
    local UI列表布局 = Instance.new("UIListLayout")
    UI列表布局.Parent = 滑动区域
    UI列表布局.Padding = UDim.new(0, 10)
    UI列表布局.VerticalAlignment = Enum.VerticalAlignment.Top
    
    UI列表布局:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        滑动区域.CanvasSize = UDim2.new(0, 0, 0, UI列表布局.AbsoluteContentSize.Y)
    end)
    
    -- 创建玩家功能区域
    local 玩家区域标题 = UI库.创建("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "玩家",
        TextColor3 = UI库.主题色,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = 滑动区域
    })
    
    -- 步行速度滑块
    local 步行速度滑动条 = UI库.创建滑动条({
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 25),
        最小值 = 16,
        最大值 = 400,
        当前值 = 16,
        回调函数 = function(速度)
            spawn(function()
                while task.wait() do
                    if 本地玩家.Character and 本地玩家.Character:FindFirstChild("Humanoid") then
                        本地玩家.Character.Humanoid.WalkSpeed = 速度
                    end
                end
            end)
        end
    })
    
    -- 跳跃高度滑块
    local 跳跃高度滑动条 = UI库.创建滑动条({
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 25),
        最小值 = 50,
        最大值 = 400,
        当前值 = 50,
        回调函数 = function(跳跃力)
            spawn(function()
                while task.wait() do
                    if 本地玩家.Character and 本地玩家.Character:FindFirstChild("Humanoid") then
                        本地玩家.Character.Humanoid.JumpPower = 跳跃力
                    end
                end
            end)
        end
    })
    
    -- 重力设置文本框
    local 重力文本框 = UI库.创建文本框({
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 35),
        占位符 = "输入重力值",
        回调函数 = function(重力值)
            local 数值 = tonumber(重力值)
            if 数值 then
                spawn(function()
                    while task.wait() do
                        game.Workspace.Gravity = 数值
                    end
                end)
            end
        end
    })
    
    -- 夜视开关
    local 夜视开关 = UI库.创建开关按钮({
        文本 = "夜视",
        父级 = 滑动区域,
        回调函数 = function(启用)
            spawn(function()
                while task.wait() do
                    if 启用 then
                        game.Lighting.Ambient = Color3.new(1, 1, 1)
                    else
                        game.Lighting.Ambient = Color3.new(0, 0, 0)
                    end
                end)
            end)
        end
    })
    
    -- 透视按钮
    local 透视按钮 = UI库.创建功能按钮({
        文本 = "透视",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local highlight = Instance.new("Highlight")
            highlight.Name = "Highlight"
            
            for i, v in pairs(Players:GetChildren()) do
                if v.Character then
                    for i, part in pairs(v.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            local highlightClone = highlight:Clone()
                            highlightClone.Adornee = part
                            highlightClone.Parent = part
                            highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlightClone.Name = "Highlight"
                        end
                    end
                end
            end
            
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    for i, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            local highlightClone = highlight:Clone()
                            highlightClone.Adornee = part
                            highlightClone.Parent = part
                            highlightClone.Name = "Highlight"
                        end
                    end
                end)
            end)
            
            Players.PlayerRemoving:Connect(function(player)
                if player.Character then
                    for i, part in pairs(player.Character:GetChildren()) do
                        if part:FindFirstChild("Highlight") then
                            part.Highlight:Destroy()
                        end
                    end
                end
            end)
            
            UI库.发送通知({
                标题 = "透视功能",
                内容 = "透视功能已激活",
                类型 = "成功",
                显示时长 = 3
            })
        end
    })
    
    -- 隐身道具按钮
    local 隐身道具按钮 = UI库.创建功能按钮({
        文本 = "隐身道具",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://gist.githubusercontent.com/skid123skidlol/cd0d2dce51b3f20ad1aac941da06a1a1/raw/f58b98cce7d51e53ade94e7bb460e4f24fb7e0ff/%7BFE%7D%20Invisible%20Tool%20(can%20hold%20tools)", "隐身道具")
        end
    })
    
    -- 穿墙开关
    local 穿墙开关 = UI库.创建开关按钮({
        文本 = "穿墙(可用)",
        父级 = 滑动区域,
        回调函数 = function(启用)
            local Workspace = game:GetService("Workspace")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            if 启用 then
                local Stepped = game:GetService("RunService").Stepped:Connect(function()
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                
                table.insert(界面状态.所有连接, Stepped)
            else
                -- 断开所有穿墙连接
                for _, connection in pairs(界面状态.所有连接) do
                    if connection then
                        connection:Disconnect()
                    end
                end
                界面状态.所有连接 = {}
                
                -- 恢复碰撞
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })
    
    -- 通用功能区域
    local 通用区域标题 = UI库.创建("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "通用",
        TextColor3 = UI库.主题色,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = 滑动区域
    })
    
    -- 最强透视按钮
    local 最强透视按钮 = UI库.创建功能按钮({
        文本 = "最强透视",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/uw2P2fbY", "最强透视")
        end
    })
    
    -- 飞行v3按钮
    local 飞行按钮 = UI库.创建功能按钮({
        文本 = "飞行v3",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt", "飞行v3")
        end
    })
    
    -- 甩人按钮
    local 甩人按钮 = UI库.创建功能按钮({
        文本 = "甩人",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/zqyDSUWX", "甩人")
        end
    })
    
    -- 反挂机v2按钮
    local 反挂机按钮 = UI库.创建功能按钮({
        文本 = "反挂机v2",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/9fFu43FF", "反挂机v2")
        end
    })
    
    -- 铁拳按钮
    local 铁拳按钮 = UI库.创建功能按钮({
        文本 = "铁拳",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt"))()
            UI库.发送通知({
                标题 = "铁拳",
                内容 = "铁拳功能已激活",
                类型 = "成功",
                显示时长 = 3
            })
        end
    })
    
    -- 键盘按钮
    local 键盘按钮 = UI库.创建功能按钮({
        文本 = "键盘",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt", "键盘")
        end
    })
    
    -- 动画中心按钮
    local 动画中心按钮 = UI库.创建功能按钮({
        文本 = "动画中心",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://raw.githubusercontent.com/GamingScripter/Animation-Hub/main/Animation%20Gui", "动画中心")
        end
    })
    
    -- 立即死亡按钮
    local 立即死亡按钮 = UI库.创建功能按钮({
        文本 = "立即死亡",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            local LocalPlayer = game.Players.LocalPlayer
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
            UI库.发送通知({
                标题 = "立即死亡",
                内容 = "角色已死亡",
                类型 = "错误",
                显示时长 = 3
            })
        end
    })
    
    -- 爬墙按钮
    local 爬墙按钮 = UI库.创建功能按钮({
        文本 = "爬墙",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/zXk4Rq2r", "爬墙")
        end
    })
    
    -- 转起来按钮
    local 转起来按钮 = UI库.创建功能按钮({
        文本 = "转起来",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/r97d7dS0", "转起来")
        end
    })
    
    -- 子弹追踪按钮
    local 子弹追踪按钮 = UI库.创建功能按钮({
        文本 = "子弹追踪",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/1AJ69eRG", "子弹追踪")
        end
    })
    
    -- 飞车按钮
    local 飞车按钮 = UI库.创建功能按钮({
        文本 = "飞车",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/63T0fkBm", "飞车")
        end
    })
    
    -- 吸人按钮
    local 吸人按钮 = UI库.创建功能按钮({
        文本 = "吸人",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://shz.al/~HHAKS", "吸人")
        end
    })
    
    -- 无限跳跃按钮
    local 无限跳跃按钮 = UI库.创建功能按钮({
        文本 = "无限跳跃",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://pastebin.com/raw/V5PQy3y0", "无限跳跃")
        end
    })
    
    -- ESP功能区域
    local ESP区域标题 = UI库.创建("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "ESP",
        TextColor3 = UI库.主题色,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = 滑动区域
    })
    
    -- 人物显示开关
    local 人物显示开关 = UI库.创建开关按钮({
        文本 = "人物显示",
        父级 = 滑动区域,
        回调函数 = function(启用)
            getgenv().enabled = 启用
            getgenv().filluseteamcolor = true
            getgenv().outlineuseteamcolor = true
            getgenv().fillcolor = Color3.new(1, 0, 0)
            getgenv().outlinecolor = Color3.new(1, 1, 1)
            getgenv().filltrans = 0.5
            getgenv().outlinetrans = 0.5
            
            if 启用 then
                加载远程脚本("https://raw.githubusercontent.com/Vcsk/RobloxScripts/main/Highlight-ESP.lua", "ESP")
            end
        end
    })
    
    -- 其他功能区域
    local 其他区域标题 = UI库.创建("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "其他",
        TextColor3 = UI库.主题色,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = 滑动区域
    })
    
    -- 死亡笔记按钮
    local 死亡笔记按钮 = UI库.创建功能按钮({
        文本 = "死亡笔记",
        父级 = 滑动区域,
        大小 = UDim2.new(1, -20, 0, 40),
        点击回调 = function()
            加载远程脚本("https://raw.githubusercontent.com/krlpl/dfhj/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0.txt", "死亡笔记")
        end
    })
    
    -- 显示欢迎通知
    UI库.发送通知({
        标题 = "通用脚本中心",
        内容 = "欢迎使用通用脚本中心！",
        类型 = "成功",
        显示时长 = 5,
        显示作者 = true,
        显示图标 = true
    })
end

-- 初始化通用脚本中心
初始化通用脚本中心()

-- 返回 UI 库
return UI库