#Creación del objeto user con los campos necesarios para la validación. En este caso del profile page
FactoryGirl.define do
  factory :user do
    name     "Jorge Carreño"
    email    "jorge@prompt.cl"
    password "pepito"
    password_confirmation "pepito"
  end
end