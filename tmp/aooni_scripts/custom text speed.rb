class Window_Message < Window_Base
  def wait_for_one_character
    2.times {
    update_show_fast
     Fiber.yield  unless @show_fast || @line_show_fast
    }
  end
end