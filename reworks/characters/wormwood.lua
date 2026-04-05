AddPrefabPostInit("wormwood",function(inst) 
    -- if inst.components.bloomness then
    --     for i =1,4 do
    --         inst:DoTaskInTime(i,function() inst.components.bloomness:Fertilize(1000000) end)
    --     end
    -- end
    local function Vampire(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.components.health:DoDelta(1)
        end
    end
    inst:ListenForEvent("onattackother",Vampire)
end)