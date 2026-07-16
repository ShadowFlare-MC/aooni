#-------------------------------------------------------------------------------
# * Dynamic Lights Addon for Khas Awesome Light Effects
#-------------------------------------------------------------------------------
# just use [dlight x] instead of [light x]
#-------------------------------------------------------------------------------
 
class Light_SSource
 
  def draw
    sx = self.sx
    sy = self.sy
    w = self.w
    h = self.h
    return if sx > Graphics.width && sy > Graphics.height && 
              sx + w < 0 && sy + h < 0
    $game_map.light_surface.bitmap.blt(sx, sy, self.bitmap,
                                       Rect.new(0,0,w,h), self.opacity)
  end
  
end
 
class Light_DSource < Light_SSource
 
  def set_shadow(shadow)
    @skip_shadow = !shadow
  end
  
  def draw
    btr = self.get_graphic
    x = self.x
    y = self.y
    r = self.range
    sx = x + r
    sy = y + r
    dr = r*2
    $game_map.surfaces.each do |s|
      if s.visible?(sx,sy) && s.within?(x,x+dr,y,y+dr)
        s.render_shadow(x,y,sx,sy,r,btr)
      end
    end unless @skip_shadow
    $game_map.light_surface.bitmap.blt(self.sx, self.sy, btr,
                                       Rect.new(0,0,dr,dr), self.opacity)
    btr.dispose
  end
 
end
 
class Game_Character < Game_CharacterBase
  
  def set_dlight(light_gfx = nil, light_alpha = 255, 
                 light_flicker = 0, light_shadow = true)
    if light_gfx
      @light = Light_DSource.new unless @light
      @light.change_owner(self)
      @light.set_graphic(light_gfx)
      @light.set_opacity(light_alpha, light_flicker)
      @light.set_shadow(light_shadow)
      @light.show
      $game_map.light_sources |= [self]
    else
      @light.dispose
      @light = nil
      $game_map.light_sources.delete(self)
    end
  end
  
  def draw_light
    @light.draw if @light
  end
  
  def dispose_light
    @light.dispose
  end
  
  def restore_light
    @light.restore
  end
 
end
 
class Game_Event < Game_Character
  
  alias_method :setup_light_dynamic_base, :setup_light
  def setup_light(dispose)
    setup_light_dynamic_base(dispose)
    unless dispose && @list.nil?
      for command in @list
        if command.code == 108 && command.parameters[0].include?("[dlight")
          command.parameters[0].scan(/\[dlight\s*(\d+)\s*\]/)
          effect = Light_Core::Effects[$1.to_i]
          set_dlight(effect[0],effect[1],effect[2],effect[3])
          return
        end
      end
    end
  end
  
  
  def draw_light
    super
  end
  
  def dispose_light
    super
  end
  
  def restore_light
    super
  end
  
end
 
class Spriteset_Map
  
  def update_lights
    return unless $game_map.light_surface
    $game_map.light_surface.bitmap.clear
    $game_map.light_surface.bitmap.fill_rect(0,0,Graphics.width, Graphics.height,$game_map.effect_surface.color)
    $game_map.light_sources.each { |source| source.draw_light }
    $game_map.lantern.draw if $game_map.lantern.visible
  end
 
end