local ReplicatedStorage = game:GetService("ReplicatedStorage");
local MarketplaceService = game:GetService("MarketplaceService");

local Fusion = require(ReplicatedStorage.Fusion);
local Knit = require(ReplicatedStorage:WaitForChild("Knit"));

local New = Fusion.New;
local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent;
local OnChange = Fusion.OnChange;
local State = Fusion.State;
local Computed = Fusion.Computed;
local ComputedPairs = Fusion.ComputedPairs;
local Compat = Fusion.Compat;
local Tween = Fusion.Tween;
local Spring = Fusion.Spring;

local Signal = require(Knit.Util.Signal);

local function Scene(props)
    local OnInput = Signal.new();

    local PurchaseValue = State(0);
    local Purchases = State(0);

    OnInput:Connect(function(New: number)
        if (not New) then
            return;
        end;

        PurchaseValue:set(New);
    end);

    return New "Frame" {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        Position = UDim2.fromScale(.5, .5);
        AnchorPoint = Vector2.new(.5, .5);
        Name = "Scene";

        [Children] = {
            New "TextBox" {
                Position = UDim2.fromScale(.5, .35);
                Size = UDim2.fromScale(.65, .1);
                AnchorPoint = Vector2.new(.5, .5);
                BackgroundColor3 = Color3.fromRGB(231, 231, 231);
                BorderColor3 = Color3.fromRGB(204, 204, 204);
                BorderSizePixel = 3;
                BorderMode = Enum.BorderMode.Outline;
                Name = "Buy";
                Font = Enum.Font.Cartoon;
                PlaceholderColor3 = Color3.fromRGB(109, 109, 109);
                PlaceholderText = "Type in the ID of the item you want to buy (40% off roblox made items only)";
                Text = '';
                TextScaled = true;
                ClearTextOnFocus = false;

                [OnChange "Text"] = function(New)
                    local Num = tonumber(New);

                    if (Num == nil) then
                        return;
                    end;

                    OnInput:Fire(New);
                end;
            };
        };

        New "TextButton" {
            Position = UDim2.fromScale(.5, .6);
            Size = UDim2.fromScale(.35, .2);
            AnchorPoint = Vector2.new(.5, .5);
            BackgroundColor3 = Color3.fromRGB(30, 255, 0);
            BorderColor3 = Color3.fromRGB(37, 219, 0);
            BorderSizePixel = 3;
            BorderMode = Enum.BorderMode.Outline;
            Font = Enum.Font.Cartoon;
            Text = 'Purchase';
            TextScaled = true;

            [OnEvent "Activated"] = function()
                local ID = PurchaseValue:get();
                MarketplaceService:PromptPurchase(game.Players.LocalPlayer, tonumber(ID));
            end;
        };
    };
end;

return Scene;