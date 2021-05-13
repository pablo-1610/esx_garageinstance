local cat, desc = "garageManager", "Garage privé"
local isWaitingServerResponse = false
local sub = function(str)
    return cat .. "_" .. str
end

local function openManagerMenu(ownedVehicles, alreadyStored)
    if isMenuOpened then
        return
    end
    isMenuOpened = true
    FreezeEntityPosition(PlayerPedId(), true)
    RMenu.Add(cat, sub("main"), RageUI.CreateMenu("Garage", desc))
    RMenu:Get(cat, sub("main")).Closed = function()
    end

    RMenu.Add(cat, sub("vehicle"), RageUI.CreateSubMenu(RMenu:Get(cat, sub("main")), "Garage", desc))
    RMenu:Get(cat, sub("vehicle")).Closed = function()
    end

    RageUI.Visible(RMenu:Get(cat, sub("main")), true)

    Citizen.CreateThread(function()
        local maxStorage = #Config.garageType[Config.availableGarages[inGarage.garageId].type].slots
        while isMenuOpened do
            local shouldStayOpened = false
            local function tick()
                shouldStayOpened = true
            end
            local function displayInfos()
                RageUI.Separator(("↓ ~g~Capacité~s~: ~g~%s~s~/~g~%s ~s~↓"):format(alreadyStored, maxStorage))
            end

            RageUI.IsVisible(RMenu:Get(cat, sub("main")), true, true, true, function()
                tick()
                displayInfos()
                local available = (maxStorage - alreadyStored)
                if available <= 0 then
                    RageUI.ButtonWithStyle("~r~Pas d'emplacement libre !", nil, {}, true)
                else
                    for i = 1, available do
                        RageUI.ButtonWithStyle(("Emplacement libre"):format(), "~r~Attention~s~: Le choix d'un emplacement est définitif ! Vous ne pourrez sortir votre véhicule que depuis ce garage.", { RightLabel = "→→" }, true, function(_, _, s)
                        end, RMenu:Get(cat, sub("vehicle")))
                    end
                end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("vehicle")), true, true, true, function()
                tick()
                displayInfos()
                RageUI.Separator("~g~Vos véhicules")
                for k, v in pairs(ownedVehicles) do
                    local label = GetDisplayNameFromVehicleModel(v.model)
                    RageUI.ButtonWithStyle(("Véhicule ~y~%s ~s~(~o~%s~s~)"):format(label, v.plate), "Cliquez pour ajouter ce véhicule au garage", { RightLabel = "→→" }, true, function(_, _, s)
                        if s then
                            shouldStayOpened = false
                            TriggerServerEvent("esx_garageinstance:putVehicleInGarage", v.plate, inGarage.garageId)
                        end
                    end)
                end
            end, function()
            end)

            if not shouldStayOpened and isMenuOpened then
                isMenuOpened = false
            end
            Wait(0)
        end
        FreezeEntityPosition(PlayerPedId(), false)
        RMenu:Delete(cat, sub("main"))
        RMenu:Delete(cat, sub("vehicle"))
    end)
end

RegisterNetEvent("esx_garageinstance:openManagerMenu")
AddEventHandler("esx_garageinstance:openManagerMenu", openManagerMenu)