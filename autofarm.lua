-- Load XanaxUILib
local XanaxUILib = loadstring(game:HttpGet("https://pastebin.com/raw/XZz3Ytbu"))()
local Ui = XanaxUILib:CreateWindow("AutoFarm UI")

-- Create Autofarm Tab
local AutoFarmTab = Ui:CreateSection("AutoFarm")

local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local backpack = player:FindFirstChild("Backpack")

-- Get the Camera and Player
local camera = game:GetService("Workspace").CurrentCamera
local height = 10  -- Camera height above the player
local distanceBehind = 15  -- Distance behind the player
local downwardAngle = -30  -- Angle for looking downward (in degrees)

local autofarmEnabled = false
local cameraLockingEnabled = false  -- Variable to track camera locking state

-- Set all ProximityPrompts hold time to 0 and max activation distance to 5
for _, prompt in ipairs(game:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 5
    end
end

-- Locations
local locations = {
    CardBuy = Vector3.new(-1126.806, 253.591, -1128.835),
    ATMs = {
        Vector3.new(-784.883, 253.396, -710.849),
        Vector3.new(-779.808, 253.396, -445.622),
        Vector3.new(-1031.068, 253.396, -769.087),
        Vector3.new(-1101.775, 253.396, -1056.871),
        Vector3.new(-1093.422, 253.396, -808.354),
        Vector3.new(-921.665, 253.314, -1004.277),
        Vector3.new(-785.053, 253.396, -929.941)
    },
    CashDropOff = Vector3.new(-700.659, 253.403, -1216.309)
}

-- Function to teleport player
local function teleportTo(position)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Function to simulate key press
local function pressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)  -- Reduced wait time for faster response
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Function to lock the camera behind and above the player, looking downward
local function lockCameraLookingDown()
    while cameraLockingEnabled do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPosition = player.Character.HumanoidRootPart.Position
            -- Set the camera's position behind and above the player
            local cameraPosition = playerPosition + Vector3.new(0, height, -distanceBehind)

            -- Create a CFrame rotation to simulate looking down at a specific angle
            local lookDirection = CFrame.new(cameraPosition, playerPosition)
            local rotation = CFrame.Angles(math.rad(downwardAngle), 0, 0)  -- Rotate downward by the specified angle
            camera.CFrame = lookDirection * rotation
            
            -- Adjust the field of view (zoom out) to simulate the 4th scroll level
            camera.FieldOfView = 90  -- Adjust FOV for zoom out (can be tweaked)
        end
        wait(0.1)  -- Update the camera position every 0.1 seconds
    end
end

-- Fixing the toggle state by using a variable to track it
AutoFarmTab:CreateToggle("Enable AutoFarm", "AutoFarmToggle", function(state)
    autofarmEnabled = state  -- This will track the state of the toggle

    if autofarmEnabled then
        -- Enable camera locking when autofarm is on
        cameraLockingEnabled = true
        spawn(lockCameraLookingDown)  -- Start the camera lock function
    else
        -- Disable camera locking when autofarm is off
        cameraLockingEnabled = false
    end
end)

-- Main AutoFarm Loop
while true do
    if autofarmEnabled then
        -- Check if we have a card in the character (not the backpack)
        if not player.Character:FindFirstChild("Card") then
            -- If no card, teleport to CardBuy
            teleportTo(locations.CardBuy)
            print("No Card, Teleporting to Card Buy")
            task.wait(0.5)  -- Reduced wait time
            pressE()
            task.wait(0.5)  -- Reduced wait time

            -- Wait for the card to appear in the backpack after pressing E
            local card = backpack:WaitForChild("Card", 10)
            if card then
                -- Equip the card if we have it
                card.Parent = player.Character
                print("Card Equipped")

                -- Wait for the card to be fully equipped in the character
                local equippedCard = player.Character:WaitForChild("Card", 10)
                if equippedCard then
                    print("Card is successfully equipped in the character")
                else
                    print("Card not equipped in character!")
                end

                task.wait(1)  -- Give extra time to make sure everything is loaded before teleporting
            else
                print("Card not found in backpack after buying!")
            end
        else
            -- If we have a card, proceed to ATM locations
            if player.Character:FindFirstChild("Card") then
                -- If we have a card, proceed to ATM locations
                for _, atmPos in ipairs(locations.ATMs) do
                    teleportTo(atmPos)
                    task.wait(0.5)  -- Slight delay before action
                    pressE()
                    task.wait(0.2)  -- Reduced wait time between actions
                end
            else
                print("Card not equipped yet!")
            end
        end
        
        -- After checking for cash in the backpack, drop it off if found
        while backpack:FindFirstChild("LargeCash") or 
              backpack:FindFirstChild("MediumCash") or 
              backpack:FindFirstChild("SmallCash") do
            teleportTo(locations.CashDropOff)
            task.wait(0.1)  -- Reduced wait time
            pressE()
            task.wait(0.1)  -- Reduced wait time
        end
    else
        task.wait(1)  -- Wait for 1 second if autofarm is disabled
    end
end
