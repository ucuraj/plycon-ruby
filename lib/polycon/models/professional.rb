class Professional
  autoload :FileManager, 'polycon/modules/FileManager'
  autoload :Text, 'polycon/helpers/text'

  include FileManager
  include Text

  SAVE_BASE_PATH = ""

  # initialize method
  def initialize(name)
    # variables
    @name = name
    @date_joined = Time.now
  end

  def dir_name
    to_snake_case(@name).split.join
  end

  def full_path
    get_abs_path dir_name
  end

  def rel_path
    File.join(SAVE_BASE_PATH, dir_name)
  end

  def save
    if dir_exists?(rel_path)
      raise Exists
    end
    create_dir rel_path
  end

  ##
  # Class Methods
  #

  def self.list
    professionals = list_dirs(SAVE_BASE_PATH)
    a = [[1.23, 5, :bagels], [3.14, 7, :gravel], [8.33, 11, :saturn]]
    bar = '-' * (a[0][0].to_s.length + 4 + a[0][1].to_s.length + 3 + a[0][2].to_s.length + 5)
    puts "\n PROFESSIONAL LIST\n\n"
    puts bar
    if professionals.any?
      puts professionals.each_with_index.map { |p, i| "#{i + 1}. #{snake_to_spaced(p.basename.to_s)}" }
    else
      puts "No professionals available"
    end
    return puts "#{bar}\n\n"
  end

  ##
  # Exceptions
  #
  class Exists < StandardError
    def initialize(msg = "The professional is already registered in Polycon")
      super
    end
  end

  class NoExists < StandardError
    def initialize(msg = "The professional is not registered in Polycon")
      super
    end
  end
end