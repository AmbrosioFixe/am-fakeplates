Config = {}

Config.Locale = 'pt' -- 'pt' ou 'en'

Config.ItemName = 'fake_plate'
Config.CustomItemName = 'custom_fake_plate'
Config.ActionDuration = 5000

Config.EnableChassiCheck = true

Config.PoliceJobs = {
    'police',
    'sheriff'
}

function GenerateFakePlate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local plate = ''
    for i = 1, 8 do
        local rand = math.random(1, #chars)
        plate = plate .. string.sub(chars, rand, rand)
    end
    return plate
end

Locales = {}

function _U(str, ...)
    if Locales[Config.Locale] ~= nil then
        if Locales[Config.Locale][str] ~= nil then
            return string.format(Locales[Config.Locale][str], ...)
        else
            return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
        end
    else
        return 'Locale [' .. Config.Locale .. '] does not exist'
    end
end
