local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local BUTTON_SCALE = 0.75
local COOLDOWN = 10
local X_POS = -785

local Roles = Class(Widget, function(self, owner)
    Widget._ctor(self, "Roles")

    self.owner = owner

    self.root = self:AddChild(Widget("root"))

    self.b1 = self.root:AddChild(self:MakeRoleButton("mask_queenhat",0))
    self.b2 = self.root:AddChild(self:MakeRoleButton("mask_foolhat",120))
    self.b3 = self.root:AddChild(self:MakeRoleButton("mask_treehat",240))

    self.cooldown = false

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
        if not self.cooldown then
            for _,button in pairs(self.buttons) do
                button:SetPosition(X_POS+button.x,200)
            end
            b:SetPosition(X_POS+b.x,250)
            self.cooldown = true
            self.owner:DoTaskInTime(COOLDOWN,function() self.cooldown = false end)
            print("rpc otpravlen")
            SendModRPCToServer(GetModRPC("ROLES","CHANGEROLE"),role)
        else
            self.owner.components.talker:Say("nuh uh")
        end
    end)

    b.icon = b:AddChild(Image(GetInventoryItemAtlas(role..".tex"), role..".tex"))
    b.icon:SetScale(1.5,1.5,1.5)

    return b
end

return Roles