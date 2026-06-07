import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";
import { registerScriptSounds } from "julgame/src/engine/runtime/scriptRegistry";
import { isTaskDone, notifyCondition, scheduleTask, waitCondition, yieldTask } from "julgame/src/engine/runtime/coroutineRuntime";


    // using JulGame
    // using (globalThis as any).JulGame.AnimatorModule
    // using (globalThis as any).JulGame.RigidbodyModule
    // using (globalThis as any).JulGame.Math

    export class PlayerMovement {
        animator
        bullet
        bulletTime: number
        canMove: boolean
        deathSound
        gun: boolean
        input
        isFacingRight: boolean
        isJump: boolean
        scoreText
        shootSound
        parent

        xDir: number
        yDir: number

        condition: unknown

        // Add a field to track the knockback coroutine
        knockbackTask: unknown

        constructor() {
            
            this.canMove = false
            this.gun = false
            this.input = null
            this.isFacingRight = true
            this.isJump = false
            this.parent = null
            this.bulletTime = 0.0
            this.deathSound = null
            this.shootSound = null
            this.scoreText = null
            this.xDir = 0
            this.yDir = 0
            this.knockbackTask = null  // Initialize knockback task as null

        }
    }

    function JulGame_initialize_PlayerMovement(self: PlayerMovement) {
        let collisionEvent = (col: any) => handle_collisions(self, col);
        (globalThis as any).JulGame.Component.add_collision_event(self.parent.collider, collisionEvent);

        (globalThis as any).MAIN.scene.camera.target = self.parent.transform
        self.animator = self.parent.animator
        self.animator.currentAnimation.animatedFPS = 0
        self.bullet = (globalThis as any).JulGame.SceneModule.get_entity_by_id((globalThis as any).MAIN.scene, "e77df85a-30e2-4c11-af06-699e0866e439")
        let bulletCollisionEvent = (col: any) => handle_bullet_collisions(self, col);
        (globalThis as any).JulGame.Component.add_collision_event(self.bullet.collider, bulletCollisionEvent)
        self.shootSound = (globalThis as any).JulGame.SoundSourceModule.InternalSoundSource(self.parent, "LaserShoot.wav")
        self.deathSound = (globalThis as any).JulGame.SoundSourceModule.InternalSoundSource(self.parent, "Death.wav")
        self.scoreText = (globalThis as any).MAIN.scene.uiElements[0]
    }

    async function JulGame_update_PlayerMovement(self: PlayerMovement, deltaTime) {
        self.canMove = true
        let speed = 5
        let input = (globalThis as any).MAIN.input
        let animIndex = self.gun ? 2 : 1
        let moveAnims = self.animator.animations[animIndex]

        if ((((globalThis as any).JulGame.InputModule.get_button_pressed((globalThis as any).MAIN.input, "SPACE") || input.button == 1) || self.isJump) && self.parent.rigidbody.grounded && self.canMove) {
            self.animator.currentAnimation = moveAnims
            self.animator.currentAnimation.animatedFPS = 0;
            (globalThis as any).JulGame.AnimatorModule.force_frame_update(self.animator, 2);
            (globalThis as any).JulGame.Component.toggle_sound(self.parent.soundSource);
            (globalThis as any).JulGame.RigidbodyModule.add_velocity(self.parent.rigidbody, {x: 0, y: -5})
        }

        if ((globalThis as any).JulGame.InputModule.get_button_pressed((globalThis as any).MAIN.input, "P")) {
            console.debug("p triggered")
        }

        let x = handle_movement(self, input, speed, moveAnims)

        if (self.gun && (globalThis as any).JulGame.InputModule.get_button_pressed((globalThis as any).MAIN.input, "F") && !self.bullet.isActive) {
            shoot_bullet(self)
        }

        if ((globalThis as any).JulGame.InputModule.get_button_pressed((globalThis as any).MAIN.input, "X") && self.knockbackTask === null) {
            console.log("Knockback triggered")
            self.condition = new (globalThis as any).JulGame.Condition()
            self.knockbackTask = scheduleTask(() => knockback_coroutine(self))
            
        } else if (self.knockbackTask !== null && !isTaskDone(self.knockbackTask)) {
            console.log("Knockback coroutine is still running")
            notifyCondition(self.condition); console.log('knockback waiting', self.condition)
            await yieldTask()
        }
        

        self.parent.rigidbody.velocity = {x: x, y: self.parent.rigidbody.velocity.y}
        
        if (self.bullet.isActive) {
            self.bulletTime += deltaTime
            bullet_update(self, deltaTime)
            if (self.bulletTime >= 1.5) {
                self.bullet.isActive = false
            }
        }

        if (self.parent.transform.position.y > 8) {
            let pos = self.parent.transform.position
            self.parent.transform.position = {x: 1, y: 4, z: pos.z}
        }
    }

    function handle_movement(self: PlayerMovement, input, speed, moveAnims) {
        let x = 0
        if ((((globalThis as any).JulGame.InputModule.get_button_held_down((globalThis as any).MAIN.input, "A") || input.xDir == -1) || ((globalThis as any).JulGame.InputModule.get_button_held_down((globalThis as any).MAIN.input, "D") || input.xDir == 1)) && self.canMove) {
            self.animator.currentAnimation = moveAnims;
            (globalThis as any).JulGame.AnimatorModule.force_frame_update(self.animator, 2)
            x = ((globalThis as any).JulGame.InputModule.get_button_held_down((globalThis as any).MAIN.input, "D") || input.xDir == 1) ? speed : -speed
            self.animator.currentAnimation.animatedFPS = self.parent.rigidbody.grounded ? 5 : self.animator.currentAnimation.animatedFPS
            
            if ((x > 0 && !self.isFacingRight) || (x < 0 && self.isFacingRight)) {
                self.isFacingRight = !self.isFacingRight;
                (globalThis as any).JulGame.Component.flip(self.parent.sprite)
            }
        } else {
            self.animator.currentAnimation.animatedFPS = self.parent.rigidbody.grounded ? 0 : self.animator.currentAnimation.animatedFPS;
            (globalThis as any).JulGame.AnimatorModule.force_frame_update(self.animator, 1)
        }
        return x
    }

    function shoot_bullet(self: PlayerMovement) {
        self.bulletTime = 0.0
        let offset = self.isFacingRight ? 1 : -1
        self.bullet.sprite.isFlipped = !self.isFacingRight

        let pos = self.parent.transform.position
        self.bullet.transform.position = {x: pos.x + offset, y: pos.y, z: pos.z}
        self.animator.currentAnimation = self.animator.animations[2]
        self.bullet.isActive = true;
        (globalThis as any).JulGame.Component.toggle_sound(self.shootSound)
    }

    function JulGame_on_shutdown_PlayerMovement(self: PlayerMovement) {
    } 

    function handle_collisions(self: PlayerMovement, event) {
        let col = event.collider
        if (col.tag == "gun" && !self.gun) {
            (globalThis as any).JulGame.destroy_entity((globalThis as any).MAIN, col.parent)
            self.animator.currentAnimation = self.animator.animations[1]
            self.gun = true
        }
    }

    function handle_bullet_collisions(self: PlayerMovement, event) {
        let col = event.collider
        if (col.tag != "Player") {
            self.bullet.isActive = false
            self.bulletTime = 0.0
        }

        if (col.tag == "Enemy") {
            (globalThis as any).JulGame.destroy_entity((globalThis as any).MAIN, col.parent);
            (globalThis as any).JulGame.Component.toggle_sound(self.deathSound)
            let score = parseInt( self.scoreText.text) + 1
            self.scoreText.text = `${score}`
        }
    }

    function bullet_update(self: PlayerMovement, deltaTime) {
       let speed = self.bullet.sprite.isFlipped ? -5 : 5
       let pos = self.bullet.transform.position
       self.bullet.transform.position = {x: pos.x + speed * deltaTime, y: pos.y, z: pos.z}
    }

    async function knockback_coroutine(self: PlayerMovement) {
        console.log("Knockback coroutine started")
        let knockbackForce = self.isFacingRight ? -3 : 3  
        
        for (let i = 0; i < 10; i++) {
            (globalThis as any).JulGame.RigidbodyModule.add_velocity(self.parent.rigidbody, {x: knockbackForce, y: -1})
            //sleep(.1)  // Pause execution for 0.1 seconds
            //await yieldTask()  // Yield control back to the main loop
            console.log("deltaTime: ", (globalThis as any).JulGame.DELTA_TIME)
            await waitCondition(self.condition)
        }
    
        console.log("Knockback coroutine ended")
        self.knockbackTask = null  // Reset the task to null after completion
    }
    
registerScript("PlayerMovement", {
    create: () => new PlayerMovement(),
    initialize: JulGame_initialize_PlayerMovement,
    update: JulGame_update_PlayerMovement,
    onShutdown: JulGame_on_shutdown_PlayerMovement,
});
registerScriptSounds(["Death.wav", "LaserShoot.wav"]);
