FactoryGirl.define do
  factory :projet do
    numero_fiscal 12
    reference_avis 15
    email 'prenom.nom@site.com'
    annee_construction 1975
    association :adresse_postale,   factory: [ :adresse, :rue_de_rome ]
    association :adresse_a_renover, factory: [ :adresse, :rue_de_la_mare ]

    trait :with_avis_imposition do
      transient do
        demandeurs_count 1
        occupants_a_charge_count 0
      end

      after(:create) do |projet, evaluator|
        create(:avis_imposition_with_occupants,
          projet: projet,
          numero_fiscal: projet.numero_fiscal,
          reference_avis: projet.reference_avis,
          demandeurs_count: evaluator.demandeurs_count,
          occupants_a_charge_count: evaluator.occupants_a_charge_count)
      end
    end

    trait :with_demandeurs do
      with_avis_imposition
      demandeurs_count 2
      occupants_a_charge_count 2
    end

    trait :with_demande do
      after(:build) do |projet|
        create(:demande, projet: projet)
      end
    end

    trait :with_intervenants_disponibles do
      after(:build) do |projet|
        create(:operateur,   departements: [projet.departement])
        create(:pris,        departements: [projet.departement])
        create(:instructeur, departements: [projet.departement])
      end
    end

    trait :with_invited_pris do
      after(:build) do |projet|
        pris = create(:pris, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: pris)
      end
    end

    trait :with_suggested_operateurs do
      after(:build) do |projet|
        operateurA = create(:operateur, departements: [projet.departement])
        operateurB = create(:operateur, departements: [projet.departement])
        operateurC = create(:operateur, departements: [projet.departement])
        projet.suggested_operateurs = [operateurA, operateurC]
        # B is available but not suggested
      end
    end

    trait :with_invited_operateur do
      after(:build) do |projet|
        operateur = create(:operateur, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: operateur)
      end
    end

    trait :with_committed_operateur do
      after(:build) do |projet|
        projet.operateur = create(:operateur, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: projet.operateur)
      end
    end

    trait :with_invited_instructeur do
      after(:build) do |projet|
        instructeur = create(:instructeur, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: instructeur)
      end
    end

    trait :with_invited_pris do
      after(:build) do |projet|
        pris = create(:pris, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: pris)
      end
    end

    trait :with_prestations do
      transient do
        prestations_count 1
      end

      after(:build) do |projet, evaluator|
        projet.prestations = Prestation.first(evaluator.prestations_count)
      end
    end

    # Project states

    trait :prospect do
      statut :prospect
      with_demandeurs
      with_demande
    end

    trait :en_cours do
      statut :en_cours
      with_demandeurs
      with_demande
      with_committed_operateur
    end

    trait :proposition_enregistree do
      statut :proposition_enregistree
      with_demandeurs
      with_demande
      with_committed_operateur
      with_prestations
    end

    trait :proposition_proposee do
      statut :proposition_proposee
      with_demandeurs
      with_demande
      with_committed_operateur
      with_prestations
    end

    trait :transmis_pour_instruction do
      statut :transmis_pour_instruction
      with_demandeurs
      with_demande
      with_committed_operateur
      with_prestations

      after(:build) do |projet|
        projet.invitations << create(:invitation, intermediaire: projet.operateur, intervenant: create(:instructeur))
      end
    end

    trait :en_cours_d_instruction do
      statut :en_cours_d_instruction
      opal_numero 4567
      with_demandeurs
      with_demande
      with_committed_operateur
      with_invited_instructeur
      with_invited_pris
      with_prestations
    end
  end
end
