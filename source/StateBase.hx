package;

import engine.Conductor;
import flixel.addons.ui.FlxUIState;

class StateBase extends FlxUIState {
    private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

    override function create() {
        if (transIn != null) {
            trace('reg ${transIn.region}');
        }

        super.create();
    }

    override function update(elapsed:Float) {
        var oldStep = curStep;

        updateCurStep();
        updateBeat();

        if (oldStep != curStep && curStep > 0) {
            stepHit();
        }

        super.update(elapsed);
    }

    private function updateBeat() {
        curBeat = Math.floor(curStep / 4);
    }

    private function updateCurStep() {
        curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
    }

    public function stepHit() {
        if (curStep % 4 == 0) {
            beatHit();
        }
    }

    public function beatHit() {
        // literally nothing
    }
}