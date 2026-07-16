#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  # ショップ Screen
  ショップBuy         = "Buy"
  ショップSell        = "Sell"
  ショップキャンセル      = "キャンセル"
  Possession      = "Possession"

  # ステータス Screen
  ExpTotal        = "Current Exp"
  ExpNext         = "To Next %s"

  # セーブ/ロード Screen
  セーブMessage     = "セーブ to which file?"
  ロードMessage     = "ロード which file?"
  ファイル            = "ファイル"

  # Display when there are multiple members
  PartyName       = "%s's Party"

  # Basic 戦闘 Messages
  Emerge          = "%s emerged!"
  Preemptive      = "%s got the upper hand!"
  Surprise        = "%s was surprised!"
  逃走Start     = "%s has started to escape!"
  逃走Failure   = "However, it was unable to escape!"

  # 戦闘 Ending Messages
  勝利         = "%s was victorious!"
  敗北          = "%s was defeated."
  ObtainExp       = "%s EXP received!"
  ObtainGold      = "%s\\G found!"
  Obtainアイテム      = "%s found!"
  LevelUp         = "%s is now %s %s!"
  ObtainSkill     = "%s learned!"

  # 使う アイテム
  使うアイテム         = "%s uses %s!"

  # Critical Hit
  CriticalToEnemy = "An excellent hit!!"
  CriticalToActor = "A painful blow!!"

  # Results for Actions on Actors
  ActorDamage     = "%s took %s damage!"
  ActorRecovery   = "%s recovered %s %s!"
  ActorGain       = "%s gained %s %s!"
  ActorLoss       = "%s lost %s %s!"
  ActorDrain      = "%s was drained of %s %s!"
  ActorいいえDamage   = "%s took no damage!"
  ActorいいえHit      = "Miss! %s took no damage!"

  # Results for Actions on Enemies
  EnemyDamage     = "%s took %s damage!"
  EnemyRecovery   = "%s recovered %s %s!"
  EnemyGain       = "%s gained %s %s!"
  EnemyLoss       = "%s lost %s %s!"
  EnemyDrain      = "Drained %s %s from %s!"
  EnemyいいえDamage   = "%s took no damage!"
  EnemyいいえHit      = "Missed! %s took no damage!"

  # Evasion/Reflection
  Evasion         = "%s evaded the attack!"
  MagicEvasion    = "%s nullified the magic!"
  MagicReflection = "%s reflected the magic!"
  CounterAttack   = "%s counterattacked!"
  Substitute      = "%s protected %s!"

  # Buff/Debuff
  BuffAdd         = "%s's %s went up!"
  DebuffAdd       = "%s's %s went down!"
  BuffRemove      = "%s's %s returned to normal."

  # Skill or アイテム Had いいえ Effect
  ActionFailure   = "There was no effect on %s!"

  # Error Message
  PlayerPosError  = "Player's starting position is not set."
  EventOverflow   = "Common event calls exceeded the limit."

  # Basic ステータス
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # Parameters
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 装備 Type
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # Commands
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # Currency Unit
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # Level
  def self.level_a;     basic(1);     end   # Level (short)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (short)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (short)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (short)
  def self.fight;       command(0);   end   # Fight
  def self.escape;      command(1);   end   # 逃走
  def self.attack;      command(2);   end   # Attack
  def self.guard;       command(3);   end   # Guard
  def self.item;        command(4);   end   # アイテムs
  def self.skill;       command(5);   end   # スキル
  def self.equip;       command(6);   end   # 装備
  def self.status;      command(7);   end   # ステータス
  def self.formation;   command(8);   end   # Change Formation
  def self.save;        command(9);   end   # セーブ
  def self.game_end;    command(10);  end   # 終了 Game
  def self.weapon;      command(12);  end   # Weapons
  def self.armor;       command(13);  end   # Armor
  def self.key_item;    command(14);  end   # Key アイテムs
  def self.equip2;      command(15);  end   # Change 装備ment
  def self.optimize;    command(16);  end   # Ultimate 装備ment
  def self.clear;       command(17);  end   # Remove All
  def self.new_game;    command(18);  end   # はじめから
  def self.continue;    command(19);  end   # つづきから
  def self.shutdown;    command(20);  end   # Shut Down
  def self.to_title;    command(21);  end   # Go to Title
  def self.cancel;      command(22);  end   # キャンセル
  #--------------------------------------------------------------------------
end
