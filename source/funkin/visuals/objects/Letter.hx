package funkin.visuals.objects;

import core.structures.LetterType;

class Letter extends FlxSprite
{
	public var image(default, set):String;

	public static var allLetterTypes:Map<String, Null<LetterType>> = [
		'a'  => null, 'b'  => null, 'c'  => null, 'd'  => null, 'e'  => null, 'f'  => null,
		'g'  => null, 'h'  => null, 'i'  => null, 'j'  => null, 'k'  => null, 'l'  => null,
		'm'  => null, 'n'  => null, 'o'  => null, 'p'  => null, 'q'  => null, 'r'  => null,
		's'  => null, 't'  => null, 'u'  => null, 'v'  => null, 'w'  => null, 'x'  => null,
		'y'  => null, 'z'  => null,

		'á'  => null, 'é'  => null, 'í'  => null, 'ó'  => null, 'ú'  => null,
		'à'  => null, 'è'  => null, 'ì'  => null, 'ò'  => null, 'ù'  => null,
		'â'  => null, 'ê'  => null, 'î'  => null, 'ô'  => null, 'û'  => null,
		'ã'  => null, 'ë'  => null, 'ï'  => null, 'õ'  => null, 'ü'  => null,
		'ä'  => null, 'ö'  => null, 'å'  => null, 'ø'  => null, 'æ'  => null,
		'ñ'  => null, 'ç'  => {offsetsBold: [0, -11]}, 'š'  => null, 'ž'  => null, 'ý'  => null, 'ÿ'  => null,
		'ß'  => null,
		
		'0'  => null, '1'  => null, '2'  => null, '3'  => null, '4'  => null,
		'5'  => null, '6'  => null, '7'  => null, '8'  => null, '9'  => null,

		'&'  => {offsetsBold: [0, 2]},
		'('  => {offsetsBold: [0, 0]},
		')'  => {offsetsBold: [0, 0]},
		'['  => null,
		']'  => {offsets: [0, -1]},
		'*'  => {offsets: [0, 28], offsetsBold: [0, 40]},
		'+'  => {offsets: [0, 7], offsetsBold: [0, 12]},
		'-'  => {offsets: [0, 16], offsetsBold: [0, 16]},
		'<'  => {offsetsBold: [0, -2]},
		'>'  => {offsetsBold: [0, -2]},
		'\'' => {anim: 'apostrophe', offsets: [0, 32], offsetsBold: [0, 40]},
		'"'  => {anim: 'quote', offsets: [0, 32], offsetsBold: [0, 40]},
		'!'  => {anim: 'exclamation'},
		'?'  => {anim: 'question'},
		'.'  => {anim: 'period'},
		'❝'  => {anim: 'start quote', offsets: [0, 24], offsetsBold: [0, 40]},
		'❞'  => {anim: 'end quote', offsets: [0, 24], offsetsBold: [0, 40]},
		'_'  => null,
		'#'  => null,
		'$'  => null,
		'%'  => null,
		':'  => {offsets: [0, 2], offsetsBold: [0, 8]},
		';'  => {offsets: [0, -2], offsetsBold: [0, 4]},
		'@'  => null,
		'^'  => {offsets: [0, 28], offsetsBold: [0, 38]},
		','  => {anim: 'comma', offsets: [0, -6], offsetsBold: [0, -4]},
		'\\' => {anim: 'back slash', offsets: [0, 0]},
		'/'  => {anim: 'forward slash', offsets: [0, 0]},
		'|'  => null,
		'~'  => {offsets: [0, 16], offsetsBold: [0, 20]},

		'¡'  => {anim: 'inverted exclamation', offsets: [0, -20], offsetsBold: [0, -20]},
		'¿'  => {anim: 'inverted question', offsets: [0, -20], offsetsBold: [0, -20]},
		'{'  => null,
		'}'  => null,
		'•'  => {anim: 'bullet', offsets: [0, 18], offsetsBold: [0, 20]}
	];

