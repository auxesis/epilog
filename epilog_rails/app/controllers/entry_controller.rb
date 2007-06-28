class EntryController < ApplicationController
  def index
    find
    render :action => 'find'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, :query ],
         :redirect_to => { :action => :find }

  def list
    @entry_pages, @entries = paginate :entries, :per_page => 10
  end

  def show
    @entry = Entry.find(params[:id])
  end

  def find
    if params[:id] then
      @query = params[:id]
    end

    @entry_pages, @entries = paginate :entries, :per_page => 10

  end

  def query

    @entries = Entry.find_by_contents(params[:query])
    @query = params[:query]

    if params[:query].blank?
      list
    end
    
    render :partial => 'results', :layout => false

  end


  # lets just disable this for now. 
  #def query_store query
  #  Query.new = query
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
