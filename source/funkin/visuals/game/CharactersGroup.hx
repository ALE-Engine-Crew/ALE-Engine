package funkin.visuals.game;

class CharactersGroup extends FlxTypedGroup<FlxTypedGroup<Character>>
{
    public var extras:FlxTypedGroup<Character>;
    public var opponents:FlxTypedGroup<Character>;
    public var players:FlxTypedGroup<Character>;

    override public function new()
    {
        super();

        extras = new FlxTypedGroup<Character>();
        add(extras);

        opponents = new FlxTypedGroup<Character>();
        add(opponents);

        players = new FlxTypedGroup<Character>();
        add(players);
    }

    public function getGroups():Array<FlxTypedGroup<Character>>
        return [extras, opponents, players];
}