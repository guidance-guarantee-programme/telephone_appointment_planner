module EmailHelper
  def p(&block)
    content_tag(
      :p,
      capture(&block),
      style: [
        'color: #000B3B',
        'font-family: Calibri, Arial, sans-serif',
        'margin: 15px 0',
        'font-size: 16px',
        'line-height: 1.315789474'
      ].join(';')
    )
  end
end
