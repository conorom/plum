class ScannedResourcePDF
  class CoverPageGenerator
    attr_reader :scanned_resource_pdf
    delegate :scanned_resource, to: :scanned_resource_pdf
    delegate :solr_document, to: :scanned_resource
    def initialize(scanned_resource_pdf)
      @scanned_resource_pdf = scanned_resource_pdf
    end

    def header(prawn_document, header, size: 16)
      Array(header).each do |text|
        prawn_document.move_down 10
        display_text(prawn_document, text, size: size, styles: [:bold], inline_format: true)
      end
      prawn_document.stroke do
        prawn_document.horizontal_rule
      end
      prawn_document.move_down 10
    end

    def text(prawn_document, text)
      Array(text).each do |value|
        display_text(prawn_document, value)
      end
      prawn_document.move_down 5
    end

    def apply(prawn_document)
      noto_cjk_b = Rails.root.join("app/assets/fonts/NotoSansCJK/NotoSansCJKtc-Bold.ttf")
      noto_cjk_r = Rails.root.join("app/assets/fonts/NotoSansCJK/NotoSansCJKtc-Regular.ttf")
      noto_ara_b = Rails.root.join("app/assets/fonts/NotoNaskhArabic/NotoNaskhArabic-Bold.ttf")
      noto_ara_r = Rails.root.join("app/assets/fonts/NotoNaskhArabic/NotoNaskhArabic-Regular.ttf")
      amiri_b = Rails.root.join("app/assets/fonts/amiri/amiri-bold.ttf")
      amiri_r = Rails.root.join("app/assets/fonts/amiri/amiri-regular.ttf")

      prawn_document.font_families.update(
        "amiri" => { normal: amiri_r, italic: amiri_r, bold: amiri_b, bold_italic: amiri_b },
        "noto_cjk" => { normal: noto_cjk_r, italic: noto_cjk_r, bold: noto_cjk_b, bold_italic: noto_cjk_b },
        "noto_ara" => { normal: noto_ara_r, italic: noto_ara_r, bold: noto_ara_b, bold_italic: noto_ara_b }
      )
      prawn_document.fallback_fonts(["noto_cjk", "noto_ara", "amiri"])

      prawn_document.bounding_box([15, Canvas::LETTER_HEIGHT - 15], width: Canvas::LETTER_WIDTH - 30, height: Canvas::LETTER_HEIGHT - 30) do
        prawn_document.image Rails.root.join("app/assets/images/pul_logo_long.png").to_s, position: :center, width: Canvas::LETTER_WIDTH - 30
        prawn_document.stroke_color "000000"
        prawn_document.move_down(20)
        header(prawn_document, scanned_resource.title, size: 24)
        solr_document.rights_statement.each do |statement|
          text(prawn_document, rights_statement_label(statement))
          rights_statement_text(statement).split(/\n/).each do |line|
            text(prawn_document, line)
          end
        end
        prawn_document.move_down 20

        header(prawn_document, "Princeton University Library Disclaimer")
        prawn_document.text I18n.t('rights.pdf_boilerplate'), inline_format: true
        prawn_document.move_down 20

        header(prawn_document, "Citation Information")
        text(prawn_document, solr_document.creator)
        text(prawn_document, solr_document.title)
        text(prawn_document, solr_document.edition)
        text(prawn_document, solr_document.extent)
        text(prawn_document, solr_document.description)
        text(prawn_document, solr_document.call_number)
        # collection name (from EAD) ? not in jsonld

        header(prawn_document, "Contact Information")
        text = HoldingLocationRenderer.new(solr_document.holding_location).value_html.gsub("<a", "<u><a").gsub("</a>", "</a></u>").gsub(/\s+/, " ")
        prawn_document.text text, inline_format: true
        prawn_document.move_down 20

        header(prawn_document, "Download Information")
        prawn_document.text "Date Rendered: #{Time.current.strftime('%Y-%m-%d %I:%M:%S %p %Z')}"
        prawn_document.text "Available Online at: <u><a href='#{helper.polymorphic_url(scanned_resource)}'>#{helper.polymorphic_url(scanned_resource)}</a></u>", inline_format: true
      end
    end

    private

      def helper
        @helper ||= ManifestBuilder::ManifestHelper.new
      end

      def rights_statement_label(statement)
        RightsStatementService.new.label(statement)
      end

      def rights_statement_text(statement)
        RightsStatementService.new.definition(statement).gsub(/<br\/>/, "\n")
      end

      def display_text(prawn_document, text, options = {})
        bidi_text = dir_split(text).map do |s|
          s = s.connect_arabic_letters.gsub("\uFEDF\uFE8E", "\uFEFB") if s.dir == 'rtl' && lang_is_arabic?
          s.dir == 'rtl' ? s.reverse : s
        end.join(" ")
        options = options.merge(align: :right, kerning: true) if bidi_text.dir == 'rtl'
        prawn_document.text bidi_text, options
      end

      def lang_is_arabic?
        solr_document.language && solr_document.language.first && solr_document.language.first == 'ara'
      end

      def dir_split(s)
        chunks = []
        s.split(/\s/).each do |word|
          (chunks.last && chunks.last.dir == word.dir) ? chunks << "#{chunks.pop} #{word}" : chunks << word
        end
        chunks
      end
  end
end
