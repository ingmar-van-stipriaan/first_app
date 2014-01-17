module ApplicationHelper
  
  #defines the page title
  def full_title(page_title)
    base_title = 'Mijn site'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
end
