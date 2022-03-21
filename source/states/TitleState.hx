package states;

import flixel.util.FlxTimer;
import openfl.utils.Assets;
import engine.Conductor;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import util.Paths;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxState;

class TitleState extends StateBase {
    var logo:FlxSprite;
    var gf:FlxSprite;
    var titleText:FlxSprite;

    var textthing:FlxText;

    static var initialized = false;
    static var skippedIntro = false;

    var danceLeft = false;

    var transitioning = false;

    var curText:Array<String>;

    public override function create() {
        super.create();

        // bind the save
        FlxG.save.bind('FNFR');

        // get intro text
        curText = FlxG.random.getObject(getIntroText());

        startIntro();
    }

    function startIntro() {
        if (!initialized) {
            var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
            diamond.persist = true;
            diamond.destroyOnNoUse = false;

            FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
            FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

            transIn = FlxTransitionableState.defaultTransIn;
            transOut = FlxTransitionableState.defaultTransOut;
            
            FlxG.sound.playMusic(Paths.music("freakyMenu"), 0);

            FlxG.sound.music.fadeIn(4, 0, 0.7);
        }

        Conductor.changeBPM(102);
        persistentUpdate = true;

        logo = new FlxSprite(-150, -100);
        logo.frames = Paths.getSparrowAtlas('logoBumpin');
        logo.antialiasing = true;
        logo.animation.addByPrefix('bump', 'logo bumpin', 24);
        logo.animation.play('bump');
        logo.updateHitbox();

        gf = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
        gf.frames = Paths.getSparrowAtlas('gfDanceTitle');
        gf.antialiasing = true;
        gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
        
        titleText = new FlxSprite(100, FlxG.height * 0.8);
        titleText.frames = Paths.getSparrowAtlas('titleEnter');
        titleText.antialiasing = true;
        titleText.animation.addByPrefix('idle', 'Press Enter to Begin', 24);
        titleText.animation.addByPrefix('press', 'ENTER PRESSED', 24);
        titleText.animation.play('idle');
        titleText.updateHitbox();
        
        textthing = new FlxText(0, 0, FlxG.width, "");
        textthing.setFormat("assets/fonts/pmEmpty.ttf", 64, 0xffffffff, CENTER);
        textthing.textField.height = FlxG.height;
        textthing.screenCenter();
        textthing.visible = false;
        add(textthing);

        FlxG.mouse.visible = false;

        if (initialized) {
            skipIntro();
        }
        else {
            initialized = true;
        }
    }

    function getIntroText():Array<Array<String>> {
        var fullText = Assets.getText(Paths.txt("introText"));

        var firstArray = fullText.split("\n");
        var secondArray:Array<Array<String>> = [];

        for (i in firstArray) {
            secondArray.push(i.split('--'));
        }

        return secondArray;
    }

    override function update(elapsed:Float) {
        if (FlxG.sound.music != null) {
            Conductor.songPosition = FlxG.sound.music.time;
        }

        if (FlxG.keys.justPressed.ENTER && skippedIntro && !transitioning) {
            titleText.animation.play('press');

            FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

            transitioning = true;

            new FlxTimer().start(2, (_) -> {
                FlxG.switchState(new MainMenuState());
            });
        }

        if (FlxG.keys.justPressed.ENTER && !skippedIntro) {
            skipIntro();
        }

        super.update(elapsed);
    }

    override function beatHit() {
        super.beatHit();

        logo.animation.play('bump');
        danceLeft = !danceLeft;

        if (danceLeft) {
            gf.animation.play('danceLeft');
        }
        else {
            gf.animation.play('danceRight');
        }

        // INTRO TEXT BS
        switch (curBeat) {
            case 3:
                textthing.text += "thepercentageguy\nPresents".toUpperCase();
                textthing.screenCenter();
                textthing.visible = true;
            case 4:
                textthing.visible = false;
            case 5:
                textthing.text = "In association\nwith".toUpperCase();
                textthing.screenCenter();
                textthing.visible = true;
            case 7:
                textthing.text += "\nabsolutely nothing".toUpperCase();
                // textthing.screenCenter();
            case 8:
                textthing.visible = false;
            case 9:
                textthing.text = curText[0].toUpperCase();
                textthing.screenCenter();
                textthing.visible = true;
            case 11:
                textthing.text += "\n" + curText[1].toUpperCase();
                // textthing.screenCenter();
            case 12:
                textthing.visible = false;
            case 13:
                textthing.text = "Friday".toUpperCase();
                textthing.screenCenter();
                textthing.visible = true;
            case 14:
                textthing.text += "\n" + "Night".toUpperCase();
                //textthing.screenCenter();
            case 15:
                textthing.text += "\n" + "Funkin'".toUpperCase();
                // textthing.screenCenter();
            case 16:
                skipIntro();
        }
    }

    function skipIntro() {
        if (!skippedIntro) {
            FlxG.camera.flash(FlxColor.WHITE, 4);
            
            remove(textthing);
            add(gf);
            add(logo);
            add(titleText);

            skippedIntro = true;
        }
    }
}