class String

  def valid_email?
    self.match /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

end