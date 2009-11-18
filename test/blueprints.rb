require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.name { Faker::Name.name }
Sham.description { Faker::Lorem.sentence}
Sham.login { Faker::Internet.user_name }
Sham.firstname { Faker::Name.first_name }
Sham.lastname { Faker::Name.last_name }
Sham.mail { Faker::Internet.email }

CustomValue.blueprint do  
end

CustomField.blueprint do
  type { "ProjectCustomField" }
  name
  field_format { "int" }
end

Project.blueprint do
  name
  description
  identifier { Sham.login }
  status { 1 }
end

User.blueprint do
  login
  firstname
  lastname
  mail
end

HarvestTime.blueprint do
  
end