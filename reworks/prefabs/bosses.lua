local armor = {
    "armorwood",
    "footballhat",
    "woodcarvedhat",
    "cookiecutterhat",
    "hivehat",
    "wathgrithrhat"
}

local function ondeath(inst)
    SpawnAt(armor[math.random(1,#armor)],inst)
end

AddPrefabPostInitAny(function(inst)
    if inst:HasTag("EPIC") and inst.prefab~="beequeen" then
        inst:ListenForEvent("death",ondeath)
    end
end)