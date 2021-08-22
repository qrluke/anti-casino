require "lib.moonloader"

script_name("anti-casino")
script_authors("qrlk", "homie nope", "#Maddison")
script_version("22.08.2021")
script_dependencies("SampFuncs", "SAMP.Lua")
script_url("https://github.com/qrlk/anti-casino")

local as_action = require('moonloader').audiostream_state
local sampev = require 'lib.samp.events'

sound = false

function main()
  if not isSampLoaded() or not isSampfuncsLoaded() then return end
  while not isSampAvailable() do wait(100) end
  -- вырежи тут, если хочешь отключить проверку обновлений
  update("http://qrlk.me/dev/moonloader/anti-casino/stats.php", '['..string.upper(thisScript().name)..']: ', "http://vk.com/qrlk.mods", "anticasinochangelog")
	openchangelog("anticasinochangelog", "http://qrlk.me/changelog/anti-casino")
	-- вырежи тут, если хочешь отключить проверку обновлений
  if not doesDirectoryExist(getGameDirectory().."\\moonloader\\resource") then
    createDirectory(getGameDirectory().."\\moonloader\\resource")
  end
  file = getGameDirectory().."\\moonloader\\resource\\casino.mp3"
  if not doesFileExist(file) then
    downloadUrlToFile("https://raw.githubusercontent.com/qrlk/anti-casino/master/resource/casino.mp3", file)
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
  if getDistanceBetweenCoords3d(pX, pY, pZ, 2195.0, 1677.5, 12.5) < 25 or getDistanceBetweenCoords3d(pX, pY, pZ, 2020.8, 1010.8, 10.8) < 10 or getDistanceBetweenCoords3d(pX, pY, pZ, 2325, 2114, 10.8) < 10 or getDistanceBetweenCoords3d(pX, pY, pZ, 2372, 2170, 10.8) < 10 then
    sampAddChatMessage("Вход в казино для тебя сегодня закрыт. У тебя денег много? Шагай отсюда!", 0xFF0000)
    sound = true
    return false
  end
end
--------------------------------------------------------------------------------
------------------------------------UPDATE--------------------------------------
--------------------------------------------------------------------------------
function update(php, prefix, url, komanda)
	komandaA=komanda
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  local ffi = require 'ffi'
  ffi.cdef[[
	int __stdcall GetVolumeInformationA(
			const char* lpRootPathName,
			char* lpVolumeNameBuffer,
			uint32_t nVolumeNameSize,
			uint32_t* lpVolumeSerialNumber,
			uint32_t* lpMaximumComponentLength,
			uint32_t* lpFileSystemFlags,
			char* lpFileSystemNameBuffer,
			uint32_t nFileSystemNameSize
	);
	]]
  local serial = ffi.new("unsigned long[1]", 0)
  ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
  serial = serial[0]
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local nickname = sampGetPlayerNickname(myid)
	if thisScript().name == "ADBLOCK" then
		if mode == nil then mode = "unsupported" end
		php = php..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&m='..mode..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
	else
		php = php..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
	end
  downloadUrlToFile(php, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            if info.changelog ~= nil then
              changelogurl = info.changelog
            end
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix, komanda)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      if komandaA ~= nil then
                        sampAddChatMessage((prefix..'Обновление завершено! Подробнее об обновлении - /'..komandaA..'.'), color)
                      end
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

function openchangelog(komanda, url)
  sampRegisterChatCommand(komanda,
    function()
      lua_thread.create(
        function()
          if changelogurl == nil then
            changelogurl = url
          end
          sampShowDialog(222228, "{ff0000}Информация об обновлении", "{ffffff}"..thisScript().name.." {ffe600}собирается открыть свой changelog для вас.\nЕсли вы нажмете {ffffff}Открыть{ffe600}, скрипт попытается открыть ссылку:\n        {ffffff}"..changelogurl.."\n{ffe600}Если ваша игра крашнется, вы можете открыть эту ссылку сами.", "Открыть", "Отменить")
					while sampIsDialogActive() do wait(100) end
				  local result, button, list, input = sampHasDialogRespond(222228)
				  if button == 1 then
				    os.execute('explorer "'..changelogurl..'"')
				  end
        end
      )
    end
  )
end
