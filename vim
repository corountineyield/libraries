local VIM = {}
VIM.__index = VIM

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local TouchRegistry = {}
local IDGen = 0
local InputQueue = {}
local ActiveInputs = {}

local TouchState = {
    Begin = 0,
    End = 1,
    Move = 2,
    Cancel = 3
}

function VIM.New()
    local Self = setmetatable({}, VIM)
    Self.Enabled = true
    Self.TouchEnabled = true
    Self.GyroEnabled = true
    Self.AccelEnabled = true
    Self.GravityEnabled = true
    Self.Touches = {}
    Self.Keys = {}
    Self.Mouse = {}
    Self.GamepadConnected = {}
    Self.Recording = false
    Self.Playing = false
    
    Self.ProcessConnection = RunService.Heartbeat:Connect(function()
        Self:ProcessInputQueue()
    end)
    
    return Self
end

function VIM:ProcessInputQueue()
    if #InputQueue == 0 then return end
    
    local Event = table.remove(InputQueue, 1)
    
    if Event.Type == "touch" then
        VirtualInputManager:SendTouchEvent(Event.State, Event.Position.X, Event.Position.Y, game)
        
    elseif Event.Type == "key" then
        VirtualInputManager:SendKeyEvent(Event.Pressed, Event.Key, Event.Repeated, Event.Layer)
        
    elseif Event.Type == "mousebutton" then
        VirtualInputManager:SendMouseButtonEvent(Event.Position.X, Event.Position.Y, Event.Button, Event.Down, Event.Layer, Event.Repeat)
        
    elseif Event.Type == "mousemove" then
        VirtualInputManager:SendMouseMoveEvent(Event.Position.X, Event.Position.Y, Event.Layer)
        
    elseif Event.Type == "mousedelta" then
        
    elseif Event.Type == "mousewheel" then
        VirtualInputManager:SendMouseWheelEvent(Event.Position.X, Event.Position.Y, Event.Forward, Event.Layer)
        
    elseif Event.Type == "textinput" then
        VirtualInputManager:SendTextInputCharacterEvent(Event.Text, Event.Layer)
        
    elseif Event.Type == "accel" then
        VirtualInputManager:SendAccelerometerEvent(Event.Acceleration)
        
    elseif Event.Type == "gyro" then
        VirtualInputManager:SendGyroscopeEvent(Event.Rotation)
        
    elseif Event.Type == "gravity" then
        VirtualInputManager:SendGravityEvent(Event.Gravity)
        
    elseif Event.Type == "scroll" then
        
    elseif Event.Type == "gamepadaxis" then
        
    elseif Event.Type == "gamepadbutton" then
        
    elseif Event.Type == "gamepadconnect" then
        
    elseif Event.Type == "gamepaddisconnect" then
        
    end
end

function VIM:SendTouchEvent(TouchID, State, X, Y)
    if not self.TouchEnabled then return end
    
    local TouchStateValue = State or TouchState.Begin
    local PosX = X or 0
    local PosY = Y or 0
    local ID = TouchID or IDGen
    
    if not self.Touches[ID] then
        self.Touches[ID] = {
            Pos = Vector2.new(PosX, PosY),
            State = TouchStateValue,
            ID = ID,
            StartTime = tick(),
            Force = 1
        }
    else
        self.Touches[ID].Pos = Vector2.new(PosX, PosY)
        self.Touches[ID].State = TouchStateValue
    end
    
    table.insert(InputQueue, {
        Type = "touch",
        ID = ID,
        State = TouchStateValue,
        Position = Vector2.new(PosX, PosY)
    })
    
    if TouchStateValue == TouchState.End or TouchStateValue == TouchState.Cancel then
        self.Touches[ID] = nil
    end
    
    IDGen = IDGen + 1
    return ID
end

