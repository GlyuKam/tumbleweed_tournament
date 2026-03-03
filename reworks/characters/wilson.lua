AddPrefabPostInit("wilson",function(inst)
    inst.recipes = {}
        for k,v in pairs(AllRecipes) do
            if IsRecipeValid(v.name) and not v.nounlock and v.builder_tag == nil then
                table.insert(inst.recipes, v.name)
            end
        end
    local function GivePrints(wilson,data)
        if data.target:HasTag("player") then return end
        if wilson.recipes~= nil and #wilson.recipes>0 then
            r = math.random(#wilson.recipes)
            if r then
                wilson.components.builder:UnlockRecipe(wilson.recipes[r])
                
                SpawnAt("fx_book_research_station",wilson)
                wilson.components.talker:Say(wilson.recipes[r])
                table.remove(wilson.recipes,r)
            end
        end
    end
    inst:ListenForEvent("onattackother",GivePrints)
end)