local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Knit);
local Roact = require(ReplicatedStorage.roact);
local RoactSpring = require(ReplicatedStorage["roact-spring"]);
local Janitor = require(ReplicatedStorage.Janitor);

local Check = Roact.Component:extend('Check');

function Check:render()	
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = self.state.zIndex,
	}, {
		frame = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 1),
		}, {
			uIGradient = Roact.createElement("UIGradient", {
				Color = self.color:map(function(col)
					return ColorSequence.new({
						ColorSequenceKeypoint.new(0, col);
						ColorSequenceKeypoint.new(1, col);
					})
				end),
				Rotation = 270,
				Transparency = self.styles.transparency:map(function(val)
					return NumberSequence.new({
						NumberSequenceKeypoint.new(0, val),
						NumberSequenceKeypoint.new(1, 1)
					});
				end);
			}),
		}),

		imageLabel = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://7859835019",
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(self.state.tilesize, self.state.tilesize),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = self.movestyle.pos,
			Size = UDim2.fromScale(5, 5),
			ImageTransparency = self.styles.transparency,
		}),
		
		Roact.createElement("TextLabel", {
			Font = Enum.Font.Cartoon,
			Text = self.text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.8, 0, 0, 75),
			TextTransparency = self.styles.transparency;
			ZIndex = 40;
		})
	});
end;

function Check:init(props)
	self.styles, self.api = RoactSpring.Controller.new{
		transparency = 0;
		config = RoactSpring.config.stiff;
	};
	self:setState{
		tilesize = props.tilesize;
		zIndex = props.zIndex;
	};
	
	self.movestyle, self.moveapi = RoactSpring.Controller.new{
		pos = UDim2.new(.5, 0, .5, 0);
	};

	self.color = Roact.createBinding(props.color or Color3.fromRGB(255, 255, 255));
	
	self.moveapi:start {
		reset = true,
		from = {pos = UDim2.new(.5, 0, .5, 0)},
		to = {pos = UDim2.new(.5, props.tilesize, .5, props.tilesize)},
		loop = true,
		config = {
			duration = 15;
			easing = RoactSpring.easings.linear
		},
	};
	
	self.text, self.updtext = Roact.createBinding("");
end

function Check:didMount()
	local Gui = Knit.GetController('GuiController');
	
	self._janitor = Janitor.new();

	
	self.api:start {
        transparency = 0;
        config = {
            duration = 0;
            easing = RoactSpring.easings.easeOutCubic;
        };
    };
end;

function Check:willUnmount()
	self._janitor:Destroy();
end;

return Check;