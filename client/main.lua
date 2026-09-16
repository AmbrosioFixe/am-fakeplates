local Framework = GetResourceState('qbx_core') == 'started' and 'qbox' or 'esx'
local ESX = Framework == 'esx' and exports["es_extended"]:getSharedObject() or nil

local function PlayPlateAnimation()
    lib.requestAnimDict('mini@repair', 2000)
    TaskPlayAnim(cache.ped, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 1, 0, false, false, false)
end

local function ApplyFakePlate(vehicle, isCustom)
    if not vehicle or vehicle == 0 then return end
    
    local hasFakePlate = Entity(vehicle).state.originalPlate
    if hasFakePlate then
        lib.notify({title = 'Erro', description = _U('error_has_plate'), type = 'error'})
        return
    end

    local itemName = isCustom and Config.CustomItemName or Config.ItemName
    local hasItem = exports.ox_inventory:Search('count', itemName)
    if hasItem < 1 then
        lib.notify({title = 'Erro', description = _U('error_no_item'), type = 'error'})
        return
    end

    local newPlate = nil
    if isCustom then
        local input = lib.inputDialog(_U('dialog_title'), {
            {type = 'input', label = _U('dialog_label'), required = true, min = 1, max = 8}
        })
        if not input or not input[1] then return end
        newPlate = string.upper(input[1])
    end

    TaskTurnPedToFaceEntity(cache.ped, vehicle, 1000)
    Wait(1000)
    
    PlayPlateAnimation()
    
    if lib.progressBar({
        duration = Config.ActionDuration,
        label = _U('prog_apply'),
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true }
    }) then
        ClearPedTasks(cache.ped)
        
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        if netId == 0 then
            lib.notify({title = 'Erro', description = _U('error_sync'), type = 'error'})
            return
        end
        
        local success = lib.callback.await('fake_plates:server:applyPlate', false, netId, isCustom, newPlate)
        
        if success == true then
            lib.notify({title = 'Sucesso', description = _U('success_apply'), type = 'success'})
        elseif success == 'sync_error' then
            lib.notify({title = 'Erro', description = _U('error_sync'), type = 'error'})
        elseif success == 'has_plate' then
            lib.notify({title = 'Erro', description = _U('error_has_plate'), type = 'error'})
        else
            lib.notify({title = 'Erro', description = _U('error_no_item'), type = 'error'})
        end
    else
        ClearPedTasks(cache.ped)
        lib.notify({title = 'Aviso', description = _U('error_cancel'), type = 'warning'})
    end
end

local function RemoveFakePlate(vehicle)
    if not vehicle or vehicle == 0 then return end
    
    TaskTurnPedToFaceEntity(cache.ped, vehicle, 1000)
    Wait(1000)
    
    PlayPlateAnimation()
    
    if lib.progressBar({
        duration = Config.ActionDuration,
        label = _U('prog_remove'),
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true }
    }) then
        ClearPedTasks(cache.ped)
        
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        local success = lib.callback.await('fake_plates:server:removePlate', false, netId)
        
        if success == 'inventory_full' then
            lib.notify({title = 'Erro', description = _U('error_inv_full'), type = 'error'})
        elseif success then
            lib.notify({title = 'Sucesso', description = _U('success_remove'), type = 'success'})
        end
    else
        ClearPedTasks(cache.ped)
        lib.notify({title = 'Aviso', description = _U('error_cancel'), type = 'warning'})
    end
end

local function CheckChassi(vehicle)
    if not vehicle or vehicle == 0 then return end
    
    TaskTurnPedToFaceEntity(cache.ped, vehicle, 1000)
    Wait(1000)
    
    PlayPlateAnimation()
    
    if lib.progressBar({
        duration = 3000,
        label = _U('prog_check'),
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true }
    }) then
        ClearPedTasks(cache.ped)
        
        local originalPlate = Entity(vehicle).state.originalPlate
        local currentPlate = GetVehicleNumberPlateText(vehicle)
        
        if originalPlate then
            lib.notify({
                title = 'Chassi Adulterado', 
                description = _U('chassi_fake', originalPlate), 
                type = 'error',
                duration = 8000
            })
        else
            lib.notify({
                title = 'Chassi Limpo', 
                description = _U('chassi_real', currentPlate), 
                type = 'success',
                duration = 5000
            })
        end
    else
        ClearPedTasks(cache.ped)
        lib.notify({title = 'Aviso', description = _U('error_cancel'), type = 'warning'})
    end
end

RegisterNetEvent('fake_plates:client:useItem', function(isCustom)
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 3.0, true)
    
    if vehicle then
        ApplyFakePlate(vehicle, isCustom)
    else
        lib.notify({title = 'Erro', description = _U('error_no_veh'), type = 'error'})
    end
end)

CreateThread(function()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'apply_fake_plate',
            icon = 'fas fa-id-card',
            label = _U('target_apply'),
            canInteract = function(entity, distance, coords, name, bone)
                return not Entity(entity).state.originalPlate and exports.ox_inventory:Search('count', Config.ItemName) > 0
            end,
            onSelect = function(data)
                ApplyFakePlate(data.entity, false)
            end
        },
        {
            name = 'apply_custom_fake_plate',
            icon = 'fas fa-id-card-clip',
            label = _U('target_apply_custom'),
            canInteract = function(entity, distance, coords, name, bone)
                return not Entity(entity).state.originalPlate and exports.ox_inventory:Search('count', Config.CustomItemName) > 0
            end,
            onSelect = function(data)
                ApplyFakePlate(data.entity, true)
            end
        },
        {
            name = 'remove_fake_plate',
            icon = 'fas fa-trash-can',
            label = _U('target_remove'),
            canInteract = function(entity, distance, coords, name, bone)
                return Entity(entity).state.originalPlate ~= nil
            end,
            onSelect = function(data)
                RemoveFakePlate(data.entity)
            end
        },
        {
            name = 'check_chassi',
            icon = 'fas fa-magnifying-glass',
            label = _U('target_check_chassi'),
            canInteract = function(entity, distance, coords, name, bone)
                if not Config.EnableChassiCheck then return false end
                
                local jobName = nil
                
                if Framework == 'esx' then
                    local playerData = ESX.GetPlayerData()
                    if playerData and playerData.job then
                        jobName = playerData.job.name
                    end
                elseif Framework == 'qbox' then
                    local playerData = exports.qbx_core:GetPlayerData()
                    if playerData and playerData.job then
                        jobName = playerData.job.name
                    end
                end
                
                if jobName then
                    for _, policeJob in pairs(Config.PoliceJobs) do
                        if jobName == policeJob then return true end
                    end
                end
                return false
            end,
            onSelect = function(data)
                CheckChassi(data.entity)
            end
        }
    })
end)