function VIM:SendKeyEvent(IsPressed, KeyCode, IsRepeated, LayerCollector)
    if not self.Enabled then return end
    
    local Pressed = IsPressed or false
    local Key = KeyCode or Enum.KeyCode.Unknown
    local Repeated = IsRepeated or false
    local Layer = LayerCollector or game
    
    self.Keys[Key] = Pressed
    
    table.insert(InputQueue, {
        Type = "key",
        Key = Key,
        Pressed = Pressed,
        Repeated = Repeated,
        Layer = Layer
    })
end

function VIM:SendMouseButtonEvent(X, Y, MouseButton, IsDown, LayerCollector, RepeatCount)
    if not self.Enabled then return end
    
    local PosX = X or 0
    local PosY = Y or 0
    local Button = MouseButton or 0
    local Down = IsDown or false
    local Layer = LayerCollector or game
    local Count = RepeatCount or 0
    
    table.insert(InputQueue, {
        Type = "mousebutton",
        Position = Vector2.new(PosX, PosY),
        Button = Button,
        Down = Down,
        Layer = Layer,
        Repeat = Count
    })
end

function VIM:SendMouseMoveEvent(X, Y, LayerCollector)
    if not self.Enabled then return end
    
    local PosX = X or 0
    local PosY = Y or 0
    local Layer = LayerCollector or game
    
    table.insert(InputQueue, {
        Type = "mousemove",
        Position = Vector2.new(PosX, PosY),
        Layer = Layer
    })
end

function VIM:SendMouseMoveDeltaEvent(DeltaX, DeltaY, LayerCollector)
    if not self.Enabled then return end
    
    local DX = DeltaX or 0
    local DY = DeltaY or 0
    local Layer = LayerCollector or game
    
    table.insert(InputQueue, {
        Type = "mousedelta",
        Delta = Vector2.new(DX, DY),
        Layer = Layer
    })
end

function VIM:SendMouseWheelEvent(X, Y, IsForwardScroll, LayerCollector)
    if not self.Enabled then return end
    
    local PosX = X or 0
    local PosY = Y or 0
    local Forward = IsForwardScroll or false
    local Layer = LayerCollector or game
    
    table.insert(InputQueue, {
        Type = "mousewheel",
        Position = Vector2.new(PosX, PosY),
        Forward = Forward,
        Layer = Layer
    })
end

function VIM:SendTextInputCharacterEvent(Str, LayerCollector)
    if not self.Enabled then return end
    
    local Text = Str or ""
    local Layer = LayerCollector or game
    
    table.insert(InputQueue, {
        Type = "textinput",
        Text = Text,
        Layer = Layer
    })
end

function VIM:SendAccelerometerEvent(Accel)
    if not self.AccelEnabled then return end
    
    local Acceleration = Accel or Vector3.new(0, 0, 0)
    
    table.insert(InputQueue, {
        Type = "accel",
        Acceleration = Acceleration
    })
end

function VIM:SendGyroscopeEvent(Rotation)
    if not self.GyroEnabled then return end
    
    local Rot = Rotation or Vector3.new(0, 0, 0)
    
    table.insert(InputQueue, {
        Type = "gyro",
        Rotation = Rot
    })
end

function VIM:SendGravityEvent(Gravity)
    if not self.GravityEnabled then return end
    
    local Grav = Gravity or Vector3.new(0, -9.81, 0)
    
    table.insert(InputQueue, {
        Type = "gravity",
        Gravity = Grav
    })
end

function VIM:SendScroll(X, Y, DeltaX, DeltaY, Options, LayerCollector)
    if not self.Enabled then return end
    
    local PosX = X or 0
    local PosY = Y or 0
    local DX = DeltaX or 0
    local DY = DeltaY or 0
    local Opts = Options or {}
    local Layer = LayerCollector or game
    
    table.insert(InputQueue, {
        Type = "scroll",
        Position = Vector2.new(PosX, PosY),
        Delta = Vector2.new(DX, DY),
        Options = Opts,
        Layer = Layer
    })
end

function VIM:HandleGamepadAxisInput(Gamepad, Axis, Value)
    if not self.Enabled then return end
    
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    local Ax = Axis or Enum.KeyCode.Thumbstick1
    local Val = Value or 0
    
    table.insert(InputQueue, {
        Type = "gamepadaxis",
        Gamepad = Pad,
        Axis = Ax,
        Value = Val
    })
