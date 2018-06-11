#LockService - This service will manage the locks (mutex) across application
require 'thread'

class LockService
	@locks_map = Hash.new
	@global_lock = Mutex.new

	def self.lock(str)
		puts "LockService: lock(): #{Thread.current.object_id} :: str = #{str}" 
		@global_lock.synchronize {
			unless @locks_map.has_key? str
				@locks_map[str] = Mutex.new
			end
		}
		puts "LockService: lock(): #{Thread.current.object_id} :: str = #{str} --> waiting to get lock" 
		@locks_map[str].lock
		puts "LockService: lock(): #{Thread.current.object_id} :: str = #{str} --> got lock" 
	end

	def self.release(str)
		puts "LockService: release(): #{Thread.current.object_id} :: str = #{str}" 
		unless @locks_map[str]
			return
		end
		if @locks_map[str].owned?
			puts "LockService: release(): #{Thread.current.object_id} :: str = #{str} --> unlocking" 
			@locks_map[str].unlock
		end

		#remove the lock from memory
		lock = @locks_map[str]
		@global_lock.synchronize {
			unless lock.locked?
				@locks_map.delete(lock)
				puts "LockService: Cleaning map entry: #{Thread.current.object_id} :: str = #{str}" 
			end
		}
	end

end