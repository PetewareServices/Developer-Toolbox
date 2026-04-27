--[[
PLEASE READ - IMPORTANT

(C) 2026 Peteware
This project is part of Developer-Toolbox, an open-sourced debugging tool for roblox.

Licensed under the MIT License.  
See the full license at:  
https://opensource.org/licenses/MIT

**Attribution required:** You must give proper credit to Peteware when using or redistributing this project or its derivatives.

This software is provided "AS IS" without warranties of any kind.  
Violations of license terms may result in legal action.

Thank you for respecting the license and supporting open source software!

Peteware Development Team
]]

--// Loading Handler
if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait()
end

--// Early Local References
local Color3 = Color3
local Color3New = Color3.new
local Color3fromRGB = Color3.fromRGB

local default_theme = {
    WindowBg = Color3fromRGB(25, 25, 25), 
    TopBar = Color3fromRGB(25, 25, 25),
    Background = Color3fromRGB(35, 35, 35),
    SectionHeader = Color3fromRGB(45, 45, 45),
    SectionBg = Color3fromRGB(35, 35, 35),
    Button = Color3fromRGB(65, 65, 65),
    ToggleBar = Color3fromRGB(65, 65, 65),
    Toggle = Color3fromRGB(255, 87, 87),
    Text = Color3fromRGB(255, 255, 255)
}

--// Settings Detection
local raw_args = ...

local Settings = raw_args and type(raw_args) == "table" and raw_args or {
    ["Owner"] = "Unknown",
    ["Build"] = "Roblox",
    ["Theme"] = "Default",
    ["Colors"] = default_theme
}

local Theme = Settings["Colors"] or default_theme

--// Local References
local game = game
local GetService = game.GetService
local Instance = Instance
local InstanceNew = Instance.new
local UDim = UDim
local UDim2New = UDim2.new
local Vector2 = Vector2
local Vector2New = Vector2.new
local Rect = Rect
local RectNew = Rect.new
local task = task
local taskwait = task.wait
local taskspawn = task.spawn
local string = string
local stringgsub = string.gsub
local Enum = Enum
local UserInputType = Enum.UserInputType
local UserInputState = Enum.UserInputState
local EasingStyle = Enum.EasingStyle
local EasingDirection = Enum.EasingDirection
local ScaleType = Enum.ScaleType
local Font = Enum.Font
local SortOrder = Enum.SortOrder
local TextXAlignment = Enum.TextXAlignment
local type = type

--// Services & Setup
local cloneref = (type(cloneref) == "function" and cloneref) or (type(clonereference) == "function" and clonereference) or function(...)
    return ...
end

local gethui = type(gethui) == "function" and gethui or function(...)
    return cloneref(GetService(game, "CoreGui"))
end

local user_input_service = cloneref(GetService(game, "UserInputService"))
local tween_service = cloneref(GetService(game, "TweenService"))
local run_service = cloneref(GetService(game, "RunService"))
local mouse_object = cloneref(GetService(game, "Players").LocalPlayer:GetMouse())

local TweenCreate = tween_service.Create

--// Old UI Cleanup
local wizard_library = gethui():FindFirstChild("WizardLibrary")
if wizard_library then
    wizard_library:Destroy()
end

--// Offsets
local window_x_offset = 0

--// Library UI Initialisation
local screen_gui = InstanceNew("ScreenGui")
screen_gui.Name = "WizardLibrary"
screen_gui.Parent = gethui()
screen_gui.DisplayOrder = 10000

local main_frame = InstanceNew("Frame")
main_frame.Name = "Container"
main_frame.Parent = screen_gui
main_frame.BackgroundColor3 = Color3.new(1, 1, 1)
main_frame.BackgroundTransparency = 1
main_frame.Size = UDim2New(0, 100, 0, 100)

--// Utility Functions
local function MakeDraggableObject(gui_object)
    local drag_start = nil
    local start_position = nil
    local is_dragging = nil
    local current_input = nil

    local function update_drag(input)
        local delta = input.Position - drag_start
        gui_object.Position = UDim2New(
            start_position.X.Scale,
            start_position.X.Offset + delta.X,
            start_position.Y.Scale,
            start_position.Y.Offset + delta.Y
        )
    end

    gui_object.InputBegan:Connect(function(input)
        if input.UserInputType == UserInputType.MouseButton1 or input.UserInputType == UserInputType.Touch then

            is_dragging = true
            drag_start = input.Position
            start_position = gui_object.Position

            input.Changed:Connect(function()
                if input.UserInputState == UserInputState.End then
                    is_dragging = false
                end
            end)
        end
    end)

    gui_object.InputChanged:Connect(function(input)
        if input.UserInputType == UserInputType.MouseMovement 
        or input.UserInputType == UserInputType.Touch then

            current_input = input
        end
    end)

    user_input_service.InputChanged:Connect(function(input)
        if input == current_input and is_dragging then
            update_drag(input)
        end
    end)