end

function VIM:HandleGamepadButtonInput(Gamepad, Button, IsPressed)
    if not self.Enabled then return end
    
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    local Btn = Button or Enum.KeyCode.ButtonA
    local Pressed = IsPressed or false
    
    table.insert(InputQueue, {
        Type = "gamepadbutton",
        Gamepad = Pad,
        Button = Btn,
        Pressed = Pressed
    })
end

function VIM:HandleGamepadConnect(Gamepad)
    if not self.Enabled then return end
    
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    self.GamepadConnected[Pad] = true
    
    table.insert(InputQueue, {
        Type = "gamepadconnect",
        Gamepad = Pad
    })
end

function VIM:HandleGamepadDisconnect(Gamepad)
    if not self.Enabled then return end
    
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    self.GamepadConnected[Pad] = false
    
    table.insert(InputQueue, {
        Type = "gamepaddisconnect",
        Gamepad = Pad
    })
end

function VIM:StartRecording()
    self.Recording = true
    self.RecordedInputs = {}
    self.RecordStartTime = tick()
end

function VIM:StopRecording()
    self.Recording = false
    return self.RecordedInputs
end

function VIM:StartPlaying(InputData)
    self.Playing = true
    self.PlaybackData = InputData or {}
    self.PlaybackIndex = 1
    self.PlaybackStartTime = tick()
end

function VIM:StopPlaying()
    self.Playing = false
    self.PlaybackData = nil
    self.PlaybackIndex = 1
end

function VIM:WaitForInputEventsProcessed()
    while #InputQueue > 0 do
        task.wait()
    end
end

function VIM:Tap(Pos, Duration)
    local Time = Duration or 0.1
    local TouchPos = Pos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local ID = self:SendTouchEvent(nil, TouchState.Begin, TouchPos.X, TouchPos.Y)
    task.wait(Time)
    self:SendTouchEvent(ID, TouchState.Move, TouchPos.X, TouchPos.Y)
    task.wait(0.05)
    self:SendTouchEvent(ID, TouchState.End, TouchPos.X, TouchPos.Y)
end

function VIM:DoubleTap(Pos, Delay)
    local Gap = Delay or 0.15
    self:Tap(Pos, 0.05)
    task.wait(Gap)
    self:Tap(Pos, 0.05)
end

function VIM:LongPress(Pos, Duration)
    local Time = Duration or 1.0
    local TouchPos = Pos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local ID = self:SendTouchEvent(nil, TouchState.Begin, TouchPos.X, TouchPos.Y)
    task.wait(Time)
    self:SendTouchEvent(ID, TouchState.Move, TouchPos.X, TouchPos.Y)
    task.wait(0.05)
    self:SendTouchEvent(ID, TouchState.End, TouchPos.X, TouchPos.Y)
end

function VIM:Swipe(Start, End, Duration)
    local Time = Duration or 0.3
    local StartPos = Start or Vector2.new(100, Camera.ViewportSize.Y / 2)
    local EndPos = End or Vector2.new(Camera.ViewportSize.X - 100, Camera.ViewportSize.Y / 2)
    
    local ID = self:SendTouchEvent(nil, TouchState.Begin, StartPos.X, StartPos.Y)
    
    local Steps = math.floor(Time * 60)
    local Delta = (EndPos - StartPos) / Steps
    
    for i = 1, Steps do
        local Current = StartPos + (Delta * i)
        self:SendTouchEvent(ID, TouchState.Move, Current.X, Current.Y)
        task.wait(1/60)
    end
    
    self:SendTouchEvent(ID, TouchState.End, EndPos.X, EndPos.Y)
end

function VIM:Drag(Start, End, Duration)
    self:Swipe(Start, End, Duration)
end

