fx_version "adamant"
games { "rdr3" }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'
author 'wasvendel'

shared_scripts {
    'config.lua',
    'events.lua',
}

client_scripts {
    'client.lua'
}

server_exports { 
    "SetBankMoney",
    "GetBankMoney",
    "IsBankMoneyEnough",
    "RemoveMoneyInBank",
    "AddMoneyInBank"
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'inventorycreate.lua',
}

ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.css',
    'html/*.js',
    'html/*.ttf',
    'html/img/*.png'
}

escrow_ignore {
    'config.lua',
    'events.lua',
    'inventorycreate.lua',
}