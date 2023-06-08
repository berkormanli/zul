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
    'imports/**/client.lua',
    'imports/**/shared.lua',
    --'web/build/index.html',
    --'web/build/**/*',
	'locales/*.json',
}

shared_script 'resource/init.lua'

shared_scripts {
	'imports/locale/shared.lua',
    'resource/**/shared.lua',
    -- 'resource/**/shared/*.lua'
}

client_scripts {
	'imports/callback/client.lua',
	'imports/requestModel/client.lua',
	'imports/requestAnimDict/client.lua',
	'imports/addKeybind/client.lua',
    'resource/**/client.lua',
    'resource/**/client/*.lua'
}

server_scripts {
	'imports/callback/server.lua',
    'resource/**/server.lua',
    'resource/**/server/*.lua',
}
