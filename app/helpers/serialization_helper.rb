module SerializationHelper
  def serialize_resource(resource, options = {})
    ActiveModelSerializers::SerializableResource.new(resource, options).to_json
  end
end
