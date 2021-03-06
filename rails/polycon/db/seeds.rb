# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

professionals = Professional.create([{ first_name: "Juan", last_name: "Perez" }, { first_name: "Professional", last_name: "Two" }, { first_name: "Professional", last_name: "Three" }])

patients = Patient.create([{ first_name: "Carlos", last_name: "Lopez", phone: "221 555 5555" }, { first_name: "Ramon", last_name: "Diaz", phone: "221 555 5556" },
                           { first_name: "Jorge", last_name: "Fernandez", phone: "221 555 5558" }, { first_name: "Pepe", last_name: "Chatruc", phone: "221 555 5557" }])

Appointment.create([{ date: Time.new(2021, 12, 12, 15, 30), observations: "Turno numero uno", patient: (patients.at 0), professional: professionals.first },
                    { date: Time.new(2021, 12, 22, 13, 30), observations: "Turno numero dos", patient: (patients.at 1), professional: professionals.first },
                    { date: Time.new(2021, 12, 23, 14, 30), observations: "Turno numero tres", patient: (patients.at 2), professional: professionals.first },
                    { date: Time.new(2021, 12, 25, 11, 00), observations: "Turno numero cuatro", patient: (patients.at 3), professional: professionals.first },
                    { date: Time.new(2021, 12, 25, 9, 30), observations: "Turno numero cinco", patient: (patients.at 1), professional: professionals.last },
                    { date: Time.new(2021, 12, 30, 14, 30), observations: "Turno numero seis", patient: (patients.at 3), professional: professionals.last },
                    { date: Time.new(2021, 12, 21, 14, 30), observations: "Turno numero siete", patient: (patients.at 0), professional: professionals.last },
                    { date: Time.new(2021, 12, 27, 14, 30), observations: "Turno numero uno", patient: (patients.at 0), professional: professionals.first },
                    { date: Time.new(2021, 12, 27, 14, 30), observations: "Turno numero dos", patient: (patients.at 1), professional: professionals.first },
                    { date: Time.new(2021, 12, 17, 11, 30), observations: "Turno numero tres", patient: (patients.at 2), professional: professionals.first },
                    { date: Time.new(2021, 12, 7, 11, 00), observations: "Turno numero cuatro", patient: (patients.at 3), professional: professionals.first },
                    { date: Time.new(2021, 12, 27, 9, 30), observations: "Turno numero cinco", patient: (patients.at 1), professional: professionals.first },
                    { date: Time.new(2021, 12, 17, 10, 30), observations: "Turno numero seis", patient: (patients.at 3), professional: professionals.last },
                    { date: Time.new(2021, 12, 27, 10, 30), observations: "Turno numero siete", patient: (patients.at 0), professional: professionals.last },
                    { date: DateTime.now.change({ hour: 11, min: 15}), observations: "Turno numero 99", patient: (patients.at 0), professional: professionals.last },
                    { date: DateTime.now.change({ hour: 11, min: 30}), observations: "Turno numero 94", patient: (patients.at 1), professional: professionals.last },
                    { date: DateTime.now.change({ hour: 12, min: 15}), observations: "Turno numero 91", patient: (patients.at 2), professional: professionals.last },
                    { date: DateTime.now.change({ hour: 8, min: 45}), observations: "Turno numero 95", patient: (patients.at 1), professional: professionals.last },
                    { date: DateTime.now.change({ hour: 9, min: 15}), observations: "Turno numero 98", patient: (patients.at 2), professional: professionals.first },
                    { date: DateTime.now.change({ hour: 9, min: 30}), observations: "Turno numero 97", patient: (patients.at 3), professional: professionals.first },
                    { date: Time.new(2022, 1, 2, 13, 30), observations: "Turno numero 11", patient: (patients.at 0), professional: professionals.last },
                    { date: Time.new(2022, 1, 2, 10, 30), observations: "Turno numero 12", patient: (patients.at 1), professional: professionals.first },
                    { date: Time.new(2022, 1, 3, 8, 30), observations: "Turno numero 13", patient: (patients.at 2), professional: professionals.last },
                    { date: Time.new(2022, 1, 3, 9, 0), observations: "Turno numero 14", patient: (patients.at 3), professional: professionals.first },
                    { date: Time.new(2022, 1, 3, 12, 15), observations: "Turno numero 15", patient: (patients.at 2), professional: professionals.last },
                    { date: Time.new(2022, 1, 4, 10, 30), observations: "Turno numero 16", patient: (patients.at 0), professional: professionals.first },
                   ])

consultor = Role.create({ name: 'Consultor', description: 'Can read appointments and professionals' })
asistent = Role.create({ name: 'Asistent', description: 'Can read,create,update and destroy appoointments. Can read professionals' })
admin = Role.create({ name: 'Admin', description: 'Can perform any CRUD operation on any resource' })

users = User.create([{ name: 'admin', email: 'admin@polycon.com', password: '123456', password_confirmation: '123456', role_id: admin.id },
                     { name: 'asistente', email: 'asistente@example.com', password: '123456', password_confirmation: '123456', role_id: asistent.id },
                     { name: 'consultor', email: 'consultor@example.com', password: '123456', password_confirmation: '123456', role_id: consultor.id }])
