package;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Boss extends Enemy
{
    public var hp:Int = 3;
    private static inline var BOSS_CHASE_SPEED:Float = 220;
    private static inline var DASH_SPEED:Float = 650;
    
    private var dashCooldownTimer:Float = 3.0;
    private var isDashing:Bool = false;
    private var dashDurationTimer:Float = 0;

    private static inline var BOSS_OFFSET_RIGHT:Float = 220;
    private static inline var BOSS_OFFSET_LEFT:Float = 290;
    private static inline var BOSS_OFFSET_Y:Float = 190;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        
        loadGraphic("assets/images/boss.png", true, 567, 556);

        animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 24, true);
        animation.add("jump", [11, 12, 13, 14, 15, 16, 17, 18, 20], 24, true);
        animation.add("jump-shoot", [21, 22, 23, 24, 25], 24, true);
        animation.add("jump-melee", [26, 27, 28, 29, 30, 31, 32, 33], 24, true);
        animation.add("melee", [34, 35, 36, 37, 38, 39, 40, 41], 24, true);
        animation.add("run", [42, 43, 44, 45, 46, 47, 48, 49], 24, true);
        animation.add("run-shoot", [50, 51, 52, 53, 54, 55, 56, 57], 24, true);
        animation.add("shoot", [58, 59, 60, 61, 62], 24, true);
        animation.add("slide", [63, 64, 65, 66, 67, 68, 69, 70, 71, 72], 24, true);
        animation.add("dead", [73, 74, 75, 76, 77, 78, 79, 80, 81, 82], 24, false);

        animation.play("run");

        scale.set(0.47, 0.47);

        width = 140;
        height = 200;
        
        offset.set(BOSS_OFFSET_RIGHT, BOSS_OFFSET_Y);
    }

    override public function update(elapsed:Float):Void
    {
        if (isDashing)
        {
            dashDurationTimer -= elapsed;
            if (dashDurationTimer <= 0)
            {
                isDashing = false;
                color = FlxColor.WHITE;
            }
            
            velocity.x = direction * DASH_SPEED;
            animation.play("slide");
            super.update(elapsed);
            return;
        }

        if (dashCooldownTimer > 0)
        {
            dashCooldownTimer -= elapsed;
        }

        super.update(elapsed);

        checkInvisibleWalls();

        var Math_abs = Math.abs;
        var playState:PlayState = cast FlxG.state;
        
        if (playState.player != null && !playState.player.isDeadState)
        {
            var distanceX:Float = Math_abs(playState.player.x - this.x);
            var distanceY:Float = Math_abs(playState.player.y - this.y);

            if (distanceX < 350 && distanceY < 150 && dashCooldownTimer <= 0)
            {
                triggerBossDash();
            }
        }

        offset.x = flipX ? BOSS_OFFSET_LEFT : BOSS_OFFSET_RIGHT;
    }

    private function checkInvisibleWalls():Void
	{
		if (x < 0)
		{
			direction = 1;
            flipX = false;
            offset.x = BOSS_OFFSET_RIGHT;
		}
		var mapLimitRight:Float = (80 * 64) - width;
		if (x > mapLimitRight)
		{
			direction = -1;
            flipX = true;
            offset.x = BOSS_OFFSET_LEFT;
		}
	}

    private function triggerBossDash():Void
    {
        isDashing = true;
        dashDurationTimer = 0.5;
        dashCooldownTimer = 4.0;
        
        color = 0xFFFF3333;
        FlxG.camera.shake(0.005, 0.2);
        trace("Le Boss utilise sa CAPACITÉ SPÉCIALE : Charge Sismique !");
    }

    public function takeBossDamage():Bool
    {
        hp--;
        
        if (hp <= 0)
        {
            animation.play("dead");
            return true;
        }
        
        color = 0xFFFFFFFF;
        new FlxTimer().start(0.2, function(t) {
            if (!isDashing) color = FlxColor.WHITE;
        });
        
        return false;
    }
}
