local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local BUTTON_SCALE = 0.75
local X_POS = 840

Assets = {
    Asset("ATLAS", "images/mask_of_anger.xml"),
    Asset("IMAGE", "images/mask_of_anger.tex"),
    Asset("ATLAS", "images/mask_of_fear.xml"),
    Asset("IMAGE", "images/mask_of_fear.tex"),
    Asset("ATLAS", "images/mask_of_brave.xml"),
    Asset("IMAGE", "images/mask_of_brave.tex"),
}

local Roles = Class(Widget, function(self, owner)
    Widget._ctor(self, "Roles")

    self.owner = owner

    self.root = self:AddChild(Widget("root"))

    self.b1 = self.root:AddChild(self:MakeRoleButton("mask_queenhat",0))
    self.b2 = self.root:AddChild(self:MakeRoleButton("mask_foolhat",140))
    self.b3 = self.root:AddChild(self:MakeRoleButton("mask_treehat",280))

    self.buttons = {
        self.b1,
        self.b2,
        self.b3,
    }

end)

function Roles:MakeRoleButton(role,x)
    local b = ImageButton("images/global_redux.xml", "char_selection.tex", "char_selection_hover.tex", "char_selection.tex", nil, nil, {1,1}, {0,0})
    b.x = x
    b.role = role
    b:SetScale(BUTTON_SCALE, BUTTON_SCALE)
    b.focus_scale = nil
    b:SetPosition(X_POS+b.x, 200)
    b:SetOnClick(function()
        if not self.owner.components.net_role.cooldown:value() then
            for _,button in pairs(self.buttons) do
                button:SetPosition(X_POS+button.x,200)
            end
            b:SetPosition(X_POS+b.x,250)
            SendModRPCToServer(GetModRPC("ROLES","CHANGEROLE"),role)
        else
            self.owner.components.talker:Say("Я ещё не выжала весь потенциал этой роли!")
        end
    end)

    

    -- b.icon = b:AddChild(Image(GetInventoryItemAtlas(role..".tex"), role..".tex"))
    if role == "mask_queenhat" then 
        b.icon = b:AddChild(Image(resolvefilepath("images/mask_of_anger.xml"),"mask_of_anger.tex"))
        b.icon:SetScale(0.5,0.5,0.5)
    elseif role == "mask_foolhat" then
        b.icon = b:AddChild(Image(resolvefilepath("images/mask_of_fear.xml"),"mask_of_fear.tex"))
        b.icon:SetScale(0.4,0.4,0.4)
    else
        b.icon = b:AddChild(Image(resolvefilepath("images/mask_of_brave.xml"),"mask_of_brave.tex"))
        b.icon:SetScale(0.5,0.5,0.5)
    end
    

    return b
end

return Roles