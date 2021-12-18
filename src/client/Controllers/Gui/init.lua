local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService('StarterGui');

local Knit = require(ReplicatedStorage:WaitForChild("Knit"));
local Fusion = require(ReplicatedStorage.Fusion);

local New = Fusion.New;
local Children = Fusion.Children;

local GuiController = Knit.CreateController { Name = "GuiController" };


function GuiController:KnitStart()
    self.Gui = New "ScreenGui" {
        Parent = game.Players.LocalPlayer.PlayerGui;
        Name = "BasicGui";
        IgnoreGuiInset = true;

        [Children] = {
            self.Components.Scene {
            };
        };
    };
end;


function GuiController:KnitInit()
    self.Components = {};

    for _, CompModule: ModuleScript in ipairs(script:WaitForChild('Components'):GetChildren()) do
        self.Components[CompModule.Name] = require(CompModule);
    end;

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);
end;


return GuiController;