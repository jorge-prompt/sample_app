require 'spec_helper'

describe "UserPages" do
  
  subject { page }

#Validación de página index que muestra listado de todos los usuarios para un usuario logeado
  describe "index" do
    
    let(:user) { FactoryGirl.create(:user) }
    
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

#Validación de que exista una paginación al tener 30 usuarios, cada uno dentro de un "li"
    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }
      
      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end#fin pagination
    
    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end#fin delete links    
    
  end#fin index

#Validación de página de registro, que contenga los elementos necesarios según diseño  
  describe "signup page" do
    before { visit signup_path }
    
    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

#Validación de página de perfil (usuario logeado), debe contener los elementos según diseño  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }  # haciendo uso de FactoryGirls para crear usuario en DB Test
    let!(:m1)  { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2)  { FactoryGirl.create(:micropost, user: user, content: "Bar") }
    
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
    
    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end
    
    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end
      end
    end#fin follow/unfollow buttons    
  end#fin profile page
  
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
  end #fin validación de registro signup
  
#Validación para la actualización de datos de usuario

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end
    
    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Nombre",             with: new_name
        fill_in "Email",              with: new_email
        fill_in "Password",           with: user.password
        fill_in "Confirmar Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end #fin describe valid      
  end  #fin de describe edit

#Validación de seguidos/seguidores  
  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end #fin followed/follower
  
end
