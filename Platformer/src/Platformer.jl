module Platformer 
    using JulGame
    using JulGame.Math
    using JulGame.SceneBuilderModule

    function run()
        JulGame.MAIN = JulGame.Main(Float64(1.0))
        JulGame.PIXELS_PER_UNIT = 16
        scene = Scene("scene.json")
        SceneBuilderModule.init(scene, "JulGame Example", false, Vector2(1920, 1080),Vector2(576, 576), true, 1.0, true, 120)
    end

    julia_main() = run()
end
# Uncommented to allow for direct execution of this file. If you want to build this project with PackageCompiler, comment the line below
# Platformer.run()