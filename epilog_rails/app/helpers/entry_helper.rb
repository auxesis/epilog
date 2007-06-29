module EntryHelper
  def highlight_or_truncate(content, query)
    content=h(content)
    if query.nil? then
      truncate(content, 90)
    else
       text=highlight(content, query, highlighter='<strong class="highlight">\1</strong>')
       excerpt(text, query, 200)
    end
  end

  # broken!
  def toggle(id)
    link_to_function("Details", nil, :id => "more_link") do |page|
      page[:details].visual_effect  :toggle_blind
      page[:more_link].replace_html "Show me less"
    end

    update_page do |page|
      page.delay(3) do
        page.toggle(id)
        #page.visual_effect(:toggle_appear, id, :duration => 0.5)
      end
    end
  end


end
