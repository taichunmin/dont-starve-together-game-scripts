local assets =
{
    Asset("ANIM", "anim/archive_orchestrina_main.zip"),
    Asset("ANIM", "anim/archive_sigil.zip"),
    Asset("MINIMAP_IMAGE", "archive_orchestrina_main"),
}

local prefabs =
{
    "archive_orchestrina_small",
    "archive_lockbox",
    "archive_orchestrina_base",
    "archive_lockbox_player_fx",
}

local RADIUS = 10
local INC = PI/20

local function mastermind(lock,key)

    local result = {exact=0,close=0}

    for i=#lock,1,-1 do
        if lock[i] == key[i] then
            result.exact = result.exact +1
            table.remove(lock,i)
            table.remove(key,i)
        end
    end

    for i=#key,1,-1 do
        for t=#lock,1,-1 do
            if key[i] == lock[t] then
                result.close = result.close +1
                table.remove(lock,t)
                table.remove(key,i)
                break
            end
        end
    end
    return result
end

local SOCKETTEST_MUST = {"resonator_socket"}
local LOCKBOX_MUST = {"archive_lockbox"}
local RESONATORTEST_CAN = {"archive_resonator","singingshell"}
local OCHESTRINA_MAIN_MUST = {"archive_orchestrina_main"}

