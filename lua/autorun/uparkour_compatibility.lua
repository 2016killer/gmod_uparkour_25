hook.Add('ShouldDisableLegs', 'UPExtGmodLegs3Compat', function()
	if VMLegs and VMLegs:IsActive() then
		return true
	end
end)


hook.Add('CalcMainActivity', 'upar.effect.WOS', function(ply, velocity)
	local anim = ply:GetNWString('UP_WOS')
	if anim == '' then
		return
	end

	return -1, ply:LookupSequence(anim)
end)
