// Tipos de ubicaciones de datos
// 	1.	storage:
// 	•	Representa datos que se almacenan permanentemente en la blockchain.
// 	•	Las variables de estado (state variables) siempre están en storage.
// 	•	Es costoso en términos de gas, ya que escribir en storage implica un costo adicional.

// 	2.	memory:
// 	•	Representa datos temporales que se usan solo durante la ejecución de una función.
// 	•	Los datos en memory no persisten después de que la función termina.
// 	•	Más económico que storage para operaciones temporales.

// 	3.	calldata:
// 	•	Es una ubicación de datos especial para parámetros de entrada de funciones externas (external).
// 	•	calldata es solo de lectura y no puede ser modificado.
// 	•	Es la opción más barata, ideal para funciones que solo necesitan consultar datos.
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract DataLocations {
    // Variables de estado en `storage`
    uint256[] public arr;
    mapping(uint256 => address) map;

    struct MyStruct {
        uint256 foo;
    }

    // Mapping para estructuras
    mapping(uint256 => MyStruct) myStructs;

    // Función que utiliza variables de estado
    function f() public {
        // Llamamos a la función `_f` pasando variables de estado (`storage`)
        _f(arr, map, myStructs[1]);

        // Obtenemos un struct de un mapping y lo almacenamos en `storage`
        MyStruct storage myStruct = myStructs[1];
        myStruct.foo = 42; // Modifica directamente en la blockchain

        // Creamos un struct temporal en `memory`
        MyStruct memory myMemStruct = MyStruct(0);
        myMemStruct.foo = 100; // Solo existe durante la ejecución de esta función
    }

    // Función interna que opera con parámetros en `storage`
    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // Operaciones con variables en `storage`
        _arr.push(1);
        _map[1] = msg.sender;
        _myStruct.foo = 123;
    }

    // Función que acepta y retorna datos en `memory`
    function g(uint256[] memory _arr) public returns (uint256[] memory) {
        // Modificamos el array en `memory` (temporalmente)
        _arr[0] = 42;
        return _arr;
    }

    // Función que utiliza `calldata`
    function h(uint256[] calldata _arr) external {
        // Leemos datos directamente desde `calldata` (no modificable)
        uint256 firstElement = _arr[0];
        // Nota: No se puede hacer `_arr[0] = 10;` porque `calldata` es solo de lectura.
    }
}
