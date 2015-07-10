class MachinesController < ApplicationController

  # GET    /users/:user_id/machines/:id/gen_features(.:format)
  # get the features of this machine that the users
  # retures what features that this machines has used
  # options:-
  #   start_id   start from this id and descend 1000 data points
  # in json mode, returns the last 1000 data points in this format:-
  #     [ {:name => feature_name, :data => [ [x1,y1], [x2,y2],...,[xn,yn]] } ]
  #     should return
  #     {
  #       :last_data_point => lowest features id,
  #       :graph_data => [
  #           { :name => feature_name1, :data => [ [x1,y1], [x2,y2], .. [xn,yn] ] },
  #           ...
  #           { :name => feature_nameN, :data => [ [x1,y1], [x2,y2], .. [xn,yn] ] },
  #       ]
  def gen_features
    @user = User.find(params[:user_id])
    @machine = @user.machines.find(params[:id])
    theMachineId = @machine.id
    if params.has_key? :start_id then
      start_id = params[:start_id].to_i - 1
    else
      start_id = Feature.last.id
    end
    #@features = @machine.features.where{ (id.lteq start_id) }.order('features.id desc').limit(100)
    #suppose to be much faster
    @features = Feature.where(:id =>
      MachineFeature.where{
        (machine_id.eq theMachineId) && ( feature_id.lteq start_id ) }.limit(1000).order(:feature_id => :desc).pluck(:feature_id)
    )

    respond_to do |format|
      format.json {
        init_hash = @features.select(:name).inject({}){ |m,e| m.merge( { e.name.to_sym => [] } ) }
        @features.order(:created_at).each{ |x| init_hash[x.name.to_sym] << [x.created_at.to_i * 1000 , x.current] }
        render :json => {
          :last_data_point => @features.empty? ? 0 : @features.min.id,
          :graph_data => init_hash.inject([]){ |m,e| m << { :name => e[0], :data => e[1].sort } }
        }
      }
      format.html {
        render :partial => 'features_accordion',
          :locals => { :user => @user, :machine => @machine, :features => @features }
      }
    end
  end

	def machine_feature_params
		params.require(:machine_feature_params).permit( :machine_id, :feature_id )
	end
end
