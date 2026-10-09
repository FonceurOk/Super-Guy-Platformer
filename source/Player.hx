package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	private static inline var SPEED:Float = 300;
	private static inline var JUMP_FORCE:Float = 700;
	private static inline var GRAVITY:Float = 1200;

	private static inline var SLIDE_SPEED:Float = 500;
	private static inline var SLIDE_DURATION:Float = 0.4;

	private var isSliding:Bool = false;
	private var slideTimer:Float = 0;
	private var slideDirection:Float = 1;

	public var isHurtState:Bool = false;
	public var isDeadState:Bool = false;
	private var hurtTimer:Float = 0;

	private static inline var OFFSET_RIGHT:Float = 310;
	private static inline var OFFSET_LEFT:Float = 255;
	private static inline var OFFSET_Y:Float = 235;

	public function new(X:Float, Y:Float)
	{
		super(X, Y);

		loadGraphic("assets/images/player.png", true, 669, 569);

		animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 24, true);
		animation.add("jump", [13, 14, 15, 16, 17, 18], 24, true);
		animation.add("falling", [19, 20, 21], 12, true);
		animation.add("slide", [30, 31, 32, 33, 34], 24, true);
		animation.add("run", [22, 23, 24, 25, 26, 27, 28, 29], 24, true);
		animation.add("hurt", [35, 36, 37, 38, 39, 40, 41, 42], 24, false);
		animation.add("dead", [42, 43, 44, 45, 46, 47, 48, 49, 50, 51], 24, false);

		animation.play("idle");

		scale.set(0.47, 0.47);

		width = 105;
		height = 150;

		offset.set(OFFSET_RIGHT, OFFSET_Y);

		acceleration.y = GRAVITY;
		maxVelocity.set(SLIDE_SPEED, 700);

		antialiasing = true;
	}

	override public function update(elapsed:Float):Void
	{
		if (isHurtState)
		{
			hurtTimer -= elapsed;
			if (hurtTimer <= 0)
			{
				isHurtState = false;
				color = FlxColor.WHITE;
			}
		}

		if (isDeadState)
		{
			velocity.x = 0;
			super.update(elapsed);
			return;
		}

		if (isSliding)
		{
			slideTimer -= elapsed;
			if (slideTimer <= 0)
				isSliding = false;
		}

		moveControls();
		super.update(elapsed);
	}

	private function moveControls():Void
	{
		if (isHurtState)
		{
			velocity.x = 0;
			animation.play("hurt");
			return;
		}

		if (isSliding)
		{
			velocity.x = slideDirection * SLIDE_SPEED;
			animation.play("slide");
			if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.SPACE) && touching == DOWN)
			{
				isSliding = false;
				velocity.y = -JUMP_FORCE;
			}
			checkInvisibleWalls();
			return;
		}

		velocity.x = 0;
		var isMoving:Bool = false;

		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
		{
			velocity.x = -SPEED;
			flipX = true;
			isMoving = true;
			offset.x = OFFSET_LEFT;
			slideDirection = -1;
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			velocity.x = SPEED;
			flipX = false;
			isMoving = true;
			offset.x = OFFSET_RIGHT;
			slideDirection = 1;
		}

		if (FlxG.keys.justPressed.SHIFT || FlxG.keys.justPressed.C)
		{
			isSliding = true;
			slideTimer = SLIDE_DURATION;
			velocity.x = slideDirection * SLIDE_SPEED;
			animation.play("slide");
			return;
		}

		if (touching == DOWN)
		{
			if (isMoving)
				animation.play("run");
			else
				animation.play("idle");
		}
		else
		{
			if (velocity.y < 0)
				animation.play("jump");
			else if (velocity.y > 0)
				animation.play("falling");
		}

		if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.SPACE) && touching == DOWN)
        {
            velocity.y = -JUMP_FORCE;
        }

        if (FlxG.keys.justReleased.UP || FlxG.keys.justReleased.SPACE)
        {
            if (velocity.y < 0)
            {
                velocity.y = velocity.y * 0.5; 
            }
		}

		checkInvisibleWalls();
	}

	private function checkInvisibleWalls():Void
	{
		if (x < 0)
		{
			x = 0;
			velocity.x = 0;
		}
		var mapLimitRight:Float = (80 * 64) - width;
		if (x > mapLimitRight)
		{
			x = mapLimitRight;
			velocity.x = 0;
		}
	}

	public function takeDamage(spawnX:Float, spawnY:Float):Void
    {
		isDeadState = true;
		animation.play("dead");

		new flixel.util.FlxTimer().start(1.5, function(t:flixel.util.FlxTimer) {
			setPosition(spawnX, spawnY);
			velocity.set(0, 0);
			isDeadState = false;
			animation.play("idle");
		});
    }

	public function isAttacking():Bool
	{
		return isSliding;
	}
}
