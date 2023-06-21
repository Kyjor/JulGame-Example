using julGame.Macros
using julGame.MainLoop

mutable struct PlayerMovement
    canMove
    input
    isFacingRight
    isJump 
    parent

    function PlayerMovement()
        this = new()
        
        this.canMove = false
        this.input = C_NULL
        this.isFacingRight = true
        this.isJump = false
        this.parent = C_NULL

        return this
    end
end

function Base.getproperty(this::PlayerMovement, s::Symbol)
    if s == :initialize
        function()
            println("PlayerMovement initialize")
            event = @event begin
                this.jump()
            end
            MAIN.scene.camera.target = this.parent.getTransform()
        end
    elseif s == :update
        function(deltaTime)
            this.canMove = true
            x = 0
            speed = 5
            input = MAIN.input
            y = this.parent.getRigidbody().getVelocity().y

            if (input.getButtonPressed("SPACE")|| this.isJump) && this.parent.getRigidbody().grounded && this.canMove
                this.parent.getRigidbody().grounded = false
                y = -5.0
            end
            if input.getButtonHeldDown("A") && this.canMove
                x = -speed
                if this.isFacingRight
                    this.isFacingRight = false
                    this.parent.getSprite().flip()
                end
            elseif input.getButtonHeldDown("D") && this.canMove
                x = speed
                if !this.isFacingRight
                    this.isFacingRight = true
                    this.parent.getSprite().flip()
                end
            end
            
            this.parent.getRigidbody().setVelocity(Vector2f(x, y))
            x = 0
            this.isJump = false
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
            collisionEvent = @event begin
                this.handleCollisions()
            end
            this.parent.getComponent(Collider).addCollisionEvent(collisionEvent)
        end
    elseif s == :handleCollisions
        function()
            return
            collider = this.parent.getComponent(Collider)
            for collision in collider.currentCollisions
                if collision.tag == "ground"
                end
            end
        end
    else
        try
            getfield(this, s)
        catch e
            println(e)
        end
    end
end