local UseGroup = GetRandomIntInRange(0, 0xffffff)
local IsMenuOpen = false
local Notified = false
local dst = nil
local pigeon = nil
local message = nil
local blip = nil

function PropFunction()
    local str = Config.Basics.Prompts.pickuptext
    UsePrompt = PromptRegisterBegin()
    PromptSetControlAction(UsePrompt, Config.Basics.Prompts.pickupkey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(UsePrompt, str)
    PromptSetEnabled(UsePrompt, 1)
    PromptSetVisible(UsePrompt, 1)
    PromptSetStandardMode(UsePrompt,1)
    PromptSetGroup(UsePrompt, UseGroup)
    PromptSetHoldMode(UsePrompt, true)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C,UsePrompt,true)
    PromptRegisterEnd(UsePrompt)
end

RegisterNetEvent('wasvendeldev_birdmail:pigeonuse')
AddEventHandler('wasvendeldev_birdmail:pigeonuse', function(players, totalOnline)  
    int = GetInteriorFromEntity(PlayerPedId())
	if Config.Basics.checkinterior then 
		if int == 0 then 
			TriggerEvent("wasvendeldev_birdmail:openmailmenu")
		else 
			TriggerEvent("wasvendeldev_birdmail:notification", 5)
		end 
	else 
		TriggerEvent("wasvendeldev_birdmail:openmailmenu")
	end
end)

RegisterNetEvent('wasvendeldev_birdmail:pigeon')
AddEventHandler('wasvendeldev_birdmail:pigeon', function(text)
	Wait(tonumber(Config.Basics.cooldown)*1000)
	if pigeon ~= nil then
		DeleteEntity(pingeon)
	end
	Notified = false
	dst = nil
	pigeon = nil
	message = nil
	blip = nil
	local player = PlayerPedId()
	local coords = GetEntityCoords(player)
	local model = GetHashKey(Config.Basics.Bird.birdmodel)
	local heading = GetEntityHeading(PlayerPedId())
	while not HasModelLoaded(model) do
		Wait(500)
		RequestModel(model)
	end
	local rand = math.random(25,50)
	local rand2 = math.random(1,2)
	if rand2 == 1 then
		pigeon = CreatePed(model, coords.x+rand, coords.y+rand, coords.z+50.0, heading-180.0, true, true, true, true)
	else
		pigeon = CreatePed(model, coords.x-rand, coords.y-rand, coords.z+50.0, heading-180.0, true, true, true, true)
	end
	while not DoesEntityExist(pigeon) do
		Wait(300)
	end
	Citizen.InvokeNative(0x283978A15512B2FE, pigeon, true)
	message = text
	ClearPedTasks(pigeon)
	ClearPedSecondaryTask(pigeon)
	ClearPedTasksImmediately(pigeon)
	SetPedFleeAttributes(pigeon, 0, 0)
	TaskWanderStandard(pigeon, 1, 0)
	TaskSetBlockingOfNonTemporaryEvents(pigeon, 1)
	SetEntityAsMissionEntity(pigeon)
	TaskFlyToCoord(pigeon, 0, coords.x+3.0, coords.y+3.0, coords.z, 1, 0)
	SetPedScale(pigeon,tonumber(Config.Basics.Bird.modelscale))
	if Config.Basics.Bird.birdblip then  
		blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -308585968, pigeon)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.Basics.Bird.blipname)
	end
	SetEntityInvincible(pigeon,true)
	while not Notified do
		Citizen.Wait(1)
		local player = PlayerPedId()
		local coords = GetEntityCoords(player)
		local ec = GetEntityCoords(pigeon)
		local IsPedAir = IsEntityInAir(pigeon, 1)
		dst = #(ec.xy - coords.xy)
		if dst < 4.0 then
			if not Notified and not IsPedAir then
				FreezeEntityPosition(pigeon, true)
				SetEntityInvincible(pigeon,true)
				Citizen.InvokeNative(0x9587913B9E772D29, pigeon, true)
				Notified = true
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		local player = PlayerPedId()
		local coords = GetEntityCoords(player)
		local ec = GetEntityCoords(pigeon)
		dst = #(ec - coords)
		local IsPedAir = IsEntityInAir(pigeon, 1)
		if pigeon ~= nil then
			if IsPedAir and not Notified and dst > 5.5 then
				TaskFlyToCoord(pigeon, 0, coords.x+3.0, coords.y+3.0, coords.z, 1, 0)
			end
		end
	end
end)       

