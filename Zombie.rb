#!/usr/bin/env ruby

# This is the world's first (I think) implementation of the
#
# ZOMBIE-ORIENTED MACHINE BEING INTERFACE ENGINE
#
# You know, like Hex, but with evil beings! Written in Python to offset the evil a bit.
#
# Evil necromancers might want to go here:
#  http://www.dangermouse.net/esoteric/zombie.html
# to read the specification, which was made over two years ago, and still nobody
# dared implement it.

STDOUT.sync = true
Thread.abort_on_exception = true
# import re,sys,thread,time,random

# regexps recognizing syntax elements
$comment_re = /\{.*?\}/ #re.compile("\{.*?\}", re.DOTALL)
$declaration_re = /([A-Za-z0-9_\-]*?)\s+is\s+an?\s+(zombie|enslaved undead|ghost|restless undead|vampire|free-willed undead|demon|djinn)/i
#re.compile(r'([A-Za-z0-9_\-]*?)\s+is\s+an?\s+(zombie|enslaved undead|' + \
#                            r'ghost|restless undead|vampire|free-willed undead' + \
#                            r'|demon|djinn)', re.I)

$task_re = /task\s+([A-Za-z0-9_-]*)/i #re.compile("task\s+([A-Za-z0-9_-]*)", re.I)
$remember_re = /remember\s+(.*)/ #re.compile("remember\s+(.*)", re.I)

$string_re = /".*?"/ #re.compile('".*?"')
$integer_re = /[\-0-9\.]+/ # re.compile('[\-0-9\.]+')

$kill = false

# error message
def die(msg)
   print "--- Fatal error: %s\n" % msg
   $kill = true
   exit
end

   
# split line according to whitespace, but keep strings intact

def splitline(string)
   cmds = []
	
   # break line up into pieces
   prev_whitespace = false
   in_string = false
   temp =  ''
   
	(string.size - 1).downto(0) do |c| #for c in reversed(range(0,len(string))):
		if string[c] == ' ' and !(prev_whitespace or in_string)
			prev_whitespace = true
			cmds.unshift(temp)
			temp = ""
		elsif string[c] != ' ' or in_string
			prev_whitespace = false
			in_string = !in_string if string[c] == '"'
			temp = string[c] + temp
		end
	end
	
	cmds.unshift(temp)
	return cmds
end
   
# Entity objects
class Entity
	attr_accessor :environment
	attr_accessor :name
	attr_accessor :memory
	attr_accessor :tasks
	attr_accessor :active
	
	def initialize
		@environment = nil
		@name = ''
		@memory = nil
		@tasks = []
		@active = false
		puts "DEBUG: New Entity (#{self.class})"
	end
	
	def runtasks
      self.active = true
      # makes a thread; runs the tasks as the specific entity type does.
      Thread.new(&method(:taskthread))
	end
   
	def taskthread
		# overloaded by individual entities that have their own way of doing things
	end

	def activate
		self.active = true
		self.runtasks
	end
      
	def banish
		self.active = false # task threads check for this and stop
	end
end
      
class Undead < Entity
	# which is what we make at undead people, of course :-)
end
   
class Zombie < Undead
	def initialize
		super
		self.active = false # zombies require animating
	end
   
	# zombies run their tasks in order
	def taskthread
		puts "DEBUG: Zombie taskthread running from Thread #{Thread.current.object_id}"
		while self.active and (!$kill)
			self.tasks.select(&:active).each do |task| #for task in [t for t in self.tasks if t.active]:
				break unless self.active #if not self.active: break
				task.run()
				task.active = false
			end
			puts "#{Thread.current.object_id} sleeping"
			sleep(0.05)
			self.active = false if self.tasks.select(&:active).empty? #if not [t for t in self.tasks if t.active]: 
		end
	end
end

