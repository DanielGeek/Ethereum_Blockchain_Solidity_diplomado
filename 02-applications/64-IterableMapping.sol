// Iterable Mapping

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Estructura de mapeo iterable
 * @dev Permite almacenar claves y valores de forma iterable, ya que los mappings en Solidity no permiten iteración nativa.
 */
library AddressToUintMap {
    struct IterableMap {
        address[] keyList; // Lista de claves para iterar
        mapping(address => uint256) valueStore; // Mapeo de clave a valor
        mapping(address => uint256) keyIndex; // Índice de cada clave en el array
        mapping(address => bool) exists; // Indica si una clave ha sido insertada
    }

    /**
     * @dev Obtiene el valor almacenado para una dirección específica.
     */
    function getValue(IterableMap storage map, address key) public view returns (uint256) {
        return map.valueStore[key];
    }

    /**
     * @dev Obtiene la clave en una posición específica del array.
     */
    function getKeyByIndex(IterableMap storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keyList[index];
    }

    /**
     * @dev Retorna el número total de claves almacenadas.
     */
    function getTotalKeys(IterableMap storage map) public view returns (uint256) {
        return map.keyList.length;
    }

    /**
     * @dev Inserta o actualiza un valor en el mapeo. Si la clave ya existe, solo actualiza el valor.
     */
    function insertOrUpdate(IterableMap storage map, address key, uint256 val) public {
        if (map.exists[key]) {
            map.valueStore[key] = val;
        } else {
            map.exists[key] = true;
            map.valueStore[key] = val;
            map.keyIndex[key] = map.keyList.length;
            map.keyList.push(key);
        }
    }

    /**
     * @dev Elimina una clave del mapeo y reorganiza el array para mantener la coherencia.
     */
    function deleteKey(IterableMap storage map, address key) public {
        if (!map.exists[key]) {
            return;
        }

        delete map.exists[key];
        delete map.valueStore[key];

        uint256 index = map.keyIndex[key];
        address lastKey = map.keyList[map.keyList.length - 1];

        map.keyIndex[lastKey] = index;
        delete map.keyIndex[key];

        map.keyList[index] = lastKey;
        map.keyList.pop();
    }
}

/**
 * @title Prueba del mapeo iterable
 * @dev Implementa la biblioteca y ejecuta pruebas para validar su funcionamiento.
 */
contract IterableMappingTest {
    using AddressToUintMap for AddressToUintMap.IterableMap;

    AddressToUintMap.IterableMap private testMap;

    /**
     * @dev Ejecuta un conjunto de operaciones para verificar el funcionamiento del mapeo iterable.
     */
    function runTests() public {
        testMap.insertOrUpdate(address(0), 0);
        testMap.insertOrUpdate(address(1), 100);
        testMap.insertOrUpdate(address(2), 200); // Inserta un nuevo valor
        testMap.insertOrUpdate(address(2), 200); // Actualiza el valor existente
        testMap.insertOrUpdate(address(3), 300);

        // Verifica que los valores insertados coincidan con los valores esperados
        for (uint256 i = 0; i < testMap.getTotalKeys(); i++) {
            address key = testMap.getKeyByIndex(i);
            assert(testMap.getValue(key) == i * 100);
        }

        testMap.deleteKey(address(1));

        // Luego de eliminar address(1), los valores restantes deben reorganizarse correctamente
        // Claves esperadas: [address(0), address(3), address(2)]
        assert(testMap.getTotalKeys() == 3);
        assert(testMap.getKeyByIndex(0) == address(0));
        assert(testMap.getKeyByIndex(1) == address(3));
        assert(testMap.getKeyByIndex(2) == address(2));
    }
}
