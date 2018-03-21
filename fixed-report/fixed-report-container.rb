require_relative './fixed-report-text'

class FixedReportContainer

	attr_reader :items

	def initialize(&block)
		@items = []
		instance_eval &block if block
	end

	def add_item(item)
		if items.nil?
			puts item
		end
		items << item
		self
	end

	def left
		:left
	end

	def right
		:right
	end

	def center
		:center
	end

	def text(*args)
		if args.length == 1
			arg = args[0]
			if arg.is_a? Hash
				options = arg
				# treating first hash entry as text => width
				text = options.to_a[0][0].to_s
				width = options.to_a[0][1].to_i
				options.delete(text)
				options[:width] = width
				add_item FixedReportText.new(text, options)
	 		else
				add_item FixedReportText.new(arg)
			end
		else
			text = args[0].to_s
			options = args[1] if args[1].is_a? Hash
			add_item FixedReportText.new(text, options)
		end
	end

	def to_s
		items.reduce("") do |total, item| 
			total += (total.length > 0 ? "\n": "") + 
				item.to_s.split("\n").map { |line| "  " + line }.join("\n")
		end
	end
end