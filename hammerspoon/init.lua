local function keyCode(key, modifiers)
   modifiers = modifiers or {}
   return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
   end
end

local function remapKey(modifiers, key, keyCode)
   hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

remapKey({'cmd'}, 'h', keyCode('left'))
remapKey({'cmd'}, 'j', keyCode('down'))
remapKey({'cmd'}, 'k', keyCode('up'))
remapKey({'cmd'}, 'l', keyCode('right'))

remapKey({'cmd', 'shift'}, 'h', keyCode('left', {'shift'}))
remapKey({'cmd', 'shift'}, 'j', keyCode('down', {'shift'}))
remapKey({'cmd', 'shift'}, 'k', keyCode('up', {'shift'}))
remapKey({'cmd', 'shift'}, 'l', keyCode('right', {'shift'}))
