local inbank = false
local prompt = Config.Prompt
local admincommand = Config.AdminCommand
local UseGroup = GetRandomIntInRange(0, 0xffffff)

function Prompt()
    local str = prompt.text
    BankPrompt = PromptRegisterBegin()
    PromptSetControlAction(BankPrompt, prompt.key)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(BankPrompt, str)
    PromptSetEnabled(BankPrompt, 1)
    PromptSetVisible(BankPrompt, 1)
    PromptSetStandardMode(BankPrompt,1)
    PromptSetGroup(BankPrompt, UseGroup)
    PromptSetHoldMode(BankPrompt, 1500)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C,BankPrompt,true)
    PromptRegisterEnd(BankPrompt)
end

local allCombinedData = {}  

function ClosestBank(coords)
    local closestDist = nil
    local closestName = nil
    local closestData = nil

    for name, datas in pairs(Banks) do
        local dist = #(coords - datas.coords)
        if closestDist == nil or dist < closestDist then
            closestDist = dist
            closestName = name
            closestData = datas.data
            closestOpening = datas.opening
        end

        local alreadyExists = false
        for _, existingData in ipairs(allCombinedData) do
            if existingData == datas.data then
                alreadyExists = true
                break
            end
        end

        if not alreadyExists then
            table.insert(allCombinedData, datas.data)
        end
    end
    
    return closestName, closestDist, closestData, allCombinedData, closestOpening
end


Citizen.CreateThread(function() 
    Prompt()
    while true do
        Citizen.Wait(1)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        if coords ~= nil then
            if not IsEntityDead(PlayerPedId()) then
                if not inbank then 
                    local closestName, closestDist, closestData = ClosestBank(coords)
                    if closestDist and closestDist <= 1.5 then
                        local currentHour = GetClockHours()
                        local openingHours = closestOpening
                        if currentHour >= openingHours[1] and currentHour < openingHours[2] then
                            local label  = CreateVarString(10, 'LITERAL_STRING', prompt.label)
                            PromptSetActiveGroupThisFrame(UseGroup, label)
                            if UiPromptHasHoldModeCompleted(BankPrompt) then
                                TriggerServerEvent("wasvendel_bank:data", closestName, closestData, allCombinedData)
                                inbank = true 
                            end
                            UiPromptSetEnabled(BankPrompt,true)
                        else
                            local label2  = CreateVarString(10, 'LITERAL_STRING', prompt.bankclosed)
                            PromptSetActiveGroupThisFrame(UseGroup, label2)
                            UiPromptSetEnabled(BankPrompt,false)
                        end
                    else 
                        Wait(500)
                    end 
                end
            end 
        end 
    end 
end) 


local blipc = Config.Blip
local blips = {}

Citizen.CreateThread(function()
    for _, bank in pairs(Banks) do
        if blipc.enable then
            if not bank.hideblip then
                local blipId = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, bank.coords.x, bank.coords.y, bank.coords.z)
                SetBlipSprite(blipId, blipc.blipsrpite, 1)  
                SetBlipScale(blipId, blipc.blipsscale)
                if blipc.usebanksname then 
                    varString = CreateVarString(10, 'LITERAL_STRING', bank.name)  
                else
                    varString = CreateVarString(10, 'LITERAL_STRING', blipc.blipname)  
                end 
                Citizen.InvokeNative(0x9CB1A1623062F402, blipId, varString)
                table.insert(blips, blipId) 
            end
        end
    end
end)

RegisterNetEvent('wasvendel_bank:openbank')
AddEventHandler('wasvendel_bank:openbank', function(bankName, bank, mymoney, money, storage, slot, combinedData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        open = true,
        price = money,
        bankName = bankName,
        bankData = bank,
        money = mymoney,
        codes = combinedData,
        enableStorage = Config.BankStorages.enable,
        storageData = Config.BankStorages,
        basicSlot = Config.BankStorages.basic.slot,
        basicPrice = Config.BankStorages.basic.price
    })
end)

RegisterNetEvent('wasvendel_bank:closebank')
AddEventHandler('wasvendel_bank:closebank', function()
    SetNuiFocus(false, false)
    inbank = false
    SendNUIMessage({
        open = false,
    })
end)

RegisterNetEvent('wasvendel_bank:updatebank')
AddEventHandler('wasvendel_bank:updatebank', function(bankValue,money)
    SendNUIMessage({
        update = true,
        price = bankValue,  
        money = money,  
    })
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    inbank = false
    cb('ok')
end)

RegisterNUICallback('Deposit', function(data, cb)
    TriggerServerEvent("wasvendel_bank:getdata",data.bankData, tonumber(data.quantity),"deposit")
    cb({ success = true })
end)

RegisterNUICallback('Whitdraw', function(data, cb)
    TriggerServerEvent("wasvendel_bank:getdata",data.bankData, tonumber(data.quantity2),"whitdraw")
    cb({ success = true })
end)

RegisterNUICallback('Transfer', function(data, cb)
    TriggerServerEvent("wasvendel_bank:transportbanktobank",data.bankData,data.selectedBankName,tonumber(data.quantity3))
    cb({ success = true })
end)

RegisterNUICallback('Storage', function(data, cb)
    TriggerServerEvent("wasvendel_bank:openstorage",data.bankData)
    cb({ success = true })
end)

RegisterNUICallback('BuyStorage', function(data, cb)
    TriggerServerEvent("wasvendel_bank:registerInventorycheckmoney",data.bankData)
    cb({ success = true })
end)

RegisterNUICallback('UpgradeStorage', function(data, cb)
    TriggerServerEvent("wasvendel_bank:upgradeStorageSlots",data.bankData, data.slot, data.price)
    cb({ success = true })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs(blips) do
            RemoveBlip(v)
        end
    end
end)
