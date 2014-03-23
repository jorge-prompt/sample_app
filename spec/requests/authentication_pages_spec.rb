require 'spec_helper'

describe "Authentication" do

  subject { page }
#Validación de que la página contenga los siguientes elementos
  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end
#Validación del proceso de logeo  
  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do #cuando el proceso de logeo es inválido
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error') }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end #Fin logeo inválido

    describe "with valid information" do #cuando el proceso de logeo es válido
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_title(user.name) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
      
      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end      
      
    end #Fin caso logeo válido
    
    
  end #Fin validación del proceso de logeo  
  
end