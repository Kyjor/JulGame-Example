module Platformer 
    using JulGame
    using JulGame.Math

    function run()
        JulGame.MAIN = JulGame.Main(Float64(1.0))
        JulGame.PIXELS_PER_UNIT = 16
        scene = SceneBuilderModule.Scene("scene.json")
        SceneBuilderModule.load_and_prepare_scene(scene, "JulGame Example", false, Vector2(1280, 720),Vector2(576, 576), true, 1.0, true, 120)
    end

    julia_main() = run()
end
# Uncomment to allow for direct execution of this file. If you want to build this project with PackageCompiler, comment the line below
Platformer.run()