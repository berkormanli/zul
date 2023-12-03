--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
games        { 'gta5' }
--[[ Resource Information ]]--
name         'zul'
author       'zeixna'
version      '3.6.0'
license      'LGPL-3.0-or-later'
repository   'https://github.com/berkormanli/zul'
description  'A set of functions that I use most of the times and '

--[[ Manifest ]]--
dependencies {
	'/server:5848',
    '/onesync',
}

--ui_page 'web/build/index.html'

files {
    'init.lua',
    'modules/**/client.lua',
    'modules/**/shared.lua',
    --'web/build/index.html',
    --'web/build/**/*',
	'locales/*.json',
}

shared_script 'resource/init.lua'

shared_scripts {
	'modules/locale/shared.lua',
    'functions/dataStructures/sh_*.lua',
    'functions/**/shared.lua',
    -- 'resource/**/shared/*.lua'
}

client_scripts {
	'modules/callback/client.lua',
	'modules/requestModel/client.lua',
	'modules/requestAnimDict/client.lua',
	'modules/addKeybind/client.lua',
    'functions/**/client.lua',
    'functions/**/client/*.lua'
}

server_scripts {
	'modules/callback/server.lua',
    'functions/**/server.lua',
    'functions/**/server/*.lua',
}
