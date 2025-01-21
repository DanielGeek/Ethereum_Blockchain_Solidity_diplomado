// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Gas golf contract to optimize gas usage
contract GasGolf {
    uint256 public total;  // Variable de estado que almacena la suma total

    // Función optimizada para calcular la suma de números pares y menores a 99.
    // Recibe un array de enteros 'nums' como input, de tipo calldata (para optimizar gas).
    // Usando varias técnicas de ahorro de gas.
    function sumIfEvenAndLessThan99(uint256[] calldata nums) external {
        uint256 _total = total; // Guardamos el valor actual de 'total' en una variable local para evitar lecturas repetidas de almacenamiento.
        uint256 len = nums.length; // Guardamos la longitud del array 'nums' en una variable local para evitar cálculos innecesarios.

        // Bucle que itera sobre el array 'nums'.
        // Usamos una sintaxis de bucle sin incremento de gas innecesario.
        for (uint256 i = 0; i < len;) {
            uint256 num = nums[i];  // Cargamos el valor actual de 'nums[i]' en una variable local (técnica de caching de elementos del array).

            // Comprobamos si el número es par (num % 2 == 0) y menor a 99 (num < 99).
            if (num % 2 == 0 && num < 99) {
                _total += num;  // Si cumple ambas condiciones, se agrega el número a la variable local '_total'.
            }

            // Usamos 'unchecked' para permitir la operación de incremento de 'i' sin verificar desbordamiento de enteros,
            // lo que ahorra gas ya que sabemos que 'i' no puede desbordarse en este contexto.
            unchecked {
                ++i;  // Incrementamos 'i' para pasar al siguiente número en el array, usando ++i en lugar de i++.
            }
        }

        // Actualizamos el valor de la variable de estado 'total' con el valor calculado.
        total = _total;
    }

    /* Técnicas de ahorro de gas aplicadas:

    1. **Reemplazar `memory` con `calldata`**:
        - `calldata` es más eficiente en términos de gas que `memory` cuando se pasan arrays como parámetros a funciones externas.
        - En lugar de copiar el array completo en memoria, `calldata` permite acceder a los datos directamente desde el almacenamiento de la transacción sin costos adicionales.

    2. **Cargar variables de estado en memoria**:
        - La variable `total` se carga en una variable local `_total` para evitar múltiples lecturas desde el almacenamiento de la blockchain. Las lecturas de almacenamiento son más caras que las variables locales, por lo que almacenarlas en una variable temporal en memoria reduce el consumo de gas.

    3. **Reemplazar `for loop i++` con `++i`**:
        - Utilizar `++i` en lugar de `i++` en los bucles es más eficiente, ya que no implica la creación de una copia temporal del valor de `i`. En la mayoría de los casos, ambos funcionan de la misma manera, pero `++i` es preferido por ser más eficiente.
    
    4. **Cachear elementos del array**:
        - En lugar de acceder directamente a `nums[i]` dentro del bucle, primero se guarda `nums[i]` en una variable local `num`. Esto reduce el costo de acceder al array en cada iteración.

    5. **Short-circuit (circuito corto)**:
        - En la condición `if (num % 2 == 0 && num < 99)`, el operador `&&` permite que la segunda parte de la condición solo se evalúe si la primera es verdadera. Si `num % 2 == 0` es falso, la segunda condición `num < 99` no se evalúa, ahorrando gas al evitar comparaciones innecesarias.

    6. **Uso de `unchecked` para el incremento del contador**:
        - En el bucle `for`, el uso de `unchecked` permite que el incremento de `i` se realice sin verificar si hay desbordamiento de enteros, lo que ahorra gas.
    
    */

}