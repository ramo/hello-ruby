require 'thread'

class LockService
	@locks_map = Hash.new
	@global_lock = Mutex.new

	def self.lock(str)
		puts "LockService: lock(): #{Thread.current.object_id} :: str = #{str}" 
		@global_lock.synchronize {
			unless @locks_map.has_key? str
				@locks_map[str] = LockCounter.new
			end
			@locks_map[str]+1
		}
		puts "LockService: lock(): #{Thread.current.object_id} :: str = #{str} --> waiting to get lock :: #{@locks_map[str]}" 
		@locks_map[str].get_mutex.lock
		puts "LockService: lock(): #{Thread.current.object_id} :: str = #{str} --> got lock :: #{@locks_map[str]}" 
	end

	def self.release(str)
		puts "LockService: release(): #{Thread.current.object_id} :: str = #{str}" 
		unless @locks_map.has_key? str
			return
		end

		lc = @locks_map[str]
		if lc.get_mutex.owned?
			puts "LockService: release(): #{Thread.current.object_id} :: str = #{str} --> unlocking :: #{@locks_map[str]}"
			lc-1
			lc.get_mutex.unlock
			puts "LockService: release(): #{Thread.current.object_id} :: str = #{str} --> unlocked :: #{@locks_map[str]}"
		end

		#remove the lock from memory
		@global_lock.synchronize {
			if lc.is_empty?
				puts "Before deleing map : #{@locks_map}"
				@locks_map.delete(str)
				puts "LockService: Cleaning map entry: #{Thread.current.object_id} :: str = #{str}" 
				puts "After deleing map : #{@locks_map}"
			end
		}
	end

end


class LockCounter
	attr_accessor :mutex, :count

	def initialize
		@mutex = Mutex.new
		@count = 0
	end

	def get_mutex
		@mutex
	end

	def +(c)
		@count = @count+c
	end

	def -(c)
		@count = @count-c
	end

	def is_empty?
		@count == 0
	end

	def to_s
		"mutex = #{@mutex}, count = #{count}"
	end
end	



threads = []
threads << Thread.new do
	puts "I am thread 1 #{Thread.current.object_id}, let me sleep for 30s"
	LockService.lock('ramo')
	puts "#{Thread.current.object_id}::Inside room for sleeping"
	sleep 30
	LockService.release('ramo')
	puts "#{Thread.current.object_id}::Released the room"
	puts "#{Thread.current.object_id}::I am thread 1, and I am back"
end

threads << Thread.new do
	puts "I am thread 2 #{Thread.current.object_id}, let me sleeep for 20s"
	LockService.lock('ramo')
	sleep 20
	LockService.release('ramo')
	puts "#{Thread.current.object_id}::Released the room"
	puts "#{Thread.current.object_id}::I am thread 2, and I am back"
end

puts 'I am main thread..., I am waiting for the t1 & t2'

threads.each {|t| t.join}

puts 'Good night!!'