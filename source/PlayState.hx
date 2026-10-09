package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import haxe.Json;

class PlayState extends FlxState
{
	public static inline var TILE_SIZE:Int = 64;
	public static inline var MAP_WIDTH:Int = 80;
	public static inline var MAP_HEIGHT:Int = 45;

	public static var mapData:Array<Int> = null;
	public static var bgMapData:Array<Int> = null; 
	public static var totalTilesChanged:Int = 0;
	public static var playerStartX:Float = 0;
	public static var playerStartY:Float = 0;
	public static var bossStartX:Float = 0;
	public static var bossStartY:Float = 0;

	public static var enemiesSaveData:Array<Array<Float>> = [];

	public static var bgsConfig:Array<Array<Dynamic>> = [
		['background_solid_cloud', 0.2, 144],
		['background_solid_cloud', 0.2, 400],
		['background_clouds', 0.2, -28],
		['background_fade_trees', 0.5, 364],
		['background_solid_sky', 0.5, 604],
	];

	public var tilemap:FlxTilemap;
	public var bgTilemap:FlxTilemap;

	public static var gameSave:FlxSave;
	public var player:Player;
	public var boss:Boss;

	public static var enemiesGroup:FlxTypedGroup<Enemy>;

	private var skyBackground:FlxSprite;
	private var backdropSprites:Array<FlxBackdrop> = [];
	private var hudText:FlxText;

	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;

		FlxSprite.defaultAntialiasing = false;
		FlxG.camera.antialiasing = false;
		FlxG.camera.pixelPerfectRender = true;

		loadLevelFromJson();

		skyBackground = new FlxSprite(0, -720);
		skyBackground.makeGraphic(MAP_WIDTH * TILE_SIZE, (MAP_HEIGHT * TILE_SIZE) + 720, 0xFF60B0FF);
		skyBackground.scrollFactor.set(0, 0);
		add(skyBackground);

		backdropSprites = [];
		for (i in 0...bgsConfig.length)
		{
			var backdrop:FlxBackdrop = new FlxBackdrop("assets/images/" + bgsConfig[i][0] + ".png", X, 0, 0);
			backdrop.scrollFactor.set(bgsConfig[i][1], 0.0);
			backdrop.pixelPerfectRender = true;
			backdrop.antialiasing = false;
			backdrop.y = bgsConfig[i][2];
			if (bgsConfig[i][0] == 'background_clouds')
				backdrop.velocity.set(8, 0);
			add(backdrop);
			backdropSprites.push(backdrop);
		}

		bgTilemap = new FlxTilemap();
		bgTilemap.loadMapFromArray(bgMapData, MAP_WIDTH, MAP_HEIGHT, "assets/images/backgrounds.png", TILE_SIZE, TILE_SIZE);
		bgTilemap.pixelPerfectRender = true;
		bgTilemap.antialiasing = true;
		add(bgTilemap);

		tilemap = new FlxTilemap();
		tilemap.antialiasing = true;
		tilemap.loadMapFromArray(mapData, MAP_WIDTH, MAP_HEIGHT, "assets/images/tiles.png", TILE_SIZE, TILE_SIZE);
		tilemap.setTileProperties(1, ANY);
		tilemap.setTileProperties(2, ANY);
		tilemap.setTileProperties(3, ANY);
		tilemap.setTileProperties(7, ANY, hitExclamationBlock);
		add(tilemap);

		enemiesGroup = new FlxTypedGroup<Enemy>();
		add(enemiesGroup);
		reloadEnemies();

		boss = new Boss(bossStartX, bossStartY);
		add(boss);

