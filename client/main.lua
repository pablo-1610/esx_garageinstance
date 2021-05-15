local onCooldown = false
ESX, inGarage = nil, nil

RegisterNetEvent("esx_garageinstance:outPedestrian")
AddEventHandler("esx_garageinstance:outPedestrian", function(coords)
    inGarage = nil
    FreezeEntityPosition(PlayerPedId(), true)
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Wait(1)
    end
    SetEntityCoords(PlayerPedId(), coords, false, false, false, false)
    DoScreenFadeIn(800)
    FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNetEvent("esx_garageinstance:outVehicle")
AddEventHandler("esx_garageinstance:outVehicle", function(coords, props)
    FreezeEntityPosition(PlayerPedId(), true)
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Wait(1)
    end
    print(json.encode(coords.pos))
    SetEntityCoords(PlayerPedId(), coords.pos, false, false, false, false)
    RequestModel(props.model)
    while not HasModelLoaded(props.model) do Wait(1) end
    local vehicle = CreateVehicle(props.model, GetEntityCoords(PlayerPedId()), coords.heading, true, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    ESX.Game.SetVehicleProperties(vehicle, props)
    DoScreenFadeIn(800)
    FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNetEvent("esx_garageinstance:prepareGarage")
AddEventHandler("esx_garageinstance:prepareGarage", function(garageInfos, vehicles)
    local currentVehicles = {}
    inGarage = garageInfos
    FreezeEntityPosition(PlayerPedId(), true)
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Wait(1)
    end
    local co = Config.garageType[Config.availableGarages[garageInfos.garageId].type].entry
    SetEntityCoords(PlayerPedId(), co.pos, false, false, false, false)
    SetEntityHeading(PlayerPedId(), co.heading)
    for k, v in pairs(vehicles) do
        local model = v.props.model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        local coV = Config.garageType[Config.availableGarages[garageInfos.garageId].type].slots[k]
        local vehicle = CreateVehicle(model, coV.pos, coV.heading, false, false)
        ESX.Game.SetVehicleProperties(vehicle, v.props)
        SetVehicleUndriveable(vehicle, true)
        currentVehicles[k] = vehicle
    end
    Wait(250)
    DoScreenFadeIn(800)
    FreezeEntityPosition(PlayerPedId(), false)
    local managerZone, exitZone = Config.garageType[Config.availableGarages[garageInfos.garageId].type].manager, Config.garageType[Config.availableGarages[garageInfos.garageId].type].entry.pos
    Citizen.CreateThread(function()
        while inGarage do
            local pos = GetEntityCoords(PlayerPedId())
            local distance, distance2 = #(pos - managerZone), #(pos - exitZone)
            DrawMarker(22, managerZone, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 69, 196, 192, 255, 55555, false, true, 2, false, false, false, false)
            DrawMarker(22, exitZone, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
            if distance <= 1.0 then
                AddTextEntry("HELP", "Appuyez sur ~INPUT_CONTEXT~ pour gérer le garage")
                DisplayHelpTextThisFrame("HELP", 0)
                if IsControlJustPressed(0, 51) then
                    if not onCooldown then
                        TriggerServerEvent("esx_garageinstance:requestGarageManager", garageInfos)
                        onCooldown = true
                        Citizen.SetTimeout(1000, function()
                            onCooldown = false
                        end)
                    end
                end
            end

            if distance2 <= 1.0 then
                AddTextEntry("HELP", "Appuyez sur ~INPUT_CONTEXT~ pour sortir")
                DisplayHelpTextThisFrame("HELP", 0)
                if IsControlJustPressed(0, 51) then
                    if not onCooldown then
                        TriggerServerEvent("esx_garageinstance:exitGarage", garageInfos)
                        onCooldown = true
                        Citizen.SetTimeout(1000, function()
                            onCooldown = false
                        end)
                    end
                end
            end
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                local plate = ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId())).plate
                for k, v in pairs(vehicles) do
                    local comparingPlate = v.plate
                    if plate == comparingPlate then
                        TriggerServerEvent("esx_garageinstance:outWithVeh", v.plate, v.props, inGarage.garageId)
                        inGarage = nil
                    end
                end
            end
            Wait(0)
        end
        Citizen.SetTimeout(1200, function()
            for k, v in pairs(currentVehicles) do
                if DoesEntityExist(v) then
                    DeleteEntity(v)
                end
            end
        end)
    end)
end)

RegisterNetEvent("esx_garageinstance:backVeh")
AddEventHandler("esx_garageinstance:backVeh", function()
    DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
end)

Citizen.CreateThread(function()
    TriggerEvent("esx:getSharedObject", function(object)
        ESX = object
    end)
    while ESX == nil do
        Wait(10)
    end
    for k, v in pairs(Config.availableGarages) do
        local blip = AddBlipForCoord(v.entry)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.80)
        SetBlipSprite(blip, 50)
        SetBlipColour(blip, 69)

        BeginTextCommandSetBlipName("BLIP")
        AddTextEntry("BLIP", "Garage privé")
        EndTextCommandSetBlipName(blip)
    end
    while true do
        local interval = 150
        local pos = GetEntityCoords(PlayerPedId())
        for id, infos in pairs(Config.availableGarages) do
            --@TODO -> Si ce garage appartient au joueur, alors afficher le point de rentrée du véhicule
            local entryPos = infos.entry
            local distance = #(pos - entryPos)
            if distance <= 25.0 and not inGarage then
                interval = 0
                DrawMarker(22, entryPos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                if distance <= 5.0 then
                    AddTextEntry("HELP", ("Appuyez sur ~INPUT_CONTEXT~ pour intéragir avec ce garage (~b~%s~s~)"):format(infos.name))
                    DisplayHelpTextThisFrame("HELP", 0)
                    if IsControlJustPressed(0, 51) then
                        if not onCooldown then
                            TriggerServerEvent("esx_garageinstance:requestGarageMenu", id)
                            onCooldown = true
                            Citizen.SetTimeout(1000, function()
                                onCooldown = false
                            end)
                        end
                    end
                end
            end
        end
        Wait(interval)
    end
end)
