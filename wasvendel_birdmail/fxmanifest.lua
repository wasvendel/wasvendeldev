  
fx_version "cerulean"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
author "wasvendel"
lua54 "yes"
version '1.0.0'

escrow_ignore {
	'config.lua',
    'events.lua',
}

client_script {
    "notification.js",
    'client.lua',
    'events.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

shared_scripts {
    'config.lua'
}

ui_page {
    'html/ui.html',
}

files {
    'html/*',
    'html/css/*',
    'html/js/*',
}

dependency '/assetpacks'