function VIM:Pinch(Center, StartDist, EndDist, Duration)
    local Time = Duration or 0.5
    local CenterPos = Center or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local Dist1 = StartDist or 200
    local Dist2 = EndDist or 50
    
    local Offset = Vector2.new(Dist1 / 2, 0)
    local P1Start = CenterPos - Offset
    local P2Start = CenterPos + Offset
    
    local ID1 = self:SendTouchEvent(nil, TouchState.Begin, P1Start.X, P1Start.Y)
    local ID2 = self:SendTouchEvent(nil, TouchState.Begin, P2Start.X, P2Start.Y)
    
    local Steps = math.floor(Time * 60)
    
    for i = 1, Steps do
        local Progress = i / Steps
        local CurrentDist = Dist1 + (Dist2 - Dist1) * Progress
        local CurrentOffset = Vector2.new(CurrentDist / 2, 0)
        
        local P1 = CenterPos - CurrentOffset
        local P2 = CenterPos + CurrentOffset
        
        self:SendTouchEvent(ID1, TouchState.Move, P1.X, P1.Y)
        self:SendTouchEvent(ID2, TouchState.Move, P2.X, P2.Y)
        
        task.wait(1/60)
    end
    
    local FinalOffset = Vector2.new(Dist2 / 2, 0)
    self:SendTouchEvent(ID1, TouchState.End, (CenterPos - FinalOffset).X, (CenterPos - FinalOffset).Y)
    self:SendTouchEvent(ID2, TouchState.End, (CenterPos + FinalOffset).X, (CenterPos + FinalOffset).Y)
end

function VIM:Zoom(Center, StartDist, EndDist, Duration)
    self:Pinch(Center, StartDist, EndDist, Duration)
end

function VIM:Rotate(Center, Radius, StartAngle, EndAngle, Duration)
    local Time = Duration or 0.5
    local CenterPos = Center or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local Rad = Radius or 100
    local Angle1 = StartAngle or 0
    local Angle2 = EndAngle or math.pi
    
    local P1Start = CenterPos + Vector2.new(math.cos(Angle1) * Rad, math.sin(Angle1) * Rad)
    local P2Start = CenterPos + Vector2.new(math.cos(Angle1 + math.pi) * Rad, math.sin(Angle1 + math.pi) * Rad)
    
    local ID1 = self:SendTouchEvent(nil, TouchState.Begin, P1Start.X, P1Start.Y)
    local ID2 = self:SendTouchEvent(nil, TouchState.Begin, P2Start.X, P2Start.Y)
    
    local Steps = math.floor(Time * 60)
    
    for i = 1, Steps do
        local Progress = i / Steps
        local CurrentAngle = Angle1 + (Angle2 - Angle1) * Progress
        
        local P1 = CenterPos + Vector2.new(math.cos(CurrentAngle) * Rad, math.sin(CurrentAngle) * Rad)
        local P2 = CenterPos + Vector2.new(math.cos(CurrentAngle + math.pi) * Rad, math.sin(CurrentAngle + math.pi) * Rad)
        
        self:SendTouchEvent(ID1, TouchState.Move, P1.X, P1.Y)
        self:SendTouchEvent(ID2, TouchState.Move, P2.X, P2.Y)
        
        task.wait(1/60)
    end
    
    local FinalP1 = CenterPos + Vector2.new(math.cos(Angle2) * Rad, math.sin(Angle2) * Rad)
    local FinalP2 = CenterPos + Vector2.new(math.cos(Angle2 + math.pi) * Rad, math.sin(Angle2 + math.pi) * Rad)
    
    self:SendTouchEvent(ID1, TouchState.End, FinalP1.X, FinalP1.Y)
    self:SendTouchEvent(ID2, TouchState.End, FinalP2.X, FinalP2.Y)
end

function VIM:MultiTouch(Positions, Duration)
    local Time = Duration or 0.1
    local IDs = {}
    
    for i, Pos in ipairs(Positions) do
        IDs[i] = self:SendTouchEvent(nil, TouchState.Begin, Pos.X, Pos.Y)
    end
    
    task.wait(Time)
    
    for i, ID in ipairs(IDs) do
        local Pos = Positions[i]
        self:SendTouchEvent(ID, TouchState.Move, Pos.X, Pos.Y)
        task.wait(0.05)
        self:SendTouchEvent(ID, TouchState.End, Pos.X, Pos.Y)
    end