class Ghost < Undead
	def initialize
		super
		self.active = false # ghosts require desturbing
	end
   
   # ghosts run their tasks in order, but may wait before starting a new task
	def taskthread
		while self.active and (!$kill)
			self.tasks.select(&:active).each do |task| #for task in [t for t in self.tasks if t.active]:
				sleep(rand(60))
				break unless self.active #if not self.active: break
				task.run()
				task.active = false
			end
			self.active = false if self.tasks.select(&:active).empty? #if not [t for t in self.tasks if t.active]:
		end
	end
end      
   
class Vampire < Undead
	def initialize
	   super
	   self.active = true # vampires are active immediately
	end
   
	# vampires process their tasks in random order
	def taskthread
		self.tasks.shuffle! # tasks in random order
		while self.active and (!$kill)
			self.tasks.select(&:active).each do |task| #for task in [t for t in self.tasks if t.active]:
				break unless self.active #if not self.active: break
				task.run()
				task.active = false
			end
			sleep(0.05)
			self.active = false if self.tasks.select(&:active).empty? #if not [t for t in self.tasks if t.active]:
		end
	end
end

class Demon < Entity
	def initialize
		super
		self.active = true # demons are always active
	end
   
	# demons process their tasks in random order, and sometimes multiple times
	def taskthread
		self.tasks.shuffle! # tasks in random order
      
		# may run multiple tasks at once (this may cause weird things to happen with
		# threading, but I don't care; you shouldn't trust demons anyway)
	  
		# if bool(int(random.random() * 4)):
		Thread.new(&:taskthread) unless rand(4).zero?
         
         
		while self.active and (!$kill)
			self.tasks.select(&:active).each do |task| #for task in [t for t in self.tasks if t.active]:for task in [t for t in self.tasks if t.active]:
				break unless self.active #if not self.active: break
				task.run()
				#task.active = not bool(int(random.random()*4)) # 1 in 4 chance a task will be repeated
				task.active = rand(4).zero? # 1 in 4 chance a task will be repeated
			end
			sleep(0.05)
			self.active = false if self.tasks.select(&:active).empty? #if not [t for t in self.tasks if t.active]:
		end
	end
end   

class Djinn < Entity
	def initialize
		super
		self.active = true # djinn are always active
	end
   
	# demons process their tasks in random order, and sometimes multiple times
	def taskthread
		self.tasks.shuffle! # tasks in random order
      
		# may run multiple tasks at once (this may cause weird things to happen with
		# threading, but I don't care; you shouldn't trust demons anyway)
	  
		# if bool(int(random.random() * 4)):
		Thread.new(&:taskthread) unless rand(4).zero?
         
         
		while self.active and (!$kill)
			self.tasks.select(&:active).each do |task| #for task in [t for t in self.tasks if t.active]:for task in [t for t in self.tasks if t.active]:
				break unless self.active #if not self.active: break
				task.run()
				# tasks may not run at all
				task.active = rand(4).zero? if task.active # 1 in 4 chance a task will be repeated
				task.run if task.active
			end
			sleep(0.05)
			self.active = false if self.tasks.select(&:active).empty? #if not [t for t in self.tasks if t.active]:
		end
	end
end  
   
