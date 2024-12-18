local noti = Config.Notifications
local FRAMEWORK = Config.Framework 
local LOG = Config.log

if FRAMEWORK == "VORP" then 
    VORPcore = exports.vorp_core:GetCore()
    AddEventHandler("vorp:SelectedCharacter", function(source, character)
        local steam = GetPlayerIdentifier(source, 0) 
        local charid = character.charIdentifier
    
        MySQL.Async.fetchScalar('SELECT COUNT(1) FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid', {
            ['@identifier'] = steam,
            ['@charid'] = charid
        }, function(count)
            if count == 0 then
                local insertQuery = "INSERT INTO wasvendel_bank (identifier, charid) VALUES (@identifier, @charid)"
                MySQL.Async.execute(insertQuery, {
                    ['@identifier'] = steam,
                    ['@charid'] = charid
                }, function(rowsChanged)
                end)
            end
        end)
    end)
    
elseif FRAMEWORK == "redemrp-reboot" then 
    RedEM = exports["redem_roleplay"]:RedEM()
    
    AddEventHandler("redemrp:playerLoaded", function(source, Player)
        local _source = source
        local Player = RedEM.GetPlayer(_source)
        local charid = Player.charid
        local steam = GetPlayerIdentifier(_source, 0) 

        MySQL.Async.fetchScalar('SELECT COUNT(1) FROM wasvendel_bank WHERE identifier = @identifier', {
            ['@identifier'] = steam
        }, function(count)
            if count == 0 then
                local insertQuery = "INSERT INTO wasvendel_bank (identifier) VALUES (@identifier)"
                MySQL.Async.execute(insertQuery, {
                    ['@identifier'] = steam
                }, function(rowsChanged)
                end)
            end
        end)
    end)
end 

--Data loading 
RegisterServerEvent("wasvendel_bank:data")
AddEventHandler("wasvendel_bank:data", function(bankName, bank, combinedData)
    local _source = source
    local steam = GetPlayerIdentifier(_source, 0)

    if FRAMEWORK == "VORP" then 
        user = VORPcore.getUser(_source)
        character = user.getUsedCharacter
        charid = character.charIdentifier
        mymoney = character.money
    elseif FRAMEWORK == "redemrp-reboot" then 
        Player = RedEM.GetPlayer(_source)
        charid = Player.charid
        mymoney = Player.money
        
        local queryCheck = "SELECT charid FROM wasvendel_bank WHERE identifier = @identifier AND charid = 0"
        MySQL.Async.fetchAll(queryCheck, {
            ['@identifier'] = steam
        }, function(result)
            if result[1] then
                local updateQuery = "UPDATE wasvendel_bank SET charid = @newCharid WHERE identifier = @identifier AND charid = 0"
                MySQL.Async.execute(updateQuery, {
                    ['@newCharid'] = charid,
                    ['@identifier'] = steam
                })
                Wait(1000)
            end
        end)
    end

    local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') AS money, JSON_EXTRACT(%s, '$.storage') AS storage, JSON_EXTRACT(%s, '$.slot') AS slot FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bank, bank, bank)

    MySQL.Async.fetchAll(query, {
        ['@identifier'] = steam,
        ['@charid'] = charid
    }, function(result)
        if result[1] then
            TriggerClientEvent("wasvendel_bank:openbank", _source, bankName, bank, mymoney, result[1].money, result[1].storage, result[1].slot, combinedData)
        end
    end)
end)

--Get event
RegisterServerEvent("wasvendel_bank:setdata")
AddEventHandler("wasvendel_bank:setdata", function(_source, bank, amount, type)
    local steam = GetPlayerIdentifier(_source, 0)
    local charid

    if FRAMEWORK == "VORP" then 
        user = VORPcore.getUser(_source)
        character = user.getUsedCharacter
        charid = character.charIdentifier
        money = character.money
    elseif FRAMEWORK == "redemrp-reboot" then 
        Player = RedEM.GetPlayer(_source)
        charid = Player.charid
        money = Player.money
    end

    local roundedAmount = tonumber(string.format("%.2f", amount))
    local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bank)
    
    MySQL.Async.fetchScalar(query, {
        ['@identifier'] = steam,
        ['@charid'] = charid
    }, function(currentBalance)
        currentBalance = tonumber(currentBalance) or 0
        
        local newBalance
        if type == "deposit" then
            newBalance = currentBalance + roundedAmount
        elseif type == "whitdraw" then
            newBalance = currentBalance - roundedAmount
            if newBalance < 0 then return end
        else
            return
        end

        local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.money', @amount) WHERE identifier = @identifier AND charid = @charid", bank, bank)

        MySQL.Async.execute(updateQuery, {
            ['@identifier'] = steam,
            ['@charid'] = charid,
            ['@amount'] = newBalance
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent("wasvendel_bank:updatebank", _source, newBalance, money)
            end
        end)
    end)
end)

