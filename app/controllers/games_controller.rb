class GamesController < ApplicationController
  before_filter :login_required
  before_filter :login_from_cookie
  before_filter :find_check_ownership, :except => [:index, :show, :new, :create]

  def find_check_ownership
    @game = Game.find(params[:id])
    unless current_user.id == @game.user.id
      flash[:notice] = 'You are not the owner of the specified record. Only the owner can perform the requested action.'
      redirect_to :action => 'show', :id => @game
    end
  end
  
  def find_game
    @game = Game.find(params[:id])
  end
  
  # GET /games
  # GET /games.xml
  def index
    if params[:filter_type].nil?
      @filter = {}
      @title = "All Games"
      @games = Game.paginate :page => params[:page], :order => "id DESC"
    else
      @filter = {:type => params[:filter_type], :id => params[:filter_id], :name => params[:filter_name]}
      @title = "Games For #{@filter[:type]}: #{@filter[:name]}"  
      case @filter[:type]
        when 'User'
          @games = current_user.games.paginate :page => params[:page], :order => 'id DESC'
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end
  
  # GET /games/1
  # GET /games/1.xml
  def show
    @game = find_game
    # @game = Game.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game }
    end
  end

  # GET /games/new
  # GET /games/new.xml
  def new
    @game = Game.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game }
    end
  end

  # POST /games
  # POST /games.xml
  def create
    uploaded_code = params[:game].delete(:uploaded_code)
    uploaded_template = params[:game].delete(:uploaded_template)
    uploaded_image = params[:game].delete(:uploaded_image)
    uploaded_css = params[:game].delete(:uploaded_css)
    @game = Game.new(params[:game])
    params[:newplayer].each do |player|
      p = Player.new(player);
      next if p.name.blank?
      # this does not save p to db because @game not yet saved
      @game.players << p
    end
    respond_to do |format|
      code = @game.build_code({:uploaded_data => uploaded_code})
      template = @game.build_template({:uploaded_data => uploaded_template})
      image = @game.build_image({:uploaded_data => uploaded_image})
      css = @game.build_css({:uploaded_data => uploaded_css})
      if(!@game.players.empty? and @game.code.valid? and
         @game.template.valid? and
         @game.image.valid? and @game.css.valid? and current_user.games << @game)
        format.html do
          flash[:notice] = 'Game was successfully created.'
          redirect_to :action => 'show', :id => @game
        end
        format.xml  { render :xml => @game, :status => :created, :location => @game }
      else
        format.html do
          if @game.players.empty?
            # don't like min 1 player here - much better if enforceable by
            # models
            flash[:notice] = 'A game must have at least one player.'
          end
          unless css.valid?
            @game.errors.add(:uploaded_css, 'CSS must be a css file')
          end
          unless image.valid?
            @game.errors.add(:uploaded_image, 'Image must be an image file')
          end
          unless code.valid?
            flash[:notice] = 'bad code'
          end
          unless template.valid?
            flash[:notice] = 'bad template'
          end

          #@game.filename = ''  # don't show this after an error
          render :action => 'new'
        end
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
    
    raise Exception.new("Code is nil") if(@game.code.nil?)
    raise Exception.new("Template is nil") if(@game.template.nil?)
    raise Exception.new("Image is nil") if(@game.image.nil?)
    raise Exception.new("CSS is nil") if(@game.css.nil?)
  end

  # GET /games/1/edit
  def edit
    #@game = Game.find(params[:id])  # now performed in :find_check_ownership
  end

  # PUT /games/1
  # PUT /games/1.xml
  def update
    @game = find_game

    uploaded_code = params[:game].delete(:uploaded_code)
    uploaded_template = params[:game].delete(:uploaded_template)
    uploaded_image = params[:game].delete(:uploaded_image)
    uploaded_css = params[:game].delete(:uploaded_css)
    
    unless(uploaded_code.nil? || uploaded_code.size == 0)
      #@game.code.destroy() unless @game.code.nil?
      @game.create_code({:uploaded_data => uploaded_code})
    end
    unless(uploaded_template.nil? || uploaded_template.size == 0)
      #@game.template.destroy() unless @game.template.nil?
      @game.create_template({:uploaded_data => uploaded_template})
    end
    unless(uploaded_image.nil? || uploaded_image.size == 0)
      #@game.image.destroy() unless @game.image.nil?
      @game.create_image({:uploaded_data => uploaded_image})
    end
    unless(uploaded_css.nil? || uploaded_css.size == 0)
      #@game.css.destroy() unless @game.css.nil?
      @game.create_css({:uploaded_data => uploaded_css})
    end
    
    delete_player_failed = false
    params[:player].each do |id, player|
      p = @game.players.find(id)
      # this line made it hard to enforce presence of one player
      #p.destroy if p.name.blank?
      if player[:name].empty?
        if @game.players.size > 1
          @game.players.delete(p) # deletes from db and players collection
        else
          # don't like min 1 player here - much better if enforceable by models
          flash[:notice] = 'A Game must have at least one player'
          delete_player_failed = true
        end
      else
        p.update_attributes(player)
      end
    end
    params[:newplayer].each do |player|
      p = Player.new(player);
      next if p.name.blank?
      @game.players << p  # this saves new player to db or returns false
    end
	respond_to do |format|
      # don't like min 1 player here - much better if enforceable by models
      if !delete_player_failed and @game.update_attributes(params[:game])
        format.html do
          flash[:notice] = 'Game was successfully updated.'
          redirect_to :action => 'show', :id => @game
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.xml
  def destroy
    @game = find_game
    # @game = Game.find(params[:id])  # now performed in :find_check_ownership
    if @game.results.nil? or @game.results.empty?
      if @game.agents.nil? or @game.agents.empty?
        @game.destroy
        flash[:notice] = 'Game successfully destroyed.'
      else
        flash[:notice] = 'Game not destroyed because there are agents that can play it.'
      end
    else
      flash[:notice] = 'Game not destroyed because it has result records.'
    end
    redirect_to :action => 'index', :filter_type => params[:filter_type], :filter_id => params[:filter_id], :filter_name => params[:filter_name]
    #respond_to do |format|
    #  format.html { redirect_to(games_url) }
    #  format.xml  { head :ok }
    #end
  end
  
  def download_source_code
    @game = find_game
    # @game = Game.find(params[:id])  # now performed in :find_check_ownership
    send_file @game.code.public_filename, :type => 'plain/text', :disposition => 'inline'
  end
  
  def edit_source_code
    @game = find_game
    # @game = Game.find(params[:id])  # now performed in :find_check_ownership
    code_file = File.open(@game.code.public_filename)
    @code = code_file.read
    code_file.close
  end
  
  def update_source_code
    @game = find_game
    # @game = Game.find(params[:id])  # now performed in :find_check_ownership
    @code = params[:source_code].gsub("\r\n", "\n")
    code_file = File.open(@game.code.public_filename, 'w')
    code_file.write @code
    code_file.close 
    flash[:notice] = 'Source code successfully updated'
    redirect_to :back
  end
end
