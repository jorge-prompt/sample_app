module SessionsHelper #Se incluye en el aplication controller

#Función encargada de generar la cookie con el remember token generado
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.hash(remember_token))
    self.current_user = user
  end

#Función que almacena en la aplicación el usuario actual para ser usado después
  def current_user=(user)
    @current_user = user
  end  

#Función que extrae el remember token de la cookie para luego buscarla en la BD
  def current_user
    remember_token = User.hash(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    user == current_user
  end

#Función encargada de informar si el usuario actual está logeado
  def signed_in?
    !current_user.nil?
  end

#Función encargada de eliminar el remember token de la BD y de la cookie, además el user apuntando a nil
  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.hash(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

#Función que redirige al usuario que intentó entrar sin logearse, pero que ahora logeado tiene acceso.
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

#Función que almacena la dirección privada a la cual el usuario no logeado irá despues de logearse.
  def store_location
    session[:return_to] = request.url if request.get?
  end


end