--Whitdraw/Deposit
RegisterServerEvent("wasvendel_bank:getdata")
AddEventHandler("wasvendel_bank:getdata", function(bank, amount, type)
    local _source = source
    local steam = GetPlayerIdentifier(_source, 0)
    local charid

    if FRAMEWORK == "VORP" then 
        user = VORPcore.getUser(_source)
        character = user.getUsedCharacter
        charid = character.charIdentifier
        money = character.money
    elseif FRAMEWORK == "redemrp-reboot" then 
        Player = RedEM.GetPlayer(_source)
        charid = Player.charid
        money = Player.money
    end

    if type == "whitdraw" then
        local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bank)
        
        MySQL.Async.fetchScalar(query, {
            ['@identifier'] = steam,
            ['@charid'] = charid
        }, function(bank_balance)
            bank_balance = tonumber(bank_balance) or 0
            local requestedAmount = tonumber(amount) or 0

            if bank_balance >= requestedAmount + (requestedAmount * Config.WhitdrawPercent) then
                if FRAMEWORK == "VORP" then
                    character.addCurrency(0, requestedAmount)
                elseif FRAMEWORK == "redemrp-reboot" then
                    Player.AddMoney(requestedAmount)
                end
                TriggerEvent('wasvendel_bank:serverlog', _source, LOG.typewhitdraw, requestedAmount, bank, nil)
                local finalAmount = requestedAmount + (requestedAmount * (Config.WhitdrawPercent or 0))
                TriggerEvent("wasvendel_bank:setdata", _source, bank, finalAmount, type)
                SuccessfulWhitdraw(_source)
            else
                NotEnoughMoneyInBank(_source)
            end
        end)
    else
        if money >= amount then
            if FRAMEWORK == "VORP" then
                character.removeCurrency(0, amount)
            elseif FRAMEWORK == "redemrp-reboot" then
                Player.RemoveMoney(amount)
            end
            TriggerEvent('wasvendel_bank:serverlog', _source, LOG.typedeposit, amount, bank, nil)
            TriggerEvent("wasvendel_bank:setdata", _source, bank, amount, type)
            SuccessfulDeposit(_source)
        else
            NotEnoughMoney(_source)
        end
    end
end)

