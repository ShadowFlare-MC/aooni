################################################################
# RETCON Library
# Journal Version 1.2
# Author: Matt (McDohl)
# Script is free for usage, but please give credit where credit 
# is due. :)
################################################################
# PURPOSE
# This script adds a journal-type feature to your game. Passages
# are defined in the matrix, and full customization allows for
# modification of the journal at any time.
#
# Lot of feature creep happened in this script. Need significant
# assistance in making sure all the bugs are out.
################################################################
# UPDATE HISTORY
# 1.2 - Added user-defined variables to set the position of the title text.
# 1.1 - Added "no entries" and "first access" to customization.
#       Slight code cleanup.
# 1.0 - First Draft
################################################################
# METHODOLOGY
# Four new classes are created:
#
# Page_Selector: Base Class for title and main journal functions
# Window_Journal: Subset of Window_Selectable, outlines the journal window 
#        and the page displays.
# Window_JournalTitle: Subset of Window_Selectable, displays the correct title
#        in the window.
# Scene_Journal: Displays the journal appropriately.
# 
# In addition, three classes are modified
# 
# Game_Party: The global function is modified and allows for reference/saving 
#             the journal.
# Scene_Menu: Displays the journal function to the menu.
# Window_MenuCommand: Calls the journal function from the menu.
################################################################
# USAGE
# In the customization section, modify the matrix to display all the journal
# entries. Each array entry contains an array with the following:
#     Entry[#] = ["Text for that journal entry", "Title for that entry"]
# If you are not using titles, you do not have to add them to the entry.
# Said entry will look like this
#     Entry[#] = ["Text for that journal entry"]
#
# To modify entry availability in game, reference the following function:
#     RETCON::Journal::journal_activate(#)
# Wherein # is replaced with the number of the entry in the matrix. To remove
# from displaying a page, use this function in a similar manner.
#     RETCON::Journal::journal_deactivate(#)
#
# To gray out the Journal in the menu, reference the following in a script call
# in your game:
#     RETCON::Journal::journal_access(true)      (makes the journal accessible)
#     RETCON::Journal::journal_access(false)     (makes the journal inaccessible)
#
# To modify journal entries after the game is started, use the following syntax
# when using a script call function:
#     RETCON::Journal::modify_entry(#, "Text for the new entry.")
#     RETCON::Journal::modify_title(#, "Title for the new entry.")
# Where the # is the number of the journal entry and/or title you wish to be 
# modified.
#
# This script, while it allows for on-the-fly modification to the journal, does
# not allow for on-the-fly addition (adding entries via script call in your game).
# This is purposeful for strict organization of code functionality. If there is
# an immense desire to add quests/entries, you may add a bunch of blank ones in the
# module, and use the modify_entry script call to edit them as you go. However,
# this is -not- recommended, as it leads to sloppiness. Organize your quests/entries
# beforehand.
################################################################
# CUSTOMIZATION

module RETCON
  module Journal
    
    #Name for the journal in the menu
    Name = "Journal"
    
    Entry = Array.new
    
    #yo dawg, I heard you like matrices, so I put an array inside your array
    #so you can arrange while you arrange.
    #in other words, edit here.
    #Use \n to delineate line breaks if not using the RETCON Word Wrap script.
    Entry[0] = ["This is entry #1 of the journal. As you can see, it functions as a generic horizontal scrolling window for you to display whatever you'd like here.", "TITLE: #1"]
    Entry[1] = ["This is entry #2 of the journal.", "TITLE: #2"]
    Entry[2] = ["This is entry #3 of the journal.", "TITLE: #3"]
    Entry[3] = ["This is entry #4 of the journal.", "TITLE: #4"]
    Entry[4] = ["This is entry #5 of the journal.", "TITLE: #5"]
    
    #width of the journal display window. set to maximum width, 544
    JWidth = 544
    
    #Number of "lines" to display for the journal. Keep to even numbers if using
    #the default font. Fool around with this value if using a different one.
    LineDisplay = 10
    
    #X and Y positions of the journal window
    JournalXPos = 0
    JournalYPos = 48
    
    #Journal initialization, for when a player starts the game
    FirstTimeAccess = true
    
    #What a Journal should display when it's accessible, but there are no
    #entries
    NoEntries = "There are currently no entries."
    NoTitle = "Not Applicable"
    
    #Display the current journal entry / Display total number of journal entries.
    PageNumbers = true
    
    #Position for the page numbers.
    PageNumXPos = 435
    PageNumYPos = 375
    
    #Create titles for journal entries.
    UseTitles = true
    
    #Color of text in the title. Corresponds to your window skin set colors.
    #0 for default.
    TitleColor = 6
    
    #Position and stats for the title window length.
    TitleXPos = 0
    TitleYPos = 0
    TitleWidth = JWidth
    TitleHeight = 48
    
    #Position and alignment for the text in the title box.
    #For alignment, 0 means left align, 1 means center align, 2 means right align.
    TitleTextXPos = 0
    TitleTextYPos = 0
    TitleTextAlign = 1
    
