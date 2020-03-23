class AddOrganisationContentIdToGroups < ActiveRecord::Migration[5.1]
  def up
    add_column :groups, :organisation_content_id, :string, null: false, default: ''

    Group.reset_column_information
    Group
      .where(organisation_content_id: '')
      .update_all(organisation_content_id: Provider::TPAS.id)
  end

  def down
    remove_column :groups, :organisation_content_id
  end
end
