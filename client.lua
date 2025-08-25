CreateThread(function()

    local lastHostility
    --[[
        HOSTILITY_NEUTRAL :: 0
        HOSTILITY_ALLY    :: 1
        HOSTILITY_HOSTILE :: 2
    --]]

    NetworkSetFriendlyFireOption(true)

    local playerId = PlayerId()

    while true do
        Wait(0)

        local hostilitySettings = 0 --[[ HOSTILITY_ALLY ]]

        N_0xe3ab5eefcb6671a2(hostilitySettings)

        Wait(0)

        hostilitySettings = 2 --[[ HOSTILITY_HOSTILE ]]

        local playerPedId = PlayerPedId()

        if IsPedOnMount(playerPedId) or IsPedInAnyVehicle(playerPedId, false) or IsPedGettingIntoAVehicle(playerPedId) or N_0x95cbc65780de7eb1(playerPedId, 0) ~= 0 then
            hostilitySettings = 1 --[[ HOSTILITY_ALLY ]]
        end

        local interactionTargetEntityId = Citizen.InvokeNative(0x3EE1F7A8C32F24E1, playerId, Citizen.PointerValueInt(), 1, false)

        -- IsPedAPlayer
        local isInteractionTargetEntityAPlayer = interactionTargetEntityId ~= 0 and IsPedAPlayer( interactionTargetEntityId )

        if interactionTargetEntityId ~= 0 and not isInteractionTargetEntityAPlayer then
            hostilitySettings = 1 --[[ HOSTILITY_ALLY ]]
        end

        N_0xe3ab5eefcb6671a2(hostilitySettings)
    end
end)


local targetedNonPlayerEntity

local targetedPlayerEntity
local targetedPlayerServerId

Citizen.CreateThread(
    function()

        while true do
            Citizen.Wait(100)

            local ped = PlayerPedId()

            local _nonPlayer

            local _targetedPlayerEntity
            local _targetedPlayerServerId

            local isTargetting, entity = GetPlayerTargetEntity(PlayerId())

            if isTargetting then
                if IsEntityAPed(entity) and IsPedHuman(entity) then
                    if IsPedAPlayer(entity) then
                        local playerId = GetPlayerIdFromPed(entity)

                        _targetedPlayerEntity = entity
                        _targetedPlayerServerId = GetPlayerServerId(playerId)
                    else
                        _nonPlayer = entity
                    end
                end
            else
                local pPosition = GetEntityCoords(ped)
                local cameraRotation = GetGameplayCamRot()
                local cameraCoord = GetGameplayCamCoord()
                local direction = RotationToDirection(cameraRotation)
                local aimingAtVector = vec3(cameraCoord.x + direction.x * 7.0, cameraCoord.y + direction.y * 7.0, cameraCoord.z + direction.z * 7.0)
                
                local rayHandle = StartShapeTestRay(cameraCoord, aimingAtVector, -1, ped, 0)
                local _, hit, endCoords, _, entityHit = GetShapeTestResult(rayHandle)
                if hit ~= 0 then
                    if IsEntityAPed(entityHit) and IsPedHuman(entityHit) then
                        if IsPedAPlayer(entityHit) then
                            if NativeIsPedLassoed(entityHit) or IsEntityDead(entityHit) then
                                local playerId = GetPlayerIdFromPed(entityHit)

                                _targetedPlayerEntity = entityHit
                                _targetedPlayerServerId = GetPlayerServerId(playerId)
                            end
                        else
                            if IsEntityDead(entityHit) then
                                _nonPlayer = entityHit
                            end
                        end
                    end
                end
            end

            if _nonPlayer ~= targetedNonPlayerEntity then
                targetedNonPlayerEntity = _nonPlayer
            end

            if _targetedPlayerEntity ~= targetedPlayerEntity then
                targetedPlayerEntity = _targetedPlayerEntity
            end

            if _targetedPlayerServerId ~= targetedPlayerServerId then
                targetedPlayerServerId = _targetedPlayerServerId
            end
        end
    end
)

CreateThread(
    function()

        while true do
            Citizen.Wait(0)

            if targetedNonPlayerEntity ~= nil or targetedPlayerEntity ~= nil then

                local ped = PlayerPedId()

                local entity
                local name = "Pessoa Desconhecida"

                if targetedNonPlayerEntity ~= nil then
                    entity = targetedNonPlayerEntity
                else
                    entity = targetedPlayerEntity
                    isAPlayer = true

                    SetPedPromptName(entity, name)
                end

            end
        end
    end
)


function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function NativeIsPedLassoed(ped)
    return Citizen.InvokeNative(0x9682F850056C9ADE, ped)
end

function GetPlayerIdFromPed(ped)
    for _, playerId in pairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(playerId)
        if playerPed == ped then
            return playerId
        end
    end
end