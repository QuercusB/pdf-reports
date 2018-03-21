require_relative "./fixed-report-container.rb"

class FixedReportLine < FixedReportContainer

	attr_reader :kind, :options

	def initialize(options = {}, &block)
		super(&block)
		@kind = (options && options[:kind]) || :text_line
		@options = options
	end

	def to_s
		if kind == :text_line && items.length == 0
			return "empty_line"
		end
		if items && items.length > 0
			"#{kind}:\n#{super.to_s}"
		else
			"#{kind}"
		end
	end

end