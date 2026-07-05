## proyecto simple para convertir un numero ingresado por pantalla a su equivalente en binario, octal y hexadecimal;Funcionalidades Requeridas

* Decimal → Binario: leer un número en base 10 y mostrar su representación en base 2 (hasta 8 bits). 

* Decimal → Hexadecimal: leer un número en base 10 y mostrar su representación en base 16. 

* Binario → Decimal: leer una cadena de 0s y 1s y calcular su valor decimal equivalente. 

* Hexadecimal → Decimal: leer un número hexadecimal (dígitos 0-9 y A-F/a-f) y calcular su equivalente decimal. 

* El resultado debe mostrarse en pantalla con una etiqueta clara que indique la base de salida. 
* El programa debe permitir reiniciar y realizar nuevas conversiones sin terminar la ejecución. 

# Requisitos Técnicos
## Entrada y validación

* Leer el número como cadena de caracteres (INT 21h, función 0Ah).

* Validar carácter a carácter según la base de entrada:

    Decimal: solo dígitos '0'–'9'.◦ Binario: solo caracteres '0' y '1'.

    Hexadecimal: dígitos '0'–'9' y letras 'A'–'F' (o 'a'–'f').

* Rango permitido de entrada decimal: 0 a 255 (cabe en 8 bits / 1 byte).

* Si se detecta un carácter inválido, mostrar mensaje de error y solicitar el dato nuevamente.