# Task objects store tasks and can be run
class Task
   attr_accessor :entity
   attr_accessor :lines
   attr_accessor :name
   attr_accessor :active
   attr_accessor :commands
   
   def initialize
		self.entity = nil
		self.lines = []
		self.name = ''
		self.active = false
		
		self.commands = {
			animate:  method(:c_animate),
			banish:   method(:c_banish),
			disturb:  method(:c_disturb),
			forget:   method(:c_forget),
			invoke:   method(:c_invoke),
			moan:     method(:c_moan),
			remember: method(:c_remember),
			say:      method(:c_say)
		}
	end
          
	# commands
	def c_animate(stack)
		if (stack) and (stack.size >= 1) and (stack.last.is_a?(Entity))
			unless stack.last.is_a?(Zombie)
				die("task %s, entity %s: attempt to animate non-zombie entity %s." % [self.name, self.entity.name, stack.last.name])
			end
			stack.pop().activate()
		else
			unless self.entity.is_a?(Zombie)
				die("task %s, entity %s: attempt to animate non-zombie entity %s." % [self.name, self.entity.name, self.entity.name])
			end
			self.entity.activate()
		end
	end
	 
	def c_banish(stack)
		if (stack) and (stack.size >= 1) and (stack.last.is_a?(Entity))
			stack.pop().banish()
		else
			self.entity.banish()
		end
	end
	
	def c_disturb(stack)
		if (stack) and (stack.size >= 1) and (stack.last.is_a?(Entity))
			unless stack.last.is_a?(Ghost)
				die("task %s, entity %s: attempt to disturb non-ghost entity %s." % [self.name, self.entity.name, stack.last.name])
			end
			stack.pop().activate()
		else
			unless self.entity.is_a?(Ghost)
				die("task %s, entity %s: attempt to disturb non-ghost entity %s." % [self.name, self.entity.name, self.entity.name])
			end
			self.entity.activate()
		end
	end
 
	def c_forget(stack)
		if (stack) and (stack.size >= 1) and (stack.last.is_a?(Entity))
			stack.pop().memory = nil
		else
			self.entity.memory = nil
		end
	end
   
	def c_invoke(stack)
		if (stack) and (stack.size >= 1) and (stack.last.is_a?(Entity))
			stack.pop().activate()
		else
			self.entity.activate()
		end
	end
   
	def c_moan(stack)
		if (stack) and (stack.size >= 1) and (stack.last.is_a?(Entity))
			#sys.stdout.write(str(stack[-1].memory))
			stack.push(stack.pop().memory)
		else
			stack.push(self.entity.memory)
			#sys.stdout.write(str(self.entity.memory))
		end
	end
	
	def c_remember(stack)
      #print "\n Remember :%s: " % str(stack)
      
		if (stack) and (stack.size >= 1) and (stack.last.is_a?(Entity))
			theEntity = stack[-1]
			values = stack[0..-2]
		else
			theEntity = self.entity
			values = stack
		end
      
		total = 0
		for value in values
			case value
			when Integer
				# numbers simply get added
				total += value
			when String
				# strings with numbers in get added, others get ignored
				total += value.to_i
			when Entity
				# entities get their memories added
				total += value.memory rescue nil
			else
				# just try to add it, ignore if not possible
				total += value rescue nil
			end
		end
		
		#for i in range(0,len(values)): stack.pop()
		values.size.times { stack.pop }
		puts("DEBUG: #{theEntity.name} <- #{total}")
		theEntity.memory = total
	end
  
   def c_say(stack)
		if (!stack) or ((stack.first.is_a?(Entity)) and (stack.size == 1))
			die("task %s, entity %s: argument error for SAY: nothing to say." % [self.name, self.entity.name])
		end
		
		if stack.first.is_a?(Entity)
			#sys.stdout.write(str(stack[1]))
			print(stack[1].to_s)
			# if not isinstance(stack[1], str): sys.stdout.write(" ")
			print(" ") unless stack[1].is_a?(String) 
		else
			#sys.stdout.write(str(stack[0]))
			print(stack.first.to_s)
			#if not isinstance(stack[0], str) or isinstance(stack[0], float): sys.stdout.write(" ")
			print(" ") unless stack.first.is_a?(String) or stack.first.is_a?(Float)
		end
	end
      
	# do task
	def run
		begin
			self._run()
		rescue => e
			die("task %s, entity %s: something weird happened; program terminated to insure safety. (%s)" % [self.name, self.entity.name, e.message + " #{e.backtrace_locations}"])
		end
	end
	
	protected
	
	def _run
		line_no = 0;
		cmdsSymbols = ['animate', 'banish', 'disturb', 'forget', 'invoke', 'moan', 'remember', 'say']
		doNothingElements = ['shamble', 'good', 'spit']
		
		while (line_no < self.lines.size)
			cmds = splitline(self.lines[line_no])
			stack = []
         
         #print self.lines[line_no]
         
			for cmd in cmds.reverse
				case cmd.downcase
				when *cmdsSymbols
				   self.commands[cmd.intern].call(stack)
				   
				when "remembering"
					if stack.size > 0
						if stack.last.is_a?(Entity)
							if stack.size > 1
								puts("DEBUG: #{stack.last.memory} == #{stack[-2]}")
								val = stack.last.memory == stack[-2] ? 1 : 0
								stack.pop()
								stack.pop()
								stack.push(val)
							else
								die("task %s, entity %s: argument error for REMEMBERING." % [self.name, self.entity.name])
							end
						else
							puts("DEBUG: #{stack.last} == #{self.entity.memory}")
							stack.push(stack.pop() == self.entity.memory ? 1 : 0)
						end
					else
						die("task %s, entity %s: argument error for REMEMBERING." % [self.name, self.entity.name])
					end
				when "stumble"
				   return;
				when "rend"
					begin
						a = stack.pop()
						stack.push(stack.pop() / a)
					rescue
						die("task %s, entity %s: argument error for REND." % [self.name,self.entity.name])
					end
				when "turn"
					begin
						stack.push(-stack.pop())
					rescue
						die("task %s, entity %s: argument error for TURN." % [self.name,self.entity.name])
					end
				when "around"
				   t = 1
					begin
						until t.zero?
							line_no -= 1
							line = self.lines[line_no].split().first.downcase()
							t += 1 if ['around', 'until'].include?(line)
							t -= 1 if (line == 'shamble')
						end
						#break
					rescue
						die("task %s, entity %s: unbalanced loop." % [self.name, self.entity.name])
					end
				when "until"
					if (stack.empty?) or (stack.first == 0)
						t = 1
						begin
							until t.zero?
								line_no -= 1
								line = self.lines[line_no].split().first.downcase()
								t += 1 if ['around', 'until'].include?(line)
								t -= 1 if (line == 'shamble')
							end
							puts("DEBUG: Back to line #{line_no}")
							#break
						rescue
							die("task %s, entity %s: unbalanced loop." % [self.name, self.entity.name])
						end
					end
				when "taste"
					if (stack.empty?) or (stack.first != 0)
						t = 1
						begin
							until t.zero?
								line_no += 1
								line = self.lines[line_no].split().first.downcase()
								t += 1 if (line == 'taste')
								t -= 1 if (line == 'spit')
								break if ((line == 'bad') and (t == 1))
							end
						rescue
							die("task %s, entity %s: unbalanced taste/spit." % [self.name,self.entity.name])
						end
					end
				when "bad"
					# this'll only happen if "taste" didn't send it to "bad"; so skip to "spit"
					t = 1
					begin
						until t.zero?
							line_no += 1
							line = self.lines[line_no].split().first.downcase()
							t += 1 if (line == 'taste')
							t -= 1 if (line == 'spit')
						end
					rescue
						die("task %s, entity %s: unbalanced taste/spit." % [self.name, self.entity.name])
					end
				  
				when *doNothingElements
				   # syntax elements that do nothing themselves when reached
				   
				else
					# it's a value
					if $string_re.match(cmd)
						stack.push(cmd[1..-2].replace("\\n","\n").replace("\\t","\t"))
					elsif $integer_re.match(cmd)
						stack.push(cmd.to_f)
						stack[-1] = stack.last.to_i if stack.last == stack.last.to_i
					elsif self.entity.environment.entities.keys.include?(cmd.to_s)
						stack.push(self.entity.environment.entities[cmd])
					else
						die("task %s, entity %s: '%s' does not exist." % [self.name, self.entity.name, cmd])
					end
				end
			end
			  
			line_no += 1
		end
	end
