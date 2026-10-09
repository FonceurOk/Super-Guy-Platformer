package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class VictorySubState extends FlxSubState
{
    private var victoryText:FlxText;
    private var replayButton:FlxButton;

    public function new()
    {
        super();
    }

    override public function create():Void
    {
        super.create();
        
        // Rend la souris visible pour pouvoir cliquer sur le bouton
        FlxG.mouse.visible = true;

        // 1. Fond semi-transparent sombre pour figer le jeu avec classe
        var bg:flixel.FlxSprite = new flixel.FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0x99000000); // 0x99 = opacité moyenne
        bg.scrollFactor.set(0, 0);
        add(bg);

        // 2. Grand texte "JEU TERMINÉ"
        victoryText = new FlxText(0, FlxG.height * 0.3, FlxG.width, "FÉLICITATIONS !\nJEU TERMINÉ", 32);
        victoryText.setFormat(null, 32, FlxColor.YELLOW, CENTER, OUTLINE, FlxColor.BLACK);
        victoryText.scrollFactor.set(0, 0);
        add(victoryText);

        // 3. Bouton "Rejouer"
        // Placé au centre horizontal de l'écran, et à 60% de la hauteur
        replayButton = new FlxButton(0, FlxG.height * 0.6, "REJOUER", clickReplay);
        replayButton.screenCenter(X); // Centre automatiquement sur l'axe X
        replayButton.scrollFactor.set(0, 0);
        
        // Customisation rapide du texte du bouton OpenFL
        replayButton.label.setFormat(null, 12, FlxColor.BLACK, CENTER);
        add(replayButton);
    }

    private function clickReplay():Void
    {
        FlxG.mouse.visible = false;
        
        FlxG.resetState();
        close();
    }
}
