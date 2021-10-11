require 'fileutils'
require 'etc'

##
# Modulo para persistir data localmente.
#

module FileManager

  def self.included(base)
    base.send :include, FileManagerBase
    base.extend FileManagerBase
  end

  module FileManagerBase
    CURRENT_USER = Etc.getlogin
    USER_HOME = Dir.home(CURRENT_USER)
    PROJECT_DIR_NAME = ".polycon"
    BASE_PATH = File.join(USER_HOME, PROJECT_DIR_NAME)
    DEFAULT_FILE_EXT = ".paf"

    ##
    # Valida que exista la carpeta del proyecto en el home del usuario.
    #
    def dir_get_or_create(path = BASE_PATH)
      begin
        unless Dir.exists?(path)
          Dir.mkdir(path)
        end
        return path
      rescue Errno::EACCES
        warn "Error al crear directorio #{path}. No tenés permisos suficientes"
      end
    end

    ##
    # Recibe un path relativo y devuelve su path absoluto(desde BASE_DIR)
    #
    def get_abs_path rel_path
      File.join(BASE_PATH, rel_path)
    end

    def dir_exists?(path)
      File.exists? File.join(BASE_PATH, path)
    end

    def check_base_dir
      dir_get_or_create BASE_PATH
    end

    ##
    # Persiste informacion en disco
    # file_path es una ruta relativa. Todas las carpetas/archivos se deben crear dentro de BASE_PATH
    # file_name es el nombre del archivo
    #
    def persist_data(file_dir_path, file_name, data, file_ext = DEFAULT_FILE_EXT)
      if check_base_dir
        full_dir_path = File.join(BASE_PATH, file_dir_path)
        full_file_path = File.join(full_dir_path, file_name.concat(file_ext))
        begin
          File.open(full_file_path, "w") { |f| f.write data }
        rescue Errno::EACCES
          warn "Error al crear archivo #{full_file_path}. No tenés permisos suficientes"
        rescue Errno::ENOENT
          warn "Error al crear archivo #{full_file_path}."
        end
      end
    end

    def create_dir(path)
      if check_base_dir
        full_path = File.join(BASE_PATH, path)
        begin
          unless dir_exists? full_path
            Dir.mkdir(full_path)
          end
          return true
        rescue Errno::EACCES
          warn "Error al crear directorio #{full_path}. No tenés permisos suficientes"
        rescue Errno::ENOENT
          warn "Error al crear directorio #{full_path}."
        end
      end
      false
    end

    def list_dirs(path)
      if check_base_dir
        begin
          Pathname.new(get_abs_path(path)).children.select { |c| c.directory? }
        rescue Errno::ENOENT
          warn "No existe el directorio #{get_abs_path(path)}"
          []
        end
      end
    end

    def list_files(path)
      if check_base_dir
        begin
          Pathname.new(get_abs_path(path)).children.select { |c| c.file? }
        rescue Errno::ENOENT
          warn "No existe el directorio #{get_abs_path(path)}"
          []
        end
      end
    end

    def list_all(path)
      if check_base_dir
        begin
          Pathname.new(get_abs_path(path)).children
        rescue Errno::ENOENT
          warn "No existe el directorio #{get_abs_path(path)}"
          []
        end
      end
    end

  end
end
