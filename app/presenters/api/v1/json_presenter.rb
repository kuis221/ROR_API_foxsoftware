class Api::V1::JsonPresenter

  # A helper to extract attributes from an object,
  # calling getters on it.
  # Example:
  #   hash_for(user_instance, ["email"])
  #     -> calls user_instance.email
  #     The result will be: { email: "the email" }
  def self.hash_for(model, attributes)
    res = {}
    attributes.map do |attr|
      res[attr] = model.send attr
    end
    res
  end
end