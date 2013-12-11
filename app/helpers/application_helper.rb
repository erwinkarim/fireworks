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
end
