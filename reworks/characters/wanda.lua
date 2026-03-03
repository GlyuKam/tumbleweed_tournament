
AddPrefabPostInit("wanda",function(inst) 
    if inst.components.builder then
        inst.components.builder:UnlockRecipe("pocketwatch_recall")
        inst.components.builder:UnlockRecipe("pocketwatch_portal")
        inst.components.builder:UnlockRecipe("pocketwatch_weapon")
    end
end)

AddPrefabPostInit("pocketwatch_weapon",function(inst)
    if inst.components.fueled then
        inst.components.fueled:SetPercent(0)
        inst.components.fueled.bonusmult = 0.1
    end
end)