end

return {
    Object = screen_gui,
    NewWindow = function(self_unused, window_name)
        local window_image_label = InstanceNew("Frame")
        local window_top_bar = InstanceNew("Frame")
        local window_dropdown_toggle = InstanceNew("TextButton")
        local window_text_label = InstanceNew("TextLabel")
        local window_secondary_frame = InstanceNew("Frame")
        local window_title_secondary = InstanceNew("Frame")
        local window_list_layout = InstanceNew("UIListLayout")
        local window_tertiary_frame = InstanceNew("Frame")

        window_x_offset = window_x_offset + 2
        local window_size = 35
        local window_dropdown_toggled = true

        local function ExpandWindow(size)
            window_size = window_size + size
            TweenCreate(tween_service, window_title_secondary, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                Size = UDim2New(0, 170, 0, window_size)
            }):Play()
        end

        local function CollapseWindow(size)
            window_size = window_size - size
            TweenCreate(tween_service, window_title_secondary, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                Size = UDim2New(0, 170, 0, window_size)
            }):Play()
        end

        window_image_label.Name = stringgsub(window_name, " ", "") .. "Window"
        window_image_label.Parent = main_frame
        window_image_label.BackgroundColor3 = Theme.WindowBg or Color3New(0.0980392, 0.0980392, 0.0980392)
        window_image_label.BackgroundTransparency = 0
        window_image_label.Position = UDim2New(window_x_offset, -100, 3, -265)
        window_image_label.Size = UDim2New(0, 170, 0, 30)
        window_image_label.ZIndex = 2

        local corner_main = Instance.new("UICorner")
        corner_main.CornerRadius = UDim.new(0, 6)
        corner_main.Parent = window_image_label

        window_top_bar.Name = "Topbar"
        window_top_bar.Parent = window_image_label
        window_top_bar.BackgroundColor3 = Color3New(1, 1, 1)
        window_top_bar.BackgroundTransparency = 1
        window_top_bar.BorderSizePixel = 0
        window_top_bar.Size = UDim2New(0, 170, 0, 30)
        window_top_bar.ZIndex = 2

        window_dropdown_toggle.Name = "WindowToggle"
        window_dropdown_toggle.Parent = window_top_bar
        window_dropdown_toggle.BackgroundColor3 = Color3New(1, 1, 1)
        window_dropdown_toggle.BackgroundTransparency = 1
        window_dropdown_toggle.Position = UDim2New(0.822450161, 0, 0, 0)
        window_dropdown_toggle.Size = UDim2New(0, 30, 0, 30)
        window_dropdown_toggle.ZIndex = 2
        window_dropdown_toggle.Font = Font.SourceSansSemibold
        window_dropdown_toggle.Text = "-"
        window_dropdown_toggle.TextColor3 = Color3New(1, 1, 1)
        window_dropdown_toggle.TextSize = 20
        window_dropdown_toggle.TextWrapped = true

        window_dropdown_toggle.MouseButton1Down:Connect(function() 
            if window_dropdown_toggled then
                window_dropdown_toggled = false
                local tween_dropdown_collapse = TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                    TextTransparency = 1
                })

                tween_dropdown_collapse:Play()

                window_dropdown_toggle.Visible = false
                window_dropdown_toggle.Text = "v"
                window_dropdown_toggle.TextSize = 14

                tween_dropdown_collapse.Completed:Wait()
                window_dropdown_toggle.Visible = true
                TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                    TextTransparency = 0
                }):Play()
            else
                window_dropdown_toggled = true
                local tween_dropdown_expand = TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                    TextTransparency = 1
                })

                tween_dropdown_expand:Play()

                window_dropdown_toggle.Visible = false
                window_dropdown_toggle.Text = "-"
                window_dropdown_toggle.TextSize = 20

                tween_dropdown_expand.Completed:Wait()
                window_dropdown_toggle.Visible = true
                TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                    TextTransparency = 0
                }):Play()
            end
        end)

        window_text_label.Name = "WindowTitle"
        window_text_label.Parent = window_top_bar
        window_text_label.BackgroundColor3 = Color3New(1, 1, 1)
        window_text_label.BackgroundTransparency = 1
        window_text_label.Size = UDim2New(0, 170, 0, 30)
        window_text_label.ZIndex = 2
        window_text_label.Font = Font.SourceSansBold
        window_text_label.Text = window_name
        window_text_label.TextColor3 = Color3New(1, 1, 1)
        window_text_label.TextSize = 17

        window_secondary_frame.Name = "BottomRoundCover"
        window_secondary_frame.Parent = window_top_bar
        window_secondary_frame.BackgroundColor3 = Theme.TopBar or Color3New(0.0980392, 0.0980392, 0.0980392)
        window_secondary_frame.BorderSizePixel = 0
        window_secondary_frame.Position = UDim2New(0, 0, 0.833333313, 0)
        window_secondary_frame.Size = UDim2New(0, 170, 0, 5)
        window_secondary_frame.ZIndex = 2

        window_title_secondary.Name = "Body"
        window_title_secondary.Parent = window_image_label
        window_title_secondary.BackgroundColor3 = Theme.Background or Color3New(0.137255, 0.137255, 0.137255)
        window_title_secondary.BackgroundTransparency = 0
        window_title_secondary.ClipsDescendants = true
        window_title_secondary.Size = UDim2New(0, 170, 0, window_size)

        local corner_body = Instance.new("UICorner")
        corner_body.CornerRadius = UDim.new(0, 6)
        corner_body.Parent = window_title_secondary

        window_list_layout.Name = "Sorter"
        window_list_layout.Parent = window_title_secondary
        window_list_layout.SortOrder = SortOrder.LayoutOrder
        window_tertiary_frame.Name = "TopbarBodyCover"
        window_tertiary_frame.Parent = window_title_secondary
        window_tertiary_frame.BackgroundColor3 = Color3New(1, 1, 1)
        window_tertiary_frame.BackgroundTransparency = 1
        window_tertiary_frame.BorderSizePixel = 0
        window_tertiary_frame.Size = UDim2New(0, 170, 0, 30)

        MakeDraggableObject(window_image_label)

        --// Return Window Methods
        return {
            NewSection = function(self_unused, section_name)
                local section_main_frame = InstanceNew("Frame")
                local section_secondary_frame = InstanceNew("Frame")
                local section_dropdown_toggle = InstanceNew("TextButton")
                local section_title = InstanceNew("TextLabel")
                local section_list_layout = InstanceNew("UIListLayout")
    
                local section_size = 30
                local section_dropdown_toggled = false

                local function ExpandSection(size)
                    section_size = section_size + size
                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                        Size = UDim2New(0, 170, 0, section_size)
                    }):Play()
                end
                
                local function CollapseSection(size)
                    section_size = section_size - size
                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                        Size = UDim2New(0, 170, 0, section_size)
                    }):Play()
                end

                section_main_frame.Name = stringgsub(section_name, " ", "") .. "Section"
                section_main_frame.Parent = window_title_secondary
                section_main_frame.BackgroundColor3 = Theme.SectionHeader or Color3New(0.176471, 0.176471, 0.176471)
                section_main_frame.BorderSizePixel = 0
                section_main_frame.ClipsDescendants = true
                section_main_frame.Size = UDim2New(0, 170, 0, section_size)

                ExpandWindow(30)

                section_secondary_frame.Name = "SectionInfo"
                section_secondary_frame.Parent = section_main_frame
                section_secondary_frame.BackgroundColor3 = Color3New(1, 1, 1)
                section_secondary_frame.BackgroundTransparency = 1
                section_secondary_frame.Size = UDim2New(0, 170, 0, 30)

                section_dropdown_toggle.Name = "SectionToggle"
                section_dropdown_toggle.Parent = section_secondary_frame
                section_dropdown_toggle.BackgroundColor3 = Color3New(1, 1, 1)
                section_dropdown_toggle.BackgroundTransparency = 1
                section_dropdown_toggle.Position = UDim2New(0.822450161, 0, 0, 0)
                section_dropdown_toggle.Size = UDim2New(0, 30, 0, 30)
                section_dropdown_toggle.ZIndex = 2
                section_dropdown_toggle.Font = Font.SourceSansSemibold
                section_dropdown_toggle.Text = "v"
                section_dropdown_toggle.TextColor3 = Color3New(1, 1, 1)
                section_dropdown_toggle.TextSize = 14
                section_dropdown_toggle.TextWrapped = true

                section_title.Name = "SectionTitle"
                section_title.Parent = section_secondary_frame
                section_title.BackgroundColor3 = Color3New(1, 1, 1)
                section_title.BackgroundTransparency = 1
                section_title.BorderSizePixel = 0
                section_title.Position = UDim2New(0.052941177, 0, 0, 0)
                section_title.Size = UDim2New(0, 125, 0, 30)
                section_title.Font = Font.SourceSansBold
                section_title.Text = section_name
                section_title.TextColor3 = Color3New(1, 1, 1)
                section_title.TextSize = 17
                section_title.TextXAlignment = TextXAlignment.Left

                section_list_layout.Name = "Layout"
                section_list_layout.Parent = section_main_frame
                section_list_layout.SortOrder = SortOrder.LayoutOrder

                window_dropdown_toggle.MouseButton1Down:Connect(function()
                    if window_dropdown_toggled then
                        if window_dropdown_toggled then
                            CollapseWindow(30)
                            section_dropdown_toggle.Text = ""
                            TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                BackgroundTransparency = 1
                            }):Play()
                        end
                    else
                        ExpandWindow(30)
                        section_dropdown_toggle.Text = "v"
                        TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                            BackgroundTransparency = 0
                        }):Play()
                    end
                end)

                section_dropdown_toggle.MouseButton1Down:Connect(function() 
                    if section_dropdown_toggled then
                        section_dropdown_toggled = false
                        TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 1
                        }):Play()

                        local tween_dropdown_collapse = TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 1
                        })

                        tween_dropdown_collapse:Play()

                        section_dropdown_toggle.Visible = false
                        window_dropdown_toggle.Visible = false
                        section_dropdown_toggle.Text = "v"
                        section_dropdown_toggle.TextSize = 14
                        
                        tween_dropdown_collapse.Completed:Wait()
                        section_dropdown_toggle.Visible = true
                        window_dropdown_toggle.Visible = true

                        TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 0
                        }):Play()
                        TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 0
                        }):Play()
                    else
                        section_dropdown_toggled = true
                        TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 1
                        }):Play()

                        local tween_dropdown_expand = TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 1
                        })

                        tween_dropdown_expand:Play()

                        section_dropdown_toggle.Text = "-"
                        section_dropdown_toggle.TextSize = 20
                        section_dropdown_toggle.Visible = false
                        window_dropdown_toggle.Visible = false

                        tween_dropdown_expand.Completed:Wait()
                        section_dropdown_toggle.Visible = true
                        window_dropdown_toggle.Visible = true
                        TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 0
                        }):Play()
                        TweenCreate(tween_service, window_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                            TextTransparency = 0
                        }):Play()
                    end
                end)
                --// Return Section Methods
                return {
                    CreateToggle = function(self_unused, toggle_name, toggle_callback, default_value)
                        local toggle_main_frame = InstanceNew("Frame")
                        local toggle_title = InstanceNew("TextLabel")
                        local toggle_background = InstanceNew("Frame")
                        local toggle_button = InstanceNew("TextButton")

                        local currently_toggled = default_value or false

                        toggle_main_frame.Name = stringgsub(toggle_name, " ", "") .. "ToggleHolder"
                        toggle_main_frame.Parent = section_main_frame
                        toggle_main_frame.BackgroundColor3 = Theme.SectionBg or Color3New(0.137255, 0.137255, 0.137255)
                        toggle_main_frame.BorderSizePixel = 0
                        toggle_main_frame.Size = UDim2New(0, 170, 0, 30)

                        toggle_title.Name = "ToggleTitle"
                        toggle_title.Parent = toggle_main_frame
                        toggle_title.BackgroundColor3 = Color3New(1, 1, 1)
                        toggle_title.BackgroundTransparency = 1
                        toggle_title.BorderSizePixel = 0
                        toggle_title.Position = UDim2New(0.052941177, 0, 0, 0)
                        toggle_title.Size = UDim2New(0, 125, 0, 30)
                        toggle_title.Font = Font.SourceSansBold
                        toggle_title.Text = toggle_name
                        toggle_title.TextColor3 = Color3New(1, 1, 1)
                        toggle_title.TextSize = 17
                        toggle_title.TextXAlignment = TextXAlignment.Left

                        toggle_background.Name = "ToggleBackground"
                        toggle_background.Parent = toggle_main_frame
                        toggle_background.BackgroundColor3 = Theme.ToggleBar or Color3New(0.254902, 0.254902, 0.254902)
                        toggle_background.BorderSizePixel = 0
                        toggle_background.Position = UDim2New(0.847058833, 0, 0.166666672, 0)
                        toggle_background.Size = UDim2New(0, 20, 0, 20)

                        local bg_corner = Instance.new("UICorner")
                        bg_corner.CornerRadius = UDim.new(0, 4)
                        bg_corner.Parent = toggle_background

                        toggle_button.Name = "ToggleButton"
                        toggle_button.Parent = toggle_background
                        toggle_button.BackgroundColor3 = Theme.Toggle or Color3New(1, 0.341176, 0.341176)
                        toggle_button.BorderSizePixel = 0
                        toggle_button.Position = UDim2New(0, 2, 0, 2)
                        toggle_button.Size = UDim2New(0, 16, 0, 16)
                        toggle_button.BackgroundTransparency = currently_toggled and 0 or 1
                        toggle_button.TextTransparency = 1

                        local btn_corner = Instance.new("UICorner")
                        btn_corner.CornerRadius = UDim.new(0, 3)
                        btn_corner.Parent = toggle_button

                        if currently_toggled then
                            toggle_callback(currently_toggled)
                        end

                        toggle_button.MouseButton1Down:Connect(function()
                            currently_toggled = not currently_toggled
                            if currently_toggled then
                                TweenCreate(tween_service, toggle_button, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                    BackgroundTransparency = 0
                                }):Play()
                            else
                                TweenCreate(tween_service, toggle_button, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                    BackgroundTransparency = 1
                                }):Play()
                            end
                            toggle_callback(currently_toggled)
                        end)

                        section_dropdown_toggle.MouseButton1Down:Connect(function()
                            if not section_dropdown_toggled then
                                ExpandSection(30)
                                ExpandWindow(30)
                            elseif section_dropdown_toggled then
                                CollapseSection(30)
                                CollapseWindow(30)
                            end
                        end)

                        window_dropdown_toggle.MouseButton1Down:Connect(function()
                            if not window_dropdown_toggled then
                                if section_dropdown_toggled then
                                    ExpandWindow(30)
                                    TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0, EasingStyle.Quart, EasingDirection.Out), {
                                        Rotation = 360
                                    }):Play()
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 0
                                    }):Play()
                                else
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 0
                                    }):Play()
                                end
                            else
                                if section_dropdown_toggled then
                                    CollapseWindow(30)
                                    TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0, EasingStyle.Quart, EasingDirection.Out), {
                                        Rotation = 0
                                    }):Play()
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                else
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                end
                            end
                            local tween_collapse_dropdown = TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                                TextTransparency = 1
                            })

                            tween_collapse_dropdown.Completed:Wait()

                            section_dropdown_toggle.Visible = false
                            tween_collapse_dropdown.Completed:Wait()
                            section_dropdown_toggle.Visible = true
                            TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                                TextTransparency = 0
                            }):Play()
                        end)
                    end, 

                    CreateButton = function(self_unused, button_name, button_callback)
                        local button_main_frame = InstanceNew("Frame")
                        local button_title = InstanceNew("TextButton")
                        local button_body = InstanceNew("Frame")

                        button_main_frame.Name = stringgsub(button_name, " ", "") .. "ButtonHolder"
                        button_main_frame.Parent = section_main_frame
                        button_main_frame.BackgroundColor3 = Theme.SectionBg or Color3New(0.137255, 0.137255, 0.137255)
                        button_main_frame.BorderSizePixel = 0
                        button_main_frame.Size = UDim2New(0, 170, 0, 30)

                        button_title.Name = "Button"
                        button_title.Parent = button_main_frame
                        button_title.BackgroundColor3 = Theme.Button or Color3New(0.254902, 0.254902, 0.254902)
                        button_title.BackgroundTransparency = 0
                        button_title.BorderSizePixel = 0
                        button_title.Position = UDim2New(0.052941177, 0, 0, 0)
                        button_title.Size = UDim2New(0, 153, 0, 24)
                        button_title.ZIndex = 2
                        button_title.AutoButtonColor = false
                        button_title.Font = Font.SourceSansBold
                        button_title.Text = button_name
                        button_title.TextColor3 = Color3New(1, 1, 1)
                        button_title.TextSize = 14

                        local button_corner = Instance.new("UICorner")
                        button_corner.CornerRadius = UDim.new(0, 4)
                        button_corner.Parent = button_title

                        button_body.Name = "ButtonRound"
                        button_body.Parent = button_title
                        button_body.Active = true
                        button_body.AnchorPoint = Vector2.new(0.5, 0.5)
                        button_body.BackgroundColor3 = Color3New(0.254902, 0.254902, 0.254902)
                        button_body.BackgroundTransparency = 1
                        button_body.BorderSizePixel = 0
                        button_body.ClipsDescendants = true
                        button_body.Position = UDim2New(0.5, 0, 0.5, 0)
                        button_body.Selectable = true
                        button_body.Size = UDim2New(1, 0, 1, 0)

                        local body_corner = Instance.new("UICorner")
                        body_corner.CornerRadius = UDim.new(0, 4)
                        body_corner.Parent = button_body

                        button_title.MouseButton1Down:Connect(button_callback)

                        section_dropdown_toggle.MouseButton1Down:Connect(function()
                            if not section_dropdown_toggled then
                                ExpandSection(30)
                                ExpandWindow(30)
                            else
                                CollapseSection(30)
                                CollapseWindow(30)
                            end
                        end)

                        window_dropdown_toggle.MouseButton1Down:Connect(function()
                            if window_dropdown_toggled then
                                if not section_dropdown_toggled then
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                else
                                    CollapseWindow(30)
                                    TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0, EasingStyle.Quart, EasingDirection.Out), {
                                        Rotation = 0
                                    }):Play()
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                end
                            elseif section_dropdown_toggled then
                                ExpandWindow(30)
                                TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0, EasingStyle.Quart, EasingDirection.Out), {
                                    Rotation = 360
                                }):Play()
                                TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                    BackgroundTransparency = 0
                                }):Play()
                            else
                                TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                    BackgroundTransparency = 0
                                }):Play()
                            end

                            local tween_collapse_dropdown = TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                                TextTransparency = 1
                            })
                            
                            tween_collapse_dropdown:Play()

                            section_dropdown_toggle.Visible = false

                            tween_collapse_dropdown.Completed:Wait()
                            section_dropdown_toggle.Visible = true
                            TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                                TextTransparency = 0
                            }):Play()
                        end)
                    end,

                    CreateTextbox = function(self_unused, textbox_name, textbox_callback, require_enter_press)
                        local textbox_main_frame = InstanceNew("Frame")
                        local textbox_title = InstanceNew("TextBox")
                        local textbox_body = InstanceNew("Frame")

                        textbox_main_frame.Name = stringgsub(textbox_name, " ", "") .. "TextBoxHolder"
                        textbox_main_frame.Parent = section_main_frame
                        textbox_main_frame.BackgroundColor3 = Theme.SectionBg or Color3New(0.137255, 0.137255, 0.137255)
                        textbox_main_frame.BorderSizePixel = 0
                        textbox_main_frame.Size = UDim2New(0, 170, 0, 30)

                        textbox_title.Parent = textbox_main_frame
                        textbox_title.BackgroundColor3 = Theme.Button or Color3New(0.254902, 0.254902, 0.254902)
                        textbox_title.BackgroundTransparency = 0
                        textbox_title.ClipsDescendants = true
                        textbox_title.Position = UDim2New(0.0529999994, 0, 0, 0)
                        textbox_title.Size = UDim2New(0, 153, 0, 24)
                        textbox_title.ZIndex = 2
                        textbox_title.Font = Font.SourceSansBold
                        textbox_title.PlaceholderText = textbox_name
                        textbox_title.Text = ""
                        textbox_title.TextColor3 = Color3New(1, 1, 1)
                        textbox_title.TextSize = 14

                        local textbox_corner = Instance.new("UICorner")
                        textbox_corner.CornerRadius = UDim.new(0, 4)
                        textbox_corner.Parent = textbox_title

                        textbox_body.Name = "TextBoxRound"
                        textbox_body.Parent = textbox_title
                        textbox_body.Active = true
                        textbox_body.AnchorPoint = Vector2.new(0.5, 0.5)
                        textbox_body.BackgroundColor3 = Color3New(0.254902, 0.254902, 0.254902)
                        textbox_body.BackgroundTransparency = 1
                        textbox_body.BorderSizePixel = 0
                        textbox_body.ClipsDescendants = true
                        textbox_body.Position = UDim2New(0.5, 0, 0.5, 0)
                        textbox_body.Selectable = true
                        textbox_body.Size = UDim2New(1, 0, 1, 0)

                        local body_corner = Instance.new("UICorner")
                        body_corner.CornerRadius = UDim.new(0, 4)
                        body_corner.Parent = textbox_body

                        textbox_title.FocusLost:Connect(function(enter_pressed)
                            if require_enter_press then
                                if enter_pressed then
                                    textbox_callback(textbox_title.Text)
                                    return
                                end
                                return
                            end
                            textbox_callback(textbox_title.Text)
                        end)

                        section_dropdown_toggle.MouseButton1Down:Connect(function()
                            if section_dropdown_toggled then
                                CollapseSection(30)
                                CollapseWindow(30)
                            else
                                ExpandSection(30)
                                ExpandWindow(30)
                            end
                        end)

                        window_dropdown_toggle.MouseButton1Down:Connect(function()
                            if window_dropdown_toggled then
                                if not section_dropdown_toggled then
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                else
                                    CollapseWindow(30)
                                    TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0, EasingStyle.Quart, EasingDirection.Out), {
                                        Rotation = 0
                                    }):Play()
                                    TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                end
                            elseif not section_dropdown_toggled then
                                TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                    BackgroundTransparency = 0
                                }):Play()
                            else
                                ExpandWindow(30)
                                TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0, EasingStyle.Quart, EasingDirection.Out), {
                                    Rotation = 360
                                }):Play()
                                TweenCreate(tween_service, section_main_frame, TweenInfo.new(0.5, EasingStyle.Quart, EasingDirection.Out), {
                                    BackgroundTransparency = 0
                                }):Play()
                            end
                            local tween_dropdown_collapse = TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                                TextTransparency = 1
                            })

                            tween_dropdown_collapse:Play()

                            section_dropdown_toggle.Visible = false
                            tween_dropdown_collapse.Completed:Wait()
                            section_dropdown_toggle.Visible = true
                            TweenCreate(tween_service, section_dropdown_toggle, TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out), {
                                TextTransparency = 0
                            }):Play()
                        end)
                    end, 

                    CreateDropdown = function(self_unused, dropdown_name, dropdown_table, current_value, dropdown_callback)
                        local dropdown_main_frame = InstanceNew("Frame")
                        local dropdown_title = InstanceNew("TextLabel")
                        local dropdown_body = InstanceNew("Frame")
                        local dropdown_toggle = InstanceNew("TextButton")
                        local dropdown_canvas = InstanceNew("ScrollingFrame")
                        local dropdown_list_layout = InstanceNew("UIListLayout")
                  
                        local needs_scrolling = false
                        local current_selected_dropdown_element = current_value
                        local current_buttons = 0
                        local current_y_offset_size = 0
                        local is_open = false
                        local current_y_size = 0
                  
                        dropdown_main_frame.Name = stringgsub(dropdown_name, " ", "") .. "DropdownHolder"
                        dropdown_main_frame.Parent = section_main_frame
                        dropdown_main_frame.BackgroundColor3 = Theme.SectionBg or Color3New(0.137255, 0.137255, 0.137255)
                        dropdown_main_frame.BorderSizePixel = 0
                        dropdown_main_frame.Size = UDim2New(0, 170, 0, 30)
                        dropdown_main_frame.ClipsDescendants = false
                  
                        local main_corner = Instance.new("UICorner")
                        main_corner.CornerRadius = UDim.new(0, 6)
                        main_corner.Parent = dropdown_main_frame
                  
                        dropdown_title.Name = "DropdownTitle"
                        dropdown_title.Parent = dropdown_main_frame
                        dropdown_title.BackgroundColor3 = Theme.Button or Color3New(0.254902, 0.254902, 0.254902)
                        dropdown_title.BackgroundTransparency = 0
                        dropdown_title.BorderSizePixel = 0
                        dropdown_title.Position = UDim2New(0.0529999994, 0, 0, 0)
                        dropdown_title.Size = UDim2New(0, 153, 0, 24)
                        dropdown_title.ZIndex = 2
                        dropdown_title.Font = Font.SourceSansBold
                        dropdown_title.Text = current_selected_dropdown_element
                        dropdown_title.TextColor3 = Color3New(1, 1, 1)
                        dropdown_title.TextSize = 14
                        dropdown_title.ClipsDescendants = false
                  
                        local title_corner = Instance.new("UICorner")
                        title_corner.CornerRadius = UDim.new(0, 4)
                        title_corner.Parent = dropdown_title
                  
                        dropdown_body.Name = "DropdownRound"
                        dropdown_body.Parent = dropdown_title
                        dropdown_body.Active = true
                        dropdown_body.AnchorPoint = Vector2.new(0.5, 0.5)
                        dropdown_body.BackgroundColor3 = Color3New(0.254902, 0.254902, 0.254902)
                        dropdown_body.BackgroundTransparency = 1
                        dropdown_body.BorderSizePixel = 0
                        dropdown_body.ClipsDescendants = true
                        dropdown_body.Position = UDim2New(0.5, 0, 0.5, 0)
                        dropdown_body.Selectable = true
                        dropdown_body.Size = UDim2New(1, 0, 1, 0)
                  
                        local body_corner = Instance.new("UICorner")
                        body_corner.CornerRadius = UDim.new(0, 4)
                        body_corner.Parent = dropdown_body
                  
                        dropdown_toggle.Name = "DropdownToggle"
                        dropdown_toggle.Parent = dropdown_title
                        dropdown_toggle.BackgroundColor3 = Color3New(1, 1, 1)
                        dropdown_toggle.BackgroundTransparency = 1
                        dropdown_toggle.Position = UDim2New(0.816928029, 0, 0, 0)
                        dropdown_toggle.Size = UDim2New(0, 28, 0, 24)
                        dropdown_toggle.AutoButtonColor = false
                        dropdown_toggle.Font = Font.SourceSansBold
                        dropdown_toggle.Text = ">"
                        dropdown_toggle.TextColor3 = Color3New(1, 1, 1)
                        dropdown_toggle.TextSize = 15
                        dropdown_toggle.ZIndex = 3

                        dropdown_canvas.Name = "DropdownCanvas_" .. stringgsub(dropdown_name, " ", "")
                        dropdown_canvas.Parent = window_image_label
                        dropdown_canvas.BackgroundColor3 = Theme.Background or Color3New(0.13725490196078433, 0.13725490196078433, 0.13725490196078433)
                        dropdown_canvas.BackgroundTransparency = 0
                        dropdown_canvas.BorderSizePixel = 0
                        dropdown_canvas.ClipsDescendants = true

                        dropdown_canvas.Position = UDim2New(0, 174, 0, 0)
                        dropdown_canvas.Size = UDim2New(0, 153, 0, 0)
                        dropdown_canvas.ScrollBarThickness = 3
                        dropdown_canvas.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
                        dropdown_canvas.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
                        dropdown_canvas.ScrollingDirection = Enum.ScrollingDirection.Y
                        dropdown_canvas.CanvasSize = UDim2New(0, 0, 0, 0)
                        dropdown_canvas.ZIndex = 50
                        dropdown_canvas.Visible = false
                  
                        local canvas_corner = Instance.new("UICorner")
                        canvas_corner.CornerRadius = UDim.new(0, 6)
                        canvas_corner.Parent = dropdown_canvas
                  
                        dropdown_list_layout.Name = "ButtonLayout"
                        dropdown_list_layout.Parent = dropdown_canvas
                        dropdown_list_layout.SortOrder = SortOrder.LayoutOrder

                        local function GetRowAbsoluteY()
                            return dropdown_main_frame.AbsolutePosition.Y - window_image_label.AbsolutePosition.Y
                        end
                  
                        local function CloseDropdown()
                            if not is_open then return end
                            is_open = false
                            dropdown_toggle.Text = ">"
                            dropdown_title.Text = current_selected_dropdown_element
                  
                            TweenCreate(tween_service, dropdown_canvas, TweenInfo.new(0.3, EasingStyle.Quart, EasingDirection.Out), {
                                Size = UDim2New(0, 153, 0, 0)
                            }):Play()
                  
                            task.delay(0.31, function()
                                dropdown_canvas.Visible = false
                            end)
                        end
                  
                        local function RefreshDropdownList(tbl)
                            CloseDropdown()
                  
                            current_buttons = 0
                            current_y_offset_size = 0
                            needs_scrolling = false
                  
                            for _, btn in pairs(dropdown_canvas:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    btn:Destroy()
                                end
                            end
                  
                            for _, dropdown_element in pairs(tbl) do
                                local button_element = InstanceNew("TextButton")
                                current_buttons = current_buttons + 1
                  
                                button_element.Name = stringgsub(dropdown_element, " ", "") .. "Button"
                                button_element.Parent = dropdown_canvas
                                button_element.BackgroundColor3 = Theme.SectionBg or Color3New(0.137255, 0.137255, 0.137255)
                                button_element.BackgroundTransparency = 0
                                button_element.BorderSizePixel = 0
                                button_element.Size = UDim2New(1, 0, 0, 25)
                                button_element.AutoButtonColor = false
                                button_element.Font = Font.SourceSansBold
                                button_element.Text = dropdown_element
                                button_element.TextColor3 = Color3New(1, 1, 1)
                                button_element.TextSize = 14
                                button_element.ZIndex = 51
                  
                                local btn_corner = Instance.new("UICorner")
                                btn_corner.CornerRadius = UDim.new(0, 4)
                                btn_corner.Parent = button_element

                                if current_buttons <= 4 then
                                    current_y_offset_size = current_y_offset_size + 25
                                else
                                    needs_scrolling = true
                                end
                  
                                button_element.MouseButton1Down:Connect(function()
                                    current_selected_dropdown_element = dropdown_element
                                    dropdown_title.Text = current_selected_dropdown_element
                                    dropdown_callback(dropdown_element)
                                    CloseDropdown()
                                end)
                            end

                            dropdown_canvas.CanvasSize = UDim2New(0, 0, 0, current_buttons * 25)
                        end
                  
                        RefreshDropdownList(dropdown_table)
                  
                        dropdown_toggle.MouseButton1Down:Connect(function()
                            if not is_open then
                                is_open = true
                                dropdown_toggle.Text = "<"
                                dropdown_title.Text = dropdown_name
                    
                                local rowY = GetRowAbsoluteY()
                                dropdown_canvas.Position = UDim2New(0, 174, 0, rowY)
                                dropdown_canvas.Visible = true
                    
                                TweenCreate(tween_service, dropdown_canvas, TweenInfo.new(0.3, EasingStyle.Quart, EasingDirection.Out), {
                                    Size = UDim2New(0, 153, 0, current_y_offset_size)
                                }):Play()
                            else
                                CloseDropdown()
                            end
                        end)
                
                        section_dropdown_toggle.MouseButton1Down:Connect(function()
                            if is_open then
                                CloseDropdown()
                            end
                            
                            if not section_dropdown_toggled then
                                ExpandSection(30)
                                ExpandWindow(30)
                            else
                                CollapseSection(30)
                                CollapseWindow(30)
                            end
                        end)
                  
                        window_dropdown_toggle.MouseButton1Down:Connect(CloseDropdown)
                  
                        return {
                            UpdateDropdown = function(self_unused, tbl)
                                RefreshDropdownList(tbl)
                            end,
                  
                            Select = function(self_unused, str)
                                current_selected_dropdown_element = str
                                dropdown_title.Text = str
                            end
                        }
                    end
                }
            end
        }
    end
}
