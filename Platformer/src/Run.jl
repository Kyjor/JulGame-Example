# `using Platformer` needs this project's env so the pkgimage cache is used.
if Base.JLOptions().project == C_NULL && get(ENV, "PLATFORMER_SKIP_PROJECT_REEXEC", "0") != "1"
    env = copy(ENV)
    env["PLATFORMER_SKIP_PROJECT_REEXEC"] = "1"
    project = abspath(joinpath(@__DIR__, ".."))
    script = abspath(PROGRAM_FILE)
    run(setenv(`$(Base.julia_cmd()) --project=$(project) $(script) $(ARGS)`, env))
    exit()
end

if get(ENV, "PLATFORMER_DEV", "0") == "1"
    include(joinpath(@__DIR__, "Platformer.jl"))
    using .Platformer
else
    using Platformer
end

Platformer.julia_main()
