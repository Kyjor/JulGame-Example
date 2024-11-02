module PlayerMovementModule
    using ..JulGame
    using ..JulGame.AnimatorModule
    using ..JulGame.Math

    mutable struct PlayerMovement
        animator
        bullet
        bulletTime::Float64
        canMove::Bool
        deathSound
        gun::Bool
        input
        isFacingRight::Bool
        isJump::Bool
        scoreText
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
            this.deathSound = nothing
            this.shootSound = nothing
            this.scoreText = nothing
            this.xDir = 0
            this.yDir = 0
            return this
        end
    end

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
        this.deathSound = JulGame.SoundSourceModule.InternalSoundSource(this.parent, "Death.wav")
        this.scoreText = MAIN.scene.uiElements[1]
    end

    function JulGame.update(this::PlayerMovement, deltaTime)
        this.canMove = true
        speed = 5
        input = MAIN.input
        animIndex = this.gun ? 2 : 1
        moveAnims = this.animator.animations[animIndex]

        if ((JulGame.InputModule.get_button_pressed(MAIN.input, "SPACE") || input.button == 1) || this.isJump) && this.parent.rigidbody.grounded && this.canMove
            this.animator.currentAnimation = moveAnims
            this.animator.currentAnimation.animatedFPS = 0
            AnimatorModule.force_frame_update(this.animator, 2)
            JulGame.Component.toggle_sound(this.parent.soundSource)
            RigidbodyModule.add_velocity(this.parent.rigidbody, Vector2f(0, -5))
        end

        x = handle_movement(this, input, speed, moveAnims)

        if this.gun && JulGame.InputModule.get_button_pressed(MAIN.input, "F") && !this.bullet.isActive
            shoot_bullet(this)
        end

        RigidbodyModule.set_velocity(this.parent.rigidbody, Vector2f(x, this.parent.rigidbody.velocity.y))
        
        if this.bullet.isActive
            this.bulletTime += deltaTime
            bullet_update(this, deltaTime)
            if this.bulletTime >= 1.5
                this.bullet.isActive = false
            end
        end

        if this.parent.transform.position.y > 8
            this.parent.transform.position = Vector2f(1, 4)
        end
    end

    function handle_movement(this::PlayerMovement, input, speed, moveAnims)
        x = 0
        if ((JulGame.InputModule.get_button_held_down(MAIN.input, "A") || input.xDir == -1) || (JulGame.InputModule.get_button_held_down(MAIN.input, "D") || input.xDir == 1)) && this.canMove
            this.animator.currentAnimation = moveAnims
            AnimatorModule.force_frame_update(this.animator, 2)
            x = (JulGame.InputModule.get_button_held_down(MAIN.input, "D") || input.xDir == 1) ? speed : -speed
            this.animator.currentAnimation.animatedFPS = this.parent.rigidbody.grounded ? 5 : this.animator.currentAnimation.animatedFPS
            
            if (x > 0 && !this.isFacingRight) || (x < 0 && this.isFacingRight)
                this.isFacingRight = !this.isFacingRight
                JulGame.Component.flip(this.parent.sprite)
            end
        else
            this.animator.currentAnimation.animatedFPS = this.parent.rigidbody.grounded ? 0 : this.animator.currentAnimation.animatedFPS
            AnimatorModule.force_frame_update(this.animator, 1)
        end
        return x
    end

    function shoot_bullet(this::PlayerMovement)
        this.bulletTime = 0.0
        offset = this.isFacingRight ? 1 : -1
        this.bullet.sprite.isFlipped = !this.isFacingRight

        this.bullet.transform.position = Vector2f(this.parent.transform.position.x + offset, this.parent.transform.position.y)
        this.animator.currentAnimation = this.animator.animations[3]
        this.bullet.isActive = true  
        JulGame.Component.toggle_sound(this.shootSound)
    end

    function JulGame.on_shutdown(this::PlayerMovement)
    end 

    function handle_collisions(this::PlayerMovement, event)
        col = event.collider
        if col.tag == "gun" && !this.gun
            JulGame.destroy_entity(MAIN, col.parent)
            this.animator.currentAnimation = this.animator.animations[2]
            this.gun = true
        end
    end

    function handle_bullet_collisions(this::PlayerMovement, event)
        col = event.collider
        if col.tag != "Player"
            this.bullet.isActive = false
            this.bulletTime = 0.0
        end

        if col.tag == "Enemy"
            JulGame.destroy_entity(MAIN, col.parent) 
            JulGame.Component.toggle_sound(this.deathSound)
            score = parse(Int, this.scoreText.text) + 1
            this.scoreText.text = "$(score)"
        end
    end

    function bullet_update(this::PlayerMovement, deltaTime)
       speed = this.bullet.sprite.isFlipped ? -5 : 5
       this.bullet.transform.position = Vector2f(this.bullet.transform.position.x + speed * deltaTime, this.bullet.transform.position.y) 
    end
end # module
