using JulGame.Macros
using JulGame.MainLoop
using JulGame.SoundSourceModule

mutable struct PlayerMovement
    animator
    blockedSpaces
    canMove
    gameManager
    input
    isFacingRight
    isJump 
    jumpSound
    parent
    timeBetweenMoves
    timer

    function PlayerMovement()
        this = new()

        this.canMove = false
        this.input = C_NULL
        this.isFacingRight = true
        this.isJump = false
        this.parent = C_NULL
        this.jumpSound = SoundSourceModule.SoundSource(joinpath(pwd(),"..",".."), "Jump.wav", 1, 50)
        this.gameManager = MAIN.scene.entities[1].scripts[1]
        this.timeBetweenMoves = 1.0/6.0
        this.timer = 0.0
        this.blockedSpaces = Dict(
            "7x4"=> true,
            "1x11"=> true,
            "12x10"=> true,
            "4x7"=> true,
            "5x7"=> true,
            "6x7"=> true,
            "8x6"=> true,
            "9x6"=> true,
            "10x6"=> true,
            "7x9"=> true,
            "8x9"=> true,
            "9x9"=> true)
        
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
            input = MAIN.input
            currentPosition = this.parent.getTransform().position
            # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
            # https://wiki.libsdl.org/SDL2/SDL_Scancode
            # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
            if input.getButtonHeldDown("A") && this.canMove
                if input.getButtonPressed("A") && this.canPlayerMoveHere(JulGame.Math.Vector2f(currentPosition.x - 1, currentPosition.y))
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x - 1, currentPosition.y)
                end
                if this.isFacingRight
                    this.isFacingRight = false
                    this.parent.getSprite().flip()
                end
            elseif input.getButtonHeldDown("D") && this.canMove
                if input.getButtonPressed("D")  && this.canPlayerMoveHere(JulGame.Math.Vector2f(currentPosition.x + 1, currentPosition.y))
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x + 1, currentPosition.y)
                end
                if !this.isFacingRight
                    this.isFacingRight = true
                    this.parent.getSprite().flip()
                end
            elseif input.getButtonHeldDown("W") && this.canMove
                if input.getButtonPressed("W") && this.canPlayerMoveHere(JulGame.Math.Vector2f(currentPosition.x, currentPosition.y - 1))
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x, currentPosition.y - 1)
                end
            elseif input.getButtonHeldDown("S") && this.canMove
                if input.getButtonPressed("S") && this.canPlayerMoveHere(JulGame.Math.Vector2f(currentPosition.x, currentPosition.y + 1))
                    this.parent.getTransform().position = JulGame.Math.Vector2f(currentPosition.x, currentPosition.y + 1)
                end
            end

            this.timer += deltaTime
            if this.timer >= this.timeBetweenMoves
                this.canMove = true
            end

            this.isJump = false
        end
    elseif s == :canPlayerMoveHere
        function(nextPosition)
            if nextPosition.x > -5 && nextPosition.x < 9 && nextPosition.y > 0 && nextPosition.y < 9 && !(haskey(this.blockedSpaces, "$(Int(nextPosition.x) + 5)x$(Int(nextPosition.y) + 3)"))
                this.canMove = false
                this.timer = 0.0
                this.gameManager.updatePos(nextPosition)
                return true
            end

            return false
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