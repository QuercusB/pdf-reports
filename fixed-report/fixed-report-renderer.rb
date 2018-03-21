require "prawn"
require_relative "./fixed-report.rb"
require "hash_dot"

class FixedReportRenderer

	attr_reader :report, :data

	def initialize(report)
		@report = report
	end

	def render(data, path)

		@document = Prawn::Document.new(
			page_layout: report.options[:orientation] || :portrait, 
			margin: report.options[:margin] || 36)

		app_path = File.dirname(__FILE__)

		@document.font_families.update("UbuntuMono" => {
			:normal => "#{app_path}/fonts/UbuntuMono-R.ttf",
			:bold => "#{app_path}/fonts/UbuntuMono-B.ttf",
			:italic => "#{app_path}/fonts/UbuntuMono-RI.ttf",
			:bold_italic => "#{app_path}/fonts/UbuntuMono-BI.ttf",
		})

		font_size = report.options[:font_size] || 12
		@line_height = report.options[:line_height] || font_size * 1.2

		@document.font "UbuntuMono"
		@document.font_size font_size

		pages = layout_pages(data)

		render_pages(data, pages)

		@document.render_file path

	end

private

	attr_reader :document, :line_height

	def layout_pages(data)

		line_count = (document.bounds.top / line_height).to_i

		# counting header size
		header_block = report.blocks.find { |block| block.kind == :header }

		if header_block
			content_line_count = line_count - header_block.line_count
		else
			content_line_count = line_count
		end

		# layouting pages
		page_items = []
		pages = [ page_items ]

		# first page includes header, items_header and items
		page_space = content_line_count

		items = data[:Items] || data["Items"]

		for item in items

			item_block = nil
			for block in report.blocks.select { |block| block.kind == :item }
				if block.options.length == 0
					item_block = block
					break
				end
				# validating properties of block for props of items
				for block_test in block.options.to_a
					item_value = item[block_test[0].to_s] || item[block_test[0].to_sym]
					if item_value == block_test[1]
						item_block = block
						break
					end
				end

				break unless item_block.nil?
			end

			next if item_block.nil?

			item_line_count = item_block.line_count

			if item_line_count > page_space
				page_items = []
				pages.push(page_items)
				page_space = content_line_count
			end

			page_items << [item, item_block]
			page_space -= item_line_count

		end

		return pages
	end

	def render_pages(data, pages)

		header_block = report.blocks.find { |block| block.kind == :header }

		# rendering 
		header_context = data.to_dot
		header_context[:page_count] = pages.length
		page_index = 1

		for page in pages

			if page_index > 1
				document.start_new_page
			end

			header_context[:page] = page_index
			unless header_block.nil?
				render_block(header_block, header_context)
			end

			for item_block in page
				context = item_block[0].clone
				context[:report] = data
				context = context.to_dot
				render_block(item_block[1], context)
			end

			page_index += 1

		end
	end


	def using(options, &render)
		unless options[:style].nil?
			current_font_options = @document.font.options
			@document.font current_font_options[:family], style: options[:style]
		end
		yield render
		unless options[:style].nil?
			@document.font current_font_options[:family], style: current_font_options[:style] || :normal
		end
	end

	def render_block(block, context)
		using block.options do
			for item in block.items
				if item.is_a? FixedReportText
					render_text(item, context)
				end
				if item.is_a? FixedReportLine
					render_line(item, context)
				end
				@document.move_down @line_height
			end
		end
	end

	def render_line(line, context)
		using line.options do 
			left_bound = 0

			if line.kind == :dashed_line
				@document.text_box '-' * 1000, 
					at: [left_bound, @document.cursor], 
					width: @document.bounds.right, 
					height: @line_height
				return
			end
		
			for textItem in line.items
				left_bound = render_text(textItem, context, left_bound)

			end
		end
	end

	def render_text(item, context, left_bound = 0)
		left_bound = left_bound || 0

		value = calculate_value(item.text, context)
		text = format_value(value, item.width, item.align)

		using item.options do
			document.text_box text, 
				at: [left_bound, document.cursor], 
				width: document.bounds.right - left_bound, 
				height: line_height

			left_bound += @document.font.compute_width_of(text)
		end

		return left_bound
	end


	def calculate_value(text, context)
		arg_regex = /{{(\s*([^}\|]|}[^}])+)\s*(\|\s*(([^}\|]|}[^}])+)\s*)?}}/

		arg_match = text.match(arg_regex)
		until arg_match.nil?
			expr = arg_match[1].strip
			formatter = nil
			formatter = arg_match[4].strip unless arg_match[4].nil?
			begin
				arg_value = context.instance_eval("self.#{expr}")
				begin
					arg_value = send(formatter, arg_value) unless formatter.nil?
				rescue
				end
			rescue
				arg_value = ""
			end

			text = "#{arg_match.pre_match}#{arg_value}#{arg_match.post_match}"

			arg_match = text.match(arg_regex)
		end	
		text
	end

	def format_value(text, width, align)
		unless width.nil?
			text = text[0..width - 2]
			spare = width - 1 - text.length
			case align
				when :left
					text = text + Prawn::Text::NBSP * spare
				when :right
					text = Prawn::Text::NBSP * spare + text
				when :center
					text = Prawn::Text::NBSP * (spare/2) +
						text + Prawn::Text::NBSP * (spare - spare/2)
			end
			text += Prawn::Text::NBSP
		end
		text
	end
end