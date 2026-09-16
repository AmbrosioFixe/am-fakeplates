local Framework = GetResourceState('qbx_core') == 'started' and 'qbox' or 'esx'

if Framework == 'esx' then
    local ESX = exports["es_extended"]:getSharedObject()
    ESX.RegisterUsableItem(Config.ItemName, function(source)
        TriggerClientEvent('fake_plates:client:useItem', source, false)
    end)
    ESX.RegisterUsableItem(Config.CustomItemName, function(source)
        TriggerClientEvent('fake_plates:client:useItem', source, true)
    end)
elseif Framework == 'qbox' then
    exports.qbx_core:CreateUseableItem(Config.ItemName, function(source, item)
        TriggerClientEvent('fake_plates:client:useItem', source, false)
    end)
    exports.qbx_core:CreateUseableItem(Config.CustomItemName, function(source, item)
        TriggerClientEvent('fake_plates:client:useItem', source, true)
    end)
end

lib.callback.register('fake_plates:server:applyPlate', function(source, netId, isCustom, newPlate)
    local itemName = isCustom and Config.CustomItemName or Config.ItemName
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then
        return 'sync_error'
    end
    
    local playerPed = GetPlayerPed(source)
    if #(GetEntityCoords(playerPed) - GetEntityCoords(vehicle)) > 10.0 then
        return false -- Cheater a tentar interagir longe do veiculo
    end
    
    local oldPlate = GetVehicleNumberPlateText(vehicle)
    
    if Entity(vehicle).state.originalPlate then
        return 'has_plate'
    end

    local item = exports.ox_inventory:GetItem(source, itemName, nil, true)
    
    if item and item >= 1 then
        exports.ox_inventory:RemoveItem(source, itemName, 1)
        
        Entity(vehicle).state:set('originalPlate', oldPlate, true)
        Entity(vehicle).state:set('isCustomPlate', isCustom, true)
        
        if not isCustom then
            newPlate = GenerateFakePlate()
        end
        SetVehicleNumberPlateText(vehicle, newPlate)
        
        return true
    end
    
    return false
end)

lib.callback.register('fake_plates:server:removePlate', function(source, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and vehicle ~= 0 then
        local playerPed = GetPlayerPed(source)
        if #(GetEntityCoords(playerPed) - GetEntityCoords(vehicle)) > 10.0 then
            return false -- Cheater a tentar interagir longe do veiculo
        end
        
        local originalPlate = Entity(vehicle).state.originalPlate
        local isCustom = Entity(vehicle).state.isCustomPlate
        
        if originalPlate then
            local itemName = isCustom and Config.CustomItemName or Config.ItemName
            
            if exports.ox_inventory:CanCarryItem(source, itemName, 1) then
                exports.ox_inventory:AddItem(source, itemName, 1)
                
                Entity(vehicle).state:set('originalPlate', nil, true)
                Entity(vehicle).state:set('isCustomPlate', nil, true)
                SetVehicleNumberPlateText(vehicle, originalPlate)
                return true
            else
                return 'inventory_full'
            end
        end
    end
    
    return false
end)
