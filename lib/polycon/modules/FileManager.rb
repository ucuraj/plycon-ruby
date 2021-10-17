require 'fileutils'
require 'etc'

##
# Modulo para persistir data localmente.
#
module Polycon
  module Modules
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
            warn "Permission Error. Check your permissions of base path(#{BASE_PATH})"
          end
        end

        ##
        # Recibe un path relativo y devuelve su path absoluto(desde BASE_DIR)
        #
        def get_abs_path rel_path
          File.join(BASE_PATH, rel_path)
        end

        def dir_exists?(path)
          File.exists? File.join(BASE_PATH, path) and File.directory? File.join(BASE_PATH, path)
        end

        def file_exists?(path)
          File.exists? File.join(BASE_PATH, path) and File.file? File.join(BASE_PATH, path)
        end

        def path_file_exists?(path, filename)
          File.exists? File.join(BASE_PATH, path, filename) and File.file? File.join(BASE_PATH, path, filename)
        end

        def check_base_dir
          dir_get_or_create BASE_PATH
        end

        ##
        # Persiste informacion en disco
        # data
        def persist_data(file_dir_path, file_name, data, **kwargs)

          file_ext = kwargs[:file_ext] || DEFAULT_FILE_EXT
          mode = kwargs[:mode] || "w"
          array = kwargs[:array] || true

          if check_base_dir
            full_dir_path = File.join(BASE_PATH, file_dir_path)
            full_file_path = File.join(full_dir_path, file_name.concat(file_ext))
            begin
              array ? File.write(full_file_path, data.join("\n"), mode: mode) : File.write(full_file_path, data, mode: mode)
            rescue Errno::EACCES
              warn "Permission Error. Check your permissions of base path(#{BASE_PATH})"
            rescue Errno::ENOENT
              warn "Error trying to create file #{full_file_path}."
            end
          end
        end

        def create_dir(path)
          if check_base_dir
            full_path = File.join(BASE_PATH, path)
            begin
              unless dir_exists? path
                Dir.mkdir(full_path)
              end
              return true
            rescue Errno::EACCES
              warn "Permission Error. Check your permissions of base path(#{BASE_PATH})"
            rescue Errno::ENOENT
              warn "Error trying to create dir #{full_path}."
            end
          end
          false
        end

        def list_dirs(path)
          if check_base_dir
            begin
              Pathname.new(get_abs_path(path)).children.select { |c| c.directory? }
            rescue Errno::ENOENT
              warn "Dir '#{get_abs_path(path)}' not found"
              []
            end
          end
        end

        def list_files(path)
          if check_base_dir
            begin
              Pathname.new(get_abs_path(path)).children.select { |c| c.file? }
            rescue Errno::ENOENT
              warn "Dir '#{get_abs_path(path)}' not found"
              []
            end
          end
        end

        def list_all(path)
          if check_base_dir
            begin
              Pathname.new(get_abs_path(path)).children
            rescue Errno::ENOENT
              warn "Dir '#{get_abs_path(path)}' not found"
              []
            end
          end
        end

        def read_file(path, raise_exception = true, exception = Errno::ENOENT, abs_path = false)

          if file_exists? path
            begin
              File.read(get_abs_path(path)).split("\n") # retorno el contenido del archivo
            rescue Errno::EACCES
              warn "Permission Error. Check your permissions of base path(#{BASE_PATH})"
            end
          elsif raise_exception
            raise exception
          end
        end

        def delete_dir(path, raise_exception = true, exception = Errno::ENOENT)
          if dir_exists? path
            begin
              FileUtils.rm_rf(get_abs_path(path))
            rescue Errno::EACCES
              warn "Permission Error. Check your permissions of base path(#{BASE_PATH})"
            end
          elsif raise_exception
            raise exception
          end
        end

        def delete_file(path, filename, raise_exception = true, exception = Errno::ENOENT)
          if dir_exists? path
            begin
              FileUtils.rm(get_abs_path(File.join(path, filename)))
            rescue Errno::EACCES
              warn "Permission Error. Check your permissions of base path(#{BASE_PATH})"
            end
          elsif raise_exception
            raise exception
          end
        end

        def rename_dir(path, new_path, raise_exception = true, exception = Errno::ENOENT)
          if dir_exists? path
            begin
              File.rename get_abs_path(path), get_abs_path(new_path)
            rescue Errno::EACCES
              warn "Permission Error. Check your permissions of base path(#{BASE_PATH})"
            end
          elsif raise_exception
            raise exception
          end
        end

        def rename_file(old_filename, new_filename, raise_exception = true, exception = Errno::ENOENT)
          if File.exists? old_filename
            return File.rename old_filename, new_filename
          end
          raise_exception ? (raise exception) : (nil)
        end
        
      end
    end
  end
end