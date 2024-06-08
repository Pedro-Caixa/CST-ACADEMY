return {
    Name = "jackbox",
    Aliases = {"jacK-box"},
    Description = "Put someone in the jackbox",
    Group = "Admin",
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "The player to put in the jackbox"
        }
    },
}