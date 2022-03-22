package states;

import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import engine.Conductor;
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

    var countdown = 0;
    var cdSprite:FlxSprite;

    var inst:FlxSound;
    var vocals:FlxSound;

    var leftSide:FlxTypedGroup<FlxSprite>;
    var rightSide:FlxTypedGroup<FlxSprite>;

    var camHUD:FlxCamera;
    var camGame:FlxCamera;

    var healthBar:FlxBar;
    var health:Int = 50;

    var icon1:FlxSprite;
    var icon2:FlxSprite;

    override function create() {
        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        chart = Json.parse(Assets.getText(Paths.json('charts/${VarHolder.curSong.toLowerCase()}')));

        // initialize cameras
        camHUD = new FlxCamera();
        camGame = new FlxCamera();
        camHUD.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);

        // Ignore any warnings this causes
        // it works, and it's not worth fixing it
        FlxCamera.defaultCameras = [camGame];
        
        loadStage();

        loadCharacters();

        camGame.zoom = defaultCamZoom;
        camHUD.zoom = defaultCamZoom;

        Conductor.changeBPM(chart.song.bpm);


        vocals = new FlxSound();
        vocals.loadEmbedded(Paths.voices(chart.song.song));
        vocals.persist = false;

        FlxG.autoPause = false;

        leftSide = new FlxTypedGroup<FlxSprite>();
        rightSide = new FlxTypedGroup<FlxSprite>();

        // load the funky arrows
        for (i in 0...4) {
            var arrow = new FlxSprite(10 + (120 * i), 20);
            arrow.frames = Paths.getSparrowAtlas("NOTE_assets", "shared");
            arrow.setGraphicSize(120);
            arrow.updateHitbox();
            arrow.ID = i;
            switch (i) {
                case 0:
                    arrow.animation.addByPrefix("idle", "arrowLEFT0000");
                    arrow.animation.addByPrefix("pressed", "left press");
                    arrow.animation.addByPrefix("confirm", "left confirm");
                    arrow.animation.play("idle");
                case 1:
                    arrow.animation.addByPrefix("idle", "arrowDOWN0000");
                    arrow.animation.addByPrefix("pressed", "down press");
                    arrow.animation.addByPrefix("confirm", "down confirm");
                    arrow.animation.play("idle");
                case 2:
                    arrow.animation.addByPrefix("idle", "arrowUP0000");
                    arrow.animation.addByPrefix("pressed", "up press");
                    arrow.animation.addByPrefix("confirm", "up confirm");
                    arrow.animation.play("idle");
                case 3:
                    arrow.animation.addByPrefix("idle", "arrowRIGHT0000");
                    arrow.animation.addByPrefix("pressed", "right press");
                    arrow.animation.addByPrefix("confirm", "right confirm");
                    arrow.animation.play("idle");
            }
            arrow.antialiasing = true;
            arrow.cameras = [camHUD];
            arrow.alpha = 0;
            FlxTween.tween(arrow, {alpha: 1, y: arrow.y + 10}, 0.2 * i + 0.3, {ease: FlxEase.quadInOut});
            leftSide.add(arrow);
        }

        for (i in 0...4) {
            var arrow = new FlxSprite(FlxG.width - 10 - leftSide.members[0].width * 4 + (120 * i), 20);
            arrow.frames = Paths.getSparrowAtlas("NOTE_assets", "shared");
            arrow.setGraphicSize(120);
            arrow.updateHitbox();
            arrow.ID = i;
            switch (i) {
                case 0:
                    arrow.animation.addByPrefix("idle", "arrowLEFT0000");
                    arrow.animation.addByPrefix("pressed", "left press");
                    arrow.animation.addByPrefix("confirm", "left confirm");
                    arrow.animation.play("idle");
                case 1:
                    arrow.animation.addByPrefix("idle", "arrowDOWN0000");
                    arrow.animation.addByPrefix("pressed", "down press");
                    arrow.animation.addByPrefix("confirm", "down confirm");
                    arrow.animation.play("idle");
                case 2:
                    arrow.animation.addByPrefix("idle", "arrowUP0000");
                    arrow.animation.addByPrefix("pressed", "up press");
                    arrow.animation.addByPrefix("confirm", "up confirm");
                    arrow.animation.play("idle");
                case 3:
                    arrow.animation.addByPrefix("idle", "arrowRIGHT0000");
                    arrow.animation.addByPrefix("pressed", "right press");
                    arrow.animation.addByPrefix("confirm", "right confirm");
                    arrow.animation.play("idle");
            }
            arrow.antialiasing = true;
            arrow.cameras = [camHUD];
            arrow.alpha = 0;
            FlxTween.tween(arrow, {alpha: 1, y: arrow.y + 10}, 0.2 * i + 0.3, {ease: FlxEase.quadInOut});
            rightSide.add(arrow);
        }

        add(leftSide);
        add(rightSide);

        // health bar
        var healthBarBG = new FlxSprite(0, FlxG.height * 0.9);
        healthBarBG.loadGraphic(Paths.image("healthBar", "shared"));
        healthBarBG.scrollFactor.set();
        healthBarBG.screenCenter(X);
        healthBarBG.antialiasing = true;
        healthBarBG.cameras = [camHUD];
        add(healthBarBG);

        healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, FlxBarFillDirection.RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, "health", 0, 100);
        healthBar.scrollFactor.set();
        healthBar.createFilledBar(0xFFFF0000, 0xFF00FF00);
        healthBar.cameras = [camHUD];
        add(healthBar);

        // icon shit
        trace("icon 1");
        icon1 = new FlxSprite(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y - 25);
        icon1.loadGraphic(Paths.image("icons/icon-" + chart.song.player1, "shared"), true, 150, 150);
        icon1.animation.add("idle", [0], 0);
        icon1.animation.add("angy", [1], 0);
        icon1.animation.play("idle");
        icon1.flipX = true;
        icon1.scrollFactor.set();
        icon1.setGraphicSize(80);
        icon1.updateHitbox();
        icon1.cameras = [camHUD];
        icon1.antialiasing = true;
        add(icon1);

        trace("icon 2");
        icon2 = new FlxSprite(healthBarBG.x + healthBarBG.width / 2 + icon1.width, healthBarBG.y - 25);
        icon2.loadGraphic(Paths.image("icons/icon-" + chart.song.player2, "shared"), true, 150, 150);
        icon2.animation.add("idle", [0], 0);
        icon2.animation.add("angy", [1], 0);
        icon2.animation.play("idle");
        icon2.scrollFactor.set();
        icon2.setGraphicSize(80);
        icon2.updateHitbox();
        icon2.cameras = [camHUD];
        icon1.antialiasing = true;
        add(icon2);

        trace("icons work");

        super.create();
        
        countdown = 4;
        trace("countdown prob");
        new FlxTimer().start(Conductor.crochet / 1000, countdownThing, 5);
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

    override function update(elapsed:Float) {
        super.update(elapsed);

        // update the health bar icons
        var iconOffset = 15;
        icon1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
        icon2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 0, 100) * 0.01)) - (icon2.width - iconOffset);

        icon1.setGraphicSize(Std.int(FlxMath.lerp(80, icon1.width, 0.80)));
		icon2.setGraphicSize(Std.int(FlxMath.lerp(80, icon2.width, 0.80)));
        icon1.updateHitbox();
        icon2.updateHitbox();

        if (FlxG.sound.music != null) {
            Conductor.songPosition = FlxG.sound.music.time;
        }
    }

    function loadCharacters() {
        return;
    }

    function countdownThing(_) {
        trace("countdown " + countdown);
        if (countdown >= 0) {
            countdown--;
        }
        switch (countdown) {
            case 3:
                FlxG.sound.play(Paths.sound('intro3', 'shared'));
            case 2:
                // ready
                cdSprite = new FlxSprite(0, 0);
                cdSprite.loadGraphic(Paths.image('ready', 'shared'));
                cdSprite.scrollFactor.x = 0;
                cdSprite.scrollFactor.y = 0;
                cdSprite.antialiasing = true;
                cdSprite.screenCenter();
                FlxTween.tween(cdSprite, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
                add(cdSprite);
                FlxG.sound.play(Paths.sound('intro2', 'shared'));
            case 1:
                // set
                cdSprite.alpha = 1;
                cdSprite.loadGraphic(Paths.image('set', 'shared'));
                cdSprite.screenCenter();
                FlxTween.tween(cdSprite, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
                FlxG.sound.play(Paths.sound('intro1', 'shared'));
            case 0:
                // go
                cdSprite.alpha = 1;
                cdSprite.screenCenter();
                FlxG.sound.play(Paths.sound('introGo', 'shared'));
                FlxTween.tween(cdSprite, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
                cdSprite.loadGraphic(Paths.image('go', 'shared'));

                // start the song
                // inst.play();
                FlxG.sound.playMusic(Paths.inst(chart.song.song)); // need to do this for reasons
                vocals.play();
            case -1:
                // kill the countdown
                remove(cdSprite);
                cdSprite.kill();
        }
    }

    override function beatHit() {
        super.beatHit();

        if (curBeat % 4 == 0) {
            camGame.zoom += 0.05;
            camHUD.zoom += 0.02;
            FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.8, {ease: FlxEase.quadOut});
            FlxTween.tween(camHUD, {zoom: defaultCamZoom}, 0.8, {ease: FlxEase.quadOut});
        }

        icon1.setGraphicSize(Std.int(icon1.width - 20));
        icon2.setGraphicSize(Std.int(icon2.width - 20));
        icon1.updateHitbox();
        icon2.updateHitbox();
    }
}