local function findlockbox(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local lockboxents = TheSim:FindEntities(x,y,z, 3, LOCKBOX_MUST)
    if #lockboxents > 0 then
        for i=#lockboxents,1,-1 do
                if lockboxents[i].components.inventoryitem and lockboxents[i].components.inventoryitem.owner then
                table.remove(lockboxents,i)
            end
        end
    end
    return lockboxents
end

local function testforlockbox(inst)
    local lockboxes= findlockbox(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    if #lockboxes == 1 and not inst.failed then
        if inst.status == "off" then
            if not inst.AnimState:IsCurrentAnimation("big_activation") and not inst.AnimState:IsCurrentAnimation("big_on") then
                inst.AnimState:PlayAnimation("big_on_pre")
                inst.AnimState:PushAnimation("big_on",true)
                inst.SoundEmitter:PlaySound("grotto/common/archive_orchestrina/0", "machine0")
            end
        end
        inst.status = "on"
    else
        if inst.status == "on" then
            if not inst.AnimState:IsCurrentAnimation("big_activation") and not inst.AnimState:IsCurrentAnimation("big_idle") then
                inst.AnimState:PlayAnimation("big_on_pst")
                inst.AnimState:PushAnimation("big_idle",true)
            end
        end
        inst.status = "off"

        inst.SoundEmitter:KillSound("machine0")

        -- turn off the outer circles
        if inst.oldlockboxes and inst.oldlockboxes > 0 and not inst.busy then
            local ents = TheSim:FindEntities(x,y,z, 10, SOCKETTEST_MUST)
            for i, ent in ipairs(ents)do
                --ent:testforplayers(ent)
                ent:smallOff(false)
            end
        end

        if inst.numcount then
            inst.numcount = nil
        end
    end

    if inst.failed then

        -- reset if player is not on a socket
        local close = false
        local sockets = TheSim:FindEntities(x,y,z, 10, SOCKETTEST_MUST)

        for i,socket in ipairs(sockets) do
            if socket.close then
                close = true
            end
        end
        if not close then
            inst.failed = nil
        end
    end
    inst.oldlockboxes = #lockboxes
end

local function testforcompletion(inst)
    local blank = true
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 10, SOCKETTEST_MUST)

    local sockets = {}
    for i=#ents,1,-1 do
        table.insert(sockets,ents[i])
    end
    table.sort(sockets, function(a,b) return a.GUID < b.GUID end)

    local lockboxents = findlockbox(inst)
    local archive = TheWorld.components.archivemanager
    if archive then
        archive.puzzlepaused = nil
    end

    inst.busy = false

    local pass = true
    if #lockboxents == 1 then
        local puzzle = lockboxents[1].puzzle
        if puzzle then
            blank = false
            inst.AnimState:PlayAnimation("big_on",true)

            local lock = deepcopy(puzzle)
            local key = {9,9,9,9,9,9,9,9}

            local order = {}
            for i,socket in ipairs(sockets)do
                if socket.order then
                    key[i] = socket.order
                    table.insert(order,i)
                end
            end

            for i,idx in ipairs(order) do
                if key[idx] ~= lock[idx] then
                    pass = false
                end
            end

            if pass and #order > 0 and #order < 8 then
                inst.SoundEmitter:PlaySound("grotto/common/archive_orchestrina/"..  #order .."_LP", "machine"..#order)
            end
            if pass and #order == 8 then
                for i=1,7 do
                    inst.SoundEmitter:KillSound("machine"..i)
                end
                inst.SoundEmitter:PlaySound("grotto/common/archive_orchestrina/8")
                inst.busy = true

                inst.AnimState:PlayAnimation("big_activation")
                inst.AnimState:PushAnimation("big_idle")

                for i,socket in ipairs(sockets)do
                    if socket.set == true then
                        if socket.order == 1 then
                            socket.AnimState:PlayAnimation("one_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        elseif socket.order == 2 then
                            socket.AnimState:PlayAnimation("two_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        elseif socket.order == 3 then
                            socket.AnimState:PlayAnimation("three_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        elseif socket.order == 4 then
                            socket.AnimState:PlayAnimation("four_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        elseif socket.order == 5 then
                            socket.AnimState:PlayAnimation("five_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        elseif socket.order == 6 then
                            socket.AnimState:PlayAnimation("six_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        elseif socket.order == 7 then
                            socket.AnimState:PlayAnimation("seven_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        elseif socket.order == 8 then
                            socket.AnimState:PlayAnimation("eight_activation")
                            socket.AnimState:PushAnimation("small_idle",true)
                        end
                    end
                end

                inst:DoTaskInTime(5,function() inst.busy = nil end)
            end

            if pass and #order == 8 then
                if lockboxents[1].product_orchestrina then
                    inst:DoTaskInTime(1/3,function()
                        lockboxents[1]:PushEvent("onteach")
                    end)
                end

                pass = false
            end
        end
    end

    if pass == false then
        for i=1,7 do
            inst.SoundEmitter:KillSound("machine"..i)
        end
        inst.SoundEmitter:PlaySound("grotto/common/archive_orchestrina/stop")
        inst.failed = true
    end
end

local function smallOff(inst,fail)
    if fail then
        inst.AnimState:PlayAnimation("small_error")
        inst.AnimState:PushAnimation("small_idle",true)
    else
        if inst.set == true then
            if inst.order == 1 then
                if inst.AnimState:IsCurrentAnimation("one") then
                    inst.AnimState:PlayAnimation("one_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            elseif inst.order == 2 then
                if inst.AnimState:IsCurrentAnimation("two") then
                    inst.AnimState:PlayAnimation("two_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            elseif inst.order == 3 then
                if inst.AnimState:IsCurrentAnimation("three") then
                    inst.AnimState:PlayAnimation("three_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            elseif inst.order == 4 then
                if inst.AnimState:IsCurrentAnimation("four") then
                    inst.AnimState:PlayAnimation("four_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            elseif inst.order == 5 then
                if inst.AnimState:IsCurrentAnimation("five") then
                    inst.AnimState:PlayAnimation("five_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            elseif inst.order == 6 then
                if inst.AnimState:IsCurrentAnimation("six") then
                    inst.AnimState:PlayAnimation("six_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            elseif inst.order == 7 then
                if inst.AnimState:IsCurrentAnimation("seven") then
                    inst.AnimState:PlayAnimation("seven_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            elseif inst.order == 8 then
                if inst.AnimState:IsCurrentAnimation("eight") then
                    inst.AnimState:PlayAnimation("eight_pst")
                    inst.AnimState:PushAnimation("small_idle",true)
                end
            end
        end
    end
    inst.set = false
    inst.order = nil
end


local function testforplayers(inst)
    inst.close = false
    local x,y,z = inst.Transform:GetWorldPosition()
    local main = TheSim:FindEntities(x,y,z, 10, OCHESTRINA_MAIN_MUST)[1]

    if main and not main.busy then
        local failed = main.failed
        local lockboxents = findlockbox( main )
        local dist = inst:GetDistanceSqToClosestPlayer(true)
        if dist < 1.7*1.7 then
            inst.close = true
        end

        if #lockboxents == 1 and inst.close and not main.failed and not inst.set then
            if not main.numcount then
                main.numcount = 0
            end
            main.numcount = main.numcount + 1
            if main.numcount == 1 then
                inst.AnimState:PlayAnimation("one_pre")
                inst.AnimState:PushAnimation("one",true)
                inst.order = 1
            elseif main.numcount == 2 then
                inst.AnimState:PlayAnimation("two_pre")
                inst.AnimState:PushAnimation("two",true)
                inst.order = 2
            elseif main.numcount == 3 then
                inst.AnimState:PlayAnimation("three_pre")
                inst.AnimState:PushAnimation("three",true)
                inst.order = 3
            elseif main.numcount == 4 then
                inst.AnimState:PlayAnimation("four_pre")
                inst.AnimState:PushAnimation("four",true)
                inst.order = 4
            elseif main.numcount == 5 then
                inst.AnimState:PlayAnimation("five_pre")
                inst.AnimState:PushAnimation("five",true)
                inst.order = 5
            elseif main.numcount == 6 then
                inst.AnimState:PlayAnimation("six_pre")
                inst.AnimState:PushAnimation("six",true)
                inst.order = 6
            elseif main.numcount == 7 then
                inst.AnimState:PlayAnimation("seven_pre")
                inst.AnimState:PushAnimation("Seven",true)
                inst.order = 7
            elseif main.numcount == 8 then
                inst.AnimState:PlayAnimation("eight_pre")
                inst.AnimState:PushAnimation("eight",true)
                inst.order = 8
            end
            inst.set= true
            testforcompletion(main)
        end
        if main.failed and not main.busy then
            inst:smallOff(failed ~= main.failed )
        end
    end
end

local function mainfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("archive_orchestrina_main")
    inst.AnimState:SetBank("archive_orchestrina_main")
    inst.AnimState:PlayAnimation("big_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    inst:AddTag("archive_orchestrina_main")

    inst.MiniMapEntity:SetIcon("archive_orchestrina_main.png")

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.status = "off"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0,function()
        local base = SpawnPrefab("archive_orchestrina_base")
        local x,y,z = inst.Transform:GetWorldPosition()
        base.Transform:SetPosition(x,y,z)
    end)

    inst.task = inst:DoPeriodicTask(0.10, function()
        local archive = TheWorld.components.archivemanager
        if not archive or archive:GetPowerSetting() then
            testforlockbox(inst)
        end
    end)
    inst.testforlockbox = testforlockbox

    return inst
end

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("archive_orchestrina_main")
    inst.AnimState:SetBank("archive_orchestrina_main")
    inst.AnimState:PlayAnimation("floor_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function smallfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("archive_orchestrina_main")
    inst.AnimState:SetBank("archive_orchestrina_main")
    inst.AnimState:PlayAnimation("small_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("resonator_socket")

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst:DoTaskInTime(0,function()
        local x,y,z = inst.Transform:GetWorldPosition()
        local main = TheSim:FindEntities(x,y,z, 10, OCHESTRINA_MAIN_MUST)[1]
        if main then
            local mx,my,mz = main.Transform:GetWorldPosition()
            local angle = inst:GetAngleToPoint(mx,my,mz)
            angle = angle -180
            inst.Transform:SetRotation(angle)
        end
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.task = inst:DoPeriodicTask(0.10, function()
        local archive = TheWorld.components.archivemanager
        if not archive or archive:GetPowerSetting() then
            testforplayers(inst)
        end
    end)
    inst.smallOff = smallOff

    return inst
end

return Prefab("archive_orchestrina_main", mainfn, assets, prefabs),
       Prefab("archive_orchestrina_small", smallfn, assets),
       Prefab("archive_orchestrina_base", basefn, assets)
