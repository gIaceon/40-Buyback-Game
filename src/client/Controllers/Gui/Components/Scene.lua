local INFO_TEXT_FORMAT = 
[[Name: %s
Cost: R$%d 
Discount: R$%d
Cost After Discount: R$%d]];

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local MarketplaceService = game:GetService("MarketplaceService");

local Knit = require(ReplicatedStorage.Knit);
local Roact = require(ReplicatedStorage.roact);
local RoactSpring = require(ReplicatedStorage["roact-spring"]);
local Janitor = require(ReplicatedStorage.Janitor);
local Signal = require(ReplicatedStorage.Signal);

local Scene = Roact.Component:extend('Scene');

function Scene:render()	
	return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
      }, {
        buy = Roact.createElement("TextBox", {
          ClearTextOnFocus = false,
          Font = Enum.Font.Cartoon,
          PlaceholderColor3 = Color3.fromRGB(109, 109, 109),
          PlaceholderText = "Type in the ID of the item you want to buy",
          Text = "",
          TextColor3 = Color3.fromRGB(0, 0, 0),
          TextScaled = true,
          TextSize = 14,
          TextWrapped = true,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = Color3.fromRGB(255, 255, 255),
          Position = UDim2.fromScale(0.9, 0.36),
          Size = UDim2.fromScale(0.5, 0.1),

          [Roact.Change.Text] = function(txt)
            local Num = tonumber(txt.Text);
            print(Num);

            if (Num == nil) then
                return;
            end;
            print('setting');

            self.onInput:Fire(Num)
          end;

          [Roact.Event.Focused] = function() 
            -- Err Text
            self.changeErr'';
          end;
        }, {
          uIStroke = Roact.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(107, 107, 107),
            LineJoinMode = Enum.LineJoinMode.Bevel,
            Thickness = 6.5,
          }),
        }),
      
        err = Roact.createElement("TextLabel", {
          Font = Enum.Font.Cartoon,
          RichText = true,
          Text = self.err,
          TextColor3 = Color3.fromRGB(255, 0, 0),
          TextScaled = true,
          TextSize = 14,
          TextWrapped = true,
          AnchorPoint = Vector2.new(0.5, 1),
          BackgroundColor3 = Color3.fromRGB(255, 255, 255),
          BackgroundTransparency = 1,
          BorderSizePixel = 0,
          Position = UDim2.fromScale(0.5, 1),
          Size = UDim2.fromScale(1, 0.1),
        }),
      
        infoText = Roact.createElement("TextLabel", {
          Font = Enum.Font.Cartoon,
        --   FontFace = Font.new(Font { Family = rbxasset://fonts/families/AccanthisADFStd.json, Weight = Regular, Style = Normal }),
          RichText = true,
          Text = self.infotxt,
          TextColor3 = Color3.fromRGB(255, 255, 255),
          TextScaled = true,
          TextSize = 14,
          TextWrapped = true,
          AnchorPoint = Vector2.new(0.5, 0.5),
          BackgroundColor3 = Color3.fromRGB(255, 255, 255),
          BackgroundTransparency = 1,
          BorderSizePixel = 0,
          Position = UDim2.fromScale(0.2, 0.7),
          Size = UDim2.fromScale(0.3, 0.3),
        }),
      
        img = Roact.createElement("ImageLabel", {
          ScaleType = Enum.ScaleType.Fit,
          AnchorPoint = Vector2.new(0.5, 0.5),
          BackgroundColor3 = Color3.fromRGB(255, 255, 255),
          BackgroundTransparency = 1,
          BorderSizePixel = 0,
          Position = UDim2.fromScale(0.2, 0.35),
          Size = UDim2.fromScale(0.3, 0.3),
          Image = self.asset:map(function(val)
            return ('rbxthumb://type=Asset&id=%d&w=420&h=420'):format(val or 0);
          end);
        }),
      
        btn = Roact.createElement("TextButton", {
          Font = Enum.Font.Cartoon,
        --   FontFace = Font.new(Font { Family = rbxasset://fonts/families/ComicNeueAngular.json, Weight = Regular, Style = Normal }),
          Text = "Buy",
          TextColor3 = Color3.fromRGB(255, 255, 255),
          TextScaled = true,
          TextSize = 14,
          TextWrapped = true,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = Color3.fromRGB(0, 255, 17),
          Position = UDim2.fromScale(0.9, 0.5),
          Size = UDim2.fromScale(0.3, 0.1),

          [Roact.Event.Activated] = function() 
            local GuiController = Knit.GetController'GuiController';
            GuiController:Play'click';

            local Done, Return = pcall(function()
                local ID = self.asset:getValue();
                local info = self.info:getValue();
                
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
                    self.changeErr(Return:gsub(SplitText[1], ''));
                end;
            end;
          end;
        }, {
          uIStroke1 = Roact.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(0, 180, 30),
            Thickness = 10.5,
          }),
        }),
      })
end;

function Scene:init(props)
    self.asset, self.changeAsset = Roact.createBinding(0);
    self.err, self.changeErr = Roact.createBinding'';
    self.infotxt, self.changeInfotxt = Roact.createBinding'';
    self.info, self.setInfo = Roact.createBinding{};
    self.onInput = Signal.new();
end

function Scene:didMount()
	local Gui = Knit.GetController('GuiController');
	
	self._janitor = Janitor.new();
    self._janitor:Add(self.onInput:Connect(function(New: number)
        if (not New) then
            return;
        end;
        self.changeAsset(New);

        local done, returned = pcall(MarketplaceService.GetProductInfo, MarketplaceService, New);
        local info = if done ~= false then returned else nil;

        self.setInfo(info);
        if (info) then
            -- if (info.Creator and info.Creator.Id == 1) then
                if (info.IsLimited or info.IsLimitedUnique) then
                    -- InfoText:set('You cannot buy limited items in game.');
                    self.changeInfotxt('You cannot buy limited items in game.');
                    return;
                end;
                local Cost = info.PriceInRobux or 0;
                local GroupCommissionAmount = math.floor(Cost * .4);
                local Saved = Cost - GroupCommissionAmount;
                local Name = info.Name or '?';

                if (info.Creator and info.Creator.Id ~= 1) then
                    -- Name = Name..' <b>(NOTE: THIS MAY NOT WORK AS IT IS UGC!)</b>'
                end;

                print(Name, Cost, GroupCommissionAmount, Saved, info);

                -- InfoText:set(string.format(INFO_TEXT_FORMAT, Name, Cost, GroupCommissionAmount, Saved));
                self.changeInfotxt(string.format(INFO_TEXT_FORMAT, Name, Cost, GroupCommissionAmount, Saved))
            -- else
                -- InfoText:set('You will not save 40% on UGC items. Use an item uploaded by the Roblox account to save 40%. You can still buy UGC items, though.');
            -- end;
        else
            self.changeInfotxt('Invalid item.');
        end;
    end));
end;

function Scene:willUnmount()
	self._janitor:Destroy();
    self.onInput:Destroy();
end;

return Scene;