Config = {}


Config.Framework = "VORP" --VORP/redemrp-reboot
Config.WhitdrawPercent = 0.05 --% or boolean value. can be set to false 
Config.TransferPercent = 0.05 --% or boolean value. can be set to false
Config.TransferTime = 1 --min

Config.Blip = {
    enable = true, --boolean (true or false) value. enable or disable blip
    blipsrpite = -2128054417, --blip sprite https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/blips
    blipsscale = 1.0,
    usebanksname = false,  --if you want to use separate names for each bank then true if you want to use the same name for all banks then false
    blipname = "Bank", --Blip name
}

Banks = {
    Valentine = { --table name
        coords = vector3(-308.39, 775.43, 119.12), --bank coords
        name = "Valentine bank", --bank label
        data = "valentine", --bank data !!!must match the name of the bank's sql table!!!
        hideblip = false,  --if you want to hide the blip of this bank then true if not then false
        opening = {0, 24} --opening and closing times
    },
    BlackWater = {
        coords = vector3(-813.21, -1276.93, 44.32),
        name = "BlackWater bank",
        data = "blackwater",
        hideblip = false,
        opening = {0, 24}
    },
    Rhodes = {
        coords = vector3(1292.11, -1302.18, 77.42),
        name = "Rhodes bank",
        data = "rhodes",
        hideblip = false,
        opening = {0, 24}
    },
    SaintDenis = {
        coords = vector3(2644.6, -1293.3, 52.33),
        name = "Saint Denis bank",
        data = "saintdenis",
        hideblip = false,
        opening = {0, 24}
    },
    Armadillo = {
        coords = vector3(-3666.1, -2627.13, -13.11),
        name = "Armadillo bank",
        data = "armadillo",
        hideblip = false,
        opening = {0, 24}
    },
    Tumbelweed = {
        coords = vector3(-5533.029296875,-2950.6304199219,-0.2027529239655),
        name = "Tumbelweed bank",
        data = "tumbleweed",
        hideblip = false,
        opening = {0, 24}
    },
}

Config.BankStorages = {
    enable = true,  -- Change this to true or false as needed
    header = "Bank inventory",
    basic = {slot = 10, price = 5},
    upgrade = {
        {slot = 20, price = 10},
        {slot = 30, price = 12},
        {slot = 40, price = 13},
        {slot = 50, price = 14},
        {slot = 60, price = 15}
    }
}

Config.Notifications = {
    notenoughmoney = "Not enough money",
    notenoughmoneyinbank = "Not enough money in the bank",
    successfulltransfer = "Successful money transfer",
    successfulldeposit = "Successful deposit",
    successfullwhitdraw = "Successful withdrawal",
    successfullstoragepurchase = "Successful purchase",
    storagenotpurchased = "The storage is not purchased",
    storagealreadypurchased = "The storage has already been purchased",
    successfullslotupdate = "The container successfully expanded",
    error = "Error",
}

Config.Prompt = {
    text = "Open",
    key = 0x760A9C6F, --https://github.com/femga/rdr3_discoveries/tree/master/Controls
    label = "Bank",
    bankclosed = "The bank is closed"
}

Config.AdminCommand = {
    enablecommand = true, -- true or false
    setbankmoney = "setbankmoney",
}

Config.Permission = { --You can specify which server rank can use the script commands.
    superadmin = true,
    admin = true, 
    moderator = true,
}

Config.log = {
    enable = true, -- true or false
    webhook = "https://discord.com/api/webhooks/",
    webhookcolor = '10471367', --https://convertingcolors.com/decimal-color-10471367.html
    --Translate
    headertext = "**Bank Transaction**",
    playerdata = "Player Data",
    transactiondata = "Transaction Data",
    transactiontype = "Transaction Type",
    transactiontarget = "Target Bank",
    bankname = "Bank",
    amount = "Amount",
    name = "Name",
    steam = "Steam ID",
    time = "Transaction Time: ",
    typedeposit = "Deposit",
    typewhitdraw = "Withdrawal",
    typetransfer = "Transfer",
    --Storage
    storageaction = "Storage action:",
    buystorage = "Storage purchased",
    updatestorage = "Storage updated",
    actionname = "Interaction type",
}