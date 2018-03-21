require_relative "./fixed-report-container.rb"
require_relative "./fixed-report-block.rb"

class FixedReport < FixedReportContainer

	attr_reader :options

	def initialize(options = {}, &block)
		super(&block)
		@options = options
	end

	def header(options = {}, &block)
		add_item FixedReportBlock.new(:header, options, &block)
	end

	def item(options = {}, &block)
		add_item FixedReportBlock.new(:item, options, &block)
	end

	def blocks
		items
	end

	def self.define(options = {}, &block)
		@@report = FixedReport.new(options, &block)
	end

	def self.report
		@@report
	end

end