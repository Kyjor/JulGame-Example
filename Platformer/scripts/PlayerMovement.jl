module PlayerMovementModule
    using ..JulGame
    using ..JulGame.AnimatorModule
    using ..JulGame.Math

    mutable struct PlayerMovement
        animator
        bullet
        bulletTime::Float64
        canMove::Bool
        gun::Bool
        input
        isFacingRight::Bool
        isJump::Bool
        shootSound
        parent

        xDir::Int
        yDir::Int

        function PlayerMovement()
            this = new()

            this.canMove = false
            this.gun = false
            this.input = C_NULL
            this.isFacingRight = true
            this.isJump = false
            this.parent = C_NULL
            this.bulletTime = 0.0
            this.shootSound = nothing

            this.xDir = 0
            this.yDir = 0

            return this
        end
    end

    # This is called when a scene is loaded, or when script is added to an entity
    # This is where you should register collision events or other events
    # Do not remove this function
    function JulGame.initialize(this::PlayerMovement)
        collisionEvent = JulGame.Macros.@argevent (col) handle_collisions(this, col)
        JulGame.Component.add_collision_event(this.parent.collider, collisionEvent)

        MAIN.scene.camera.target = this.parent.transform
        this.animator = this.parent.animator
        this.animator.currentAnimation.animatedFPS = 0
        this.bullet = JulGame.SceneModule.get_entity_by_id(MAIN.scene, "e77df85a-30e2-4c11-af06-699e0866e439")
        bulletCollisionEvent = JulGame.Macros.@argevent (col) handle_bullet_collisions(this, col)
        JulGame.Component.add_collision_event(this.bullet.collider, bulletCollisionEvent)
        this.shootSound = JulGame.SoundSourceModule.InternalSoundSource(this.parent, "LaserShoot.wav")
    end

    # This is called every frame
    # Do not remove this function
    function JulGame.update(this::PlayerMovement, deltaTime)
        this.canMove = true
        x = 0
        speed = 5
        input = MAIN.input
        animIndex = this.gun ? 2 : 1
        moveAnims = this.animator.animations[animIndex]
        # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
        # https://wiki.libsdl.org/SDL2/SDL_Scancode
        # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
        if ((JulGame.InputModule.get_button_pressed(MAIN.input,  "SPACE")  || input.button == 1)|| this.isJump) && this.parent.rigidbody.grounded && this.canMove 
            this.animator.currentAnimation = moveAnims
            this.animator.currentAnimation.animatedFPS = 0
            AnimatorModule.force_frame_update(this.animator, 2)
            JulGame.Component.toggle_sound(this.parent.soundSource)
            RigidbodyModule.add_velocity(this.parent.rigidbody, Vector2f(0, -5))
        end
        if (JulGame.InputModule.get_button_held_down(MAIN.input,  "A") || input.xDir == -1) && this.canMove
            this.animator.currentAnimation = moveAnims
            if JulGame.InputModule.get_button_pressed(MAIN.input,  "A")
                AnimatorModule.force_frame_update(this.animator, 2)
            end
            x = -speed
            if this.parent.rigidbody.grounded
                this.animator.currentAnimation.animatedFPS = 5
            end
            if this.isFacingRight
                this.isFacingRight = false
                JulGame.Component.flip(this.parent.sprite)
            end
        elseif (JulGame.InputModule.get_button_held_down(MAIN.input,  "D")  || input.xDir == 1) && this.canMove
            this.animator.currentAnimation = moveAnims
            if JulGame.InputModule.get_button_pressed(MAIN.input,  "D")
                AnimatorModule.force_frame_update(this.animator, 2)
            end
            if this.parent.rigidbody.grounded
                this.animator.currentAnimation.animatedFPS = 5
            end
            x = speed
            if !this.isFacingRight
                this.isFacingRight = true
                JulGame.Component.flip(this.parent.sprite)
            end
        elseif this.parent.rigidbody.grounded
            this.animator.currentAnimation.animatedFPS = 0
            AnimatorModule.force_frame_update(this.animator, 1)
        end

        if this.gun && JulGame.InputModule.get_button_pressed(MAIN.input, "F") && !this.bullet.isActive
            this.bulletTime = 0.0
            offset = 1
            if this.isFacingRight
                this.bullet.sprite.isFlipped = false
            else
                offset = -1
                this.bullet.sprite.isFlipped = true 
            end

            this.bullet.transform.position = Vector2f(this.parent.transform.position.x + offset, this.parent.transform.position.y)
            this.animator.currentAnimation = this.animator.animations[3]
            this.bullet.isActive = true  
            JulGame.Component.toggle_sound(this.shootSound)
        end
        
        RigidbodyModule.set_velocity(this.parent.rigidbody, Vector2f(x, this.parent.rigidbody.velocity.y))
        x = 0
        this.isJump = false
        if this.parent.transform.position.y > 8
            this.parent.transform.position = Vector2f(1, 4)
        end

        if this.bullet.isActive
            this.bulletTime += deltaTime
            bullet_update(this, deltaTime)
            if this.bulletTime >= 3.0
                this.bulletTime = 0.0
                this.bullet.isActive = false
            end
        end
    end

    # This is called when the script is removed from an entity (scene change, entity deletion)
    # Do not remove this function
    function JulGame.on_shutdown(this::PlayerMovement)
    end 

    function handle_collisions(this::PlayerMovement, event)
        col = event.collider
        if col.tag == "gun" && this.gun === false 
            JulGame.destroy_entity(MAIN, col.parent)
            this.animator.currentAnimation = this.animator.animations[2]
            this.gun = true
        end
    end

    function handle_bullet_collisions(this::PlayerMovement, event)
        col = event.collider
        if col.tag == "Player"
            println("Hit player")
        else 
            this.bullet.isActive = false
            this.bulletTime = 0.0
        end

        if col.tag == "Enemy"
            JulGame.destroy_entity(MAIN, col.parent) 
        end
    end

    function bullet_update(this::PlayerMovement, deltaTime)
       speed = this.bullet.sprite.isFlipped ? -5 : 5
       this.bullet.transform.position = Vector2f(this.bullet.transform.position.x + speed * deltaTime, this.bullet.transform.position.y) 
    end
end # module
