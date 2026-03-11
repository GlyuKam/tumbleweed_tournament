net_role = Class(function(self,inst)
    self.inst = inst
    self.cooldown = net_bool(self.inst.GUID, "net_role", "OnRoleChange")
    self.cooldown:set(false)
end)

return net_role