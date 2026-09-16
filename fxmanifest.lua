fx_version 'cerulean'
game 'gta5'
autor 'gomass.'
description 'Fake Plates Script for ESX and Qbox'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/pt.lua',
    'locales/en.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

lua54 'yes'
