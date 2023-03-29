package engine;

import flixel.FlxG;
import util.Paths;
import flixel.FlxSprite;

enum NoteType {
    LEFT;
    DOWN;
    UP;
    RIGHT;
}

class Note extends FlxSprite {
    var strumTime:Int;

    public override function new(strumTime:Int, x:Float, type:NoteType, hasToHit:Bool) {
        super(x,FlxG.height + 150);
        this.strumTime = strumTime;
        frames = Paths.getSparrowAtlas("NOTE_assets");
        switch (type) {
            case LEFT:
                animation.addByPrefix("idle", "purple0000");
            case DOWN:
                animation.addByPrefix("idle", "blue0000");
            case UP:
                animation.addByPrefix("idle", "green0000");
            case RIGHT:
                animation.addByPrefix("idle", "red0000");
        }
        
        animation.play("idle");
    }
}

class SustainNote extends FlxSprite {
    var strumTime:Int;

    public override function new(strumTime:Int, x:Float, type:NoteType, hasToHit:Bool, isEnd:Bool) {
        super(x,FlxG.height + 150);
        this.strumTime = strumTime;
        frames = Paths.getSparrowAtlas("NOTE_assets");
        if (!isEnd) {
            switch (type) {
                case LEFT:
                    animation.addByPrefix("idle", "purple hold piece0000");
                case DOWN:
                    animation.addByPrefix("idle", "blue hold piece0000");
                case UP:
                    animation.addByPrefix("idle", "green hold piece0000");
                case RIGHT:
                    animation.addByPrefix("idle", "red hold piece0000");
            }
        }
        else {
            switch (type) {
                case LEFT:
                    animation.addByPrefix("idle", "purple hold end0000");
                case DOWN:
                    animation.addByPrefix("idle", "blue hold end0000");
                case UP:
                    animation.addByPrefix("idle", "green hold end0000");
                case RIGHT:
                    animation.addByPrefix("idle", "red hold end0000");
            }
        }
        
        
        animation.play("idle");
    }
}