function EoM.ltiplot(
    obj::EoM.lti_soln,
    data::Union{Matrix{Float64},Vector{Float64}}=zeros(length(obj.t), 0),
    t::Union{Vector{Float64},StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64},Int64}}=obj.t;
    yidx::Union{Vector{Int},StepRange{Int,Int},Colon}=:,
    uidx::Union{Vector{Int},StepRange{Int,Int},Colon}=:,
    sidx::Union{Vector{String},Nothing}=nothing,
    aidx::Union{Vector{String},Nothing}=nothing,
    label::Union{Array{String},Nothing}=nothing,
    xlabel::String="Time [s]",
    ylabel::Union{String,Nothing}=nothing,
    lw::Int=2,
    size::Tuple{Int,Int}=(800, 400),
    scale::Int=0,
    kwargs...)

    if !isnothing(sidx)
        yidx = get.([obj.sys_data.sidx], sidx, 0)
    end

    if !isnothing(aidx)
        uidx = get.([obj.sys_data.aidx], aidx, 0)
    end

    if yidx != [0]
        snames = obj.sys_data.snames[yidx]
        sunits = obj.sys_data.sunits[yidx]
        sdesc = obj.sys_data.sdesc[yidx]
    else
        snames = String[]
        sunits = String[]
        sdesc = String[]
        yidx = []
    end

    if uidx != [0]
        anames = obj.sys_data.anames[uidx]
        aunits = obj.sys_data.aunits[uidx]
        adesc = obj.sys_data.adesc[uidx]
    else
        anames = String[]
        aunits = String[]
        adesc = String[]
        uidx = []
    end

    if isnothing(label)
        label = reshape([sdesc .* " " .* snames; adesc .* " " .* anames], 1, :)
    else
        label = [reshape([sdesc .* " " .* snames; adesc .* " " .* anames], 1, :) label]
    end
    if isnothing(ylabel)
        ylabel = join([snames .* " [" .* ["$i" for i in sunits] .* "]"; anames .* " [" .* ["$i" for i in aunits] .* "]"], ", ")
    elseif ylabel[1] == ','
        ylabel = join([snames .* " [" .* ["$i" for i in sunits] .* "]"; anames .* " [" .* ["$i" for i in aunits] .* "]"], ", ") * ylabel
    end

    if scale == 0
        scale = Int(round(length(t) / 2000))
    end
    scale < 1 && (scale = 1)

    Plots.plot(t[1:scale:end], [hcat(obj.y...)'[1:scale:end, yidx] hcat(obj.u...)'[1:scale:end, uidx] data[1:scale:end, :]]; xlabel, ylabel, label, lw, size, kwargs...)

end
