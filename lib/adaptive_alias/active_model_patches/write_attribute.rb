require 'active_record'

module ActiveRecord::AttributeMethods::Write
  def write_attribute(attr_name, value)
    name = attr_name.to_s
    name = self.class.attribute_aliases[name] || name

    name = @primary_key if name == 'id' && @primary_key
    _write_attribute(name, value)
  end

  # This method exists to avoid the expensive primary_key check internally, without
  # breaking compatibility with the write_attribute API
  def _write_attribute(attr_name, value) # :nodoc:
    name = attr_name.to_s
    name = self.class.attribute_aliases[name] || name

    sync_with_transaction_state if @transaction_state&.finalized?
    @attributes.write_from_user(name, value)
    value
  end
end
