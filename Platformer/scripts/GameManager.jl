using JulGame.Component 
using JulGame.EntityModule 
using JulGame.Math
using JulGame.UI

mutable struct GameManager
    parent
    test

    function GameManager()
        this = new()

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            MAIN.cameraBackgroundColor = (252, 223, 205)
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