################################################################
#Customization ends here!
#You shouldn't really edit below here, but if you know what
#you're doing, it won't be a big deal. Edit at your own risk and
#all that jazz.
################################################################
    
    def self.journal_activate(journalpage)
      $game_party.journal_hash[journalpage] = true
    end
    
    def self.journal_deactivate(journalpage)
      $game_party.journal_hash[journalpage] = false
    end
    
    def self.journal_access(journalbool)
      $game_party.journal_active = journalbool
    end
    
    def self.modify_entry(entrynum, entrytext)
        $game_party.journal[entrynum][0] = entrytext
    end
    
    def self.modify_title(entrynum, titletext)
      $game_party.journal[entrynum][1] = titletext
    end
  end
end

#################
#CLASS ORIGINALS#
#################

#class to reference which page the journal is on, used by both title
#and journal window classes.
class Page_Selector
  attr_accessor   :currentpage  #the currently displayed journal page
  attr_accessor   :maxpage      #the maximum number of pages to show
  attr_accessor   :changeit     #boolean reference for update method
  attr_accessor   :currentindex #index used for total number of true pages
  
  def initialize
    @currentpage = 0
    @currentindex = 0
    @maxpage = 0
    @changeit = false
    @errorcheck = false
    @justopened = true
    check_for_entries
  end
  
  #detects keyinput, left or right
  def change_page
    if @errorcheck == false
      page_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
      page_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    end
  end
  
  def check_for_entries
    generate_pages
    if @errorcheck == false
      page_right
    end
  end

  #increments the index when going right
  def page_right(wrap = false)
    check_page_right
    if @justopened == true
      @currentpage = 0
      @justopened = false
    end
    while $game_party.journal_hash[@currentpage] == false
      check_page_right
    end
    finish_change
    @currentindex += 1
    if @currentindex > @maxpage
      @currentindex = 1
    end
  end
    
  def check_page_right
    @currentpage += 1
    if @currentpage > $game_party.journal.length - 1
      @currentpage = 0
    end
  end
  
  #decrements the index when going left
  def page_left(wrap = false)
    check_page_left
    while $game_party.journal_hash[@currentpage] == false
      check_page_left
    end
    finish_change
    @currentindex -= 1
    if @currentindex <= 0
      @currentindex = @maxpage
    end
  end
  
  def check_page_left
    @currentpage -= 1
    if @currentpage < 0
       @currentpage = $game_party.journal.length - 1
    end
  end
  
  #plays sound when browsing journal pages.
  def finish_change 
    @changeit = true
    if @maxpage >= 2
      Sound::play_cursor
    end
  end
  
  #implements what to display versus what's in the hash.
  def generate_pages
    $game_party.journal_hash.each do |key, value|
      if value == true
        @maxpage += 1
      end
    end
    if @maxpage == 0
      @errorcheck = true
    end
  end
end

