local garages = {}
ESX = nil

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:requestGarageMenu")
AddEventHandler("::{korioz#0110}::esx_garageinstance:requestGarageMenu", function(garageId)
    local _src = source
    local garageFound, garageInfos = false, {}
    local xPlayer = ESX.GetPlayerFromId(_src)
    for id, infos in pairs(garages) do
        if infos.garageId == garageId and infos.owner == xPlayer.identifier then
            garageFound = true
            garageInfos = infos
        end
    end
    TriggerClientEvent("::{korioz#0110}::esx_garageinstance:openMenu", _src, garageId, garageFound)
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:exitGarage")
AddEventHandler("::{korioz#0110}::esx_garageinstance:exitGarage", function(garageInfos)
    local _src = source
    SetPlayerRoutingBucket(_src, 0)
    TriggerClientEvent("::{korioz#0110}::esx_garageinstance:outPedestrian", _src, Config.availableGarages[garageInfos.garageId].entry)
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:outWithVeh")
AddEventHandler("::{korioz#0110}::esx_garageinstance:outWithVeh", function(plate, props, garageId)
    local _src = source
    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 0 WHERE plate = @a", { ['a'] = plate }, function()
        SetPlayerRoutingBucket(_src, 0)
        TriggerClientEvent("::{korioz#0110}::esx_garageinstance:outVehicle", _src, Config.availableGarages[garageId].out, props)
    end)
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:backVehicle")
AddEventHandler("::{korioz#0110}::esx_garageinstance:backVehicle", function(plate, props, garageId)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    print("["..plate.."]")
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @a AND stored = 0 AND garageId = @b AND plate = @c", {
        ['a'] = xPlayer.identifier,
        ['b'] = garageId,
        ['c'] = plate
    }, function(result)
        if result[1] then
            MySQL.Async.execute("UPDATE owned_vehicles SET stored = 1, vehicle = @d WHERE owner = @a AND plate = @b AND garageId = @c", {
                ['a'] = xPlayer.identifier;
                ['b'] = plate,
                ['c'] = garageId,
                ['d'] = json.encode(props)
            }, function()
                TriggerClientEvent("::{korioz#0110}::esx_garageinstance:backVeh", _src)
                TriggerClientEvent("esx:showNotification", _src, ("%sVéhicule rangé !"):format(Config.prefix))
            end)
        else
            TriggerClientEvent("esx:showNotification", _src, ("%sVous ne pouvez pas rentrer ce véhicule dans ce garage !"):format(Config.prefix))
        end
    end)
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:enterInOwnedGarage")
AddEventHandler("::{korioz#0110}::esx_garageinstance:enterInOwnedGarage", function(garageId)
    local _src = source
    local garageFound, garageInfos = false, {}
    local xPlayer = ESX.GetPlayerFromId(_src)
    for id, infos in pairs(garages) do
        if infos.garageId == garageId and infos.owner == xPlayer.identifier then
            garageFound = true
            garageInfos = infos
        end
    end
    if not garageFound then
        DropPlayer(_src, "Une erreur est survenue dans la tentative d'accès au garage !")
        return
    end
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @a AND garageId = @b AND stored = 1", {
        ['a'] = xPlayer.identifier,
        ['b'] = garageInfos.garageId
    }, function(result)
        local vehicles = {}
        for k, v in pairs(result) do
            vehicles[k] = { props = json.decode(v.vehicle), plate = v.plate }
        end
        SetPlayerRoutingBucket(_src, (250000 + garageInfos.id))
        TriggerClientEvent("::{korioz#0110}::esx_garageinstance:prepareGarage", _src, garageInfos, vehicles)
    end)
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:requestGarageManager")
AddEventHandler("::{korioz#0110}::esx_garageinstance:requestGarageManager", function(garageInfos)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @a", { ['a'] = xPlayer.identifier }, function(result)
        local vehicles = {}
        local inThisGarage = 0
        for k, v in pairs(result) do
            if v.garageId == garageInfos.garageId then
                inThisGarage = inThisGarage + 1
            elseif v.garageId == nil or v.garageId == 0 then
                vehicles[#vehicles + 1] = { plate = v.plate, model = json.decode(v.vehicle).model }
            end
        end
        TriggerClientEvent("::{korioz#0110}::esx_garageinstance:openManagerMenu", _src, vehicles, inThisGarage)
    end)
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:putVehicleInGarage")
AddEventHandler("::{korioz#0110}::esx_garageinstance:putVehicleInGarage", function(plate, garageId)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.execute("UPDATE owned_vehicles SET garageId = @a WHERE owner = @b AND plate = @c", {
        ['a'] = garageId,
        ['b'] = xPlayer.identifier,
        ['c'] = plate
    }, function()
        TriggerClientEvent("esx:showNotification", _src, ("%sLe véhicule ~b~%s~s~ a bien été ajouté à ce garage !"):format(Config.prefix, plate))
    end)
end)

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:purchaseGarage")
AddEventHandler("::{korioz#0110}::esx_garageinstance:purchaseGarage", function(garageId)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not Config.availableGarages[garageId] then
        DropPlayer(_src, "Une erreur est survenue dans la tentative d'achat du garage !")
        return
    end
    local requieredAmmount = Config.availableGarages[garageId].price
    local bank = xPlayer.getAccount("bank").money
    if bank < requieredAmmount then
        TriggerClientEvent("esx:showNotification", _src, ("%sVous n'avez pas assez d'argent pour payer ! (Requis: ~b~%s$~s~)"):format(Config.prefix, ESX.Math.GroupDigits(requieredAmmount)))
        return
    end
    xPlayer.removeAccountMoney("bank", requieredAmmount)
    MySQL.Async.insert("INSERT INTO garage_instance (garageId, owner, type, ownerName) VALUES (@a,@b,@c,@d)", {
        ['a'] = garageId,
        ['b'] = xPlayer.identifier,
        ['c'] = Config.availableGarages[garageId].type,
        ['d'] = GetPlayerName(_src)
    }, function(insertId)
        garages[insertId] = { id = insertId, garageId = garageId, owner = xPlayer.identifier, type = Config.availableGarages[garageId].type, ownerName = GetPlayerName(_src) }
        TriggerClientEvent("esx:showNotification", _src, ("%s~g~Félicitations ~s~! ~s~Vous possédez désormais le garage \"~b~%s~s~\""):format(Config.prefix, Config.availableGarages[garageId].name))
    end)
end)

Citizen.CreateThread(function()
    MySQL.Async.fetchAll("SELECT * FROM garage_instance", {}, function(result)
        for k, v in pairs(result) do
            garages[v.id] = v
        end
    end)
end)