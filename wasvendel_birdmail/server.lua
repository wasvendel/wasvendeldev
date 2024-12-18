local VorpInv
if Config.Framework == "redemrp-reboot" then 
    RedEM = exports["redem_roleplay"]:RedEM()
elseif Config.Framework == "vorp" then
    VorpCore = exports.vorp_core:GetCore()
    VorpInv = exports.vorp_inventory:vorp_inventoryApi()
end 

local birdmaillog = Config.Discordlog.webhook

if Config.Framework == "redemrp-reboot" then 
    RegisterServerEvent("RegisterUsableItem:"..Config.Basics.Items.itempigeon)
    AddEventHandler("RegisterUsableItem:"..Config.Basics.Items.itempigeon, function(source)
        local _source = source
        TriggerClientEvent("wasvendeldev_birdmail:pigeonuse",_source)
        TriggerClientEvent("redemrp_inventory:closeinv",source)
    end)
elseif Config.Framework == "vorp" then
    VorpInv.RegisterUsableItem(Config.Basics.Items.itempigeon, function(data)
        TriggerClientEvent("wasvendeldev_birdmail:pigeonuse",data.source)
        VorpInv.CloseInv(data.source)
    end)
end

RegisterServerEvent("wasvendeldev_birdmail:sendletter")
AddEventHandler("wasvendeldev_birdmail:sendletter", function(firstname, lastname, message, players, id)
	local _source = source

    if Config.Framework == "redemrp-reboot" then 
        local Player = RedEM.GetPlayer(_source)
        local data = RedEM.GetInventory()
        local piegonamount = tonumber(Config.Basics.Items.piegonamount)
        local telegramamount = tonumber(Config.Basics.Items.telegramamount)
        local ItemData = data.getItem(_source, Config.Basics.Items.itempigeon)
        local ItemData2 = data.getItem(_source, Config.Basics.Items.itemtelegram)
	    if Player then 
	    	local sendername = Player.name
	    	MySQL.query("SELECT identifier, characterid FROM characters WHERE firstname=? AND lastname=?", { firstname, lastname}, function(result) 
	    		if result[1] then 
                    if ItemData.ItemAmount >= piegonamount and ItemData2.ItemAmount >= telegramamount then
	    		        local recipient = result[1].identifier 
	    		        local recipientid = result[1].characterid
	    		        local recipient_name = firstname.." "..lastname
	    		        for k, v in pairs(GetPlayers()) do
	    		        	local Player2 = RedEM.GetPlayer(tonumber(v))
	    		        	if Player2 then 
	    		        		if Player2.firstname .. ' ' .. Player2.lastname == tostring(recipient_name) then 
                                    TriggerClientEvent("wasvendeldev_birdmail:notification", _source, 1)
                                    Wait(1000)
                                    TriggerClientEvent("wasvendeldev_birdmail:notification", v, 2)
                                    TriggerClientEvent("wasvendeldev_birdmail:pigeon", v, message)

                                    ItemData.RemoveItem(piegonamount)
                                    ItemData2.RemoveItem(telegramamount)
                                
                                    local steam = Player.identifier
                                    local steam2 = Player2.identifier
                                    local name1 = Player.name
                                    local name2 = Player2.name
                                
                                    if Config.Discordlog.discordlog then 
                                        local logtext = Config.Discordlog.logtext
                                        local sender = Config.Discordlog.sender
                                        local sendersteam = Config.Discordlog.sendersteam
                                        local target = Config.Discordlog.target
                                        local targetsteam = Config.Discordlog.targetsteam
                                        local messageh = Config.Discordlog.messageh
                                        BirdmailLog(birdmaillog, logtext .. "\n```\n" .. sender .. ": " .. name1 .. "[" .. _source .. "]\n" .. sendersteam .. ": " .. steam .. "\n" .. target .. ": " .. name2 .. "[" .. v .. "]\n" .. targetsteam .. ": " .. steam2 .. "\n" .. messageh .. ": " .. message .. "\n```")
                                    end
                                end
	    		        	end
	    		        	Citizen.Wait(10)
	    		        end

                    else
                        TriggerClientEvent("wasvendeldev_birdmail:notification", _source, 3)
                    end
	    		else 
                    TriggerClientEvent("wasvendeldev_birdmail:notification", _source, 4)
                end
	    	end)
	    end
    elseif Config.Framework == "vorp" then 
        local Player = VorpCore.getUser(_source).getUsedCharacter
        local itempiegon = Config.Basics.Items.itempigeon
        local itemtelegram = Config.Basics.Items.itemtelegram
        local piegonamount = tonumber(Config.Basics.Items.piegonamount)
        local telegramamount = tonumber(Config.Basics.Items.telegramamount)

        local ItemData = VorpInv.getItemCount(_source,itempiegon)
        local ItemData2 = VorpInv.getItemCount(_source,itemtelegram)
        if Player then 
	    	exports.ghmattimysql:execute("SELECT identifier, charidentifier FROM characters WHERE firstname=? AND lastname=?", { firstname, lastname}, function(result) 
	    		if result[1] then 
                    if ItemData >= piegonamount and ItemData2 >= telegramamount then
                        VorpInv.subItem(_source,Config.Basics.Items.itempigeon,piegonamount)
                        VorpInv.subItem(_source,Config.Basics.Items.itemtelegram,telegramamount)
                        local recipient = result[1].identifier 
                        local recipientid = result[1].charidentifier
	    		        local recipient_name = firstname.." "..lastname
	    		        for k, v in pairs(GetPlayers()) do
                            print("V",v)
                            local Player2 = VorpCore.getUser(tonumber(v)).getUsedCharacter
                            --if Player2.identifier ~= Player.identifier then
	    		        	    if Player2.firstname .. ' ' .. Player2.lastname == tostring(recipient_name) then 
                                    TriggerClientEvent("wasvendeldev_birdmail:notification", _source, 1)
                                    Wait(1000)
                                    TriggerClientEvent("wasvendeldev_birdmail:notification", v, 2)
                                    TriggerClientEvent("wasvendeldev_birdmail:pigeon", v, message)
                                    local steam = Player.identifier
                                    local steam2 = Player2.identifier
                                    local name1 = GetPlayerName(_source)
                                    local name2 = GetPlayerName(v)
                                
                                    if Config.Discordlog.discordlog then 
                                        local logtext = Config.Discordlog.logtext
                                        local sender = Config.Discordlog.sender
                                        local sendersteam = Config.Discordlog.sendersteam
                                        local target = Config.Discordlog.target
                                        local targetsteam = Config.Discordlog.targetsteam
                                        local messageh = Config.Discordlog.messageh
                                        BirdmailLog(birdmaillog, logtext .. "\n```\n" .. sender .. ": " .. name1 .. "[" .. _source .. "]\n" .. sendersteam .. ": " .. steam .. "\n" .. target .. ": " .. name2 .. "[" .. v .. "]\n" .. targetsteam .. ": " .. steam2 .. "\n" .. messageh .. ": " .. message .. "\n```")
                                    end
                                end 
                            --end
	    		        end
	    		        Citizen.Wait(10)

                    else
                        TriggerClientEvent("wasvendeldev_birdmail:notification", _source, 3)
                    end
	    		else 
                    TriggerClientEvent("wasvendeldev_birdmail:notification", _source, 4)
                end
	    	end)
	    end
    end 
end)

