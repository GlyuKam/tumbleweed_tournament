local modules = {
    "movespeed",
    "movespeed2",
    "maxhealth",
    "maxhealth2",
    "maxsanity1",
    "maxsanity",
    "maxhunger1",
    "maxhunger",
    "light",
    "heat",
    "cold",
    "bee",
    "nightvision",
    "music",
    "taser"
}

AddPrefabPostInit("wx78",function(inst) 
    if inst.components.builder then
        for _,module_ in pairs(modules) do
            inst.components.builder:UnlockRecipe("wx78module_"..module_)
        end
    end
end)