class Window_Journal < Window_Selectable
  def initialize
    @page = Page_Selector.new
    super(RETCON::Journal::JournalXPos, RETCON::Journal::JournalYPos, RETCON::Journal::JWidth, window_height)
    determine_ox
    init_counter_display
    refresh
  end

 #window height, as defined in module
 def window_height
    wh = line_height * RETCON::Journal::LineDisplay
    return wh
  end
  
  #adds left window arrow
  def determine_ox
    if @page.maxpage < 2
      self.ox = 0
    else
      self.ox = 1
    end
  end
  
  #adds right window arrow.
  def contents_width
    if @page.maxpage < 2
      return width - 24
    else
      return width + 2
    end
  end
  
  #used for drawing the out-of-window counter display
  #first function is inits
  def init_counter_display
    @journalpages = Sprite.new
    @journalpages.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @journalpages.z = 100
  end
  
  #function used to create out-of-window counter
  def create_counter_display
    init_counter_display
    rect = Rect.new(RETCON::Journal::PageNumXPos, RETCON::Journal::PageNumYPos, 75, 24)
    @journalpages.bitmap.draw_text(rect, @page.currentindex.to_s + " / " + @page.maxpage.to_s, 2)
  end
  
  #update used to detect functions.
  def update
    super
    @page.change_page
    if (@page.changeit == true)
      refresh
      @page.changeit = false
    end
  end
  
  #draws the journal window.
  def create_journal_display
    entry = ""
    if @page.maxpage == 0
      entry = RETCON::Journal::NoEntries
    else
      entry = $game_party.journal[@page.currentpage][0].to_str
    end
    if !$imported.nil? && $imported["RETCON-wordwrap"] == true
        draw_text(0, 0, Graphics.width, Graphics.height, entry)
    else
      draw_text_ex(0, 0, entry)  
    end
  end

  def refresh
    super
    contents.clear
    @journalpages.dispose
    create_counter_display
    create_journal_display
  end
end

class Window_JournalTitle < Window_Base
  def initialize
    super(RETCON::Journal::TitleXPos, RETCON::Journal::TitleYPos, RETCON::Journal::TitleWidth, RETCON::Journal::TitleHeight)
    @pagetitle = Page_Selector.new
    refresh
  end
  
  #the titlefixins
  def update
    super
    @pagetitle.change_page
    if (@pagetitle.changeit == true)
      refresh
      @pagetitle.changeit = false
    end
  end
  
  def create_title
    title = ""
    if @pagetitle.maxpage == 0
      title = RETCON::Journal::NoTitle
    else
      title = $game_party.journal[@pagetitle.currentpage][1].to_str
    end
    change_color(text_color(RETCON::Journal::TitleColor))
    draw_text(RETCON::Journal::TitleTextXPos, RETCON::Journal::TitleTextYPos, Graphics.width, line_height, title , RETCON::Journal::TitleTextAlign)
    change_color(normal_color)
  end
  
  def refresh
    contents.clear
    create_title
  end
end

class Scene_Journal < Scene_MenuBase
  def initialize
    super
    journal_window
  end
  
  #short and simple scene, creates the window classes appropriately.
  def journal_window
     @journalwindow = Window_Journal.new
     if RETCON::Journal::UseTitles == true
      @journalwindowtitle = Window_JournalTitle.new
     end
     @journalwindow.set_handler(:cancel, method(:backout))
     @journalwindow.active = true
   end
  
  def backout
    SceneManager.return
  end
end

###############
#CLASS ADDENDA#
###############

#adds journal to the menu function
#class Window_MenuCommand < Window_Command
  #alias journal_command add_original_commands
  #def add_original_commands
    #journal_command
    #add_command(RETCON::Journal::Name, :journal, $game_party.journal_active)
  #end
#end

#displays journal to the menu
#class Scene_Menu < Scene_MenuBase
  #alias journal_command_window create_command_window
  #def create_command_window
    #journal_command_window
    #the addition
    #@command_window.set_handler(:journal,   method(:command_journal))
  #end
  
  def command_journal
    SceneManager.call(Scene_Journal)
  end
#end

class Game_Party < Game_Unit 
  attr_accessor   :journal
  attr_accessor   :journal_hash
  attr_accessor   :journal_active
  
  #creates the journal
  alias journal_retain_previous initialize
  def initialize
    journal_retain_previous
    @journal = Array.new
    @journal_hash = Hash.new
    @journal_active = RETCON::Journal::FirstTimeAccess
    make_the_journal
  end
  
  #initalizes the journal hash.
  def make_the_journal
    @journal = RETCON::Journal::Entry
    i = 0
    while i < @journal.length
      @journal_hash.merge! i => false
      i += 1
    end
  end
end