		player = new Player(playerStartX, playerStartY);
		add(player);

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic("assets/music/background_music.mp3", 0.5, true);
		}
		else
		{
			FlxG.sound.music.volume = 0.5;
		}

		startPlayMode();

		hudText = new FlxText(20, 20, 800, "COMMANDES : [FLÈCHES / A-D] Courir | [ESPACE / HAUT] Sauter (Maintenir pour plus haut)\n[SHIFT / C] Glissade d'Attaque (Détruit les ennemis !)", 14);
        hudText.setFormat(null, 14, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        hudText.scrollFactor.set(0, 0);
        add(hudText);
	}

	private function hitExclamationBlock(tileObject:flixel.FlxObject, object:flixel.FlxObject):Void
	{
		if (Std.isOfType(object, Player))
		{
			var p:Player = cast object;
			if (p.touching == UP)
			{
				var tile:flixel.tile.FlxTile = cast tileObject;
				var tileX:Int = Math.floor(tile.x / TILE_SIZE);
				var tileY:Int = Math.floor(tile.y / TILE_SIZE);
				var index1D:Int = tileY * MAP_WIDTH + tileX;

				if (index1D >= 0 && index1D < mapData.length)
				{
					mapData[index1D] = 8;
					tilemap.setTileIndex(tileX, tileY, 8, true);
				}
			}
		}
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(player, tilemap);
		FlxG.collide(boss, tilemap);
		FlxG.collide(enemiesGroup, tilemap);

		FlxG.overlap(player, enemiesGroup, playerTouchEnemy);
		FlxG.overlap(player, boss, playerTouchEnemy);

		super.update(elapsed);

		if (player != null && player.y > (MAP_HEIGHT * TILE_SIZE) && !player.isDeadState)
		{
			FlxG.resetState();
			FlxG.sound.playMusic("assets/music/background_music.mp3", 0.5, true);
			trace("Le joueur est tombé dans le vide ! Respawn activé.");
		}

		if (player != null && FlxG.camera.target != null)
		{
			var targetXOffset:Float = player.flipX ? -180 : 180;
			FlxG.camera.targetOffset.x = flixel.math.FlxMath.lerp(FlxG.camera.targetOffset.x, targetXOffset, 4 * elapsed);
		}
	}

	private function playerTouchEnemy(p:Player, e:Enemy):Void
    {
	if (p.isAttacking())
	{
		if (Std.isOfType(e, Boss))
		{
			if (boss.takeBossDamage())
			{
				boss.kill();
				FlxG.camera.shake(0.02, 0.4);
				
				FlxG.camera.follow(null); 
				if (FlxG.sound.music != null) FlxG.sound.music.stop;
				
				openSubState(new VictorySubState());
			}
			else
			{
				FlxG.camera.shake(0.008, 0.2);
				p.velocity.x = p.flipX ? 400 : -400;
			}
		}
		else
		{
			e.kill();
			FlxG.camera.shake(0.01, 0.15);
		}
	}
	else if (!p.isHurtState && !p.isDeadState)
	{
		p.takeDamage(playerStartX, playerStartY);
	}
}

	public static function reloadEnemies():Void
	{
		if (enemiesGroup != null)
		{
			enemiesGroup.clear();
			for (coord in enemiesSaveData)
			{
				enemiesGroup.add(new Enemy(coord[0], coord[1]));
			}
		}
	}

	public function startPlayMode():Void
	{
		for (i in 0...backdropSprites.length)
		{
			backdropSprites[i].y = bgsConfig[i][2];
		}

		FlxG.camera.follow(player, PLATFORMER, 0.05);
		FlxG.camera.targetOffset.x = 0;

		FlxG.camera.setScrollBoundsRect(0, 0, MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * 16, true);

		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = 0.5;
	}

	public function loadLevelFromJson():Void
	{
	    var levelJson:String = Assets.getText('assets/data/level.json');
        var level:Dynamic = Json.parse(levelJson);

		mapData = level.mapData;
	    bgMapData = level.bgMapData;
	    playerStartX = level.playerX;
	    playerStartY = level.playerY;
		bossStartX = level.bossX;
	    bossStartY = level.bossY;
		enemiesSaveData = level.enemies;
    }
}