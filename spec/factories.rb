#Creación del objeto user con los campos necesarios para la validación. En este caso del profile page
#Posteriormente modificado para generar una secuencia de usuarios de prueba
FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
  
    factory :admin do
      admin true
    end  
  end
  
end