Citizen.CreateThread(function()
	PropFunction()
	while true do
		Citizen.Wait(0)
		if pigeon ~= nil then
			local player = PlayerPedId()
			local coords = GetEntityCoords(player)
			local ec = GetEntityCoords(pigeon)
			dst = #(ec - coords)
			if Notified and dst < 5.5 then
				if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z,ec.x, ec.y, ec.z,true) < 1.5)  then --BlackWater rács
					local label2  = CreateVarString(10, 'LITERAL_STRING', Config.Basics.Prompts.label)
					PromptSetActiveGroupThisFrame(UseGroup, label2)
					if Citizen.InvokeNative(0xC92AC953F0A982AE,UsePrompt) then
						TriggerEvent("wasvendeldev_birdmail:readletter")
					end
				end
			end
		end
	end
end)

RegisterNetEvent('wasvendeldev_birdmail:readletter')
AddEventHandler('wasvendeldev_birdmail:readletter', function(players, totalOnline)        
    local carriable = Citizen.InvokeNative(0xF0B4F759F35CC7F5, pigeon, Citizen.InvokeNative(0x34F008A7E48C496B, pigeon, 2), 0, 0, 512)
    TaskPickupCarriableEntity(PlayerPedId(), carriable)
	FreezeEntityPosition(pigeon, false)
    openGuiRead(message)
    Wait(2500)
    DeleteEntity(pigeon)
	writinganim()
	Notified = false
	dst = nil
	pigeon = nil
	message = nil
	blip = nil
end)

RegisterNetEvent('wasvendeldev_birdmail:openmailmenu')
AddEventHandler('wasvendeldev_birdmail:openmailmenu', function(players, totalOnline)
	AddTextEntry("FMMC_KEY_TIP8", Config.Basics.firstname)
    DisplayOnscreenKeyboard(0, "FMMC_KEY_TIP8", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
        Citizen.Wait(1);
    end
    while (UpdateOnscreenKeyboard() == 2) do
        Citizen.Wait(1);
        break
    end
    while (UpdateOnscreenKeyboard() == 1) do
        Citizen.Wait(1)
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            AddFirstname(result)
            break
        end
    end
end)

function AddFirstname(firstname)
    AddTextEntry("FMMC_KEY_TIP8", Config.Basics.lastname)
    DisplayOnscreenKeyboard(0, "FMMC_KEY_TIP8", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
        Citizen.Wait(1)
    end
    while (UpdateOnscreenKeyboard() == 2) do
        Citizen.Wait(1)
        break
    end
    while (UpdateOnscreenKeyboard() == 1) do
        Citizen.Wait(1)
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            AddMessage(firstname, result)
            break
        end
    end
end

function AddMessage(firstname, lastname)
    AddTextEntry("FMMC_KEY_TIP8", Config.Basics.message)
    DisplayOnscreenKeyboard(0, "FMMC_KEY_TIP8", "", "", "", "", "", Config.Basics.messagemaxchar)
    while (UpdateOnscreenKeyboard() == 0) do
        Citizen.Wait(1)
    end
    while (UpdateOnscreenKeyboard() == 2) do
        Citizen.Wait(1)
        break
    end
    while (UpdateOnscreenKeyboard() == 1) do
        Citizen.Wait(1)
        if (GetOnscreenKeyboardResult()) then
            local message = GetOnscreenKeyboardResult()   
			TriggerServerEvent("wasvendeldev_birdmail:sendletter", firstname, lastname, message, GetPlayerServerIds(), id)
            break
        end
    end
end

function GetPlayerServerIds()
    local players = {}
    local a = GetActivePlayers()
    for i,v in pairs(a) do 
        table.insert(players, GetPlayerServerId(v))
    end
    return players
end

function writinganim()
	Citizen.InvokeNative(0x524B54361229154F, PlayerPedId(), GetHashKey("world_human_write_notebook"), -1,true,false, false, false)
end

function animcancel()
	ClearPedSecondaryTask(PlayerPedId())
	ClearPedTasks(PlayerPedId())
	SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true) -- unarm player    
end

function openGuiRead(text)
	SendNUIMessage({
		action = 'openLetterRead',
		TextRead = text,
	})
	SetNuiFocus(true, true)
end

RegisterNUICallback('updating', function()
	SetNuiFocus(false, false)
	animcancel()
end)

RegisterNetEvent('wasvendeldev_birdmail:callnotification')
AddEventHandler('wasvendeldev_birdmail:callnotification', function(text, duration)
	exports.wasvendel_birdmail:ShowTooltip(tostring(text), tonumber(duration))
end)

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() == resourceName then
		DeleteEntity(pigeon)
	end
end)