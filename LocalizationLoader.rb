# Simple Japanese localization loader for Ao Oni
# This is a lightweight compatibility layer for common menu and self-window text.

module LocalizationLoader
  DATA_FILE = 'ja_texts.txt'

  def self.load
    path = File.join(Dir.pwd, DATA_FILE)
    return {} unless File.exist?(path)

    data = {}
    File.readlines(path).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      key, value = line.split('=', 2)
      data[key.to_s.strip] = value.to_s.strip if key && value
    end
    data
  rescue
    {}
  end

  def self.text(key, fallback = nil)
    @texts ||= load
    @texts[key] || fallback
  end
end

# Basic menu labels
if defined?(Vocab)
  Vocab::MENU_NEW_GAME = LocalizationLoader.text('MENU_NEW_GAME', 'New Game')
  Vocab::MENU_CONTINUE = LocalizationLoader.text('MENU_CONTINUE', 'Continue')
  Vocab::MENU_OPTIONS = LocalizationLoader.text('MENU_OPTIONS', 'Options')
  Vocab::MENU_EXIT = LocalizationLoader.text('MENU_EXIT', 'Exit')
  Vocab::MENU_LOAD = LocalizationLoader.text('MENU_LOAD', 'Load')
  Vocab::MENU_SAVE = LocalizationLoader.text('MENU_SAVE', 'Save')
  Vocab::MENU_ITEM = LocalizationLoader.text('MENU_ITEM', 'Item')
  Vocab::MENU_SKILLS = LocalizationLoader.text('MENU_SKILLS', 'Skills')
  Vocab::MENU_EQUIP = LocalizationLoader.text('MENU_EQUIP', 'Equip')
  Vocab::MENU_STATUS = LocalizationLoader.text('MENU_STATUS', 'Status')
  Vocab::MENU_OK = LocalizationLoader.text('MENU_OK', 'OK')
  Vocab::MENU_CANCEL = LocalizationLoader.text('MENU_CANCEL', 'Cancel')
  Vocab::MENU_YES = LocalizationLoader.text('MENU_YES', 'Yes')
  Vocab::MENU_NO = LocalizationLoader.text('MENU_NO', 'No')
end

# Common action labels used by GUI and self-window style displays
if defined?(RPG)
  if defined?(RPG::System)
    begin
      RPG::System::WORDS = LocalizationLoader.text('SYSTEM_WORDS', 'System') if RPG::System.respond_to?(:const_set)
    rescue StandardError
      nil
    end
  end
end

# Override common strings at runtime when possible
module LocalizationHooks
  def self.apply
    return unless defined?(Window_Selectable)

    Window_Selectable.class_eval do
      alias_method :orig_draw_item, :draw_item if method_defined?(:draw_item)
      def draw_item(index)
        return orig_draw_item(index) unless LocalizationLoader.text('MENU_NEW_GAME', nil)
        super
      rescue StandardError
        super
      end
    end
  rescue StandardError
    nil
  end
end

LocalizationHooks.apply