end

function VIM:Circle(Center, Radius, Clockwise, Duration)
    local Time = Duration or 1.0
    local CenterPos = Center or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local Rad = Radius or 100
    local Direction = Clockwise and 1 or -1
    
    local StartPos = CenterPos + Vector2.new(Rad, 0)
    local ID = self:SendTouchEvent(nil, TouchState.Begin, StartPos.X, StartPos.Y)
    
    local Steps = math.floor(Time * 60)
    local AngleDelta = Direction * (math.pi * 2) / Steps
    
    for i = 1, Steps do
        local Angle = AngleDelta * i
        local Pos = CenterPos + Vector2.new(math.cos(Angle) * Rad, math.sin(Angle) * Rad)
        self:SendTouchEvent(ID, TouchState.Move, Pos.X, Pos.Y)
        task.wait(1/60)
    end
    
    self:SendTouchEvent(ID, TouchState.End, StartPos.X, StartPos.Y)
end

function VIM:PressKey(Key, Duration)
    local Time = Duration or 0.1
    local KeyCode = Key or Enum.KeyCode.Space
    
    self:SendKeyEvent(true, KeyCode, false, game)
    task.wait(Time)
    self:SendKeyEvent(false, KeyCode, false, game)
end

function VIM:HoldKey(Key)
    local KeyCode = Key or Enum.KeyCode.Space
    self:SendKeyEvent(true, KeyCode, false, game)
end

function VIM:ReleaseKey(Key)
    local KeyCode = Key or Enum.KeyCode.Space
    self:SendKeyEvent(false, KeyCode, false, game)
end

function VIM:TypeText(Text, Delay)
    local Gap = Delay or 0.05
    local Str = Text or ""
    
    for i = 1, #Str do
        local Char = string.sub(Str, i, i)
        self:SendTextInputCharacterEvent(Char, game)
        task.wait(Gap)
    end
end

function VIM:ClickMouse(Button, Pos)
    local Btn = Button or 0
    local Position = Pos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    self:SendMouseButtonEvent(Position.X, Position.Y, Btn, true, game, 0)
    task.wait(0.05)
    self:SendMouseButtonEvent(Position.X, Position.Y, Btn, false, game, 0)
end

function VIM:HoldMouse(Button, Pos)
    local Btn = Button or 0
    local Position = Pos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    self:SendMouseButtonEvent(Position.X, Position.Y, Btn, true, game, 0)
end

function VIM:ReleaseMouse(Button, Pos)
    local Btn = Button or 0
    local Position = Pos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    self:SendMouseButtonEvent(Position.X, Position.Y, Btn, false, game, 0)
end

function VIM:MoveMouse(Pos)
    local Position = Pos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    self:SendMouseMoveEvent(Position.X, Position.Y, game)
end

function VIM:ScrollMouse(Forward, Pos)
    local IsForward = Forward or true
    local Position = Pos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    self:SendMouseWheelEvent(Position.X, Position.Y, IsForward, game)
end

function VIM:DragMouse(Start, End, Duration)
    local Time = Duration or 0.3
    local StartPos = Start or Vector2.new(100, Camera.ViewportSize.Y / 2)
    local EndPos = End or Vector2.new(Camera.ViewportSize.X - 100, Camera.ViewportSize.Y / 2)
    
    self:SendMouseButtonEvent(StartPos.X, StartPos.Y, 0, true, game, 0)
    
    local Steps = math.floor(Time * 60)
    local Delta = (EndPos - StartPos) / Steps
    
    for i = 1, Steps do
        local Current = StartPos + (Delta * i)
        self:SendMouseMoveEvent(Current.X, Current.Y, game)
        task.wait(1/60)
    end
    
    self:SendMouseButtonEvent(EndPos.X, EndPos.Y, 0, false, game, 0)