function GetPlayerIdFromName(fullFirstName, fullLastName)
    for _, playerId in ipairs(GetPlayers()) do
        local player = GetPlayerIdentifiers(playerId)
        for _, identifier in ipairs(player) do
            if string.match(identifier, "firstname:" .. fullFirstName) and string.match(identifier, "lastname:" .. fullLastName) then
                return playerId
            end
        end
    end
    return -1
end

function BirdmailLog(name,message,color)
    local connect = {
        {
            ["color"] = Config.Discordlog.color,
            ["title"] = Config.Discordlog.title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = Config.Discordlog.text,
            },
        }
    }
  PerformHttpRequest(birdmaillog, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, embeds = connect, avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
end

function GetPlayerNeededIdentifiers(source)
    local steam = ""
    local live = ""
    local license = ""
    local ip = ""
    local discord = ""
    local id = ""
    identifiers = GetNumPlayerIdentifiers(source)
    for i = 0, identifiers + 1 do
        if GetPlayerIdentifier(source, i) ~= nil then
            if string.match(GetPlayerIdentifier(source, i), "steam") then
                steam = GetPlayerIdentifier(source, i)
                id = string.sub(steam, 9, -1)
            elseif string.match(GetPlayerIdentifier(source, i), "live") then
                live = GetPlayerIdentifier(source, i)
            elseif string.match(GetPlayerIdentifier(source, i), "license") then
                license = GetPlayerIdentifier(source, i)
            elseif string.match(GetPlayerIdentifier(source, i), "ip") then
                ip = GetPlayerIdentifier(source, i)
            elseif string.match(GetPlayerIdentifier(source, i), "discord") then
                discord = GetPlayerIdentifier(source, i)
                discord = "<@"..string.sub(discord, 9, -1)..">"
            end
        end
    end
    return license, steam, discord
end