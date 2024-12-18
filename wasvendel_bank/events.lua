local NOTI = Config.Notifications
local frw = Config.Framework 

if frw == "VORP" then 
    VORPcore = exports.vorp_core:GetCore()    
elseif frw == "redemrp-reboot" then 
    RedEM = exports["redem_roleplay"]:RedEM()
end 


function NotEnoughMoneyInBank(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.notenoughmoneyinbank, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.notenoughmoneyinbank, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    end 
end 

function NotEnoughMoney(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.notenoughmoney, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.notenoughmoney, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    end 
end 

function SuccessfulWhitdraw(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.successfullwhitdraw, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.successfullwhitdraw, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    end 
end 

function SuccessfulDeposit(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.successfulldeposit, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.successfulldeposit, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    end 
end

function SuccessfulTransfer(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.successfulltransfer, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.successfulltransfer, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    end 
end 


function Successfulpurchase(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.successfullstoragepurchase, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.successfulltransfer, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    end 
end 

function Successfulslotupdate(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.successfullslotupdate, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.successfulltransfer, "mp_lobby_textures", "leaderboard_cash", "COLOR_PURE_WHITE", 4000)
    end 
end 

function StorageAlreadyPurchased(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.storagealreadypurchased, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.error, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    end 
end 

function StorageNotPurchased(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.storagenotpurchased, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.error, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    end 
end 

function error(_source)
    if frw == "VORP" then 
        VORPcore.NotifyAvanced(_source, NOTI.error, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    elseif frw == "redemrp-reboot" then 
        TriggerClientEvent('redem_roleplay:ShowAdvancedRightNotification',_source, NOTI.error, "scoretimer_textures", "scoretimer_generic_cross", "COLOR_PURE_WHITE", 4000)
    end 
end 
