local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage:WaitForChild("Knit"));

Knit.AddControllers(script.Parent:WaitForChild('Controllers'));

Knit.Start{ServicePromises = false}:catch(warn);