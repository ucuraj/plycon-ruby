# Polycon

Plantilla para comenzar con el Trabajo Práctico Integrador de la cursada 2021 de la materia Taller de Tecnologías de
Producción de Software - Opción Ruby, de la Facultad de Informática de la Universidad Nacional de La Plata.

Polycon es una herramienta para gestionar los turnos y profesionales de un policonsultorio.

## Uso de `polycon`

Para ejecutar el comando principal de la herramienta se utiliza el script `bin/polycon`, el cual puede correrse de las
siguientes manera:

```bash
$ ruby bin/polycon [args]
```

O bien:

```bash
$ bundle exec bin/polycon [args]
```

O simplemente:

```bash
$ bin/polycon [args]
```

Si se agrega el directorio `bin/` del proyecto a la variable de ambiente `PATH` de la shell, el comando puede utilizarse
sin prefijar `bin/`:

```bash
# Esto debe ejecutarse estando ubicad@ en el directorio raiz del proyecto, una única vez
# por sesión de la shell
$ export PATH="$(pwd)/bin:$PATH"
$ polycon [args]
```

> Notá que para la ejecución de la herramienta, es necesario tener una versión reciente de
> Ruby (2.6 o posterior) y tener instaladas sus dependencias, las cuales se manejan con
> Bundler. Para más información sobre la instalación de las dependencias, consultar la
> siguiente sección ("Desarrollo").

Documentar el uso para usuarios finales de la herramienta queda fuera del alcance de esta plantilla y **se deja como una
tarea para que realices en tu entrega**, pisando el contenido de este archivo `README.md` o bien en uno nuevo. Ese
archivo deberá contener cualquier documentación necesaria para entender el funcionamiento y uso de la herramienta que
hayas implementado, junto con cualquier decisión de diseño del modelo de datos que consideres necesario documentar.

## Desarrollo

Esta sección provee algunos tips para el desarrollo de tu entrega a partir de esta plantilla.

### Instalación de dependencias

Este proyecto utiliza Bundler para manejar sus dependencias. Si aún no sabés qué es eso o cómo usarlo, no te preocupes:
¡lo vamos a ver en breve en la materia! Mientras tanto, todo lo que necesitás saber es que Bundler se encarga de
instalar las dependencias ("gemas")
que tu proyecto tenga declaradas en su archivo `Gemfile` al ejecutar el siguiente comando:

```bash
$ bundle install
```

> Nota: Bundler debería estar disponible en tu instalación de Ruby, pero si por algún
> motivo al intentar ejecutar el comando `bundle` obtenés un error indicando que no se
> encuentra el comando, podés instalarlo mediante el siguiente comando:
>
> ```bash
> $ gem install bundler
> ```

### Estructura de la plantilla

* `lib/`: directorio que contiene todas las clases del modelo y de soporte para la ejecución del programa `bin/polycon`.
    * `lib/polycon.rb` es la declaración del namespace `Polycon`, y las directivas de carga de clases o módulos que
      estén contenidos directamente por éste (`autoload`).
    * `lib/polycon/` es el directorio que representa el namespace `Polycon`. Notá la convención de que el uso de un
      módulo como namespace se refleja en la estructura de archivos del proyecto como un directorio con el mismo nombre
      que el archivo `.rb` que define el módulo, pero sin la terminación `.rb`. Dentro de este directorio se ubicarán
      los elementos del proyecto que estén bajo el namespace `Polycon` - que, también por convención y para facilitar la
      organización, deberían ser todos. Es en este directorio donde deberías ubicar tus clases de modelo, módulos,
      clases de soporte, etc.
    * `lib/polycon/commands.rb` y `lib/polycon/commands/*.rb` son las definiciones de comandos de `dry-cli` que se
      utilizarán.
    * `lib/polycon/models` y `lib/polycon/models/*` son las definiciones de los modelos de Polycon.
    * `lib/polycon/modules` y `lib/polycon/modules/*` son las definiciones de los modulos que forman parte de Polycon.
    * `lib/polycon/helpers` y `lib/polycon/helpers/*` son las definiciones de los helpers que forman parte de Polycon,
      como por ejemplo TextHelper.
    * `lib/polycon/version.rb` define la versión de la herramienta, utilizando [SemVer](https://semver.org/lang/es/).
* `bin/`: directorio donde reside cualquier archivo ejecutable, siendo el más notorio `polycon`
  que se utiliza como punto de entrada para el uso de la herramienta.

## Modelos de datos

### Clase Professional

Es la clase que representa a un Professional.

Por el momento posee solo dos campos,
`@name: String` y `@date_joined: Time`

### Clase Appointment

Es la clase que representa a un Appointment.

**Campos**

- `@patient_first_name: String`

- `@patient_last_name: String`

- `@patient_phone: String`

- `@professional: String`

- `@date: Time`

- `@observations: ?String`

La idea es que tanto el modelo Professional como el modelo Appointment sean los encargados de crear los archivos que
persisten la información en el sistema, como también encargarse de mostrar en la consola la información, limitando a los
comandos al uso de los métodos provistos por los modelos, para en un futuro poder migrar facilmente a Rails o el
framework elegido. A medida que vaya avanzado el desarrollo, también la idea es agregar una capa de servicios para
dividir correctamente las responsabilidades (vistas, modelos, servicios, etc)

### Modules y helpers

La aplicación también tiene una division por modulos y helpers. Los modulos estan pensandos para agregarle funcionalidad
a las clases, por ejemplo con el módulo FileManager, que es el encargado de realizar las operaciones de
lectura/escritura de archivos y directorios.

Los helpers pueden ser clases o funciones útiles que están disponibles para poder utilizarlos cuando sea necesario, como
por ejemplo la funcion snake_case de TextHelper que dado un string lo convierte a snake_case.

### Appointments Grid

**El sistema cuenta con restricciones a la hora de crear turnos, para simplificar el manejo de los mismos**

Los turnos son de 15 minutos.

- Hay 4 turnos por hora, arrancando en el minuto 0 de cada hora. En total sería 00, 15, 30, 45.
- Por ejemplo para las 11am, se pueden reservar turnos a las 11:00, 11:15, 11:30 u 11:45.

Un profesional no posee turnos solapados.

Se pueden reservar turnos entre las 8 AM y las 4 PM.

#

Se agregó el namespace **Outputs**, el cual actualmente se encarga de generar la salida de los turnos por dia/semana
permitiendo filtrar por profesional

Los turnos se exportan en una grilla en formato HTML, aprovechando el uso de la gema erb, que nos permite de manera
sencilla crear templates html dinámicos.

Los turnos diarios filtrados sin filtro por professional se guardan en la carpeta .polycon(home usuario) con el
formato "output_day_[DATE].html"

Los turnos diarios filtrados por profesional se guardan en la carpeta del profesional .polycon/PROF (home usuario) con
el formato "output_day_[DATE].html"

Para filtrar una grilla de turnos semanales por fecha, a partir de la fecha recibida se calcula la semana actual. La
semana comienza el dia lunes

