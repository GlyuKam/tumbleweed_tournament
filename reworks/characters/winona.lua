AddPrefabPostInit("winona_catapult",function(inst)
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
end)

TUNING.TRAP_VINES_DURATION = 10