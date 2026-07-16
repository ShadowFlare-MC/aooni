#!/usr/bin/env ruby
# Safe rvdata2 string replacer: loads Marshal objects with global stub classes,
# replaces matching English strings with Japanese, and writes back using Marshal.dump.

require 'json'
require 'set'

# Ensure missing constants create placeholder classes
class Module
  def const_missing(name)
    const_set(name, Class.new)
  end
end

# Define RPG module
module RPG; end

# Generic tone loader for Marshal compatibility
class Tone
  def self._load(data)
    vals = Marshal.load(data)
    obj = new
    if vals.is_a?(Array)
      obj.instance_variable_set(:@red, vals[0])
      obj.instance_variable_set(:@green, vals[1])
      obj.instance_variable_set(:@blue, vals[2])
      obj.instance_variable_set(:@gray, vals[3])
    end
    obj
  end
end

# Replacement mapping (expand as needed)
REPL = {
  'New Game' => 'はじめから',
  'Continue' => 'つづきから',
  'Title' => 'タイトル',
  'Save' => 'セーブ',
  'Load' => 'ロード',
  'Item' => 'アイテム',
  'Skills' => 'スキル',
  'Equip' => '装備',
  'Status' => 'ステータス',
  'Cancel' => 'キャンセル',
  'Yes' => 'はい',
  'No' => 'いいえ',
  'Use' => '使う',
  'Look' => '調べる',
  'Open' => '開ける',
  'Close' => '閉じる',
  'Take' => '取る',
  'Run' => '走る',
  'Wait' => '待つ',
  'Talk' => '話す',
  'Self' => 'セルフ',
  'Menu' => 'メニュー',
  'Game' => 'ゲーム',
  'new game' => 'はじめから',
  'game' => 'ゲーム',
  'save' => 'セーブ',
  'item' => 'アイテム',
  'equip' => '装備',
  'use' => '使う',
  'look' => '調べる',
  'take' => '取る',
  'open' => '開ける',
  'close' => '閉じる',
}

# Files to process (safe set)
DATA_DIR = '/tmp/aooni_unpack2/Data'
TARGET_FILES = %w[System.rvdata2 MapInfos.rvdata2 Actors.rvdata2 CommonEvents.rvdata2 Scripts.rvdata2]

# Recursive walker to replace strings in object graph
def replace_in_obj(obj, repl)
  case obj
  when String
    begin
      s = obj.encode('UTF-8')
    rescue
      s = obj.dup.force_encoding('UTF-8') rescue obj.dup
    end
    repl.each do |k,v|
      s = s.gsub(k, v)
    end
    return s
  when Array
    obj.map! {|e| replace_in_obj(e, repl) }
  when Hash
    obj.keys.each do |k|
      nk = replace_in_obj(k, repl)
      nv = replace_in_obj(obj.delete(k), repl)
      obj[nk] = nv
    end
    obj
  else
    if obj.respond_to?(:instance_variables)
      obj.instance_variables.each do |ivar|
        val = obj.instance_variable_get(ivar)
        new_val = replace_in_obj(val, repl)
        obj.instance_variable_set(ivar, new_val)
      end
    end
    obj
  end
end

processed = []
TARGET_FILES.each do |fname|
  f = File.join(DATA_DIR, fname)
  next unless File.exist?(f)
  begin
    raw = File.binread(f)
    obj = Marshal.load(raw)
  rescue Exception => e
    puts "[skip-load] #{fname}: #{e.class} #{e.message}"
    next
  end
  begin
    before = Marshal.dump(obj)
    obj = replace_in_obj(obj, REPL)
    after = Marshal.dump(obj)
    if before != after
      File.open(f, 'wb') {|io| io.write(after) }
      puts "[updated] #{fname}"
      processed << fname
    else
      puts "[unchanged] #{fname}"
    end
  rescue Exception => e
    puts "[error] #{fname}: #{e.class} #{e.message}"
  end
end

puts "Done. processed=#{processed.size}\n"

# Repack archive
out = '/workspaces/aooni/Game_transle_internal_fixed.rgss3a'
cmd = ['python3','/tmp/rgss3a-unpack/dec.py','pack','/tmp/aooni_unpack2', out, '3']
puts 'Running: ' + cmd.join(' ')
success = system(*cmd)
puts 'pack ok' if success

# Verify loads for the target files
puts '\nVerifying target loads:'
TARGET_FILES.each do |fname|
  f = File.join(DATA_DIR, fname)
  begin
    Marshal.load(File.binread(f))
    puts "ok: #{fname}"
  rescue Exception => e
    puts "bad: #{fname} => #{e.class} #{e.message}"
  end
end
