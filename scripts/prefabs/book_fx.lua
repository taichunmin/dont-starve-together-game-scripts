local function MakeBookFX(name, bankandbuild, anim, failanim, tint, ismount)
	local assets =
	{
		Asset("ANIM", "anim/"..bankandbuild..".zip"),
	}

    local OnFail = failanim ~= nil and function(inst, doer)
        inst.AnimState:PlayAnimation(failanim)
		if doer ~= nil and doer.SoundEmitter ~= nil then
			doer.SoundEmitter:PlaySound("wickerbottom_rework/book_spells/fail")
		end
    end or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        if ismount then
            inst.Transform:SetSixFaced()
        else
            inst.Transform:SetFourFaced()
        end

        inst.AnimState:SetBank(bankandbuild)
        inst.AnimState:SetBuild(bankandbuild)
        inst.AnimState:PlayAnimation(anim)
        --inst.AnimState:SetScale(1.5, 1, 1)
        inst.AnimState:SetFinalOffset(3)
        if tint ~= nil then
            inst.AnimState:SetMultColour(unpack(tint))
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        if failanim ~= nil then
            inst:ListenForEvent("fail_fx", OnFail)
        end

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeBookFX("book_fx", "book_fx_wicker", "book_fx_wicker", "book_fx_fail_wicker", { 1, 1, 1, .4 }, false),
	MakeBookFX("book_fx_mount", "book_fx_wicker", "book_fx_wicker_mount", "book_fx_fail_wicker_mount", { 1, 1, 1, .4 }, true),
	MakeBookFX("waxwell_book_fx", "book_fx", "book_fx", nil, { 0, 0, 0, 1 }, false),
	MakeBookFX("waxwell_book_fx_mount", "book_fx", "book_fx_mount", nil, { 0, 0, 0, 1 }, true),
	MakeBookFX("waxwell_shadow_book_fx", "fx_book_waxwell", "shadowmagic", nil, { 1, 1, 1, .6 }, false),
	MakeBookFX("waxwell_shadow_book_fx_mount", "fx_book_waxwell", "shadowmagic_mount", nil, { 1, 1, 1, .6 }, true)
