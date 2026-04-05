local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local BUTTON_SCALE = 0.75
local X_POS = 840

local Razor = Class(Widget, function(self, owner)
    Widget._ctor(self, "Roles")

    self.owner = owner

    self.root = self:AddChild(Widget("root"))

    self.b1 = self.root:AddChild(self:MakeButton(120))

end)

function Razor:MakeButton(x)
    local b = ImageButton("images/global_redux.xml", "char_selection.tex", "char_selection_hover.tex", "char_selection.tex", nil, nil, {1,1}, {0,0})
    b:SetScale(BUTTON_SCALE, BUTTON_SCALE)
    b.focus_scale = nil
    b:SetPosition(X_POS+x, 200)
    b:SetOnClick(function()
        SendModRPCToServer(GetModRPC("WENDY","SELFHARM"))
    end)

    b.icon = b:AddChild(Image(GetInventoryItemAtlas("razor.tex"), "razor.tex"))
    b.icon:SetScale(1.5,1.5,1.5)

    return b
end

return Razor