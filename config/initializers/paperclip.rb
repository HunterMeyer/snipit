Paperclip::Attachment.default_options[:url]          = 'storeitforme.s3.amazonaws.com'
Paperclip::Attachment.default_options[:s3_host_name] = 's3-us-west-2.amazonaws.com'
Paperclip::Attachment.default_options[:path]         = '/:object/:type/:reference/:style/:filename'
Paperclip::Attachment.default_options[:default_url]  = 'https://storeitforme.s3.amazonaws.com/:object/:style/default.png'
Paperclip.interpolates :object do |attachment, style|
  attachment.name.to_s.pluralize
end
Paperclip.interpolates :reference do |attachment, style|
  attachment.instance.reference
end
Paperclip.interpolates :type do |attachment, style|
  attachment.instance.view_type
end