--Transfer
RegisterServerEvent("wasvendel_bank:transportbanktobank")
AddEventHandler("wasvendel_bank:transportbanktobank", function(source_bank_data, target_bank_data, amount)
    local _source = source
    local steam = GetPlayerIdentifier(_source, 0)

    local sourceBank = nil
    local targetBank = nil
    for k, v in pairs(Banks) do
        if v.data == source_bank_data then
            sourceBank = v
        end
        if v.data == target_bank_data then
            targetBank = v
        end
    end

    if not sourceBank or not targetBank or (source_bank_data == target_bank_data) then
        error(_source)
        return
    end

    local charid, money
    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(_source)
        local character = user.getUsedCharacter
        charid = character.charIdentifier
        money = character.money
    elseif FRAMEWORK == "redemrp-reboot" then
        local Player = RedEM.GetPlayer(_source)
        charid = Player.charid
        money = Player.money
    end

    local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') AS money FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", sourceBank.data)
    MySQL.Async.fetchScalar(query, {
        ['@identifier'] = steam,
        ['@charid'] = charid
    }, function(bank_balance)
        bank_balance = tonumber(bank_balance) or 0
        local requestedAmount = tonumber(amount) or 0

        local TransferAmount = Config.TransferPercent and requestedAmount + (requestedAmount * Config.TransferPercent)

        if bank_balance >= TransferAmount then
            local newBalance = bank_balance - TransferAmount

            local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.money', @amount) WHERE identifier = @identifier AND charid = @charid", sourceBank.data, sourceBank.data)
            MySQL.Async.execute(updateQuery, {
                ['@identifier'] = steam,
                ['@charid'] = charid,
                ['@amount'] = newBalance
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent("wasvendel_bank:updatebank", _source, newBalance, money)
                    Wait(Config.TransferTime * 60000)
                    local depositQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.money', JSON_EXTRACT(%s, '$.money') + @amount) WHERE identifier = @identifier AND charid = @charid", targetBank.data, targetBank.data, targetBank.data)
                    MySQL.Async.execute(depositQuery, {
                        ['@identifier'] = steam,
                        ['@charid'] = charid,
                        ['@amount'] = requestedAmount
                    }, function(rowsChanged)
                        if rowsChanged > 0 then
                            SuccessfulTransfer(_source)
                            TriggerEvent('wasvendel_bank:serverlog', _source, LOG.typetransfer, amount, sourceBank.data, targetBank.data)
                        else
                            error(_source)
                        end
                    end)
                end
            end)
        else
            NotEnoughMoneyInBank(_source)
        end
    end)
end)

--Storage buy
RegisterServerEvent("wasvendel_bank:registerInventorycheckmoney")
AddEventHandler("wasvendel_bank:registerInventorycheckmoney", function(bankname)
    local _source = source
    local steam = GetPlayerIdentifier(_source, 0)
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(_source)
        local character = user.getUsedCharacter
        charid = character.charIdentifier

        -- Check if the player has enough money
        if character.money >= tonumber(Config.BankStorages.basic.price) then
            -- Query to check if storage is false in the specified bank's JSON data
            local query = string.format("SELECT JSON_EXTRACT(%s, '$.storage') AS storage FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bankname)
            MySQL.Async.fetchAll(query, {
                ['@identifier'] = steam,
                ['@charid'] = charid
            }, function(result)
                if result[1] then
                    local storage = result[1].storage

                    -- Check if storage is false
                    if tonumber(storage) == 0 then
                        -- Update storage to true and set slot to Config.BankStorages.basic.slot
                        local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.storage', true, '$.slot', @slotValue) WHERE identifier = @identifier AND charid = @charid", bankname, bankname)
                        MySQL.Async.execute(updateQuery, {
                            ['@identifier'] = steam,
                            ['@charid'] = charid,
                            ['@slotValue'] = Config.BankStorages.basic.slot
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                TriggerEvent("wasvendel_bank:registerInventory", bankname, _source)
                                character.removeCurrency(0, tonumber(Config.BankStorages.basic.price))
                                TriggerEvent('wasvendel_bank:storageserverlog', _source, bankname, LOG.buystorage)
                                Successfulpurchase(_source)
                            end
                        end)
                    else
                        StorageAlreadyPurchased(_source)
                    end
                end
            end)
        else
            NotEnoughMoney(_source)
        end
    end
end)

--Open storage
RegisterServerEvent("wasvendel_bank:openstorage")
AddEventHandler("wasvendel_bank:openstorage", function(bankname)
    local _source = source
    local steam = GetPlayerIdentifier(_source, 0)
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(_source)
        local character = user.getUsedCharacter
        charid = character.charIdentifier

        -- Query to check storage and slot in the specified bank's JSON data
        local query = string.format("SELECT JSON_EXTRACT(%s, '$.storage') AS storage, JSON_EXTRACT(%s, '$.slot') AS slot FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bankname, bankname)
        MySQL.Async.fetchAll(query, {
            ['@identifier'] = steam,
            ['@charid'] = charid
        }, function(result)
            if result[1] then
                local storage = result[1].storage
                local slot = result[1].slot
                slot = slot:gsub("\"", "")  -- Remove any quotation marks
                slot = tonumber(slot)  -- Convert to a number after removing quotes
                                
                if storage == "true" then
                    local registered = exports.vorp_inventory:isCustomInventoryRegistered(bankname)

                    if registered then 
                        TriggerEvent("wasvendel_bank:openInventory", bankname, _source, slot)
                    else 
                        TriggerEvent("wasvendel_bank:registerInventory", bankname, _source, slot)
                    end 
                    TriggerClientEvent("wasvendel_bank:closebank", _source)
                else
                    StorageNotPurchased(_source)
                end
            end
        end)
    end
end)

--Open storage slot
RegisterServerEvent("wasvendel_bank:upgradeStorageSlots")
AddEventHandler("wasvendel_bank:upgradeStorageSlots", function(bankname, slot, price)
    local _source = source
    local steam = GetPlayerIdentifier(_source, 0)
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(_source)
        local character = user.getUsedCharacter
        charid = character.charIdentifier

        -- Check if storage is true for the specified bank's JSON data
        local query = string.format("SELECT JSON_EXTRACT(%s, '$.storage') AS storage FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bankname)
        MySQL.Async.fetchAll(query, {
            ['@identifier'] = steam,
            ['@charid'] = charid
        }, function(result)
            if result[1] then
                local storage = result[1].storage

                -- Check if storage is true
                if storage == "true" then
                    if character.money >= tonumber(price) then
                        -- Update the slot value for the specified bank
                        local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.slot', @newSlot) WHERE identifier = @identifier AND charid = @charid", bankname, bankname)
                        MySQL.Async.execute(updateQuery, {
                            ['@identifier'] = steam,
                            ['@charid'] = charid,
                            ['@newSlot'] = slot
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                character.removeCurrency(0, tonumber(price))
                                Successfulslotupdate(_source)
                                TriggerEvent('wasvendel_bank:storageserverlog', _source, bankname, LOG.updatestorage)
                            end
                        end)
                    else 
                        NotEnoughMoney(_source)
                    end 
                else
                    StorageNotPurchased(_source)
                end
            end
        end)
    end
end)


--Admin command 
if Config.AdminCommand.enablecommand then 
    RegisterCommand(Config.AdminCommand.setbankmoney, function(source, args, rawCommand)
        local _source = source
        local target = args[1]
        local bank = args[2]
        local amount = tonumber(args[3])
        if FRAMEWORK == "VORP" then
            local user = VORPcore.getUser(source).getUsedCharacter
            local user2 = VORPcore.getUser(target).getUsedCharacter
            local charid = user2.charIdentifier
            if Config.Permission[user.group] then 
                TriggerEvent("wasvendel_bank:setbankbyadmin", target, charid, amount, bank)
            end 
        elseif FRAMEWORK == "redemrp-reboot" then
            local Player = RedEM.GetPlayer(source)
            local Player2 = RedEM.GetPlayer(target)
            local charid = Player2.charid
            if Config.Permission[Player.group] then 
                TriggerEvent("wasvendel_bank:setbankbyadmin", target, charid, amount, bank)
            end
        end
    end, false)
end

RegisterServerEvent("wasvendel_bank:setbankbyadmin")
AddEventHandler("wasvendel_bank:setbankbyadmin", function(target, charid, amount, bank)
    local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.money', @amount) WHERE identifier = @identifier AND charid = @charid", bank, bank)
    MySQL.Async.execute(updateQuery, {
        ['@identifier'] = GetPlayerIdentifier(target),
        ['@charid'] = charid,
        ['@amount'] = amount
    })
end)

--Exports
exports('SetBankMoney', function(source, bank, amount)
    local _source = source
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(source).getUsedCharacter
        charid = user.charIdentifier
    elseif FRAMEWORK == "redemrp-reboot" then
        local Player = RedEM.GetPlayer(source)
        charid = Player.charid
    end

    local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.money', @amount) WHERE identifier = @identifier AND charid = @charid", bank, bank)
    MySQL.Async.execute(updateQuery, {
        ['@identifier'] = GetPlayerIdentifier(source),
        ['@charid'] = charid,
        ['@amount'] = tonumber(amount)
    }, function(rowsChanged)
        if rowsChanged > 0 then
            SuccessfulTransfer(_source)
        else
            error(_source)
        end
    end)
end)

exports('GetBankMoney', function(source, bank)
    local _source = source
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(source).getUsedCharacter
        charid = user.charIdentifier
    elseif FRAMEWORK == "redemrp-reboot" then
        local Player = RedEM.GetPlayer(source)
        charid = Player.charid
    end

    local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') AS money FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bank)
    local result = MySQL.Sync.fetchScalar(query, {
        ['@identifier'] = GetPlayerIdentifier(source),
        ['@charid'] = charid
    })
    return result
end)

exports('IsBankMoneyEnough', function(source, bank, amount)
    local _source = source
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(source).getUsedCharacter
        charid = user.charIdentifier
    elseif FRAMEWORK == "redemrp-reboot" then
        local Player = RedEM.GetPlayer(source)
        charid = Player.charid
    end

    local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') AS money FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bank)
    local result = MySQL.Sync.fetchScalar(query, {
        ['@identifier'] = GetPlayerIdentifier(source),
        ['@charid'] = charid
    })

    if result ~= nil and tonumber(result) >= tonumber(amount) then
        return true
    else
        return false
    end
end)

exports('RemoveMoneyInBank', function(source, bank, amount)
    local _source = source
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(source).getUsedCharacter
        charid = user.charIdentifier
    elseif FRAMEWORK == "redemrp-reboot" then
        local Player = RedEM.GetPlayer(source)
        charid = Player.charid
    end

    local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') AS money FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bank)
    local result = MySQL.Sync.fetchScalar(query, {
        ['@identifier'] = GetPlayerIdentifier(source),
        ['@charid'] = charid
    })

    if result ~= nil and tonumber(result) >= tonumber(amount) then
        local newAmount = tonumber(result) - tonumber(amount)
        local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.money', @newAmount) WHERE identifier = @identifier AND charid = @charid", bank, bank)
        MySQL.Async.execute(updateQuery, {
            ['@identifier'] = GetPlayerIdentifier(source),
            ['@charid'] = charid,
            ['@newAmount'] = newAmount
        })
    end
end)

exports('AddMoneyInBank', function(source, bank, amount)
    local _source = source
    local charid

    if FRAMEWORK == "VORP" then
        local user = VORPcore.getUser(source).getUsedCharacter
        charid = user.charIdentifier
    elseif FRAMEWORK == "redemrp-reboot" then
        local Player = RedEM.GetPlayer(source)
        charid = Player.charid
    end

    local query = string.format("SELECT JSON_EXTRACT(%s, '$.money') AS money FROM wasvendel_bank WHERE identifier = @identifier AND charid = @charid", bank)
    local result = MySQL.Sync.fetchScalar(query, {
        ['@identifier'] = GetPlayerIdentifier(source),
        ['@charid'] = charid
    })

    if result ~= nil then
        local newAmount = tonumber(result) + tonumber(amount)
        local updateQuery = string.format("UPDATE wasvendel_bank SET %s = JSON_SET(%s, '$.money', @newAmount) WHERE identifier = @identifier AND charid = @charid", bank, bank)
        MySQL.Async.execute(updateQuery, {
            ['@identifier'] = GetPlayerIdentifier(source),
            ['@charid'] = charid,
            ['@newAmount'] = newAmount
        })
    end
end)

--log 
RegisterServerEvent('wasvendel_bank:serverlog')
AddEventHandler('wasvendel_bank:serverlog', function(source, type, amount, bank, targetbank)
    local _source = source
    local name = GetPlayerName(source)
	local steam = GetPlayerIdentifier(source)
    local date = os.date('*t')
    if targetbank == nil then 
        targetbank = "nil"
    end 
	if date.day < 10 then date.day = '0' .. tostring(date.day) end
	if date.month < 10 then date.month = '0' .. tostring(date.month) end
	if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
	if date.min < 10 then date.min = '0' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end

    local connect = {
        {
            ["color"] = LOG.webhookcolor,
            ["title"] = LOG.headertext,
            ["description"] = "```" .. LOG.playerdata .. ":\n " .. LOG.name .. ": " .. name .. "\n " .. LOG.steam .. ": " .. steam .. "\n" .. LOG.transactiondata .. ":\n " .. LOG.bankname .. ": " .. bank .. "\n " .. LOG.amount .. ": " .. amount .. " $" .. "\n " .. LOG.transactiontype .. ": " .. type .. "\n " .. LOG.transactiontarget .. ": " .. targetbank .. " ```",
            ["footer"] = {
				["text"] = LOG.time .. " " .. tostring(date.hour) .. ":" .. tostring(date.min) .. ":" .. tostring(date.sec),
            },
        }
    }
    PerformHttpRequest(LOG.webhook, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, embeds = connect, avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })    
end)

RegisterServerEvent('wasvendel_bank:storageserverlog')
AddEventHandler('wasvendel_bank:storageserverlog', function(source, bank, type)
    local _source = source
    local name = GetPlayerName(source)
	local steam = GetPlayerIdentifier(source)
    local date = os.date('*t')
    if targetbank == nil then 
        targetbank = "nil"
    end 
	if date.day < 10 then date.day = '0' .. tostring(date.day) end
	if date.month < 10 then date.month = '0' .. tostring(date.month) end
	if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
	if date.min < 10 then date.min = '0' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end

    local connect = {
        {
            ["color"] = LOG.webhookcolor,
            ["title"] = LOG.headertext,
            ["description"] = "```" .. LOG.playerdata .. ":\n " .. LOG.name .. ": " .. name .. "\n " .. LOG.steam .. ": " .. steam .. "\n" .. LOG.storageaction .. ":\n " .. LOG.bankname .. ": " .. bank .. "\n " .. LOG.actionname .. ": " .. type .. "\n```",
            ["footer"] = {
				["text"] = LOG.time .. " " .. tostring(date.hour) .. ":" .. tostring(date.min) .. ":" .. tostring(date.sec),
            },
        }
    }
    PerformHttpRequest(LOG.webhook, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, embeds = connect, avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })    
end)

