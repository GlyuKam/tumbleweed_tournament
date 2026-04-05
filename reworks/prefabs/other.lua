AddPrefabPostInit("wardrobe",function(inst)
    if inst.components.wardrobe then
        inst:RemoveComponent("wardrobe")
    end
    local function fn(inst,doer)
        TheWorld:PushEvent("ms_playerdespawnanddelete", doer)
        inst.components.activatable.inactive = true
    end    
    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = fn 
end)

AddPrefabPostInit("moonrockseed",function(inst)
    if inst.DoUpgrade then
        inst:DoUpgrade()
    end
end)