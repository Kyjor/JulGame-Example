proj = Base.JLOptions().project
proj_flag = proj == C_NULL ? "" : unsafe_string(proj)
if isempty(proj_flag)
    println("No --project flag (default/global env)")
    include("Platformer.jl")
    using .Platformer
else
    println("Using --project=$proj_flag")
    using Platformer
end


Platformer.julia_main()
