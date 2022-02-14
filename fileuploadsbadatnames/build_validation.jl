
using JuMP
using DataFrames
using CSV
using Random
using Gurobi

arrayid = 1

solinfo = DataFrame(CSV.File("./validation_setup.csv"))


variation = solinfo[arrayid, 2]
budget = solinfo[arrayid, 3]
exp = solinfo[arrayid, 4]
nscens = solinfo[arrayid, 5]
mod = solinfo[arrayid, 6]

# put solution vector here
x = solinfo[arrayid, 7:30]

## make sure these files and their dependencies are in their proper place ##
include("./parameters.jl")
include("./get_functions.jl")
include("./modification_functions.jl")
##

## adjust to actual file location
model = JuMP.read_from_file("./storage_expansion_revised/second_stage/noint_PR_exp3_scen_1.mps");
##

scenarios = collect(DataFrame(CSV.File("./scenarios/validation.csv"))[exp,:]);

## upload these to cluster ##
loaddf = DataFrame(CSV.File("loaddata.csv"))
winddf = DataFrame(CSV.File("winddata.csv"))
##

loaddis = load_distribution_dict(loadcsv);

## make sure this is uploaded with everything ## 
ptdfdf = DataFrame(CSV.File("./ptdfsmall.csv"));
##

cd("./validation_results/v$(variation)_b$(budget)_e$(exp)_n$(nscens)_$(mod)/")

lmax = 0.0
wmax = 0.0
for i = 1:24
    if maximum(loaddf[:,2+i]) > lmax
        lmax = maximum(loaddf[:,2+i])
    end
    if maximum(winddf[:,2+i]) > wmax
        wmax = maximum(winddf[:,2+i])
    end
end

ptdfdict = Dict()

for i = 1:38
    br = ptdfdf[i,1]
    ptdfdict[br] = Dict()
    for j = 2:25
        bus = parse(Int64,names(ptdfdf)[j])
        ptdfdict[br][bus] = ptdfdf[i,j]
    end
end

JuMP.set_optimizer(model, Gurobi.Optimizer)
set_optimizer_attribute(model, "OutputFlag", 0) 

cost = 57.62
fscost = 0.0
for i = 1:24
    fscost += cost*x[i]
    JuMP.fix(get_PR_variable(model, 100+i), x[i])
end

n = size(winddf[:,1],1)
lrts = 2850.0
wrts = 713.5

for i = 1:4000
    print("$i ")
    ## change this to nfsscratch location for models ##
    file = "./$(i).txt"
    ##
    if isfile(file)
        println("Scenario $(scenarios[i]) already has been ran. Skipping.")
    else
        println("Running validation on $(scenarios[i])")
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
        
        #JuMP.write_to_file(model, file)
        JuMP.optimize!(model)
        
        infovec = [];
        push!(infovec, scenarios[i])
        push!(infovec, objective_value(model))
        push!(infovec, objective_value(model)-fscost)
        
        #charging aggregate
        for ts in timesteps
            val = 0.0
            for bus in buses
                val += JuMP.value(get_charging_variable(model, bus, ts))
            end
            push!(infovec, val)
        end
        
        #discharging aggregate
        for ts in timesteps
            val = 0.0
            for bus in buses
                val += JuMP.value(get_discharging_variable(model, bus, ts))
            end
            push!(infovec, val)
        end
        
        #state of charge aggregate
        for ts in timesteps
            val = 0.0
            for bus in buses
                val += JuMP.value(get_stored_variable(model, bus, ts))
            end
            push!(infovec, val)
        end
        
        # loss of load aggregate
        for ts in timesteps
            val = 0.0
            for bus in buses
                val += JuMP.value(get_lossofload_variable(model, bus, ts))
            end
            push!(infovec, val)
        end
        
        # overload aggregate
        for ts in timesteps
            val = 0.0
            for bus in buses
                val += JuMP.value(get_overload_variable(model, bus, ts))
            end
            push!(infovec, val)
        end
        
        acsv = string("solution_summary.csv")
    
        vec = string(infovec)
        n = length(vec)

        vec = vec[5:n-1]
        open(acsv, "a") do io
            write(io, "$(vec) \n")
        end
        
        open(file,"a") do io
           println(io,"")
        end
        
    end
end


