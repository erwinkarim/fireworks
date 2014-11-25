module WatchListsHelper
	# required option
	# 	user							the current user that is logged on
	# 	model_type				the model type
	# 	model_id					the model id
	# options
	# 	class							class attribute to the link
	# 	text							to display text. 'watched' if the item is being watched, and 'watch' if not yet
	def watch_icon( options = { :user => current_ads_user, :model_type => nil, :model_id => nil, :class => '' , :text => true} )
		# check if the item under watch or not
		watched =  current_ads_user.watch_lists.where( :model_type => options[:model_type], :model_id => options[:model_id] ).count > 0 ? true : false  
		link_text = watched ? fa_icon('star',{ :text => options[:text] ? 'Watched' : '' }) : fa_icon('star-o', { :text => options[:text] ? 'Watch' : '' })	
		link_address = ads_user_toggle_watch_path(options[:user].login, :model_type => options[:model_type], :model_id => options[:model_id])

		return link_to link_text, link_address, :method => :post, :remote => true, :class => options[:class]
	end
end
