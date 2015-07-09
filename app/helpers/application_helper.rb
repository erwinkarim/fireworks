module ApplicationHelper
  def generate_header(stack)
    @returnString = String.new
    stack.each do |element|
      @returnString = @returnString + (stack.last == element ? '<li class="active">' : '<li>') +
        element + (stack.last == element ? '' : ' <span class="divider">/<span>') + '</li>'
    end
    @returnString = '<ul class="breadcrumb">'+ @returnString + '</ul>'
    return @returnString.html_safe
  end

	#return the word active if active_path is the current path
	def active_path( active_path )
		if request.fullpath == active_path then
			return "active"
		else
			return ""
		end
	end

  def flash_class flash_type
    flash_type_text = flash_type.to_s
    case flash_type_text
    when 'success'
      return 'success'
    when 'notice'
      return 'info'
    when 'alert'
      return 'danger'
    else 
      return 'info'
    end
  end
end
