AddPrefabPostInit("woodie",function(inst)
    inst.armorpen = 2
    inst:AddTag("axe_thrower")
    if inst.components.builder then
        inst.components.builder:UnlockRecipe("goldenaxe")
        inst.components.builder:UnlockRecipe("moonglassaxe")
    end
end)