end

function VIM:Tilt(Pitch, Roll, Yaw, Duration)
    if not self.GyroEnabled then return end
    
    local Time = Duration or 0.5
    local Target = Vector3.new(Pitch or 0, Roll or 0, Yaw or 0)
    local Current = Vector3.new(0, 0, 0)
    
    local Steps = math.floor(Time * 60)
    
    for i = 1, Steps do
        local Progress = i / Steps
        Current = Current:Lerp(Target, Progress)
        self:SendGyroscopeEvent(Current)
        task.wait(1/60)
    end
end

function VIM:Shake(Intensity, Duration)
    if not self.AccelEnabled then return end
    
    local Time = Duration or 0.5
    local Power = Intensity or 1
    
    local Steps = math.floor(Time * 60)
    
    for i = 1, Steps do
        local ShakeVector = Vector3.new(
            (math.random() - 0.5) * Power * 2,
            (math.random() - 0.5) * Power * 2,
            (math.random() - 0.5) * Power * 2
        )
        self:SendAccelerometerEvent(ShakeVector)
        task.wait(1/60)
    end
    
    self:SendAccelerometerEvent(Vector3.new(0, 0, 0))
end

function VIM:SetGravity(Direction, Strength)
    if not self.GravityEnabled then return end
    
    local Dir = Direction or Vector3.new(0, -1, 0)
    local Str = Strength or 9.81
    
    local Gravity = Dir.Unit * Str
    self:SendGravityEvent(Gravity)
end

function VIM:PressButton(Gamepad, Button, Duration)
    local Time = Duration or 0.1
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    local Btn = Button or Enum.KeyCode.ButtonA
    
    self:HandleGamepadButtonInput(Pad, Btn, true)
    task.wait(Time)
    self:HandleGamepadButtonInput(Pad, Btn, false)
end

function VIM:MoveStick(Gamepad, Stick, Position)
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    local Axis = Stick or Enum.KeyCode.Thumbstick1
    local Pos = Position or Vector2.new(0, 0)
    
    self:HandleGamepadAxisInput(Pad, Axis, Pos.X)
end

function VIM:ConnectGamepad(Gamepad)
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    self:HandleGamepadConnect(Pad)
end

function VIM:DisconnectGamepad(Gamepad)
    local Pad = Gamepad or Enum.UserInputType.Gamepad1
    self:HandleGamepadDisconnect(Pad)
end

function VIM:ClearInputs()
    InputQueue = {}
    self.Touches = {}
    self.Keys = {}
    ActiveInputs = {}
end

function VIM:GetTouches()
    return self.Touches
end

function VIM:GetActiveKeys()
    local Active = {}
    for Key, Pressed in pairs(self.Keys) do
        if Pressed then
            table.insert(Active, Key)
        end
    end
    return Active
end

function VIM:IsKeyPressed(Key)
    return self.Keys[Key] == true
end

function VIM:IsTouchActive(ID)
    return self.Touches[ID] ~= nil
end

function VIM:GetTouchPosition(ID)
    if self.Touches[ID] then
        return self.Touches[ID].Pos
    end
    return nil
end

function VIM:EnableTouch()
    self.TouchEnabled = true
end

function VIM:DisableTouch()
    self.TouchEnabled = false
end

function VIM:EnableGyro()
    self.GyroEnabled = true
end

function VIM:DisableGyro()
    self.GyroEnabled = false
end

function VIM:EnableAccel()
    self.AccelEnabled = true
end

function VIM:DisableAccel()
    self.AccelEnabled = false
end

function VIM:EnableGravity()
    self.GravityEnabled = true
end

function VIM:DisableGravity()
    self.GravityEnabled = false
end

function VIM:Enable()
    self.Enabled = true
end

function VIM:Disable()
    self.Enabled = false
end

function VIM:Destroy()
    if self.ProcessConnection then
        self.ProcessConnection:Disconnect()
    end
    self:ClearInputs()
end

return VIM