	var parent:Alphabet;
	public var alignOffset:Float = 0;
	public var letterOffset:Array<Float> = [0, 0];

	public var row:Int = 0;
	public var rowWidth:Float = 0;
	public var character:String = '?';
	public function new()
	{
		super(x, y);
		image = 'ui/alphabet';
		antialiasing = ClientPrefs.data.antialiasing;
	}
	
	public var curLetterType:LetterType = null;
	public function setupLetter(x:Float, y:Float, ?character:String = null, ?bold:Null<Bool> = null)
	{
		this.x = x;
		this.y = y;

		if (parent != null)
		{
			if (bold == null)
				bold = parent.bold;
			this.scale.x = parent.scaleX;
			this.scale.y = parent.scaleY;
		}
		
		if (character != null)
		{
			this.character = character;
			curLetterType = null;
			var lowercase:String = this.character.toLowerCase();
			if (allLetterTypes.exists(lowercase)) curLetterType = allLetterTypes.get(lowercase);
			else curLetterType = allLetterTypes.get('?');

			var suffix:String = '';
			if (!bold)
			{
				if (isTypeAlphabet(lowercase))
				{
					if (lowercase != this.character)
						suffix = ' uppercase';
					else
						suffix = ' lowercase';
				}
				else suffix = ' normal';
			}
			else suffix = ' bold';

			var alphaAnim:String = lowercase;
			if (curLetterType != null && curLetterType.anim != null) alphaAnim = curLetterType.anim;

			var anim:String = alphaAnim + suffix;
			animation.addByPrefix(anim, anim, 24);
			animation.play(anim, true);
			if (animation.curAnim == null)
			{
				if (suffix != ' bold') suffix = ' normal';
				anim = 'question' + suffix;
				animation.addByPrefix(anim, anim, 24);
				animation.play(anim, true);
			}
		}
		updateHitbox();
	}

	public static function isTypeAlphabet(c:String)
	{
		var ascii = StringTools.fastCodeAt(c, 0);
		return (ascii >= 65 && ascii <= 90)
			|| (ascii >= 97 && ascii <= 122)
			|| (ascii >= 192 && ascii <= 214)
			|| (ascii >= 216 && ascii <= 246)
			|| (ascii >= 248 && ascii <= 255);
	}

	private function set_image(name:String)
	{
		if (frames == null)
		{
			image = name;
			frames = Paths.getSparrowAtlas(name);
			return name;
		}

		var lastAnim:String = null;
		if (animation != null)
		{
			lastAnim = animation.name;
		}
		image = name;
		frames = Paths.getSparrowAtlas(name);
		this.scale.x = parent.scaleX;
		this.scale.y = parent.scaleY;
		alignOffset = 0;
		
		if (lastAnim != null)
		{
			animation.addByPrefix(lastAnim, lastAnim, 24);
			animation.play(lastAnim, true);
			
			updateHitbox();
		}
		return name;
	}

	public function updateLetterTypeOffset()
	{
		if (animation.curAnim == null)
		{
			trace(character);
			return;
		}

		var add:Float = 110;
		if (animation.curAnim.name.endsWith('bold'))
		{
			if (curLetterType != null && curLetterType.offsetsBold != null)
			{
				letterOffset[0] = curLetterType.offsetsBold[0];
				letterOffset[1] = curLetterType.offsetsBold[1];
			}
			add = 70;
		} else {
			if (curLetterType != null && curLetterType.offsets != null)
			{
				letterOffset[0] = curLetterType.offsets[0];
				letterOffset[1] = curLetterType.offsets[1];
			}
		}
		add *= scale.y;
		offset.x += letterOffset[0] * scale.x;
		offset.y += letterOffset[1] * scale.y - (add - height);
	}

	override public function updateHitbox()
	{
		super.updateHitbox();
		updateLetterTypeOffset();
	}
}