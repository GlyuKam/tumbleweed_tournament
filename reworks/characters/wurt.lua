AddPrefabPostInit("wurt",function(inst)
    if inst.components.builder then
        inst.components.builder:UnlockRecipe("mermthrone_construction")
        inst.components.builder:UnlockRecipe("mermhouse_crafted")
        inst.components.builder:UnlockRecipe("mermwatchtower")
        inst.components.builder:UnlockRecipe("turf_marsh")
    end
    inst:DoPeriodicTask(10,function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.components.health:DoDelta(5)
            if inst.components.moisture then
                inst.components.moisture:DoDelta(5)
            end
        end
    end)
end)