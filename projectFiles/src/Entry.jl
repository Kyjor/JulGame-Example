module Entry 
    using JulGame
    using JulGame.Math
    using JulGame.SceneBuilderModule

    function run()
        dir = @__DIR__
        #dir = pwd()
        scene = Scene(joinpath(dir, ".."), "scene.json")
        main = scene.init(false, Vector2(1280, 720), 2.0)
        return main
    end

    julia_main() = run()
end
# Uncommented to allow for direct execution of this file. If you want to build this project with PackageCompiler, comment the line below
Entry.run()