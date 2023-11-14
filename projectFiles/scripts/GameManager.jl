using JulGame.MainLoop 
using JulGame.Math
using JulGame.UI

mutable struct GameManager
    parent

    function GameManager()
        this = new()

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            MAIN.cameraBackgroundColor = [252, 223, 205]
            push!(MAIN.scene.screenButtons, ScreenButtonModule.ScreenButton(joinpath(pwd(),".."), "ButtonUp.png", "ButtonDown.png", Vector2(256, 64), Vector2(), "test"))
        end
    elseif s == :update
        function(deltaTime)
        end
    elseif s == :setParent 
        function(parent)
            this.parent = parent
        end
    else
        getfield(this, s)
    end
end