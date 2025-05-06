package other;

class StrumLinesGroup extends FlxTypedGroup<FlxTypedGroup<StrumLine>>
{
    public var extras:FlxTypedGroup<StrumLine>;
    public var opponents:FlxTypedGroup<StrumLine>;
    public var players:FlxTypedGroup<StrumLine>;

    override public function new()
    {
        super();

        extras = new FlxTypedGroup<StrumLine>();
        add(extras);

        opponents = new FlxTypedGroup<StrumLine>();
        add(opponents);

        players = new FlxTypedGroup<StrumLine>();
        add(players);
    }
}