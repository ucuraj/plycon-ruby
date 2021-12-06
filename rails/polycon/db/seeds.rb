# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

professionals = Professional.create([{ first_name: "Juan", last_name: "Perez" }, { first_name: "Juan", last_name: "Perez" }])

patients = Patient.create([{ first_name: "Carlos", last_name: "Lopez", phone: "221 555 5555" }, { first_name: "Ramon", last_name: "Diaz", phone: "221 555 5556" },
                           { first_name: "Jorge", last_name: "Fernandez", phone: "221 555 5558" }, { first_name: "Pepe", last_name: "Chatruc", phone: "221 555 5557" }])

Appointment.create([{ date: Time.new(2021, 12, 12, 15, 30), observations: "Turno numero uno", patient: (patients.at 0), professional: professionals.first },
                    { date: Time.new(2021, 12, 12, 16, 30), observations: "Turno numero dos", patient: (patients.at 1), professional: professionals.first },
                    { date: Time.new(2021, 12, 13, 15, 30), observations: "Turno numero tres", patient: (patients.at 2), professional: professionals.first },
                    { date: Time.new(2021, 12, 15, 11, 00), observations: "Turno numero cuatro", patient: (patients.at 3), professional: professionals.first },
                    { date: Time.new(2021, 12, 15, 9, 30), observations: "Turno numero cinco", patient: (patients.at 1), professional: professionals.last },
                    { date: Time.new(2021, 12, 20, 15, 30), observations: "Turno numero seis", patient: (patients.at 3), professional: professionals.last },
                    { date: Time.new(2021, 12, 21, 15, 30), observations: "Turno numero siete", patient: (patients.at 0), professional: professionals.last }])
