package other;

import core.enums.ALECharacterType;

import core.enums.NoteState;

class Note extends FlxSprite
{
    public var isSustainNote:Bool = false;

    public var strum:StrumNote;
    
    public var strumTime:Float = 0;

    public var spawned:Bool = false;
    
	public var state:NoteState = NEUTRAL;

    override public function new(noteData:Int, strumTime:Float, strum:StrumNote)
    {
        super();

        this.strumTime = strumTime;

        this.strum = strum;

        makeGraphic(100, 100);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        updatePosition();
    }

	public var direction(get, never):Float;
	function get_direction():Float
        return strum == null ? 90 : strum.direction * Math.PI / 180;

	public var distance(get, never):Float;
	function get_distance():Float
        return 0.45 * (Conductor.songPosition - strumTime) * strum.scrollSpeed * (ClientPrefs.data.downScroll ? 1 : -1);

	public var distanceX(get, never):Float;
	function get_distanceX():Float
		return strum == null ? 0 : strum.x + strum.width / 2 - width / 2 + Math.cos(direction) * distance;

	public var distanceY(get, never):Float;
	function get_distanceY():Float
		return strum == null ? 0 : strum.y + Math.sin(direction) * distance;

    public function updatePosition()
    {
		if (strum == null || state == HIT || !spawned)
            return;

        angle = strum.angle;

        scale.x = strum.scale.x;

        alpha = strum.alpha * (state == LOST ? 0.3 : isSustainNote ? 0.85 : 1);
        
        x = distanceX;

        y = distanceY;

        visible = strum.visible && x > -width && y > -height;

        if (y < -height || Conductor.songPosition > strumTime)
            killFunction();
    }

    public var customKillFunction:Void -> Void;

    public function killFunction()
    {
        if (customKillFunction != null)
            customKillFunction();
    }
}