end

# The environment in which the entities do their tasks. 
# Not necessarily a graveyard, one can work around that
# by not using any undead.
class Environment
   attr_accessor :entities
  
	def initialize(file)
		@entities = {}
		# read file
		begin
			code = File.read(file)
		rescue
			die("cannot open file %s." % [file])
		end
      
		# parse code
		self.parse(code)
	end
      
	def run
		# activate all entities that should be activated
		#[self.entities[e].runtasks() for e in self.entities if self.entities[e].active]
		self.entities.values.select(&:active).each(&:runtasks)
      
		# keep the main thread running until all entities are done
		while (!$kill) and self.entities.values.any?(&:active) # [e for e in self.entities if self.entities[e].active]:
			Thread.pass
			sleep(1)
			exit if $kill
		end
         
		print "\n"
	end
      
   # Make entities according to the code supplied
   def parse(code)
		currentEntity = nil
		inEntity = false
      
		currentTask = nil
      
		# remove comments from code
		code = code.gsub($comment_re, '')
      
		# split into lines and remove whitespace
		lines = code.split("\n").map{|a| a.strip }.reject(&:empty?) #[a.strip() for a in code.split("\n") if not a.strip() == '']
      
		line_no = 0
		while (line_no < lines.size)
			print "LINE : '%s'\n" % lines[line_no]
			line = lines[line_no]
			
			if !inEntity
				a = $declaration_re.match(line)
				
				if a
					if lines[line_no+1].downcase() == 'summon'
						# we're in an entity declaration block.
						# start a new entity, if possible
				   
						if self.entities.has_key?(a[1])
							die("line %d: entity '%s' is already defined." % [line_no, a[1]])
						end
						typeName = a[2].downcase
						
						case a[2].downcase
						when 'zombie', 'enslaved undead'     then type = Zombie
						when 'ghost', 'restless undead'      then type = Ghost
						when 'vampire', 'free-willed undead' then type = Vampire
						when 'demon'                         then type = Demon
						when 'djinn'                         then type = Djinn
						else die("line %d: '%s' is not a valid entity type." % [a[2]])
						end
					  
						currentEntityName = a[1]
						currentEntity = type.new
						currentEntity.name = currentEntityName
						line_no += 1
						inEntity = true
					else
						die("line %d: entity declaration incomplete, missing SUMMON." % [line_no])
					end
				else
				   die("line %d: only entity declarations may appear outside of entities." % line_no)
				end
			else
				a = $task_re.match(lines[line_no])
				b = $remember_re.match(lines[line_no])
				
				if a
					#read the task, store it in the entity
					currentTask = Task.new
					currentTask.name = a[1]
					
					loop do
						line_no += 1
						line = lines[line_no].downcase
						if ['bind', 'animate'].include?(line)
							currentTask.active = (line == 'animate')
							currentTask.entity = currentEntity
							currentEntity.tasks += [currentTask]
							break
						else
							currentTask.lines += [lines[line_no]]
						end
					end   
				elsif b
					#default value
					if b[1][0] == '"' and b[1][-1] == '"'
					  # string
					  currentEntity.memory = b[1][1..-2]
					else
						begin
							currentEntity.memory = Integer(b[1])
						rescue ArgumentError
							die("line %d: REMEMBER outside of task may only use a constant." % [line_no])
						end
					end
				else
					line = lines[line_no].downcase
					
					if !['animate', 'bind', 'disturb'].include?(line)
						die("line %d: not allowed outside of task." % [line_no])
					else
						inEntity = false
					end
				  
					if line != 'bind'
						# a state change (to active) is required
						unless currentEntity.is_a?(Undead)
							die("line %d: safety check failed: free-willed non-undead *must* be bound or all hell will break loose quite literally." % [line_no])
						end
					  
						if ((line == 'animate') and !currentEntity.is_a?(Zombie)) or (line == 'disturb' and !currentEntity.is_a?(Ghost))
							die("line %d: type error: you are either animating a ghost or disturbing a zombie; both aren't a very good idea." % [line_no])
						end
						 
						# The fact that we're still here means that the program hasn't been killed.
						# That means the safety checks have passed, we can safely activate the entity.
						currentEntity.active = true
					end
				   
					currentEntity.environment = self
					self.entities[currentEntity.name] = currentEntity
				end
			end
			line_no += 1
		end
	end
end

env = Environment.new("Z:\\Users\\Gabriel\\Desktop\\Backup\\Zombie\\EuclidesMDC.zb")
env.run()
