module Scripts
    const _SCRIPTS_DIR = joinpath(@__DIR__, "..", "scripts")
    _script_files = filter(contains(r".jl$"), readdir(_SCRIPTS_DIR; join=true))
    include.(_script_files)
end
