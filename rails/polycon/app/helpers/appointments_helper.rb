require 'erb'
require 'etc'
require 'date'
require 'time'

module AppointmentsHelper
  def output(name, output_dir, template, **options)
    html = File.open(template).read
    erb = ERB.new(html)
    out = erb.result_with_hash(**options)

    dirname = File.join("/home/ucuraj", output_dir)
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
    File.write(File.join(dirname, "#{name}.html"), out)
  end
end
