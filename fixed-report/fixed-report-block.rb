require_relative "./fixed-report-container.rb"
require_relative "./fixed-report-line.rb"

class FixedReportBlock < FixedReportContainer

	attr_reader :kind, :options

	def initialize(kind, options = {}, &block)
		super(&block)
		@options = options
		@kind = kind
	end

	def line(&block)
		add_item FixedReportLine.new(&block)
	end

	def empty_line
		add_item FixedReportLine.new
	end

	def dashed_line
		add_item FixedReportLine.new({ kind: :dashed_line })
	end

	def line_count
		items.length
	end

	def to_s
		"#{kind}:\n#{super.to_s}"
	end

end