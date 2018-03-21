require "date"
require "json"
require_relative "./fixed-report/fixed-report.rb"
require_relative "./fixed-report/fixed-report-renderer.rb"
require 'optparse'

def short_date(date)
	date.strftime('%m/%d/%y')
end

def long_date(date)
	date.strftime('%A %B %d, %Y')
end

def currency(value)
	("%.2f" % value).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

options = {}
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: generate-report.rb [options]"

  opts.on('-r', '--report FILE', 'Report definition file') { |v| options[:report] = v }
  opts.on('-d', '--data FILE', 'Report data file') { |v| options[:data] = v }
  opts.on('-o', '--out FILE', 'Output file') { |v| options[:out] = v }
  opts.on('-h', '--help', "Prints this help") do
    puts opts
    exit
  end
end

opt_parser.parse!

if options[:report].nil? || options[:data].nil? || options[:out].nil? 
	opt_parser.parse '-h'
end

report = load(options[:report])
data = JSON::parse(File.new(options[:data]).read)

["Today", "DateFrom", "DateTo"].each do |field|
	data[field] = Date.parse(data[field]) if data[field]
end

data["Items"].each do |item|
	["LossDate", "ReceivedDate", "CheckDate"].each do |field|
		item[field] = Date.parse(item[field]) if item[field]
	end
end

# test_data = {
# 	"Today": Date.today,
# 	"DateFrom": Date.new(2001,01,01),
# 	"DateTo": Date.today,
# 	"Lender": {
# 		"Number": 9184001,
# 		"LongName": "JMC Leasing Specialities"
# 	},
# 	"Items": [
# 		{
# 			"Type": "Bank"
# 		},
# 		{
# 			"Type": "Claim",
# 			"ClaimNumber": "OIC-101708",
# 			"LoanNumber": "121054",
# 			"PolicyNumber": "021359-04",
# 			"BorrowerName": "SHNEQUA NOLEN",
# 			"Adjuster": "Sandra Sterner",
# 			"Loss": 1843.00,
# 			"LossDate": Date.new(2017,10,12),
# 			"ReceivedDate": Date.new(2017,10,22),
# 			"CheckNumber": 1242,
# 			"Expense": "",
# 			"Recovery": "",
# 			"CheckDate": Date.new(2017,10,26),
# 			"CheckType": "Settlement",
# 			"ClaimStatus": "Closed",
# 			"ClaimType": "All Risk Physical Damage",
# 			"Perils": "",
# 			"CategoryLoss": ""
# 		},
# 		{
# 			"Type": "Claim",
# 			"ClaimNumber": "OIC-101709",
# 			"LoanNumber": "124771",
# 			"PolicyNumber": "027440-01",
# 			"BorrowerName": "LAQUANNA JONES",
# 			"Adjuster": "Sandra Sterner",
# 			"Loss": 6238.75,
# 			"LossDate": Date.new(2017,10,15),
# 			"ReceivedDate": Date.new(2017,10,20),
# 			"CheckNumber": 1524,
# 			"Expense": "",
# 			"Recovery": "",
# 			"CheckDate": Date.new(2017,10,22),
# 			"CheckType": "Settlement",
# 			"ClaimStatus": "Closed",
# 			"ClaimType": "All Risk Physical Damage",
# 			"Perils": "",
# 			"CategoryLoss": ""
# 		}
# 	]
# }

# for i in (0..30) do
# 	test_data[:Items].push(test_data[:Items].last)
# end

# totalItem = {
# 	"Type": "Total",
# 	"Loss": test_data[:Items].select { |item| item[:Type] == "Claim" }.reduce(0) { |total, item| total + item[:Loss].to_f },
# 	"Expense": test_data[:Items].select { |item| item[:Type] == "Claim" }.reduce(0) { |total, item| total + item[:Expense].to_f },
# 	"Recovery": test_data[:Items].select { |item| item[:Type] == "Claim" }.reduce(0) { |total, item| total + item[:Recovery].to_f },
# 	"Count": test_data[:Items].select { |item| item[:Type] }.length
# }

# totalItem[:Net] = totalItem[:Loss] - totalItem[:Expense] - totalItem[:Recovery]

# test_data[:Items].push(totalItem)

renderer = FixedReportRenderer.new(FixedReport::report)
renderer.render(data, options[:out])
