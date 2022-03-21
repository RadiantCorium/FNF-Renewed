package states;

import openfl.utils.Assets;
import haxe.Json;
import lime.app.Application;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import util.Paths;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class MainMenuState extends StateBase {
    var menuItems:FlxTypedGroup<FlxSprite>;

    var selector:FlxSprite;

    var curSelected = 0;
    var curSelectedInMenu = 0;

    var storymodeGroup:FlxTypedGroup<FlxSprite>;
    var freeplayGroup:FlxTypedGroup<FlxSprite>;
    var optionsGroup:FlxTypedGroup<FlxSprite>;

    var focusedOnMenu = false;

    var weeks:engine.Classes.Weeks;

    var menuBG:FlxSprite;

    override function create() {
        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        persistentUpdate = persistentDraw = true;
        
        super.create();

        var bg = new FlxSprite(0, 0);
        bg.loadGraphic(Paths.image("menuBG"));
        bg.scrollFactor.set();
        add(bg);

        var buttonBG = new FlxSprite(0, 0);
        buttonBG.makeGraphic(Std.int(FlxG.width / 4) + 160, FlxG.height, 0xAA000000);
        buttonBG.scrollFactor.set();
        add(buttonBG);

        menuBG = new FlxSprite(buttonBG.width, 0);
        menuBG.makeGraphic(Std.int(FlxG.width - buttonBG.width), FlxG.height, 0xCC000000);
        menuBG.scrollFactor.set();
        add(menuBG);

        var versionshit = new FlxText(2, FlxG.height - 20, FlxG.width, 'v${Application.current.meta.get("version")} - FNFR');
        versionshit.setFormat("assets/fonts/pmFull.otf", 16, 0xFFFFFFFF, LEFT);
        versionshit.scrollFactor.set();
        add(versionshit);

        // generate menu items
        menuItems = new FlxTypedGroup<FlxSprite>();
        for (i in 0...3) {
            var item = new FlxSprite(20, 0);
            item.frames = Paths.getSparrowAtlas("FNF_main_menu_assets");
            switch (i) {
                case 0:
                    item.animation.addByPrefix("idle", "story mode basic", 24);
                    item.animation.addByPrefix("pressed", "story mode white", 24);
                    item.animation.play("idle");
                case 1:
                    item.animation.addByPrefix("idle", "freeplay basic", 24);
                    item.animation.addByPrefix("pressed", "freeplay white", 24);
                    item.animation.play("idle");
                case 2:
                    trace("options shit");
                    item.animation.addByPrefix("idle", "options basic", 24);
                    item.animation.addByPrefix("pressed", "options white", 24);
                    item.animation.play("idle");
            }
            item.setGraphicSize(0, 70);
            item.updateHitbox();
            item.scrollFactor.set();
            if (i == 0)
                item.animation.play("pressed");
            item.antialiasing = true;
            item.y = 60 + (i * 130);

            menuItems.add(item);
        }
        add(menuItems);

        // generate story mode menu
        storymodeGroup = new FlxTypedGroup<FlxSprite>();
        var text = Assets.getText(Paths.json("weeks"));
        weeks = Json.parse(text);
        for (i in 0...weeks.weeks.length) {
            var item = new FlxSprite(menuBG.x + 5, 0);
            item.loadGraphic(Paths.image("storymenu/week" + i));
            item.setGraphicSize(0, 70);
            item.updateHitbox();
            item.x = menuBG.x + menuBG.width - menuBG.width / 2 - item.width / 2;
            item.antialiasing = true;
            item.y = 60 + (i * 80);
            item.ID = i;
            item.scrollFactor.set(0,1);
            storymodeGroup.add(item);
        }
        add(storymodeGroup);

        // generate freeplay menu
        freeplayGroup = new FlxTypedGroup<FlxSprite>();
        var songs:Array<String> = Assets.getText(Paths.txt("freeplaySonglist")).split("\n");
        for (i in 0...songs.length) {
            var item = new FlxText(menuBG.x, 0, menuBG.width, songs[i]);
            item.setFormat("assets/fonts/pmEmpty.ttf", 45, 0xFFFFFFFF, CENTER);
            item.y = 60 + (i * 60);
            item.ID = i;
            item.antialiasing = true;
            item.scrollFactor.set(0,1);
            freeplayGroup.add(item);
        }

        // generate options menu
        optionsGroup = new FlxTypedGroup<FlxSprite>();
        var testText = new FlxText(menuBG.x, 0, FlxG.width, "test of options");
        optionsGroup.add(testText);
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.DOWN) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            if (!focusedOnMenu) {
                if (curSelected < menuItems.length - 1) {
                    // FlxTween.tween(selector, {y: selector.y + 130}, 0.2, {ease: FlxEase.quadInOut});
                    curSelected++;
                    for (i in 0...menuItems.members.length) {
                        if (i == curSelected) {
                            menuItems.members[i].animation.play("pressed");
                        } else {
                            menuItems.members[i].animation.play("idle");
                        }
                    }

                    curSelectedInMenu = 0;

                    switch (curSelected) {
                        case 0:
                            loadStoryMode();
                        case 1:
                            loadFreeplay();
                        case 2:
                            loadOptions();
                    }
                }
            }
            else {
                switch (curSelected) {
                    case 0:
                        if (curSelectedInMenu < storymodeGroup.members.length - 1) {
                            curSelectedInMenu++;
                        }
                    case 1:
                        if (curSelectedInMenu < freeplayGroup.members.length - 1) {
                            curSelectedInMenu++;
                        }
                    case 2:
                        if (curSelectedInMenu < optionsGroup.members.length - 1) {
                            curSelectedInMenu++;
                        }
                }
            }
        }
        if (FlxG.keys.justPressed.UP) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            if (!focusedOnMenu) {
                if (curSelected > 0) {
                    // FlxTween.tween(selector, {y: selector.y - 130}, 0.2, {ease: FlxEase.quadInOut});
                    curSelected--;
                    for (i in 0...menuItems.members.length) {
                        if (i == curSelected) {
                            menuItems.members[i].animation.play("pressed");
                        } else {
                            menuItems.members[i].animation.play("idle");
                        }
                    }

                    curSelectedInMenu = 0;

                    switch (curSelected) {
                        case 0:
                            loadStoryMode();
                        case 1:
                            loadFreeplay();
                        case 2:
                            loadOptions();
                    }
                }
            }
            else {
                if (curSelectedInMenu > 0) {
                    curSelectedInMenu--;
                }
            }
        }

        if (FlxG.keys.justPressed.RIGHT) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            focusedOnMenu = true;
            for (item in menuItems.members) {
                item.alpha = 0.5;
            }
        }
        if (FlxG.keys.justPressed.LEFT) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            focusedOnMenu = false;
            for (item in menuItems.members) {
                item.alpha = 1;
            }
        }

        if (focusedOnMenu)
        {
            switch (curSelected) {
                case 0:
                    for (item in storymodeGroup.members) {
                        if (item.ID == curSelectedInMenu) {
                            item.alpha = 1;
                            FlxG.camera.follow(item, LOCKON, 0.06);
                        } else {
                            item.alpha = 0.5;
                        }
                    }
                case 1:
                    for (item in freeplayGroup.members) {
                        if (item.ID == curSelectedInMenu) {
                            item.alpha = 1;
                            FlxG.camera.follow(item, LOCKON, 0.06);
                        } else {
                            item.alpha = 0.5;
                        }
                        if (item.ID < 0) {
                            item.alpha = 1;
                        }
                    }
                case 2:
                    for (item in optionsGroup.members) {
                        if (item.ID == curSelectedInMenu) {
                            item.alpha = 1;
                            FlxG.camera.follow(item, LOCKON, 0.06);
                        } else {
                            item.alpha = 0.5;
                        }
                        if (item.ID < 0) {
                            item.alpha = 1;
                        }
                    }
            }
        }

        super.update(elapsed);
    }

    function loadStoryMode() {
        remove(freeplayGroup);
        remove(optionsGroup);
        add(storymodeGroup);
    }

    function loadFreeplay() {
        remove(storymodeGroup);
        remove(optionsGroup);
        add(freeplayGroup);
    }

    function loadOptions() {
        remove(storymodeGroup);
        remove(freeplayGroup);
        add(optionsGroup);
    }
}