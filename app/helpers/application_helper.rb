module ApplicationHelper
  def button_to(name = nil, options = nil, html_options = nil, &block)
    html_options = html_options.to_h
    data = html_options.delete(:data).to_h
    form = html_options.delete(:form).to_h

    form.deep_merge! data: { turbo_frame: data.delete(:turbo_frame) }

    super name, options, html_options.merge(data: data, form: form), &block
  end
end
