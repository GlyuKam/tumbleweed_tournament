AddPrefabPostInit("wathgrithr",function(inst)
    inst:AddComponent("net_role")

    if TheWorld.ismastersim then
        inst:AddComponent("rolemanager")
        inst._queentask = nil
        inst._fooltask  = nil
        inst._treetask  = nil
        inst.components.rolemanager:SetCrown()

        if inst.currentmask == nil then
            inst.currentmask = "mask_foolhat"
            inst.components.rolemanager:SetRole(inst.currentmask)
        end
    end

    if inst.components.battleborn then
        inst.components.battleborn:SetHealthEnabled(false)
    end
    if inst.components.combat then
        inst.components.combat.damagemultiplier = 1
        inst.components.health:SetAbsorptionAmount(0)
    end

    local oldSave = inst.OnSave
    local oldLoad = inst.OnLoad

    inst.OnSave = function(inst,data)
        if oldSave then
            oldSave(inst,data)
        end
        data.currentmask = inst.currentmask
    end
    inst.OnLoad = function(inst,data)
        if oldLoad then
            oldLoad(inst,data)
        end
        inst.currentmask = data.currentmask
        if inst.components.rolemanager then
            inst.components.rolemanager:SetRole(inst.currentmask)
        end
    end
end)

AddPrefabPostInit("spear_wathgrithr_lightning",function(inst)
    inst:DoTaskInTime(0,function() inst:Remove() end)
end)

AddPrefabPostInit("spear_wathgrithr_lightning_charged",function(inst)
    inst:DoTaskInTime(0,function() inst:Remove() end)
end)