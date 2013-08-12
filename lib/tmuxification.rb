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
      @template_name = options.fetch('template_name') { "default.#{current_shell}" }

      template template_file, project_file
      chmod project_file, 777 # ha!
      append_to_file shellrc_file, "#{shell_source_command} #{project_file}\n"
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
      @template_name = 'default.zsh'
      copy_file 'templates/default.zsh.tmux.erb', template_file unless File.exists?(template_file)
      @template_name = 'default.fish'
      copy_file 'templates/default.fish.tmux.erb', template_file unless File.exists?(template_file)
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

    def shellrc_file
      projects_rc = File.expand_path('~/.projects')
      return File.expand_path projects_rc                  if File.exists?(projects_rc)
      return File.expand_path '~/.zshrc'                   if zsh?
      return File.expand_path '~/.config/fish/config.fish' if fish?
    end

    def shell_source_command
      "source" if zsh?
      "." if fish?
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

    def zsh?
      current_shell == 'zsh'
    end

    def fish?
      current_shell == 'fish'
    end

    def current_shell
      ENV['SHELL'].split('/').last
    end
  end
end
