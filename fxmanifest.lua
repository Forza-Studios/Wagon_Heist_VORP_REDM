fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author '_forza'
description 'A complete server-authoritative instanced wagon heist'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/camera.lua',
    'client/nui.lua',
    'client/mission.lua',
    'client/main.lua'
}

server_scripts {
    'server/session.lua',
    'server/entities.lua',
    'server/main.lua'
}
