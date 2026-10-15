AddCSLuaFile()

VManip:RegisterAnim('dp_catch_BaiLang', {
    ["model"]='weapons/dp_hand_BaiLang.mdl',
    ["lerp_peak"]=1,
    ["lerp_speed_in"]=12,
    ["lerp_speed_out"]=12,
    ["lerp_curve"]=1,
    ["speed"]=6
})


VMLegs:RegisterAnim('dp_lazy_BaiLang', {
    ["model"]='dp_legs_BaiLang.mdl',
    ["speed"]=1.2,
    ["forwardboost"]=-10,
    ["upwardboost"]=-5
})

VManip:RegisterAnim('dp_catch_mtbntb',
    {
        ["model"]='weapons/dp_hand_mtbntb.mdl',
        ["lerp_peak"]=1,
        ["lerp_speed_in"]=12,
        ["lerp_speed_out"]=12,
        ["lerp_curve"]=1,
        ["speed"]=2
    }
)

VMLegs:RegisterAnim('dp_lazy_mtbntb', 
    {
        ["model"]='dp_legs_mtbntb.mdl',
        ["speed"]=1.5,
        ["forwardboost"]=2,
        ["upwardboost"]=-5
    }
)


VManip:RegisterAnim('horizontalwallrun_YongLi',
    {
        ['model']='weapons/horizontalwallrun_YongLi.mdl',
        ['lerp_peak']=0.265,
        ['lerp_speed_in']=0.5,
        ['lerp_speed_out']=0.5,
        ['lerp_curve']=0.8,
        ['speed']=1,
        ['holdtime']=0.265
    }
)


VManip:RegisterAnim('verticalwallrun',
    {
        ["model"]='mantleanim.mdl',
        ["lerp_peak"]=1,
        ["lerp_speed_in"]=12,
        ["lerp_speed_out"]=12,
        ["lerp_curve"]=1,
        ["speed"]=3,
        ["cam_ang"]=Angle()
    }
)

