#Creación del objeto user con los campos necesarios para la validación. En este caso del profile page
FactoryGirl.define do
  factory :user do
    name     "Michael Hartl"
    email    "michael@example.com"
    password "foobar"
    password_confirmation "foobar"
  end
end