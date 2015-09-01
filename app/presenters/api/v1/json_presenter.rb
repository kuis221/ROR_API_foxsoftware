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
      # datetime or related object classes does not using :default format that called in initializer
      value = model[attr].is_a?(ActiveSupport::TimeWithZone) ? model[attr].to_s : model.send(attr)
      res[attr] = value
    end
    res
  end
end