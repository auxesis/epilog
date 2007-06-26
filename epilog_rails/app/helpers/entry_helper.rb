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

end
