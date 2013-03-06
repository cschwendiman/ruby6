# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def fix_game_data(game)
    conditions = ["game_id = ?", game.id]
    game.code = Code.find(:first, :conditions =>conditions)
    game.template = Template.find(:first,:conditions =>conditions)
    game.image = Image.find(:first,:conditions =>conditions)
    game.css = Css.find(:first, :conditions =>conditions)
    nil
  end
end
