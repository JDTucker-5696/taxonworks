require 'rqrcode'
module LabelsHelper

  # !! Note that `label_tag` is a Rails reserved word, so we have to append and make exceptions
  def taxonworks_label_tag(label)
    return nil if label.nil?
    case label.type
    when 'Label::QrCode'
      c = ::RQRCode::QRCode.new(label.text)

      # TODO: provide necessary structure here
      content_tag(:span, label.text, class: 'qrcode_text') +
        content_tag(
          :span, 
          c.as_svg(
            offset: 0,
            color: '000',
            shape_rendering: 'crispEdges',
            module_size: 6,
            standalone: true
          ).to_s,
          class: :qrcode_barcode
        )
    else
      content_tag(:span, label.text, style: label.style) # TODO: properly reference style
    end
  end

  def label_link(label)
    return nil if label.nil?
    if label.label_object_id.blank?
      taxonworks_label_tag(label)
    else
      link_to(content_tag(:span, label.text), label.label_object)
    end
  end

end
