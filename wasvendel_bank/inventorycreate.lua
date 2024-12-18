local Core = exports.vorp_core:GetCore()

RegisterNetEvent('wasvendel_bank:openInventory', function(containerId, source, slot)
    exports.vorp_inventory:updateCustomInventorySlots(containerId, tonumber(slot))
    exports.vorp_inventory:openInventory(source, containerId)
end)

RegisterNetEvent('wasvendel_bank:registerInventory', function(containerId, source, slot)
    local data = {
        id = containerId,
        name = Config.BankStorages.header,
        limit = slot,
        acceptWeapons = true,
        shared = false,
        ignoreItemStackLimit = true,
        whitelistItems = false,
        UsePermissions = false,
        UseBlackList = false,
        whitelistWeapons = false
    }
    exports.vorp_inventory:registerInventory(data)
end)
