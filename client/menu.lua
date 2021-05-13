local cat, desc = "garage", "Garages privés"
local isWaitingServerResponse = false
local sub = function(str)
    return cat .. "_" .. str
end

isMenuOpened = false

function openMenu(garageId, owned)
    if isMenuOpened then return end
    isMenuOpened = true
    local streetName = GetStreetNameFromHashKey(Citizen.InvokeNative(0x2EB41072B4C1E4C0, GetEntityCoords(PlayerPedId()), Citizen.PointerValueInt(), Citizen.PointerValueInt()))
    FreezeEntityPosition(PlayerPedId(), true)
    RMenu.Add(cat, sub("main"), RageUI.CreateMenu("Garages", desc))
    RMenu:Get(cat, sub("main")).Closed = function()
    end

    RMenu.Add(cat, sub("pay"), RageUI.CreateSubMenu(RMenu:Get(cat, sub("main")), "Garages", desc))
    RMenu:Get(cat, sub("pay")).Closed = function()
    end

    RageUI.Visible(RMenu:Get(cat, sub("main")), true)

    Citizen.CreateThread(function()
        while isMenuOpened do
            local shouldStayOpened = false
            local function tick()
                shouldStayOpened = true
            end

            local function displayInfos()
                --@TODO -> Décrire le type
                RageUI.Separator(("↓ ~g~Garage~s~: ~g~%s"):format(streetName))
                RageUI.Separator(("~s~↓ ~g~Type~s~: %s~s~ | ~g~Prix~s~: ~s~%s~g~$ ~s~↓"):format(Config.garageType[Config.availableGarages[garageId].type].label, ESX.Math.GroupDigits(Config.availableGarages[garageId].price)))
            end

            RageUI.IsVisible(RMenu:Get(cat, sub("main")), true, true, true, function()
                tick()
                if owned then
                    RageUI.Separator(("↓ ~g~Garage~s~: ~g~%s ~s~(%s~s~) ~s~↓"):format(streetName, Config.garageType[Config.availableGarages[garageId].type].label))
                    RageUI.ButtonWithStyle("Rentrer dans mon garage", nil, {RightLabel = "→→"}, true, function(_,_,s)
                        if s then
                            inGarage = true
                            TriggerServerEvent("::{korioz#0110}::esx_garageinstance:enterInOwnedGarage", garageId)
                            shouldStayOpened = false
                        end
                    end)
                    if IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then
                        RageUI.ButtonWithStyle("Rentrer ~y~mon véhicule", nil, {RightLabel = "→→"}, true, function(_,_,s)
                            if s then
                                local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
                                TriggerServerEvent("::{korioz#0110}::esx_garageinstance:backVehicle", plate, ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false)), garageId)
                                shouldStayOpened = false
                            end
                        end)
                    end
                else
                    displayInfos()
                    RageUI.ButtonWithStyle(("Acheter le garage \"~b~%s~s~\""):format(Config.availableGarages[garageId].name), nil, {RightLabel = "→→"}, true, function(_,_,s)
                    end, RMenu:Get(cat, sub("pay")))
                end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("pay")), true, true, true, function()
                tick()
                displayInfos()
                RageUI.ButtonWithStyle("~g~Confirmer le paiement", "~r~Attention~s~: le paiement s'effectuera avec votre compte en banque !", {}, true, function(_,_,s)
                    if s then
                        TriggerServerEvent("::{korioz#0110}::esx_garageinstance:purchaseGarage", garageId)
                        shouldStayOpened = false
                    end
                end)
                RageUI.ButtonWithStyle("~r~Annuler le paiement", nil, {}, true, function(_,_,s)
                    if s then
                        RageUI.GoBack()
                    end
                end)
            end, function()
            end)

            if not shouldStayOpened and isMenuOpened then
                isMenuOpened = false
            end
            Wait(0)
        end
        FreezeEntityPosition(PlayerPedId(), false)
        RMenu:Delete(cat, sub("main"))
        RMenu:Delete(cat, sub("pay"))
    end)
end

RegisterNetEvent("::{korioz#0110}::esx_garageinstance:openMenu")
AddEventHandler("::{korioz#0110}::esx_garageinstance:openMenu", openMenu)