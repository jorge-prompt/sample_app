require 'spec_helper'

describe "UserPages" do
  
  subject { page }

#Validación de página de registro, que contenga los elementos necesarios según diseño  
  describe "signup page" do
    before { visit signup_path }
    
    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

#Validación de página de perfil (usuario logeado), debe contener los elementos según diseño  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }  # haciendo uso de FactoryGirls para crear usuario en DB Test
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end
  
 #Validación del comportamiento en el registro de usuarios
 
  describe "signup" do
  
    before { visit signup_path }
  
    let(:submit) { "Create my account" }
  
    describe "with invalid information" do #Caso inválido 
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end #fin caso inválido

    describe "with valid information" do #Caso válido - ATENCION
      before do                          # Los campos a llenar son el valor del label del campo.
        fill_in "Nombre",       with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmación", with: "foobar"
      end
  
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Bienvenido') }
      end      
      
    end #fin caso válido
  end #fin validación de registro
  
  
  
  
end
