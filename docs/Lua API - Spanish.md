# Wiki de ALE Engine - API de Lua

# Global

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

# Color