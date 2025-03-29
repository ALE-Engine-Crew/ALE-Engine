package utils.scripting.lua;

class LuaText extends LuaPresetBase
{
    public function new(lua)
    {
        super(lua);

        set('newText', function(tag:String, ?x:Float, ?y:Float, ?width:Float, ?text:String, ?size:Int)
            {
                
            }
        );
    }
}