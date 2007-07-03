class EntryController < ApplicationController
  def index
    find
    render :action => 'find'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :index }

  def calendar
    #render :layout => false
  end

  def show
    @entry = Entry.find(params[:id])
    render :partial => 'details', :layout => true
  end

  def details
    @entry = Entry.find(params[:id])
    element = 'entry-' + @entry.id.to_s
    # icky! this should be separated out into rjs
    render :update do |page|
      page.replace_html element, :partial => "details"
      page.visual_effect(:toggle_appear, element, :duration => 0.6)
    end
  end

  def find
    #@query = params[:id] if params[:id] 

    @pages, @entries = paginate :entries, :per_page => 10
  end

  def query
    find if params[:query].blank?

    @query = params[:query]
    
    #@query = contextualise_time(@query)
    #if params[:query].is_hash? then @query = params[:query][:query].split('=').pop end
    
    @total, @entries = Entry.full_text_search(@query, :page => (params[:page]||1))          
    @pages = pages_for(@total)

    find if params[:query].blank?
    
    render :partial => 'results', :layout => false
  end


  def contextualise_time(query)
    case query
    when /yesterday/
      timestamp = 1.day.ago.strftime("%A %B %d %Y %j")
      query.gsub!('yesterday', timestamp)
      return query
    when /last week/
      day = 1.week.ago.beginning_of_week.strftime("%j").to_i
      range = []
      (day..day+6).each {|n| range << n}
      range = range.join(' ')
      query.gsub!('last week', range)
      return query
    else
      return query
    end
  end

  # lets just disable this for now. 
  #def query_store 
  #  Query.new = params[:query]
  #  Query.save
  #end


  # everything below here is probably going to go :-)

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(params[:entry])
    if @entry.save
      flash[:notice] = 'Entry was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @entry = Entry.find(params[:id])
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      flash[:notice] = 'Entry was successfully updated.'
      redirect_to :action => 'show', :id => @entry
    else
      render :action => 'edit'
    end
  end

  def destroy
    Entry.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
