# README

* **Ruby version** `ruby 2.7.4p191 (2021-07-07 revision a21a3b7d23) [x86_64-linux]`

* System dependencies

    - rails ~> 6.1.4
    - ruby '2.7.4'
    - sqlite

* Installation

    - execute `bundle install` and `yarn install` in root's project

* Configuration

* **Database creation**

    - bin/rails db:create

* **Database initialization**
  
    - bin/rails db:migrate

    - bin/rails db:seed

* **Run**

    - `bin/webpack-dev-server`
    - `bin/rails serve`

**El sistema cuenta con restricciones a la hora de crear turnos, para simplificar el manejo de los mismos**

Los turnos son de 15 minutos.

- Hay 4 turnos por hora, arrancando en el minuto 0 de cada hora. En total sería 00, 15, 30, 45.
- Por ejemplo para las 11am, se pueden reservar turnos a las 11:00, 11:15, 11:30 u 11:45.

Un profesional no posee turnos solapados.

Se pueden reservar turnos entre las 8 AM y las 4 PM.

###

Utilicé las gemas **cancancan** y **devise** para gestionar los usuarios, roles y permisos de la aplicación.

Existen tres tipos de usuarios: **Administradores**(Poseen todos los permisos), **Asistentes**(Pueden gestionar turnos(
ABM)) y **Consultores**(Pueden leer información pero no modificarla)

El CRUD de usuarios roles y permisos solo es accesible por usuarios Administradores, el resto de los usuarios no pueden
ver ni modificar.

Los permisos se modifican en el modelo _ability.rb_

El template utilizado para la interfaz de usuario es un template de uso libre

_Author: BootstrapMade.com_

_License: https://bootstrapmade.com/license/_

**Para simplificar la configuración de la aplicación utilicé SQLite como motor de base de datos**

Se iníectó codigo adicional javascript mediante packs, para el uso de los data tables.

Los data tables los utilicé para paginar y filtrar sobre las tablas.

####

Mediante los comandos detallados en **Database creation** se puede inicializar la base de datos de la aplicación con
datos de prueba.


### Usuarios de prueba

**Administrador:**

admin 123456

**Asistente:**

asistente 123456

**Consultor**

consultor 123456


