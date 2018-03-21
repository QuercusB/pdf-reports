FixedReport::define(margin: 36, orientation: :landscape, font_size: 9) do
	header style: :bold do
		line do
			text "{{Today | short_date}}": 16
			text "LRS Financial": 120, align: center
			text "Page {{page}} / {{page_count}}": 16, align: right
		end
		text "Claim Loss Report": 152, align: center
		empty_line
		text "Reporting Period: {{DateFrom | long_date}} - {{DateTo | long_date}}"
		text "Report Option: Sorted by Claim # - Break On Bank"
		empty_line
		line do
			text "Lender #": 11
			text "Claim #": 22
			text "Loan #": 21
			text "Policy #": 17
			text "Borrower": 41
			text "Check Payee": 44
		end
		line do
			text "": 5
			text "Staff Adjuster": 26
			text "Loss Date": 12
			text "Received Date": 15
			text "Check #": 20
			text "Loss": 12, align: right
			text "Expense": 12, align: right
			text "Recovery": 12, align: right
			text "Check Date": 12
			text "Check Type": 15
			text "Claim Status": 15			
		end
		line do
			text "": 5
			text "Claim Type": 26
			text "Perils": 110
			text "Cat Loss Cd": 15
		end
		dashed_line
	end
	
	item Type: 'Lender' do
		text "Bank: {{LenderNumber}} - {{LenderFullName}}"
		empty_line
	end

	item Type: 'Claim' do
		line do
			text "{{LenderNumber}}": 11
			text "{{ClaimNumber}}": 22
			text "{{LoanNumber}}": 21
			text "{{PolicyNumber}}": 17
			text "{{BorrowerName}}": 41
			text "{{CheckPayee}}": 44
		end
		line do
			text "": 5
			text "{{Adjuster}}": 26
			text "{{LossDate | short_date}}": 12
			text "{{ReceivedDate | short_date}}": 15
			text "{{CheckNumber}}": 20
			text "{{Loss | currency}}": 12, align: right
			text "{{Expense | currency}}": 12, align: right
			text "{{Recovery | currency}}": 12, align: right
			text "{{CheckDate | short_date}}": 12
			text "{{CheckType}}": 15
			text "{{ClaimStatus}}": 15
		end
		line do
			text "": 5
			text "{{ClaimType}}": 26
			text "{{Perils}}": 110
			text "{{CategoryLoss}}": 15
		end
		empty_line
	end

	item Type: 'LenderTotal' do
		line do
			text "": 60
			text '-' * 70
		end
		line do
			text "": 60
			text "Bank Total: ": 18
			text "{{Loss | currency}}": 12, align: right
			text "{{Expense | currency}}": 12, align: right
			text "{{Recovery | currency}}": 12, align: right
			text "Net": 5, align: right
			text "{{Net | currency}}": 12, align: right
		end
		empty_line
	end

	item Type: 'Total' do
		line do
			text "": 60
			text '-' * 70
		end
		line do
			text "": 60
			text "Grand Total: ": 18
			text "{{Loss | currency}}": 12, align: right
			text "{{Expense | currency}}": 12, align: right
			text "{{Recovery | currency}}": 12, align: right
			text "Net": 5, align: right
			text "{{Net | currency}}": 12, align: right
		end
		empty_line
		text "Total Number of Distinct Claims Included on Report: {{Count}}"
	end
end
