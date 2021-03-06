require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Remplir la proposition de travaux" do
  let(:projet)           { create :projet, :en_cours }
  let(:operateur)        { projet.operateur }
  let(:agent_operateur)  { create :agent, intervenant: operateur }
  let(:aide)             { Aide.first }

  context "en tant qu'opérateur" do
    before { login_as agent_operateur, scope: :agent }

    scenario "je visualise la proposition de travaux pour m'affecter le projet" do
      visit dossier_path(projet)
      click_link I18n.t('projets.visualisation.remplir_le_projet')
      expect(page).to have_current_path(dossier_proposition_path(projet))
      expect(page).to have_content I18n.t('projets.visualisation.projet_affecte')
    end

    scenario "je remplis et j'enregistre une proposition de travaux'" do
      visit dossier_proposition_path(projet)
      expect(page).to have_content('Plan de financement prévisionnel')
      expect(page).to have_content(aide.libelle)

      # Section "Logement"
      select 'Appartement', from: 'projet_type_logement'
      select '2', from: 'projet_etage'
      select 'Plus de 5', from: 'projet_nb_pieces'
      fill_in 'projet_annee_construction', with: '1954'
      fill_in 'projet_surface_habitable', with: '42'
      fill_in 'projet_etiquette_avant_travaux', with: 'C'

      # Section "Diagnostic opérateur"
      choose 'projet_autonomie_true'
      fill_in 'projet_niveau_gir', with: '712'
      choose 'projet_handicap_true'
      fill_in 'projet_note_degradation', with: '0,1'
      fill_in 'projet_note_insalubrite', with: '0,2'
      choose 'projet_ventilation_adaptee_true'
      choose 'projet_presence_humidite_true'
      choose 'projet_auto_rehabilitation_true'
      fill_in 'projet_remarques_diagnostic', with: 'Le diagnostic est complet.'

      # Section "Description des travaux proposés"
      check 'Remplacement d’une baignoire par une douche'
      check 'Lavabo adapté'
      fill_in 'projet_gain_energetique', with: '31'
      fill_in 'projet_etiquette_apres_travaux', with: 'A'

      # Section "Financement"
      fill_in 'projet_montant_travaux_ht', with: '3 333,33'
      fill_in 'projet_montant_travaux_ttc', with: '4 444,44'
      fill_in 'projet_reste_a_charge', with: '1 111,11'
      fill_in 'projet_pret_bancaire', with: '2 222,22'
      fill_in  aide.libelle, with: '5 555,55'

      # Section "Précisions"
      fill_in 'projet_precisions_travaux', with: 'Il faudra casser un mur.'
      fill_in 'projet_precisions_financement', with: 'Le prêt sera sans doute accordé.'

      click_on 'Enregistrer cette proposition'

      # Section "Logement"
      expect(page.current_path).to eq(dossier_path(projet))
      expect(page).to have_content('Appartement')
      expect(page).to have_css('.etage', text: 2)
      expect(page).to have_css('.pieces', text:'Plus de 5')
      expect(page).to have_content('1954')
      expect(page).to have_content('42 m2')
      expect(page).to have_css('.etiquette_avant', text: 'C')

      # Section "Diagnostic opérateur"
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.autonomie'))
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.niveau_gir') + ' : 712')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.handicap') + ' : Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.note_degradation') + ' : 0,1')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.note_insalubrite') + ' : 0,2')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.ventilation_adaptee') + ' : Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.presence_humidite') + ' : Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.auto_rehabilitation') + ' Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.remarques_diagnostic') + ' : Le diagnostic est complet.')

      # Section "Description des travaux proposés"
      expect(page).to have_content('Remplacement d’une baignoire par une douche')
      expect(page).to have_content('Lavabo adapté')
      expect(page).not_to have_content('Géothermie')
      expect(page).to have_content(I18n.t('helpers.label.proposition.gain_energetique'))
      expect(page).to have_css('.gain_energetique', text: 31)
      expect(page).to have_content(I18n.t('helpers.label.proposition.etiquette_apres_travaux'))
      expect(page).to have_css('.etiquette_apres', text: 'A')

      # Section "Financement"
      expect(page).to have_content(I18n.t('helpers.label.proposition.montant_travaux_ht'))
      expect(page).to have_content('3 333,33 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.montant_travaux_ht'))
      expect(page).to have_content('4 444,44 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.reste_a_charge'))
      expect(page).to have_content('1 111,11 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.pret_bancaire'))
      expect(page).to have_content('2 222,22 €')
      expect(page).to have_content(aide.libelle)
      expect(page).to have_content('5 555,55 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.precisions_travaux') + ' : Il faudra casser un mur.')
      expect(page).to have_content(I18n.t('helpers.label.proposition.precisions_financement') + ' : Le prêt sera sans doute accordé.')
    end

    context "quand je rentre des données invalides" do
      scenario "je vois un message d'erreur" do
        visit dossier_proposition_path(projet)
        fill_in 'projet_note_degradation', with: '9999'
        click_on 'Enregistrer cette proposition'
        expect(page).to have_current_path dossier_proposition_path(projet)
        expect(page).to have_content "La note de dégradation doit être comprise entre zéro et un"
      end
    end

    context "quand je ne réponds non/pas aux questions" do
      scenario "elles n'apparaissent pas dans la synthèse" do
        visit dossier_proposition_path(projet)
        choose 'projet_ventilation_adaptee_false'
        click_on 'Enregistrer cette proposition'
        expect(page.current_path).to eq(dossier_path(projet))
        within('.block.projet-ope') { expect(page).not_to have_content 'Non' }
      end
    end

    scenario "upload d'un document sans label" do
      visit dossier_proposition_path(projet)
      attach_file :fichier_document, Rails.root + "spec/fixtures/Ma pièce jointe.txt"
      fill_in 'label_document', with: ''
      click_button(I18n.t('projets.proposition.action_depot_document'))

      expect(projet.documents.count).to eq(1)
      expect(page).to have_content(I18n.t('projets.proposition.messages.succes_depot_document'))
      expect(page).to have_link('Ma_pi_ce_jointe.txt', href: "/uploads/projets/#{projet.id}/Ma_pi_ce_jointe.txt")
    end

    scenario "upload d'un document avec un label" do
      visit dossier_proposition_path(projet)
      attach_file :fichier_document, Rails.root + "spec/fixtures/Ma pièce jointe.txt"
      fill_in 'label_document', with: 'Titre de propriété'
      click_button(I18n.t('projets.proposition.action_depot_document'))

      expect(projet.documents.count).to eq(1)
      expect(page).to have_content(I18n.t('projets.proposition.messages.succes_depot_document'))
      expect(page).to have_link('Titre de propriété', href: "/uploads/projets/#{projet.id}/Ma_pi_ce_jointe.txt")
    end

    scenario "upload d'un document avec erreur" do
      visit dossier_proposition_path(projet)
      click_button(I18n.t('projets.proposition.action_depot_document'))

      expect(page).to have_content(I18n.t('projets.proposition.messages.erreur_depot_document'))
    end

    context "pour une demande déjà remplie" do
      let(:projet)     { create :projet, :proposition_enregistree }
      let(:prestation) { projet.prestations.first }

      scenario "je peux modifier la proposition" do
        visit dossier_path(projet)
        within 'article.projet-ope' do
          click_link I18n.t('projets.visualisation.lien_edition')
        end
        expect(page.current_path).to eq(dossier_proposition_path(projet))
        expect(find("#prestation_#{prestation.id}")).to be_checked

        fill_in 'projet_surface_habitable', with: '42'
        uncheck prestation.libelle
        fill_in aide.libelle, with: ''

        click_on 'Enregistrer cette proposition'
        expect(page.current_path).to eq(dossier_path(projet))
        expect(page).to have_content('42')
        expect(page).not_to have_content(prestation.libelle)
        expect(page).not_to have_content(aide.libelle)
      end
    end
  end
end
