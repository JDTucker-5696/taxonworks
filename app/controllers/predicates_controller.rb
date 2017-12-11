class PredicatesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def autocomplete
    predicates = Predicate.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = predicates.collect do |t|
      str = t.name + ": " + t.definition
      {id: t.id,
       label: str,
       response_values: {
         params[:method] => t.id},
       label_html: str
      }
    end

    render :json => data
  end


  def select_options
    @predicates = Predicate.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:klass))
  end



end
