local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Roact = require(ReplicatedStorage.roact);
local Knit = require(ReplicatedStorage.Knit);

local function App(props)
	local Gui = Knit.GetController('GuiController');

	return Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
		Name = 'MAIN';
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	}, {
		Check = Roact.createElement(props.Components.Check, {
			tilesize = 250;
			color = Color3.fromRGB(244, 118, 7);
			-- colorTo = Color3.fromRGB(0, 238, 255);
            zIndex = -5;
		});

		Scene = Roact.createElement(props.Components.Scene, {
			
		})
	});
end;

return App;