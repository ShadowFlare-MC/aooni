#==============================================================================
# ■ Follower Touch [VXA]
# Author: Mesiah A.K.A. MakoInfused
# Version: N/A
# Contact: www.cetrastudios.com/
#------------------------------------------------------------------------------
# ■ Short Description
#------------------------------------------------------------------------------
# Makes it so that touch encounter based events will trigger when they
# collide with players or followers.
#===============================================================================

#==============================================================================
# ** Game_Event
#==============================================================================

class Game_Event < Game_Character

  #--------------------------------------------------------------------------
  # overwrite method: check_event_trigger_touch
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 && collide_with_player_characters?(x, y)
      start if !jumping? && normal_priority?
    end
  end
  
end