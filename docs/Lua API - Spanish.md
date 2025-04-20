# Wiki de ALE Engine - API de Lua

# General

## add

Uso: 
`````````lua
add(tag:String)
`````````

Sirve para Añadir Objetos al Estado / Sub-Estado <br/>
<sub>Solo Sirve con Objetos que son Sub-Clase de FlxBasic</sub>

Ejemplo: 
`````````lua
add('theSprite')
`````````

---

## remove

Uso: 
`````````lua
remove(tag:String)
`````````

Sirve para Remover Objetos del Estado / Sub-Estado <br/>
<sub>Solo Sirve con Objetos que ya Han Sido Añadidos, Obviamente</sub>

Ejemplo: 
`````````lua
remove('theSprite')
`````````

---

## insert

Uso: 
`````````lua
insert(position:Int, tag:String)
`````````

Similar a [add](#add), pero que Inserta el Objeto en una Posición Específica

Ejemplo: 
`````````lua
insert(1, 'theSprite')
`````````

---

## debugPrint

Uso: 
`````````lua
debugPrint(text:Dynamic, ?color:FlxColor)
`````````

Sirve para Mostrar un Texto tanto en la Pantalla como en la Consola

También cual se le Puede Asignar un Color <br/>
<sub>(Opcional)</sub>

Ejemplo: 
`````````lua
debugPrint('ALE Engine Supremacy', colorFromName('RED'))
`````````
<sub>Se Hace Uso de las Funciones de [Color](#color)</sub>

---

## setObjectCameras

Uso: 
`````````lua
setObjectCameras(tag:String, cameras:Array<String>)
`````````

Sirve para Cambiar las Cámaras en donde se Muestra un Objeto

Ejemplo: 
`````````lua
setObjectCameras('mySprite', {'camGame'})
`````````

---

## setVariable

Uso: 
`````````lua
setVariable(name:String, value:Dynamic)
`````````

Sirve para Asignar una Variable al Script

Ejemplo: 
`````````lua
setVariable('epicBool', true)
`````````

---

## setTag

Uso: 
`````````lua
setTag(tag:String, value:Dynamic)
`````````

Sirve para Agregar / Alterar una Etiqueta al / del Script

Ejemplo: 
`````````lua
setTag('epicTag', true)
`````````

---

## switchState

Uso: 
`````````lua
switchState(fullClassPath:String, params:Array<Dynamic>)
`````````

Sirve para Dirigirse a Otro Estado

Ejemplo: 
`````````lua
switchState('funkin.states.CustomState', ['CoolState'])
`````````

---

## switchToCustomState

Uso: 
`````````lua
switchToCustomState(name:String)
`````````

Sirve para Dirigirse a un Estado Personalizado </br>
<sub>Si el Script del Estado no Existe, se Mostrará un Error en la Pantalla</sub>

Ejemplo: 
`````````lua
switchToCustomState('CoolState')
`````````

---

## openSubState

Uso: 
`````````lua
openSubState(fullClassPath:String, params:Array<Dynamic>)
`````````

Sirve para Abrir un Sub-Estado

Ejemplo: 
`````````lua
openSubState('funkin.substates.CustomSubState', ['CoolSubState'])
`````````

<sub>Solo está Disponible para Estados</sub>

---

## openCustomSubState

Uso: 
`````````lua
openCustomSubState(name:String)
`````````

Sirve para Abrir un Sub-Estado Personalizado </br>
<sub>Si el Script del Sub-Estado no Existe, se Mostrará un Error en la Pantalla</sub>

Ejemplo: 
`````````lua
openCustomSubState('CoolSubState')
`````````

<sub>Solo está Disponible para Estados</sub>

---

## close

Uso / Ejemplo: 
`````````lua
close()
`````````

Sirve para Cerrar el Sub-Estado Actual

<sub>Solo está Disponible para Sub-Estados</sub>

---

# Reflect

## getProperty

Uso: 
`````````lua
getProperty(variable:String, ?allowMaps:Bool = false)
`````````

Sirve para Obtener una Propiedad de una Variable, ya sea Propia del Script o Propia del Estado / Sub-Estado en donde se está Ejecutando

Ejemplo: 
`````````lua
getProperty('playerIcon.scale.x')
`````````

---

## setProperty

Uso: 
`````````lua
setProperty(variable:String, properties:Dynamic)
`````````

Sirve para Asignar una Propiedad de una Variable, ya sea Propia del Script o Propia del Estado / Sub-Estado en donde se está Ejecutando

Ejemplo: 
`````````lua
setProperty('playerIcon', {scale = {x = 2, y = 2}, {x = 100, y = 100}})
`````````

---

## getPropertyFromClass

Uso: 
`````````lua
getPropertyFromClass(classVar:String, variable:String, ?allowMaps:Bool = false)
`````````

Sirve para Obtener el Valor de una Variable que se Encuentra en la Clase donde se Especifique

Ejemplo: 
`````````lua
getPropertyFromClass('core.config.ClientPrefs', 'antialiasing')
`````````

---

## setPropertyFromClass

Uso: 
`````````lua
setPropertyFromClass(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false)
`````````

Sirve para Asignar un Valor a una Variable que se Encuentra en la Clase donde se Especifique

Ejemplo: 
`````````lua
setPropertyFromClass('core.config.ClientPrefs', 'antialiasing', true)
`````````

---

## getPropertyFromGroup

Uso: 
`````````lua
getPropertyFromGroup(obj:String, index:Int, variable:Dynamic, ?allowMaps:Bool = false)
`````````

Sirve para Obtener un Valor de un Grupo

Ejemplo: 
`````````lua
getPropertyFromGroup('characters', 1, 'icon')
`````````

---

## setPropertyFromGroup

Uso: 
`````````lua
setPropertyFromGroup(obj:String, index:Int, variable:Dynamic, value:Dynamic, ?allowMaps:Bool = false)
`````````

Sirve para Asignar un Valor en un Grupo

Ejemplo: 
`````````lua
setPropertyFromGroup('characters', 1, 'icon', 'dad')
`````````

---

## removeFromGroup

Uso: 
`````````lua
removeFromGroup(obj:String, index:Int, dontDestroy:Bool = false)
`````````

Sirve para Remover un Miembro de un Grupo

Ejemplo: 
`````````lua
removeFromGroup('characters', 1, true)
`````````

---

## callMethod

Uso: 
`````````lua
callMethod(funcToRun:String, ?args:Array<Dynamic> = null)
`````````

Sirve para Llamar a una Función y Obtener su Valor

Ejemplo: 
`````````lua
callMethod('resyncVoices')
`````````

---

## callMethodFromClass

Uso: 
`````````lua
callMethodFromClass(className:String, funcToRun:String, ?args:Array<Dynamic> = null)
`````````

Sirve para Llamar a una Función de la Clase Especificada y Obtener su Valor

Ejemplo: 
`````````lua
callMethodFromClass('utils.CoolUtil', 'browserLoad', {'https://www.youtube.com/watch?v=dQw4w9WgXcQ'})
`````````

---

## createInstance

Uso: 
`````````lua
createInstance(variableToSave:String, className:String, ?args:Array<Dynamic> = null)
`````````

Sirve para Crear una instancia de la Clase Indicada y Guardarla en una Variable/Etiqueta

Ejemplo: 
`````````lua
createInstance('uselessIcon', 'funkin.visuals.objects.HealthIcon', {'dad'})
`````````

---

## instanceArg

Uso: 
`````````lua
instanceArg(instanceName:String, ?className:String = null)
`````````

Sirve para Formatear una Cadena de Manera Específica para Indicar a las Funciones Mencionadas Anteriormente que la Cadena debe ser una Instancia </br>
<sub>Se Utiliza con ```callMethod```, ```callMethodFromClass```, ```createInstance```, ```setProperty```, ```setPropertyFromGroup```, ```setPropertyFromClass```</sub>

Ejemplo: 
`````````lua
setVariable('firstCharacter', instanceArg('characters.members[0]'))
`````````

---

# Sistema de Archivos

## pathExists

Uso: 
`````````lua
pathExists(path:String)
`````````

Sirve para Verificar si un Archivo / Carpeta Existe o No dentro de la Carpeta ```assets``` o ```mods/Mod```

Ejemplo: 
`````````lua
pathExists('data.json')
`````````

---

## getFileContent

Uso: 
`````````lua
getFileContent(path:String)
`````````

Sirve para Obtener el Contenido de un Archivo

Ejemplo: 
`````````lua
getFileContent('data.json')
`````````

---

## createFile

Uso: 
`````````lua
createFile(path:String, value:String)
`````````

Sirve para Crear un Archivo dentro de la Carpeta de Tu Mod

Ejemplo: 
`````````lua
createFile('README.txt', 'ALE Engine Supremacy')
`````````

---

## deleteFile

Uso: 
`````````lua
deleteFile(path:String)
`````````

Sirve para Eliminar un Archivo que se Encuentra dentro de la Carpeta de tu Mod

Ejemplo: 
`````````lua
deleteFile('data.json')
`````````

---

## createFolder

Uso: 
`````````lua
createFolder(path:String)
`````````

Sirve para Crear una Carpeta dentro de la Carpeta de tu Mod

Ejemplo: 
`````````lua
createFolder('extraFolder')
`````````

---

## deleteFolder

Uso: 
`````````lua
deleteFolder(path:String)
`````````

Sirve para Eliminar una Carpeta dentro de la Carpeta de tu Mod

Ejemplo: 
`````````lua
deleteFolder('extraFolder')
`````````

---

## readFolder

Uso: 
`````````lua
readFolder(path:String)
`````````

Sirve para Leer una Carpeta y Obtener el Nombre de Cada uno de sus Archivos Junto con su Extensión

Ejemplo: 
`````````lua
readFolder('data')
`````````

---

## pathIsFolder

Uso: 
`````````lua
pathIsFolder(path:String)
`````````

Sirve para Saber la Ruta Indicada es o no una Carpeta

Ejemplo: 
`````````lua
pathIsFolder('data')
`````````

---

# FlxSprite API

## newSprite
**Uso:**
`````````lua
newSprite(tag:String, ?x:Float, ?y:Float, ?sprite:String)
`````````

Crea una Instancia de FlxSprite

**Ejemplo:**
`````````lua
newSprite('mySprite', 10, 10, 'menuBG')
`````````

---

## loadGraphic
**Uso:**
`````````lua
loadGraphic(tag:String, name:String, ?animated:Bool = false, ?frameWidth:Int = 0, frameHeight:Int = 0)
`````````

Sirve para Cargar una Imágen a un Sprite

**Ejemplo:**
`````````lua
loadGraphic('mySprite', 'menuBGMagenta')
`````````

---

## makeGraphic
**Uso:**
`````````lua
makeGraphic(tag:String, width:Int, height:Int, ?color:FlxColor = FlxColor.WHITE)
`````````

Sirve para Crear un Gráfico y Asignárselo a un Sprite

**Ejemplo:**
`````````lua
makeGraphic('mySprite', 100, 100, colorFromName('blue'))
`````````

---

## playAnimation
**Uso:**
`````````lua
playAnimation(tag:String, name:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
`````````

Sirve para Reproducir una Animación que ya fue Añadida al Sprite

**Ejemplo:**
`````````lua
playAnimation('mySprite', 'epicAnim', true, false)
`````````

---

## newGradient

Uso: 
`````````lua
newGradient(tag:String, width:Int, height:Int, colors:Array<FlxColor>, ?chunkSize:Int = 1, ?rotation:Int = 90, ?interpolate:Bool = true)
`````````

Sirve para Crear FlxSprites que se ve como Gradiente

Ejemplo: 
`````````lua
newGradient('myGradient', 1280, 720, {colorFromName('black'), colorFromName('transparent')}, 1, 90, true)
`````````

---

## getSparrowAtlas

Uso: 
`````````lua
getSparrowAtlas(tag:String, path:String)
`````````

Sirve para Cargar un Sprite Animado que Hace uso de XML

Ejemplo: 
`````````lua
getSparrowAtlas('mySprite', 'characters/BOYFRIEND')
`````````

---

## addAnimationByPrefix

Uso: 
`````````lua
addAnimationByPrefix(tag:String, name:String, prefix:String, ?frameRate:Float, ?looped:Bool, ?flipX:Bool, ?flipY:Bool)
`````````

Sirve para Añadir una Animación a un Sprite Animado

Ejemplo: 
`````````lua
addAnimationByPrefix('mySprite', 'epicAnim', 'epicAnim', 24, true, true, false)
`````````

---

## addAnimationByIndices

Uso: 
`````````lua
addAnimationByIndices(tag:String, name:String, prefix:String, indices:Array<Int>, ?frameRate:Float, ?looped:Bool, flipX:Bool, flipY:Bool)
`````````

Sirve para Añadir una Animación a un Sprite Animado basándose en Índices

Ejemplo: 
`````````lua
addAnimationByIndices('mySprite', 'epicAnim', 'epicAnim', {0, 12, 20}, 24, true, true, false)
`````````

---

## updateHitbox

Uso: 
`````````lua
updateHitbox(tag:String)
`````````

Sirve para Actualizar la Hitbox de un Sprite

Ejemplo: 
`````````lua
updateHitbox('mySprite')
`````````

---

# FlxText API

## newText
**Uso:**
`````````lua
newText(tag:String, ?x:Float, ?y:Float, ?width:Float, ?text:String, ?size:Int)
`````````

Sirve para Crear una Instancia de FlxText

**Ejemplo:**
`````````lua
newText('myText', 10, 100, 1280, 'ALE Engine Supremacy', 24)
`````````

---

## applyTextMarkup
**Uso:**
`````````lua
applyTextMarkup(tag:String, text:String, rules:Array<Array<Dynamic>>)
`````````

Sirve para Asignarle Varios Colores a la Vez a un Texto

**Ejemplo:**
`````````lua
applyTextMarkup('myText', '*ALE* #Engine# %Supremacy%', {
  {'*', colorFromName('cyan')},
  {'#', colorFromName('red')},
  {'%', colorFromName('green')}
})
`````````

---

## setTextFormat
**Uso:**
`````````lua
setTextFormat(tag:String, ?font:String, ?size:Int, ?color:FlxColor, ?alignment:String, ?borderStyle:String, ?borderColor:FlxColor)
`````````

Sirve para Cambiar la Fuente, el Tamaño, el Color, la Alineación, el Estilo del borde y el Color del Borde a un Texto

**Ejemplo:**
`````````lua
setTextFormat('myText', 'vcr.ttf', 24, colorFromName('white'), 'center', 'shadow', colorFromName('black'))
`````````

---

# FlxSound API

## newSound
**Uso:**
`````````lua
newSound(tag:String, sound:String)
`````````

Sirve para Crear una Instancia de FlxSound

**Ejemplo:**
`````````lua
newSound('mySound', 'scrollMenu')
`````````

---

## playSound
**Uso:**
`````````lua
playSound(tag:String)
`````````

Sirve para Reproducir un Sonido

**Ejemplo:**
`````````lua
playSound('mySound')
`````````

---

## playMusic
**Uso:**
`````````lua
playMusic(sound:String)
`````````

Sirve para Reproducir Música en el Juego

**Ejemplo:**
`````````lua
playMusic('freakyMenu')
`````````

---

## pauseSound
**Uso:**
`````````lua
pauseSound(tag:String)
`````````

Sirve para Pausar un Sonido

**Ejemplo:**
`````````lua
pauseSound('mySound')
`````````

---

## resumeSound
**Uso:**
`````````lua
resumeSound(tag:String)
`````````

Sirve para Despausar un Sonido

**Ejemplo:**
`````````lua
resumeSound('mySound')
`````````

---

## pauseSound

Uso: 
`````````lua
pauseSound(tag:String)
`````````

Sirve para Pausar un Sonido

Ejemplo: 
`````````lua
pauseSound('mySound')
`````````

---

## resumeSound

Uso: 
`````````lua
resumeSound(tag:String)
`````````

Sirve para Despausar un Sonido

Ejemplo: 
`````````lua
resumeSound('mySound')
`````````

---

## stopSound

Uso: 
`````````lua
stopSound(tag:String)
`````````

Sirve para Parar un Sonido

Ejemplo: 
`````````lua
stopSound('mySound')
`````````

---

## playMusic

Uso: 
`````````lua
playMusic(sound:String)
`````````

Sirve para Reproducir Música en el Juego

Ejemplo: 
`````````lua
playMusic('freakyMenu')
`````````

---

## pauseMusic

Uso / Ejemplo: 
`````````lua
pauseMusic()
`````````

Sirve para Pausar la Música del Juego

---

## stopMusic

Uso / Ejemplo: 
`````````lua
stopMusic()
`````````

Sirve para Parar la Música del Juego

---

## resumeMusic

Uso / Ejemplo: 
`````````lua
resumeMusic()
`````````

Sirve para Despausar la Música del Juego

---

## playSoundFile

Uso: 
`````````lua
playSoundFile(path:String, ?volume:Float = 1)
`````````

Sirve para Correr un Sonido

Ejemplo: 
`````````lua
playSoundFile('scrollMenu', 1)
`````````

---

# Color

## colorFromString

Uso: 
`````````lua
colorFromString(color:String)
`````````

Sirve para Obtener un Color por medio de un String que Contenga su Código Hexadecimal

Ejemplo: 
`````````lua
colorFromString('5DE2E7')
`````````

---

## colorFromRGB

Uso: 
`````````lua
colorFromRGB(r:Int, g:Int, b:Int)
`````````

Sirve para Obtener un Color por medio de su RGB

Ejemplo: 
`````````lua
colorFromRGB(93, 226, 231)
`````````

---

## colorFromName

Uso: 
`````````lua
colorFromName(name:String)
`````````

Sirve para Obtener un Color por medio de su Nombre

Ejemplo: 
`````````lua
colorFromName('red')
`````````

---

# FlxTween

## tween

Uso: 
`````````lua
tween(tag:String, vars:String, valueTypes:Dynamic, duration:Float, ?options:Dynamic)
`````````

Sirve para Crear y Correr un FlxTween

Ejemplo: 
`````````lua
tween('myTween', 'mySprite.scale', {x = 5, y = 5}, 1, {ease = 'circInOut', type = 'pingpong'})
`````````

---

## cancelTween

Uso: 
`````````lua
cancelTween(tag:String)
`````````

Sirve para Cancelar un Tween

Ejemplo: 
`````````lua
cancelTween('myTween')
`````````

---

# FlxTimer

## newTimer

Uso: 
`````````lua
newTimer(tag:String)
`````````

Sirve para Crear un FlxTimer

Ejemplo: 
`````````lua
newTimer('myTimer')
`````````

---

## startTimer

Uso: 
`````````lua
startTimer(tag:String, time:Float = 1, loops:Int)
`````````

Sirve para Correr un Timer ya Creado

Ejemplo: 
`````````lua
startTimer('myTimer', 1, 1)
`````````

---

## cancelTimer
**Uso:**
`````````lua
cancelTimer(tag:String)
`````````

Sirve para Cancelar un Timer que esté Corriendo

**Ejemplo:**
`````````lua
cancelTimer('myTimer')
`````````

---

## resetTimer
**Uso:**
`````````lua
resetTimer(tag:String, ?newTime:Float = -1)
`````````

Sirve para Reiniciar un Timer y Reajustar su Duración de forma Opcional

**Ejemplo:**
`````````lua
resetTimer('myTimer', 0.5)
`````````

---

## runTimer
**Uso:**
`````````lua
runTimer(tag:String, time:Float = 1, loops:Int = 1)
`````````

Sirve para Crear y Correr un Timer

**Ejemplo:**
`````````lua
runTimer('fastTimer', 0.5, 1)
`````````