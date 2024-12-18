Config = {}

Config.Framework = "redemrp-reboot" --redemrp-reboot/vorp
Config.Notifications = {
    SenderNotification = "You sent the message.",
    TargetNotification = "You will receive a message.",
    NoItem = "Acquire a carrier pigeon and an empty telegram!",
    InvalidName = "You entered an invalid name!",
    InInterior = "You can only send letters outdoors!"    
}

Config.Basics = {
    Prompts = {
        pickuptext = "Pick up",
        pickupkey = 0x760A9C6F,
        label = "Bird",
    },
    Bird = {
        birdmodel = "A_C_Pigeon",
        modelscale = 2.0,
        birdblip = true,
        blipname =  "Bird",
    }, 
    Items = {
        itempigeon = "pigeon",
        itemtelegram = "emptytelegram",
        piegonamount = 1,
        telegramamount = 1,
    },
    cooldown = 10, --sec|How many seconds until the bird mail arrives
    firstname = "Firstname: ",
    lastname = "Lastname: ",
    message = "Message: ",
    messagemaxchar = 90,
    checkinterior = true,
}

Config.Discordlog = {
    discordlog = true,
    webhook = "https://discord.com/api/webhooks/1185668232724631652/Q9CinG2wDPwFGb3Ibj9sB-BxyAWF9Og5UPm_wHtru9uuttBFntVMEayFrpXEzLkOVZyc",
    color = 15874618,
    title = "**Birdmail**",
    text = "wasvendel dev",
    logtext = "They sent bird mail!",
    sender = "Sender: ",
    sendersteam = "Sender Steam: ",
    target = "Target: ",
    targetsteam = "Target Steam: ",
    messageh = "Message: ",
}