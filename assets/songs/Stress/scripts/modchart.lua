--[[
function onCreatePost()
    setProperty('botplay', true)
    newSprite('oso', 100, 500)
    getSparrowAtlas('oso', 'notes/notes')
    addAnimationByPrefix('oso', 'masha', 'red0')
    playAnimation('oso', 'masha')
    add('oso')

    newText('masha', 0, 500, 1280, 'oso tengo hambre oso', 32);
    add('masha')
    setTextFormat('masha', 'rajdhani.ttf', 128, colorFromName('white'), 'center', 'outline', colorFromName('black'))
    setProperty('masha.borderSize', 2)

    setObjectCameras('masha', {'camOther'})
end

local curTime = 0

function onUpdate(elapsed)
    curTime = curTime + elapsed

    setProperty('oso.x', math.sin(curTime) * 100);
end
]]