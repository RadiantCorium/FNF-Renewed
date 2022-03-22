package states;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Exception;
import util.Paths;
import openfl.utils.Assets;
import haxe.Json;
import engine.VarHolder;
import flixel.addons.transition.FlxTransitionableState;

class PlayState extends StateBase {
    var isFreeplay = VarHolder.weekLoaded == null;

    var chart:engine.Classes.Chart;

    var stage:engine.Classes.Stage;

    var defaultCamZoom = 1.0;

    override function create() {
        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        chart = Json.parse(Assets.getText(Paths.json('charts/${VarHolder.curSong.toLowerCase()}')));
        
        loadStage();

        FlxG.camera.zoom = defaultCamZoom;

        super.create();
    }

    function loadStage() {
        var stageFile:engine.Classes.Stages = Json.parse(Assets.getText(Paths.json('stages')));

        // loop over each stage to find the one we want
        for (stageL in stageFile.stages) {
            if (stageL.name == chart.song.stageName) {
                // assign the stage to the stage variable
                stage = stageL;
                break; // break out of the loop to save time and performance
            }
        }
        
        // make sure we actually found the stage
        if (stage == null) {
            throw new Exception("Could not find stage " + chart.song.stageName);
        }

        // load the stage itself
        defaultCamZoom = stage.camZoom;

        var stageBG = new FlxSprite(stage.bgX, stage.bgY);
        stageBG.loadGraphic(Paths.image(stage.background, stage.customLib == null ? 'shared' : stage.customLib));
        stageBG.scrollFactor.x = 1;
        stageBG.scrollFactor.y = 1;
        stageBG.antialiasing = true;
        add(stageBG);

        // loop over sprites and load them
        for (sprite in stage.sprites) {
            var s = new FlxSprite(sprite.x, sprite.y);
            s.loadGraphic(Paths.image(sprite.img, stage.customLib == null ? 'shared' : stage.customLib));
            s.scrollFactor.x = sprite.scrollFactorX;
            s.scrollFactor.y = sprite.scrollFactorY;
            s.ID = sprite.id;
            s.antialiasing = true;
            add(s);
        }
    }
}