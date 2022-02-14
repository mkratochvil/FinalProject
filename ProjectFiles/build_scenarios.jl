
using JuMP
using DataFrames
using CSV
using DataFrames
using Random

## make sure these files and their dependencies are in their proper place ##
include("./parameters.jl")
include("./get_functions.jl")
include("./modification_functions.jl")
##

### Adjust this as needed ### 
scenarios = collect(DataFrame(CSV.File("./scenarios/strat133.csv"))[1,:])
###

## upload these to cluster ##
loaddf = DataFrame(CSV.File("loaddata.csv"))
winddf = DataFrame(CSV.File("winddata.csv"))
##

lmax = 0.0
wmax = 0.0
for i = 1:24
    println(i, " ", maximum(loaddf[:,2+i]))
    if maximum(loaddf[:,2+i]) > lmax
        lmax = maximum(loaddf[:,2+i])
    end
    println(maximum(winddf[:,2+i]))
    if maximum(winddf[:,2+i]) > wmax
        wmax = maximum(winddf[:,2+i])
    end
end

loaddis = load_distribution_dict(loadcsv);

## make sure this is uploaded with everything ## 
ptdfdf = DataFrame(CSV.File("./ptdfsmall.csv"));
##
ptdfdict = Dict()

for i = 1:38
    br = ptdfdf[i,1]
    ptdfdict[br] = Dict()
    for j = 2:25
        bus = parse(Int64,names(ptdfdf)[j])
        ptdfdict[br][bus] = ptdfdf[i,j]
    end
end

model = JuMP.read_from_file("./storage_expansion_revised/second_stage/noint_PR_exp3_scen_1.mps")

n = size(winddf[:,1],1)
lrts = 2850.0
wrts = 713.5

for i = 1:12#n
    ## change this to nfsscratch location for models ##
    file = "./storage_expansion_revised/ercot/PR_exp3_scen_$(scenarios[i]).mps"
    ##
    if isfile(file)
        println("Scenario $(scenarios[i]) already exists. Skipping its creation.")
    else
        println("Creating scenario $(scenarios[i])")
        wind = (1/wmax)*(wrts/100)*collect(winddf[scenarios[i],3:26])
        load = (1/lmax)*(1.35*lrts/100)*collect(loaddf[scenarios[i],3:26])
        
        for bus in buses
            lf = loaddis[bus]
            for ts in timesteps
                con = get_load_balance(model, bus, ts)
                oldval = JuMP.constraint_object(con).set.value
                lval = load[ts]
                JuMP.set_normalized_rhs(con, lf*lval)
                newval = JuMP.constraint_object(con).set.value
                #println("$(name(con)), $(oldval), $(newval)")
            end
        end
        
        # change ptdf constraint (remember to run load changes FIRST)
        for ts in timesteps
            for br in branches
                ptdfcon = get_ptdf_con(model,br,ts)

                valold = JuMP.constraint_object(ptdfcon).set.value
                valnew = 0.0
                for bus in buses
                    buscon = get_load_balance(model,bus,ts)

                    loadcon = copy(JuMP.constraint_object(buscon).func)
                    loadval = copy(JuMP.constraint_object(buscon).set.value)

                    valnew -= ptdfdict[br][bus]*loadval

                end 

                JuMP.set_normalized_rhs(ptdfcon, valnew)
                #println("$(JuMP.name(ptdfcon)), $(valold), $(valnew)")

            end
        end
        
        bus = 122
        for ts in timesteps
            con = get_wind_ub(model, bus, ts)
            oldval = JuMP.constraint_object(con).set.upper
            wval = wind[ts]
            JuMP.set_normalized_rhs(con, wval)
            newval = JuMP.constraint_object(con).set.upper
            #println("$(name(con)), $(oldval), $(newval)")
        end
        
        JuMP.write_to_file(model, file)
    end
end


