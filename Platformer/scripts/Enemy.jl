using JulGame.Macros

mutable struct Enemy
    animator
    isFacingRight
    parent

    function Enemy()
        this = new()
        
        this.parent = C_NULL

        return this
    end
end

function Base.getproperty(this::Enemy, s::Symbol)
    if s == :initialize
        function()
            this.animator = this.parent.animator
            this.animator.currentAnimation = this.animator.animations[1]
            this.animator.currentAnimation.animatedFPS = 2
            this.parent.sprite.isFlipped = true
        end
    elseif s == :update
        function(deltaTime)
           
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
            collisionEvent = @argevent (col) this.handleCollisions(col)

            Component.add_collision_event(this.parent.collider, collisionEvent)
        end
    elseif s == :handleCollisions
        function(otherCollider)
            if otherCollider.tag == "ground"
            end
        end
    else
        getfield(this, s)
    end
end