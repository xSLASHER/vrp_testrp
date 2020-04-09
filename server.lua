------ TEST RP PENTRU APEX ----------
------ Acest sistem de test rp este-- 
------ obtinut din vrp_dmvschool-----
------ SLASHER DATE: 02/10/2019 -----
-------------------------------------


--[[BASE]]--
MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_testrp")

--[[LANG]]--
local Lang = module("vrp", "lib/Lang")
local cfg = module("vrp", "cfg/base")
local lang = Lang.new(module("vrp", "cfg/lang/"..cfg.lang) or {})

--[[SQL]]--
MySQL.createCommand("vRP/dmv_column", "ALTER TABLE vrp_users ADD IF NOT EXISTS pieton varchar(50) NOT NULL default '1'")
MySQL.createCommand("vRP/get_pieton","SELECT pieton FROM vrp_users WHERE id = @user_id")
MySQL.createCommand("vRP/dmv_success", "UPDATE vrp_users SET pieton='Passed' WHERE id = @id")
MySQL.createCommand("vRP/set_pieton","UPDATE vrp_users SET pieton = @pieton WHERE id = @user_id")
MySQL.createCommand("vRP/dmv_search", "SELECT * FROM vrp_users WHERE id = @id AND pieton = 'Passed'")

RegisterServerEvent("dmv:success")
AddEventHandler("dmv:success", function()
	local user_id = vRP.getUserId({source})
	MySQL.query("vRP/dmv_success", {id = user_id})
end)

--- sql
function vRP.isPieton(user_id, cbr)
  local task = Task(cbr, {false})

  MySQL.query("vRP/get_pieton", {user_id = user_id}, function(rows, affected)
    if #rows > 0 then
      task({rows[1].pieton})
    else
      task()
    end
  end)
end
--- sql
function vRP.setPieton(user_id,pieton)
  MySQL.execute("vRP/set_pieton", {user_id = user_id, pieton = pieton})
end

function vRP.pieton(source,reason)
  local user_id = vRP.getUserId(source)

  if user_id ~= nil then
        TriggerClientEvent('dmv:startttest',player)
		vRPclient.notify(player,{"~r~Trebuie sa treci testul"})
  end
end 

function vRP.isFirstSpawn(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  return tmp and tmp.spawns == 1
end
RegisterServerEvent("vRP:playerSpawn")
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn, deferrals)
	local player = vRP.getUserSource({user_id})
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		MySQL.query("vRP/dmv_search", {id = user_id}, function(rows, affected)
		if #rows > 0 then
		    vRPclient.notify(player,{"~r~Bravo ai testul indeplinit"})
		else
			TriggerClientEvent('dmv:startttest',player)
		end
    end)
	end
end)	