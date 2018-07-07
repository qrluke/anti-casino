script_name("AntiCasino")
script_authors("#Maddison") -- edited by homie nope
script_version_number(2)
local as_action = require('moonloader').audiostream_state
sound = false

local sampev = require 'lib.samp.events'
require "lib.moonloader"

function main()
  if not isSampLoaded() or not isSampfuncsLoaded() then return end
  while not isSampAvailable() do wait(100) end
  if not doesDirectoryExist(getGameDirectory().."\\moonloader\\resource") then
    createDirectory(getGameDirectory().."\\moonloader\\resource")
  end
  file = getGameDirectory().."\\moonloader\\resource\\casino.mp3"
  if not doesFileExist(file) then
    downloadUrlToFile("http://rubbishman.ru/dev/moonloader/casino.mp3", file)
  end
	a1 = loadAudioStream(file)
  while true do
    wait(0)
    if sound then
      if getAudioStreamState(a1) ~= as_action.PLAY then
        setAudioStreamState(a1, as_action.PLAY)
      end
      sound = false
    end
  end
end

function sampev.onSendPickedUpPickup(pid)
  pX, pY, pZ = getCharCoordinates(playerPed)
  if getDistanceBetweenCoords3d(pX, pY, pZ, 1022.5, - 1123.0, 24.0) < 25 or getDistanceBetweenCoords3d(pX, pY, pZ, 2195.0, 1677.5, 12.5) < 25 or getDistanceBetweenCoords3d(pX, pY, pZ, 2014.8, 1106.8, 10.8) < 100 then
    sampAddChatMessage("Вход в казино закрыт. {FFFFFF}У тебя денег много?", 0xFF0000)
    sound = true
    return false
  end
end
