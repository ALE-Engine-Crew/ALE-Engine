package utils;

import core.structures.*;

class ALEParserHelper 
{
	public static function getALESong(json:Dynamic):ALESong
	{
		var formattedJson:Dynamic = {};

		if (json.format == 'ale-format-v0.1')
		{
			return cast json;
		} else if (json.format == 'psych_v1') {
			var daJson = json;
			
			formattedJson = {
				song: daJson.song == null ? 'test' : json.song,
				needsVoices: json.needsVoices == null ? true : json.needsVoices,
				speed: daJson.speed == 0 ? 1 : daJson.speed,
				stage: daJson.stage == null ? 'stage' : daJson.stage,
				
				grids: new Array<Dynamic>(),
				events: new Array<Dynamic>(),
				metadata: {},

				bpm: daJson.bpm == null ? 100 : daJson.bpm,
				beats: 4,
				steps: 4,

				format: 'ale-format-v0.1',
			}
			
			var newJson:PsychSong = cast json;

			var sectionsOpponent:Array<Dynamic> = [];
			var sectionsPlayer:Array<Dynamic> = [];

			for (section in newJson.notes)
			{
				var notesPlayer:Array<Dynamic> = [];
				var notesOpponent:Array<Dynamic> = [];

				for (noteArray in section.sectionNotes)
				{
					if ((section.mustHitSection && noteArray[1] <= 3) || (!section.mustHitSection && noteArray[1] >= 4))
						notesPlayer.push(noteArray);
					else
						notesOpponent.push(noteArray);
				}

				sectionsOpponent.push(
					{
						notes: notesOpponent,

						cameraFocusThis: !section.mustHitSection
					}
				);

				sectionsPlayer.push(
					{
						notes: notesPlayer,

						cameraFocusThis: section.mustHitSection
					}
				);
			}

			formattedJson.grids.push(
				{
					sections: sectionsOpponent,
					
					character: json.player2,
					type: 'opponent'
				}
			);

			formattedJson.grids.push(
				{
					sections: sectionsPlayer,
					
					character: json.player1,
					type: 'player'
				}
			);

			formattedJson.grids.push(
				{
					sections: new Array<Dynamic>(),

					character: json.gfVersion == null ? 'gf' : json.gfVersion,
					type: 'extra'
				}
			);

			for (_ in 0...sectionsOpponent.length - 1)
			{
				formattedJson.grids[2].sections.push(
					{
						notes: new Array<Int>(),
		
						cameraFocusThis: false
					}
				);
			}
		} else {
			var daJson = json.song;

			formattedJson = {
				song: daJson.song,
				needsVoices: true,
				speed: daJson.speed == null ? 1 : daJson.speed,
				stage: daJson.stage != null ? daJson.stage : json.stage != null ? json.stage : 'stage',
				
				grids: new Array<Dynamic>(),
				events: new Array<Dynamic>(),
				metadata: {},

				bpm: daJson.bpm,
				beats: 4,
				steps: 4,

				format: 'ale-format-v0.1',
			}

			var newJson:PsychSong = cast json.song;

			var sectionsOpponent:Array<Dynamic> = [];
			var sectionsPlayer:Array<Dynamic> = [];

			for (section in newJson.notes)
			{
				var notesPlayer:Array<Dynamic> = [];
				var notesOpponent:Array<Dynamic> = [];

				for (noteArray in section.sectionNotes)
				{
					if ((section.mustHitSection && noteArray[1] <= 3) || (!section.mustHitSection && noteArray[1] >= 4))
					{
						noteArray[1] = noteArray[1] % 4;
						notesPlayer.push(noteArray);
					} else {
						noteArray[1] = noteArray[1] % 4;
						notesOpponent.push(noteArray);
					}
				}

				sectionsOpponent.push(
					{
						notes: notesOpponent,

						cameraFocusThis: !section.mustHitSection
					}
				);

				sectionsPlayer.push(
					{
						notes: notesPlayer,

						cameraFocusThis: section.mustHitSection
					}
				);
			}

			formattedJson.grids.push(
				{
					sections: sectionsOpponent,
					
					character: json.song.player2,
					type: 'opponent'
				}
			);

			formattedJson.grids.push(
				{
					sections: sectionsPlayer,
					
					character: json.song.player1,
					type: 'player'
				}
			);

			formattedJson.grids.push(
				{
					sections: new Array<Dynamic>(),

					character: json.song.gfVersion == null ? 'gf' : json.song.gfVersion,
					type: 'extra'
				}
			);

			for (_ in 0...sectionsOpponent.length - 1)
			{
				formattedJson.grids[2].sections.push(
					{
						notes: new Array<Int>(),
		
						cameraFocusThis: false
					}
				);
			}
		}

		return formattedJson;
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
}