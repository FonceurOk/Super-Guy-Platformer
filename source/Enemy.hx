package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

class Enemy extends FlxSprite
{
    private static inline var PATROL_SPEED:Float = 100;
    private static inline var CHASE_SPEED:Float = 180;
    private static inline var GRAVITY:Float = 1200;
    private static inline var AGRO_RANGE:Float = 350;

	private static inline var OFFSET_RIGHT:Float = 240;
	private static inline var OFFSET_LEFT:Float = 340;
	private static inline var OFFSET_Y:Float = 173;

    private var direction:Float = 1; 

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        
		loadGraphic("assets/images/enemy.png", true, 680, 472);

		animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 24, true);
		animation.add("jump", [13, 14, 15, 16, 17, 18], 24, true);
		animation.add("falling", [19, 20, 21], 12, true);
		animation.add("run", [22, 23, 24, 25, 26, 27, 28, 29], 24, true);

		animation.play("run");

		scale.set(0.47, 0.47);

		width = 105;
		height = 150;
        
        offset.set(OFFSET_RIGHT, OFFSET_Y);
        
        acceleration.y = GRAVITY;
        velocity.x = PATROL_SPEED;
        antialiasing = true;
    }

    override public function update(elapsed:Float):Void
    {
        var playState:PlayState = cast FlxG.state;
        var player:Player = playState.player;
        
        var currentSpeed:Float = PATROL_SPEED;

        if (player != null && !player.isDeadState)
        {
            var distanceX:Float = Math.abs(player.x - this.x);
            var distanceY:Float = Math.abs(player.y - this.y);

            if (distanceX < AGRO_RANGE && distanceY < 150)
            {
                currentSpeed = CHASE_SPEED;
                
                if (player.x < this.x) {
                    direction = -1;
                    flipX = true;
                    offset.x = OFFSET_LEFT;
                }
                else {
                    direction = 1;
                    flipX = false;
                    offset.x = OFFSET_RIGHT;
                }
            }
        }
        
        var leftFlag:Int = FlxDirectionFlags.LEFT.toInt();
        var rightFlag:Int = FlxDirectionFlags.RIGHT.toInt();

        if ((touching.toInt() & leftFlag) != 0)
        {
            direction = 1;
            flipX = false;
            offset.x = OFFSET_RIGHT;
        }
        else if ((touching.toInt() & rightFlag) != 0)
        {
            direction = -1;
            flipX = true;
            offset.x = OFFSET_LEFT;
        }

        velocity.x = direction * currentSpeed;

        super.update(elapsed);
    }
}