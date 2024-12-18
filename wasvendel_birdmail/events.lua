local TEXTS = Config.Notifications
local notifSettings = {}

local notifSettings = {
	[1] = {
		TEXTS.SenderNotification, 3000,
	},
    [2] = {
		TEXTS.TargetNotification, 3000,
	},
    [3] = {
		TEXTS.NoItem, 5000,
	},
    [4] = {
		TEXTS.InvalidName, 4000,
	},
    [5] = {
		TEXTS.InInterior, 3000,
	},
}

function CallNotification(id, extra)
	local _id = tonumber(id)
	local title = notifSettings[_id][1]
	local timer = notifSettings[_id][2]

	TriggerEvent("wasvendeldev_birdmail:callnotification", title,timer)
end

RegisterNetEvent("wasvendeldev_birdmail:notification")
AddEventHandler("wasvendeldev_birdmail:notification", function(id, extra)
	local _id = tonumber(id)
	CallNotification(_id, extra)
end)
