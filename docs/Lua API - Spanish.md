# Wiki de ALE Engine - API de Lua

# General

## add

Uso: `add(tag:String)`

Sirve para Añadir Objetos al Estado / Sub-Estado <br/>
<sub>Solo Sirve con Objetos que son Sub-Clase de FlxBasic</sub>

Ejemplo: `add('theSprite')`

---

## remove

Uso: `remove(tag:String)`

Sirve para Remover Objetos del Estado / Sub-Estado <br/>
<sub>Solo Sirve con Objetos que ya Han Sido Añadidos, Obviamente</sub>

Ejemplo: `remove('theSprite')`

---

## insert

Uso: `insert(position:Int, tag:String)`

Similar a [add](#add), pero que Inserta el Objeto en una Posición Específica

Ejemplo: `insert(1, 'theSprite')`

---

## debugPrint

Uso: `debugPrint(text:Dynamic, ?color:FlxColor)`

Sirve para Mostrar un Texto tanto en la Pantalla como en la Consola

También cual se le Puede Asignar un Color <br/>
<sub>(Opcional)</sub>

Ejemplo: `debugPrint('ALE Engine Supremacy', colorFromName('RED'))` </br>
<sub>Se Hace Uso de las Funciones de [Color](#color)</sub>

---

## setObjectCameras

Uso: `setObjectCameras(tag:String, cameras:Array<String>)`

Sirve para Cambiar las Cámaras en donde se Muestra un Objeto

---

## switchState

Uso: `switchState(fullClassPath:String, params:Array<Dynamic>)`

Sirve para Dirigirse a Otro Estado

Ejemplo: `switchState('funkin.states.CustomState', ['CoolState'])`

---

## switchToCustomState

Uso: `switchToCustomState(name:String)`

Sirve para Dirigirse a un Estado Personalizado </br>
<sub>Si el Script del Estado no Existe, se Mostrará un Error en la Pantalla</sub>

Ejemplo: `switchToCustomState('CoolState')`

---

## openSubState

Uso: `openSubState(fullClassPath:String, params:Array<Dynamic>)`

Sirve para Abrir un Sub-Estado

Ejemplo: `openSubState('funkin.substates.CustomSubState', ['CoolSubState'])`

<sub>Solo está Disponible para Estados</sub>

---

## openCustomSubState

Uso: `openCustomSubState(name:String)`

Sirve para Abrir un Sub-Estado Personalizado </br>
<sub>Si el Script del Sub-Estado no Existe, se Mostrará un Error en la Pantalla</sub>

Ejemplo: `openCustomSubState('CoolSubState')`

<sub>Solo está Disponible para Estados</sub>

---

## close

Uso / Ejemplo: `close()`

Sirve para Cerrar el Sub-Estado Actual

<sub>Solo está Disponible para Sub-Estados</sub>

---

# Reflect

## setVariable

Uso: `setVariable(tag:String, value:Dynamic)`

Sirve para Crear una Variable / Etiqueta

Ejemplo: `serVariable('age', 18)`

## getProperty

Uso: `getProperty(variable:String, ?allowMaps:Bool = false)`

Sirve para Obtener una Propiedad de una Variable, ya sea Propia del Script o Propia del Estado / Sub-Estado en donde se está Ejecutando

Ejemplo: `getProperty('playerIcon.scale.x')`

---

## setProperty

Uso: `setProperty(variable:String, value:Dynamic, allowMaps:Bool = false)`

Sirve para Asignar una Propiedad de una Variable, ya sea Propia del Script o Propia del Estado / Sub-Estado en donde se está Ejecutando

Ejemplo: `setProperty('playerIcon.y', 100)`

---

## getPropertyFromClass

Uso: `getPropertyFromClass(classVar:String, variable:String, ?allowMaps:Bool = false)`

Sirve para Obtener el Valor de una Variable que se Encuentra en la Clase donde se Especifique

Ejemplo: `getPropertyFromClass('core.config.ClientPrefs', 'antialiasing')`

---

## setPropertyFromClass

Uso: `setPropertyFromClass(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false)`

Sirve para Asignar un Valor a una Variable que se Encuentra en la Clase donde se Especifique

Ejemplo: `setPropertyFromClass('core.config.ClientPrefs', 'antialiasing', true)`

---

## getPropertyFromGroup

Uso: `getPropertyFromGroup(obj:String, index:Int, variable:Dynamic, ?allowMaps:Bool = false)`

Sirve para Obtener un Valor de un Grupo

Ejemplo: `getPropertyFromGroup('characters', 1, 'icon')`

---

## setPropertyFromGroup

Uso: `setPropertyFromGroup(obj:String, index:Int, variable:Dynamic, value:Dynamic, ?allowMaps:Bool = false)`

Sirve para Asignar un Valor en un Grupo

Ejemplo: `setPropertyFromGroup('characters', 1, 'icon', 'dad')`

---

## removeFromGroup

Uso: `removeFromGroup(obj:String, index:Int, dontDestroy:Bool = false)`

Sirve para Remover un Miembro de un Grupo

Ejemplo: `removeFromGroup('characters', 1, true)`

---

## callMethod

Uso: `callMethod(funcToRun:String, ?args:Array<Dynamic> = null)`

Sirve para Llamar a una Función y Obtener su Valor

Ejemplo: `callMethod('resyncVoices')`

---

## callMethodFromClass

Uso: `callMethodFromClass(className:String, funcToRun:String, ?args:Array<Dynamic> = null)`

Sirve para Llamar a una Función de la Clase Especificada y Obtener su Valor

Ejemplo: `callMethodFromClass('utils.CoolUtil', 'browserLoad', {'https://www.youtube.com/watch?v=dQw4w9WgXcQ'})`

---

## createInstance

Uso: `createInstance(variableToSave:String, className:String, ?args:Array<Dynamic> = null)`

Sirve para Crear una instancia de la Clase Indicada y Guardarla en una Variable/Etiqueta

Ejemplo: `createInstance('uselessIcon', 'funkin.visuals.objects.HealthIcon', {'dad'})`

---

## instanceArg

Uso: `instanceArg(instanceName:String, ?className:String = null)`

Sirve para Formatear una Cadena de Manera Específica para Indicar a las Funciones Mencionadas Anteriormente que la Cadena debe ser una Instancia </br>
<sub>Se Utiliza con `callMethod`, `callMethodFromClass`, `createInstance`, `setProperty`, `setPropertyFromGroup`, `setPropertyFromClass`</sub>

Ejemplo: `setVariable('firstCharacter', instanceArg('characters.members[0]'))`

---

# Sistema de Archivos

## pathExists

Uso: `pathExists(path:String)`

Sirve para Verificar si un Archivo / Carpeta Existe o No dentro de la Carpeta `assets` o `mods/Mod`

Ejemplo: `pathExists('data.json')`

---

## getFileContent

Uso: `getFileContent(path:String)`

Sirve para Obtener el Contenido de un Archivo

Ejemplo: `getFileContent('data.json')`

---

## createFile

Uso: `createFile(path:String, value:String)`

Sirve para Crear un Archivo dentro de la Carpeta de Tu Mod

Ejemplo: `createFile('README.txt', 'ALE Engine Supremacy')`

---

## deleteFile

Uso: `deleteFile(path:String)`

Sirve para Eliminar un Archivo que se Encuentra dentro de la Carpeta de tu Mod

Ejemplo: `deleteFile('data.json')`

---

## createFolder

Uso: `createFolder(path:String)`

Sirve para Crear una Carpeta dentro de la Carpeta de tu Mod

Ejemplo: `createFolder('extraFolder')`

---

## deleteFolder

Uso: `deleteFolder(path:String)`

Sirve para Eliminar una Carpeta dentro de la Carpeta de tu Mod

Ejemplo: `deleteFolder('extraFolder')`

---

## readFolder

Uso: `readFolder(path:String)`

Sirve para Leer una Carpeta y Obtener el Nombre de Cada uno de sus Archivos Junto con su Extensión

Ejemplo: `readFolder('data')`

---

## pathIsFolder

Uso: `pathIsFolder(path:String)`

Sirve para Saber la Ruta Indicada es o no una Carpeta

Ejemplo: `pathIsFolder('data)`

---

# Color