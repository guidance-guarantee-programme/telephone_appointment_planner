module MultiGuiderHelper
  def sortable_list_config(groups)
    value_names = ['name']

    groups.each do |group|
      value_names << dom_id(group)
    end

    { valueNames: value_names }.to_json
  end
end
