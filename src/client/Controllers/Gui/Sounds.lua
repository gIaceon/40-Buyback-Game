local function Sound(Id, Volume)
    return {Id = 'rbxassetid://'..Id; Volume = Volume};
end;

return {
    click = Sound(12221976, .25);
};