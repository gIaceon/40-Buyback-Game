local INFO_TEXT_FORMAT = 
[[Name: %s
Cost: R$%d 
Discount: ~R$%d
Cost After Discount: ~R$%d]];

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
    local GuiController = Knit.GetController'GuiController';
    local OnInput = Signal.new();

    local PurchaseValue = State(0);
    local Purchases = State(0);
    local Info = State(nil);
    local Mode = State(0);
    local ErrText = State'';
    local InfoText = State'';

    OnInput:Connect(function(New: number)
        if (not New) then
            return;
        end;

        PurchaseValue:set(New);
        
        -- local info = pcall(function()
        --     return MarketplaceService:GetProductInfo(New);
        -- end);
        local done, returned = pcall(MarketplaceService.GetProductInfo, MarketplaceService, New);
        local info = if done ~= false then returned else nil;
        
        Info:set(info);

        if (info) then
            -- if (info.Creator and info.Creator.Id == 1) then
                if (info.IsLimited or info.IsLimitedUnique) then
                    InfoText:set('You cannot buy limited items in game.');
                    return;
                end;
                local Cost = info.PriceInRobux or 0;
                local GroupCommissionAmount = math.floor(Cost * .4);
                local Saved = Cost - GroupCommissionAmount;
                local Name = info.Name or '?';

                if (info.Creator and info.Creator.Id ~= 1) then
                    Name = Name..' <b>(NOTE: THIS MAY NOT WORK AS IT IS UGC!)</b>'
                end;

                print(Name, Cost, GroupCommissionAmount, Saved, info);

                InfoText:set(string.format(INFO_TEXT_FORMAT, Name, Cost, GroupCommissionAmount, Saved));
            -- else
                -- InfoText:set('You will not save 40% on UGC items. Use an item uploaded by the Roblox account to save 40%. You can still buy UGC items, though.');
            -- end;
        else
            InfoText:set('Invalid item.');
        end;
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
                Position = UDim2.fromScale(.9, .35);
                Size = UDim2.fromScale(.5, .1);
                AnchorPoint = Vector2.new(1, .5);
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

                [OnEvent "Focused"] = function()
                    ErrText:set'';
                end;
            };

            New "TextLabel" {
                Position = UDim2.fromScale(.5, .1);
                Size = UDim2.fromScale(1, .1);
                AnchorPoint = Vector2.new(.5, .5);
                BackgroundTransparency = 1;
                Name = 'Err';
                Font = Enum.Font.Cartoon;
                Text = Computed(function()
                    return ErrText:get();
                end);
                TextScaled = true;
                TextColor3 = Color3.fromRGB(255, 0, 0);
            };

            New "TextLabel" {
                Position = UDim2.fromScale(.2, .7);
                Size = UDim2.fromScale(.3, .3);
                AnchorPoint = Vector2.new(.5, .5);
                BackgroundTransparency = 1;
                Name = 'InfoText';
                RichText = true;
                Font = Enum.Font.Cartoon;
                Text = Computed(function()
                    return InfoText:get();
                end);
                TextScaled = true;
                TextColor3 = Color3.fromRGB(255, 255, 255);
            };

            New "TextLabel" {
                Position = UDim2.fromScale(.5, 1);
                Size = UDim2.fromScale(1, .08);
                AnchorPoint = Vector2.new(.5, 1);
                BackgroundTransparency = 1;
                Name = 'Disclaimer';
                Font = Enum.Font.Cartoon;
                Text = 'Note: The "Discount" number will be sent to your group funds. When you purchase the item it will show as the original price, and you will pay the original price.';
                TextScaled = true;
                TextColor3 = Color3.fromRGB(95, 231, 255);
            };

            New "ImageLabel" {
                Position = UDim2.fromScale(.2, .35);
                Size = UDim2.fromScale(.3, .3);
                AnchorPoint = Vector2.new(.5, .5);
                BackgroundTransparency = 1;
                Image = Computed(function()
                    return ('rbxthumb://type=Asset&id=%d&w=420&h=420'):format(PurchaseValue:get() or 0);
                end);
                ScaleType = Enum.ScaleType.Fit;
            };

            New "TextButton" {
                Position = UDim2.fromScale(.9, .6);
                Size = UDim2.fromScale(.35, .125);
                AnchorPoint = Vector2.new(1, .5);
                BackgroundColor3 = Color3.fromRGB(30, 255, 0);
                BorderColor3 = Color3.fromRGB(37, 219, 0);
                BorderSizePixel = 3;
                BorderMode = Enum.BorderMode.Outline;
                Font = Enum.Font.Cartoon;
                Name = 'PurchaseBtn';
                Text = 'Purchase';
                TextScaled = true;
    
                [OnEvent "Activated"] = function()
                    GuiController:Play'click';
                    local Done, Return = pcall(function()
                        local ID = PurchaseValue:get();
                        local info = Info:get();
                        
                        assert(info ~= nil, 'This is not a valid item.');
                        -- assert(info.Creator.Id == 1, 'Item must be uploaded by Roblox.');
                        assert(info.IsForSale == true, 'This item is not on sale.');

                        local PurchaseDone, Err = pcall(
                            MarketplaceService.PromptPurchase,
                            MarketplaceService,
                            game.Players.LocalPlayer,
                            tonumber(ID)
                        );

                        assert(PurchaseDone == true, 'This is not a valid item.');
                    end);

                    if (not Done) then
                        warn('Failed!', Return);
                        if (Return and type(Return) == 'string') then
                            -- this is gross, i want to remove the traceback.
                            -- i split it to get the traceback, then remove it using gsub.
                            local SplitText = Return:split(' ');
                            ErrText:set(Return:gsub(SplitText[1], ''));
                        end;
                        
                    end;
                end;
            };
        };
    };
end;

return Scene;