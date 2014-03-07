class MachinesController < ApplicationController
  
  # GET    /users/:user_id/machines/:id/gen_features(.:format)
  # get the features of this machine that the users 
  def gen_features
    @user = User.find(params[:user_id])
    @machine = @user.machines.find(params[:id])
    @features = @machine.features

    respond_to do |format|
      format.json { 
        init_hash = @features.select(:name).inject({}){ |m,e| m.merge( { e.name.to_sym => [] } ) }
        @features.order(:created_at).each{ |x| init_hash[x.name.to_sym] << [x.created_at.to_i * 1000 , x.current] } 
        render :json => init_hash.inject([]){ |m,e| m << { :name => e[0], :data => e[1] } }
      }
      format.html { 
        render :partial => 'features_accordion', 
          :locals => { :user => @user, :machine => @machine, :features => @features }
      }
    end
  end
end
