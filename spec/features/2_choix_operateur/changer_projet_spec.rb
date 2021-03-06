require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_ban_helper'

feature "En tant que demandeur, j'ai accès aux données concernant mon projet" do
  context "quand mon projet est éligible" do
    let(:projet) { create(:projet, :prospect, :with_invited_operateur) }

    scenario "je peux consulter mon projet en me connectant" do
      signin(projet.numero_fiscal, projet.reference_avis)
      @role_utilisateur = :demandeur
      expect(page).to have_content("Jean Martin")
      expect(page).to have_content("Total Revenu Fiscal de Référence")
      expect(page).not_to have_content(I18n.t('projets.visualisation.non_eligible'))
    end

    scenario "je peux modifier mes données personnelles" do
      signin(projet.numero_fiscal, projet.reference_avis)
      within 'article.occupants' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end

      expect(find('#demandeur_principal_civilite_mr')).to be_checked
      expect(page).to have_field('Adresse postale', with: '65 rue de Rome, 75008 Paris')

      fill_in :projet_adresse_postale,   with: Fakeweb::ApiBan::ADDRESS_PORT
      fill_in :projet_adresse_a_renover, with: Fakeweb::ApiBan::ADDRESS_MARE
      fill_in :projet_tel, with: '01 10 20 30 40'

      click_button I18n.t('projets.edition.action')

      expect(page).to have_content('01 10 20 30 40')
      expect(page).to have_current_path projet_path(projet)
      expect(page).to have_content Fakeweb::ApiBan::ADDRESS_PORT
      expect(page).to have_content Fakeweb::ApiBan::ADDRESS_MARE
    end

    scenario "je peux modifier les données concernant mon habitation et mon projet" do
      signin(projet.numero_fiscal, projet.reference_avis)
      within 'article.projet' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end
      fill_in :demande_annee_construction, with: '1950'
      click_button I18n.t('projets.edition.action')
      expect(page).to have_content(1950)
      # TODO: tester la modification des travaux demandés
    end
  end
end
