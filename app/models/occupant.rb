class Occupant < ActiveRecord::Base

  enum civilite: ['mr', 'mme']
  enum lien_demandeur: [ 'père/mère', 'enfant', 'frère/soeur', 'conjoint']

  belongs_to :avis_imposition
  delegate :projet, to: :avis_imposition

  validates :nom, :prenom, :date_de_naissance, presence: true
  validates :civilite, presence: true, on: :update, if: :require_civilite?

  strip_fields :nom, :prenom

  scope :sans_revenus, -> { where(revenus: nil) }

  def require_civilite?
    projet && projet.demandeur_principal == self
  end

  def fullname
    "#{prenom} #{nom}"
  end

  def can_be_deleted?
    !demandeur && avis_imposition.occupants.count > 1
  end
end
