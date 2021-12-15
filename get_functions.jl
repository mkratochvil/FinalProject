# Constraints

function get_storage_balance(model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Sbal_{",string(bus),",",string(timestep),"}"))
end

function get_load_balance(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Dbal_{",string(bus),",",string(timestep),"}"))
end

function get_ptdf_con(model::JuMP.Model, branch::String, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("PTDF_{", branch, ",", string(timestep), "}"))
end

# note this may have to change if we add wind expansion
function get_wind_lb(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Wlb_{",string(bus),",",string(timestep),"}"))
end

#Note this indexes from  2:24, since there is no ramping at the first timestep
function get_ramp_lb(model::JuMP.Model, gen::String, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Rlb_{",string(gen),",",string(timestep),"}"))
end

function get_charge_lb(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Clb_{",string(bus),",",string(timestep),"}"))
end

function get_discharge_lb(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Dlb_{",string(bus),",",string(timestep),"}"))
end

function get_storage_lb(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Elb_{",string(bus),",",string(timestep),"}"))
end

function get_loss_of_load_lb(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Llb_{",string(bus),",",string(timestep),"}"))
end

function get_overload_lb(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Olb_{",string(bus),",",string(timestep),"}"))
end

# note this may have to change if we add wind expansion
function get_wind_ub(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Wub_{",string(bus),",",string(timestep),"}"))
end

#Note this indexes from  2:24, since there is no ramping at the first timestep
function get_ramp_ub(model::JuMP.Model, gen::String, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Rub_{",string(gen),",",string(timestep),"}"))
end

function get_charge_ub(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Cub_{",string(bus),",",string(timestep),"}"))
end

function get_discharge_ub(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Dub_{",string(bus),",",string(timestep),"}"))
end

function get_storage_ub(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Eub_{",string(bus),",",string(timestep),"}"))
end

function get_thermal_interval(model::JuMP.Model, gen::String, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Tint_{",gen,",",string(timestep),"}"))
end

function get_branch_interval(model::JuMP.Model, branch::String, timestep::Int64)
    
    return JuMP.constraint_by_name(model, string("Bint_{",branch,",",string(timestep),"}"))
end

#1st stage constraint
function get_ER_lb(model::JuMP.Model, bus::Int64)
    
    return JuMP.constraint_by_name(model, "ER_lb_{$(bus)}")  
end

#1st stage constraints
function get_ER_ub(model::JuMP.Model, bus::Int64)
    
    return JuMP.constraint_by_name(model, "ER_ub_{$(bus)}")  
end

#1st stage constraints 
function get_PR_lb(model::JuMP.Model, bus::Int64)
    
    return JuMP.constraint_by_name(model, "PR_lb_{$(bus)}")  
end


# Variables

function get_line_variable(model::JuMP.Model, branch::String, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("Fbr_{",branch,",",timestep,"}"))
end

function get_thermal_variable(model::JuMP.Model, gen::String, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("Pth_{", gen,",", timestep,"}"))
end

function get_storage_expansion_variable(model::JuMP.Model, bus::Int64)
    
    return JuMP.variable_by_name(model, string("m_EE[",bus,"_STORAGE_1]"))
end

function get_charging_variable(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("Pch_{",bus,"_STORAGE_1",",",timestep,"}"))
end

function get_discharging_variable(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("Pdis_{",bus,"_STORAGE_1",",",timestep,"}"))
end

function get_stored_variable(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("Est_{",bus,"_STORAGE_1",",",timestep,"}"))
end

function get_lossofload_variable(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("LOL_{",bus,",",timestep,"}"))
end

function get_overload_variable(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("OL_{",bus,",",timestep,"}"))
end

#currently only one at bus 122
function get_wind_variable(model::JuMP.Model, bus::Int64, timestep::Int64)
    
    return JuMP.variable_by_name(model, string("Pre_{",bus,"_WIND_1,",timestep,"}"))
end

function get_PR_variable(model::JuMP.Model, bus::Int64)
    
    return JuMP.variable_by_name(model, "PR_{$(bus)}")
end

function get_ER_variable(model::JuMP.Model, bus::Int64)
    
    return JuMP.variable_by_name(model, "ER_{$(bus)}")
end