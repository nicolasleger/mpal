require 'rails_helper'
require 'support/mpal_helper'

feature "Administration des intervenants" do
  let!(:intervenant1) { create :operateur }
  let!(:intervenant2) { create :instructeur }
  let!(:intervenant3) { create :pris }

  scenario "je peux lister tous les intervenants du site" do
    authenticate_as_admin
    visit admin_intervenants_path
    expect(page.current_path).to eq(admin_intervenants_path)
    expect(page).to have_content intervenant1.raison_sociale
    expect(page).to have_content intervenant2.raison_sociale
    expect(page).to have_content intervenant3.raison_sociale
  end

  scenario "je peux importer des opérateurs contenus dans un fichier CSV" do
    authenticate_as_admin
    visit admin_intervenants_path
    attach_file :csv_file, Rails.root + "spec/fixtures/Import intervenants.csv"
    click_button I18n.t('admin.intervenants.impoter_fichier')
    expect(page.current_path).to eq(admin_intervenants_path)
    expect(page).to have_content "Les intervenants ont été importés."
    expect(page).to have_content "Maison de L'Emploi de la Déodatie"
  end
end
