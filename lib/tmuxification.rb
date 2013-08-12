require "tmuxification/version"

module Tmuxification
  class App < Thor
    include Thor::Actions

    attr_reader :project_name, :template_name, :project_root

    desc 'create', 'Creates a new tmux project'
    method_options :project_name => :string, :template_name => :string
    def create
      setup
      @project_name = options.fetch('project_name') { Dir.pwd.split('/').last }
      @project_root = Dir.pwd
      @template_name = options.fetch('template_name') { 'default' }

      template template_file, project_file
      chmod project_file, 777 # ha!
      rc_file = shellrc_files.find { |rc_file| File.exists?(rc_file) }
      append_to_file rc_file, "source #{project_file}\n"
    end

    desc 'destroy', 'Destroys a tmux project'
    def destroy(project_name = nil)
      @project_name ||= Dir.pwd.split('/').last
      File.delete project_file if File.exists?(project_file)
    end

    desc 'list', 'List all tmux projects'
    def list
      Dir.glob(config_directory + '/*.tmux').map { |path| path.split('/').last }.each do |project_name|
        puts project_name
      end
    end

    desc 'setup', 'Create folder for tmux projects'
    def setup
      empty_directory config_directory
      @template_name = 'default'
      copy_file 'templates/default.tmux.erb', template_file unless File.exists?(template_file)
    end

    desc 'teardown', 'Delete all projects and containing folder'
    def teardown
      Dir.rmdir(config_directory) if yes? 'Are you sure?'
    end

    # source root for templates etc.
    def self.source_root
      File.dirname(__FILE__) + '/..'
    end

    private

    def shellrc_files
      ['~/.projects', '~/.zshrc', '~/.bashrc'].map { |path| File.expand_path(path) }
    end

    def template_file
      File.join(config_directory, template_name) + '.tmux.erb'
    end

    def project_file
      File.join(config_directory, project_name) + '.tmux'
    end

    # or set destination_root
    def config_directory
      File.expand_path '~/.tmuxification'
    end
  end
end
