# Generated via
#  `rails generate hyrax:work EphemeraBox`
module Hyrax
  class EphemeraBoxForm < SingleValuedForm
    self.model_class = ::EphemeraBox
    self.terms = [:box_number, :identifier, :member_of_collection_ids]
    self.required_fields = [:box_number, :identifier]
    self.single_valued_fields = [:identifier, :box_number]
  end
end
