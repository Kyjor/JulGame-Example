# commented out to allow for direct execution of this file. If you want to build this project with PackageCompiler, uncomment all of the lines below
#module Entry 
    using JulGame.SceneBuilderModule
    using SimpleDirectMediaLayer
    const SDL2 = SimpleDirectMediaLayer 

    #function run()
        SDL2.init()
        dir = @__DIR__
        #dir = pwd()
        main = Scene(joinpath(dir, "..", ".."), "scene.json")
        return main.init()
    #end

    #julia_main() = run()
#end