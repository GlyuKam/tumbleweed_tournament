-- local function JustDrown(inst)
--     inst.components.drownable.enabled = true
--     inst:DoTaskInTime(0.25,function() 
--         inst.components.drownable.enabled = false
--     end)
-- end

AddPrefabPostInit("wurt",function(inst)

    inst:AddTag("book_reader")

    if not TheWorld.ismastersim then return end

    if inst.components.builder then
        inst.components.builder:UnlockRecipe("mermthrone_construction")
        inst.components.builder:UnlockRecipe("mermhouse_crafted")
        inst.components.builder:UnlockRecipe("mermwatchtower")
        inst.components.builder:UnlockRecipe("turf_marsh")
    end
    -- inst:DoPeriodicTask(0.25,function(inst)
    --     if inst:IsOnOcean() and not inst:HasTag("playeghost") then
    --         inst.components.locomotor.externalspeedmultiplier = 0.5
    --         inst.components.moisture:DoDelta(2.5)
    --         local water = SpawnAt("boat_water_fx",inst)
    --         water.Transform:SetRotation(inst.Transform:GetRotation()+90)
    --         water.Transform:SetScale(0.7,0.7,0.7)
    --         if inst.components.moisture.moisture>70 then
    --             inst.components.combat:GetAttacked(inst,1)
    --         end
    --     else
    --         inst.components.locomotor.externalspeedmultiplier = 1
    --     end
    -- end)
    -- if inst.components.drownable then
    --     inst.components.drownable.enabled = false
        
    --     inst.components.drownable:SetOnTakeDrowningDamageFn(function() 
    --         inst.Physics:CollidesWith(COLLISION.LAND_OCEAN_LIMITS)
    --         inst.components.health:DoDelta(-30)
    --         inst:DoTaskInTime(30,function()
    --             SpawnAt("waterstreak_burst",inst)
    --             inst.Physics:ClearCollidesWith(COLLISION.LAND_OCEAN_LIMITS)
    --         end)
    --     end)
    -- end
    -- if inst.Physics then
    --     inst.Physics:ClearCollidesWith(COLLISION.LAND_OCEAN_LIMITS)
    -- end
    -- inst:ListenForEvent("attacked",JustDrown)
end)