class SessionsController < ApplicationController
  layout 'application'

  before_action :authentifie_sans_redirection

  def new
    if agent_signed_in?
      return redirect_to dossiers_path
    end
  end

  def create
    unless "1" == params[:proprietaire]
      flash.now[:alert] = t('sessions.erreur_proprietaire_html', anil: view_context.link_to('Anil.org', 'https://www.anil.org/')).html_safe
      return render :new
    end
    contribuable = ApiParticulier.new(param_numero_fiscal, param_reference_avis).retrouve_contribuable
    unless contribuable
      flash.now[:alert] = t('sessions.invalid_credentials')
      return render :new
    end
    session[:numero_fiscal] = param_numero_fiscal
    projet = Projet.find_by(numero_fiscal: param_numero_fiscal)
    if projet
      redirect_to projet
    else
      create_projet_and_redirect
    end
  end

  def create_projet_and_redirect
    projet = ProjetInitializer.new.initialize_projet(param_numero_fiscal, param_reference_avis)
    if projet.save
      EvenementEnregistreurJob.perform_later(label: 'creation_projet', projet: projet)
      notice = t('projets.messages.creation.corps')
      flash[:notice_titre] = t('projets.messages.creation.titre')
      redirect_to etape1_recuperation_infos_path(projet), notice: notice
    else
      redirect_to new_session_path, alert: t('sessions.erreur_creation_projet')
    end
  end

  def deconnexion
    reset_session
    redirect_to new_session_path, notice: t('sessions.confirmation_deconnexion')
  end

private
  def param_numero_fiscal
    params[:numero_fiscal].try(:delete, ' ')
  end

  def param_reference_avis
    params[:reference_avis].try(:delete, ' ')
  end
end
