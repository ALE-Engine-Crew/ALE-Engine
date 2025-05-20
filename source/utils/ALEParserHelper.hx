package utils;

import core.structures.*;

class ALEParserHelper 
{
	public static function getALESong(songJson:Dynamic):ALESong
	{
		if (songJson.format == 'ale-format-v0.1')
			return cast songJson;

		var json:Dynamic = songJson;

		if (json.format == null || json.format != 'psych_v1')
			json = json.song;

		var formattedJson:ALESong = {
            characters: [
                [json.player3 == null ? (json.gfVersion == null ? 'gf' : json.gfVersion) : json.player3, 'extra'],
                [json.player2 == null ? 'dad' : json.player2, 'opponent'],
                [json.player1 == null ? 'bf' : json.player1, 'player']
            ],

			sections: [],

            events: [],

			song: json.song,
			stage: json.stage == null ? (songJson.stage == null ? 'stage' : songJson.stage) : json.stage,

			metadata: {},

			needsVoices: json.needsVoices == null ? true : json.needsVoices,
			speed: json.speed == 0 ? 1 : json.speed,

			bpm: json.bpm == null ? 100 : json.bpm,
			beats: 4,
			steps: 4,

			format: 'ale-format-v0.1'
		}

		var psychSections:Array<PsychSection> = cast json.notes;

		for (section in psychSections)
		{
			var newSection = {
				notes: [],
				focus: section.mustHitSection ? 2 : 1
			};

			for (note in section.sectionNotes)
			{
				newSection.notes.push(   
					[
						note[0],
						note[1] % 4,
						note[2],
						note[3],
						(section.mustHitSection && note[1] <= 3) || (!section.mustHitSection && note[1] >= 4) ? 2 : 1
					]
				);
			}

			formattedJson.sections.push(newSection);
		}
		
		return cast formattedJson;
	}

    public static function getALECharacter(path:String):ALECharacter
    {
        if (Paths.fileExists('characters/' + path + '.json'))
        {
            var theJson:Dynamic = Json.parse(File.getContent(Paths.getPath('characters/' + path + '.json')));

            if (theJson.format == 'ale-format-v0.1')
            {
                return cast theJson;
            } else {
                var newAnims:Array<ALECharacterJSONAnimation> = [];

                var psychAnims:Array<PsychCharacterJSONAnimation> = cast theJson.animations;

                for (anim in psychAnims)
                {
                    newAnims.push(
                        {
                            offset: anim.offsets,
                            looped: anim.loop,
                            framerate: anim.fps,
                            animation: anim.anim,
                            indices: anim.indices,
                            prefix: anim.name
                        }
                    );
                }

                var formattedJson:ALECharacter = {
                    animations: newAnims,

                    image: theJson.image,
                    flipX: theJson.flip_x,
                    antialiasing: !theJson.no_antialiasing,

                    position: theJson.position,
                
                    icon: theJson.healthicon,
                
                    barColor: theJson.healthbar_colors,
                
                    cameraPosition: theJson.camera_position,
                
                    scale: theJson.scale,
                
                    format: 'ale-format-v0.1'
                };

                return cast formattedJson;
            }
        } else {
            return {
                animations: [],

                image: 'characters/BOYFRIEND',
                flipX: false,
                antialiasing: true,
            
                position: [0, 0],
            
                icon: 'bf',
            
                barColor: [255, 255, 255],
            
                cameraPosition: [0, 0],
            
                scale: 1,
            
                format: 'ale-format-v0.1',
            };
        }
    }

	public static function getALEStage(path:Dynamic):ALEStage
	{
        if (Paths.fileExists('stages/' + path + '.json'))
        {
            var data:Dynamic = Json.parse(File.getContent(Paths.getPath('stages/' + path + '.json')));

            if (data.format == 'ale-format-v0.1')
            {
                return cast data;
            } else {
                return cast {
                    opponentsPosition: data.opponent == null ? [[0, 0]] : [data.opponent],
                    playersPosition: data.boyfriend == null ? [[0, 0]] : [data.boyfriend],
                    extrasPosition: data.girlfriend == null ? [[0, 0]] : [data.girlfriend],
    
                    opponentsCamera: data.camera_opponent == null ? [[0, 0]] : [data.camera_opponent],
                    playersCamera: data.camera_boyfriend == null ? [[0, 0]] : [data.camera_boyfriend],
                    extrasCamera: data.camera_girlfriend == null ? [[0, 0]] : [data.camera_girlfriend],
    
                    format: 'ale-format-v0.1',
    
                    cameraZoom: data.defaultZoom,
                    cameraSpeed: data.camera_speed == null ? 1 : data.camera_speed
                };
            }
        } else {
            return cast {
                opponentsPosition: [[0, 0]],
                playersPosition: [[0, 0]],
                extrasPosition: [[0, 0]],

                opponentsCamera: [[0, 0]],
                playersCamera: [[0, 0]],
                extrasCamera: [[0, 0]],

                format: 'ale-format-v0.1',

                cameraZoom: 1,
                cameraSpeed: 1
            }
        }
	}

    public static function getALEDialogueCharacter(name:String):ALEDialogueCharacter
    {
        var data:Dynamic = Json.parse(File.getContent(Paths.getPath('dialogue/' + name + '.json')));

        if (data.format == 'ale-format-v0.1')
            return cast data;

        var formattedJson:ALEDialogueCharacter = {
            image: data.image,
            position: switch(data.dialogue_pos)
                {
                    case 'right':
                        RIGHT;
                    case 'center':
                        CENTERED;
                    default:
                        LEFT;
                },
            format: 'ale-format-v0.1',
            scale: data.scale,
            screenPosition: data.position,
            antialiasing: data.no_antialiasing == null ? true : !data.no_antialiasing,
            animations: []
        }

        var psychAnimArray:Array<PsychDialogueCharacterJSONAnimation> = cast data.animations;

        for (anim in psychAnimArray)
        {
            var formattedAnimation:ALEDialogueCharacterJSONAnimation = {
                animation: anim.anim,
                idleName: anim.idle_name,
                idleOffset: anim.idle_offsets,
                name: anim.loop_name,
                offset: anim.loop_offsets
            };

            formattedJson.animations.push(formattedAnimation);
        }

        return formattedJson;
    }

    public static function getALEDialogue(json:Dynamic):ALEDialogue
    {
        if (json.format == 'ale-format-v0.1')
            return json;
        
        var formattedJson:ALEDialogue = {
            format: 'ale-format-v0.1',

            lines: []
        };

        var psychJson:PsychDialogue = cast json;

        for (line in psychJson.dialogue)
        {
            var formattedLine:ALEDialogueLine = {
                character: line.portrait,
                animation: line.expression,
                text: line.text,
                boxState: cast line.boxState,
                speed: line.speed,
                sound: line.sound
            };

            formattedJson.lines.push(formattedLine);
        }

        return formattedJson;
    }
}