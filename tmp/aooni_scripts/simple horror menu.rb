#----------------------------------------------------------------------------#
#Z-ON: Simple Non-RPG Menu                                                   #
#contact:                                                                    #
#-email            : evanandasatria@gmail.com                                #
#-rpgmakervxace.net: Zeon013                                                 #
#----------------------------------------------------------------------------#
#Change Logs:                                                                #
#2014.06.27 - Version 1.0 - Release                                          #
#2014.06.29 - Version 1.1 - Added Actor_nickname and Actor_Class             #
#----------------------------------------------------------------------------#
#Introduction:                                                               #
#this script is made for Non-RPGs like story telling or                      #
#horror games, it only need items, save, load, and game end.                 #
#----------------------------------------------------------------------------#
#Instruction:                                                                #
#Place this script under ▼ Materials and above ▼ Main Process                #
#----------------------------------------------------------------------------#
#Terms of Use:                                                               #
#feel free to use this script in commercial or non-commercial                #
#project as long as you:                                                     #
#credit me as "Zeon013" or "Z-ON".                                           #
#----------------------------------------------------------------------------#

module NLV
  Load_Vocab = "Load" #edit if you want to change Load Vocab
end

#----------------------------------------------------------------------------
# EDIT AT YOUR OWN RISK
#----------------------------------------------------------------------------
class Window_MenuStatus < Window_Selectable

  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_actor_face(actor, rect.x + 1, rect.y + 1, enabled)
    draw_actor_name(actor, rect.x + 100, rect.y)
#~     draw_actor_level(actor, rect.x + 100, rect.y + line_height * 1)
#~     draw_actor_nickname(actor, rect.x + 220, rect.y)
     draw_actor_class(actor, rect.x + 220, rect.y + line_height * 1)
  end

end

class Window_MenuCommand < Window_Command
  alias make_command_list make_command_list
  def make_command_list
    add_main_commands
    add_original_commands
    add_save_command
    add_game_end_command
  end

  alias add_main_commands add_main_commands
  def add_main_commands
    add_command(Vocab::item,   :item,   main_commands_enabled)
    add_command(NLV::Load_Vocab,   :continue, main_commands_enabled)
  end
  
  alias add_save_command add_save_command
  def add_save_command
    add_command(Vocab::save, :save, save_enabled)
  end
  
end
  
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
    create_status_window
  end

  alias create_command_window create_command_window
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,      method(:command_item))
    @command_window.set_handler(:continue, method(:on_load_ok))
    @command_window.set_handler(:save,      method(:command_save))
    @command_window.set_handler(:game_end,  method(:command_game_end))
    @command_window.set_handler(:cancel,    method(:return_scene))
  end

  #--------------------------------------------------------------------------
  # * Create Status Window
  #--------------------------------------------------------------------------
  alias create_status_window create_status_window
  def create_status_window
    @status_window = Window_MenuStatus.new(@command_window.width, 0)
  end
  #--------------------------------------------------------------------------
  # * [Item] Command
  #--------------------------------------------------------------------------
  alias command_item command_item
  def command_item
    SceneManager.call(Scene_Item)
  end
  
  def on_load_ok
    SceneManager.call(Scene_Load)
  end

  #--------------------------------------------------------------------------
  # * [Exit Game] Command
  #--------------------------------------------------------------------------
  alias command_game_end command_game_end
  def command_game_end
    SceneManager.call(Scene_End)
  end

end

class Window_ItemCategory < Window_HorzCommand
  alias col_max col_max
  def col_max
    return 1
  end
  
  alias make_command_list make_command_list  
  def make_command_list
    add_command(Vocab::item,     :item)
  end
end

class Window_ItemList < Window_Selectable
  alias include? include?
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item?
    else
      false
    end
  end
end