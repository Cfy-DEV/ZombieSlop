const Players = game:GetService("Players")
const RunService = game:GetService("RunService")
const lp = Players.LocalPlayer
const currentCamera = workspace.CurrentCamera

while true do
    RunService:UnbindFromRenderStep("IsometricCamera")

    repeat
        task.wait()
    until lp.Character

    local char = lp.Character

    RunService:BindToRenderStep("IsometricCamera", Enum.RenderPriority.Camera.Value, function(delta: number)
        currentCamera.ProjectionType = Enum.ProjectionType.Orthographic
        currentCamera.CameraType = Enum.CameraType.Scriptable
        currentCamera.CFrame = 
    end)

    while char do
        task.wait()
    end
end
