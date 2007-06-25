module EntryHelper
  def highlight_or_truncate(content, query)
    if query.nil? then
      truncate(h(content), 90)
    else
      highlight(h(content), @query, highlighter='<strong class="highlight">\1</strong>')
    end
  end

end
