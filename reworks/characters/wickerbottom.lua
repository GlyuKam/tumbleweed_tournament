local books = {
    "book_tentacles",
    "book_brimstone",
    "book_sleep",
    "book_temperature",
    "book_fish",
    "book_fire",
    "book_horticulture_upgraded",
    "book_web",
    "book_birds",
    "book_horticulture",
    "book_silviculture",
    "book_light",
    "book_light_upgraded",
    "book_rain",
    "book_moon",
    "book_bees",
    "book_research_station",
}

AddPrefabPostInit("wickerbottom",function(inst)
    inst:AddTag("book_reader")

    if inst.components.builder then
        for _,book in pairs(books) do
            inst.components.builder:UnlockRecipe(book)
        end
    end

end)