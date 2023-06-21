#module Entry
    using julGame.SceneBuilderModule
    using SimpleDirectMediaLayer
    const SDL2 = SimpleDirectMediaLayer 

    #function run()
        SDL2.init()
        dir = pwd()
        main = Scene(joinpath(dir, "..", ".."), "scene.json")
        return main.init()
    #end

    #julia_main() = run()
#end