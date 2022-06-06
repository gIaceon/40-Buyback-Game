local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService('StarterGui');
local ContentProvider = game:GetService('ContentProvider');

local Knit = require(ReplicatedStorage:WaitForChild("Knit"));
local Roact = require(ReplicatedStorage.roact);

local GuiController = Knit.CreateController { Name = "GuiController" };

function GuiController:Sound(Name: string)
    local Sound = self._sound[Name]; if (not Sound) then return; end;
    return Sound;
end;

function GuiController:Play(Name: string)
    local s = self:Sound(Name); if (s) then s:Play() end;
end;

function GuiController:KnitStart()
    self.Gui = Roact.createElement(
        self.Components.App, {
            Components = self.Components;
        }
    );

    self.Mount = Roact.mount(
        self.Gui,
        game.Players.LocalPlayer.PlayerGui
    )
end;


function GuiController:KnitInit()
    self.Components = {};

    self._sound = {};

    for SoundName, SoundObj in pairs(require(script.Sounds)) do
        local newsound = Instance.new('Sound');
        newsound.Name = SoundName;
        newsound.Volume = SoundObj.Volume;
        newsound.SoundId = SoundObj.Id;

        -- Preload the sound using ContentProvider, using task.defer so it doesn't halt
        task.defer(function () 
            return ContentProvider:PreloadAsync({newsound}, function (ID, Status: Enum.AssetFetchStatus)
                warn(
                    string.format(
                        'Load %s:%s for asset %s', 
                        SoundName,
                        if (Status == Enum.AssetFetchStatus.Success) then 'success' else 'failed',
                        tostring(ID)
                        )
                    )
            end);
        end); 

        self._sound[SoundName] = newsound;
        newsound.Parent = workspace;
    end;

    for _, CompModule: ModuleScript in ipairs(script:WaitForChild('Components'):GetChildren()) do
        if (not CompModule.Name:find('.old')) then
            self.Components[CompModule.Name] = require(CompModule);
        end;
    end;

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);
end;


return GuiController;