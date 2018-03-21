class FixedReportText

	attr_accessor :text, :width, :align, :options

	def initialize(text, options={})
		@text = text
		@width = options && options[:width]
		@align = (options && options[:align]) || :left
		@options = options
		self
	end

	def to_s
		result = "'#{text}'"
		unless width.nil?
			result += ": #{width}"
		end
		result += " (align: #{align})"
	end
end