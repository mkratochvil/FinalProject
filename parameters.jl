branches = ["A1","A2","A3","A4","A5","A6","A7","A8","A9","A10","A11","A12-1","A13-2","A14","A15","A16","A17","A18",
    "A19","A20","A21","A22","A23","A24","A25-1","A25-2","A26","A27","A28","A29","A30","A31-1","A31-2","A32-1","A32-2",
    "A33-1","A33-2","A34"]

buses = [101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124];

wind_buses = [103,109,117,122];

timesteps = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24];

gens = ["101_CT_1","101_CT_2","101_STEAM_3","101_STEAM_4","102_CT_1","102_CT_2","102_STEAM_3","102_STEAM_4",
    "107_CC_1","113_CT_1","113_CT_2","113_CT_3","113_CT_4","115_STEAM_1","115_STEAM_2","115_STEAM_3","116_STEAM_1",
    "118_CC_1","123_STEAM_2","123_STEAM_3","123_CT_1","123_CT_4","123_CT_5","121_NUCLEAR_1"];

#storage parameters (likely outdated)
rhol = 0.2
rhou = 0.8
pr_cost = 500000 #$/mW
er_cost = 20000 #$/mWh
expansion_budget = 20000000 #20 million dollar budget)

#ercot wind/load max
wmaxdict = Dict(103 => 300.5, 109 => 112.5, 117 => 206.345, 122 => 502.135)
#const wmax103 = 300.5
#const wmax109 = 112.5
#const wmax117 = 206.345
#const wmax122 = 502.135
lmax = 74665.57949

#used this on accident for initial experiments whoops
wmax = 443.52

#rts wind/load max
wrtsdict = Dict(103 => 847.0, 109 => 148.3, 117 => 799.1, 122 => 713.5)
#const wrts103 = 847.0
#const wrts109 = 148.3
#const wrts117 = 799.1
#const wrts122 = 713.5
lrts = 2850.0
