const PhysicsService = game:GetService("PhysicsService")
const Players = game:GetService("Players")

local module = {}

function module.Init()
    PhysicsService:CreateCollisionGroup("Enemys")
    PhysicsService:CreateCollisionGroup("Players")
    PhysicsService:CollisionGroupSetCollidable("Enemys", "Enemys", false)
    PhysicsService:CollisionGroupSetCollidable("Enemys", "Players", false)
    PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)

    local playerFolder = workspace.Players or Instance.new("Folder")
    playerFolder.Name = "Players"

    Players.PlayerAdded:Connect(function(plr: Player)
        local function charAdded(char)
            char.Parent = playerFolder
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CollisionGroup = "Players"
                end
            end
        end
        if plr.Character ~= nil then
            charAdded(plr.Character)
        end
        plr.CharacterAdded:Connect(function(char: Model)
            charAdded(char)
        end)
    end)
end

return module