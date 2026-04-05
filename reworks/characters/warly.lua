local ings = {
    'wormlight',
    "wormlight_lesser",
    'carrot',
    'berries',
    "berries_juicy",   
    'red_cap', 
    'blue_cap', 
    'green_cap', 
    'cactus_meat',
    'cactus_flower',
    'meat', 
    'cookedmeat', 
    'monstermeat', 
    'cookedmonstermeat', 
    'smallmeat',
    "honey",
    "pepper",
    "garlic",
    "fish",
    "eel",
    "barnacle",
    "egg", 
    "butterflywings", 
    "butter", 
    "ice",
    "dragonfruit",
    "mole",
    "rabbit",
    "plantmeat",
    "kelp",
    "moon_cap",
    "bird_egg",
    "cave_banana",
    "pomegranate",
    "durian",
    "watermelon",
    "trunk_summer",
    "trunk_winter",
    "fishmeat",
    "batnose",
    "potato",
    "tomato",
    "onion",
    "forgetmelots",
    "lightninggoathorn",
    "spice_chili",
    "spice_garlic",
    "royal_jelly",
}

AddPrefabPostInit("warly",function(inst)
    local function GiveIngs(warly,data)
        if not data.target:HasTag("player") then
            local pos = Vector3(warly.Transform:GetWorldPosition())
            local ing = SpawnPrefab(ings[math.random(1,#ings)])
            if ing then
                ing.Transform:SetPosition(pos.x,10,pos.z)
                for _, item in pairs(warly.components.inventory.itemslots) do
                    if ing.prefab == item.prefab and ing.prefab ~= "rabbit" and ing.prefab ~= "mole" then 
                        if item.components.stackable.stacksize <=39 then
                            warly.components.inventory:GiveItem(ing)
                        end
                    elseif ing.sg then
                        ing.Transform:SetPosition(pos.x,3,pos.z)
                        ing:DoTaskInTime(0,function() ing.sg:GoToState("stunned") end)
                    end
                end
            end
        end
    end
    inst:ListenForEvent("onattackother",GiveIngs)
end)

for _,ing in pairs(ings) do
    AddPrefabPostInit(ing,function(inst)
        if inst.components.stackable then 
            inst.components.stackable.maxsize = 40
        end
    end)
end

AddPrefabPostInit("portablecookpot",function(inst)
    if inst.components.stewer then 
        inst.components.stewer.cooktimemult = 0
    end
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
end)

AddPrefabPostInit("portablespicer",function(inst)
    if inst.components.stewer then 
        inst.components.stewer.cooktimemult = 0
    end
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
end)