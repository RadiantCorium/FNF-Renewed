package engine;

typedef Week = {
    public var name:String;
    public var songs:Array<String>;
}

typedef Weeks = {
    public var weeks:Array<Week>;
}

typedef Chart = {
    song:Song
}

typedef Song = {
    var player2:String;
    var player1:String;
    var speed:Float;
    var needsVoices:Bool;
    var sectionLengths:Array<Float>;
    var song:String;
    var notes:Array<Section>;
    var bpm:Int;
    var sections:Int;
    var validScore:Bool;
    var stageName:String;
}

typedef Section = {
    var mustHitSection:Bool;
    var typeOfSection:Int;
    var lengthInSteps:Int;
    var sectionNotes:Array<Array<Int>>;
    var altAnim:Bool;
}

enum Difficulty { // uhh no difficulties cause i am dum dum and forgot to add them
    EASY;
    NORMAL;
    HARD;
}

typedef Stages = {
    stages:Array<Stage>
}

typedef Stage = {
    var name:String;
    var camZoom:Float;
    var background:String;
    var bgX:Float;
    var bgY:Float;
    var dadX:Float;
    var dadY:Float;
    var bfX:Float;
    var bfY:Float;
    var gfX:Float;
    var gfY:Float;
    var customLib:String;
    var sprites:Array<StageSprite>;
}

typedef StageSprite = {
    var img:String;
    var id:Int;
    var x:Float;
    var y:Float;
    var scrollFactorX:Float;
    var scrollFactorY:Float;
}