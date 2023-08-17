using JulGame.Macros
using JulGame.MainLoop
using JulGame.SoundSourceModule

mutable struct PlayerMovement
    animator
    canMove
    gameManager
    input
    isFacingRight
    isJump 
    jumpSound
    parent


    function PlayerMovement()
        this = new()

        this.canMove = false
        this.input = C_NULL
        this.isFacingRight = true
        this.isJump = false
        this.parent = C_NULL
        this.jumpSound = SoundSourceModule.SoundSource(joinpath(pwd(),"..",".."), "Jump.wav", 1, 50)
        this.gameManager = MAIN.scene.entities[1].scripts[1]

        return this
    end
end

function Base.getproperty(this::PlayerMovement, s::Symbol)
    if s == :initialize
        function()
            this.animator = this.parent.getAnimator()
            this.animator.currentAnimation = this.animator.animations[1]
            this.animator.currentAnimation.animatedFPS = 0
        end
    elseif s == :update
        function(deltaTime)
            this.canMove = true
            input = MAIN.input
            currentPosition = this.parent.getTransform().position
            # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
            # https://wiki.libsdl.org/SDL2/SDL_Scancode
            # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
            if input.getButtonHeldDown("A") && this.canMove
                if input.getButtonPressed("A") && currentPosition.x > -4
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x - 1, currentPosition.y)
                end
                if this.isFacingRight
                    this.isFacingRight = false
                    this.parent.getSprite().flip()
                end
            elseif input.getButtonHeldDown("D") && this.canMove
                if input.getButtonPressed("D") && currentPosition.x < 8
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x + 1, currentPosition.y)
                end
                if !this.isFacingRight
                    this.isFacingRight = true
                    this.parent.getSprite().flip()
                end
            elseif input.getButtonHeldDown("W") && this.canMove
                if input.getButtonPressed("W") && currentPosition.y > 1
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x, currentPosition.y - 1)
                end
            elseif input.getButtonHeldDown("S") && this.canMove
                if input.getButtonPressed("S") && currentPosition.y < 8
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x, currentPosition.y + 1)
                end
            end
            
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
                if collision.tag == "coin"
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