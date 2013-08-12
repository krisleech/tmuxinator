# Tmuxification

Generator for tmux configurations. The default template starts a tmux session
with two windows in your project root, vim is started in the first window.

## Tested on

* Ruby 1.9
* zsh & fish shells

## Installation

    $ gem install tmuxification

## Usage

### Create a new tmux project

    $ cd ~/code/my_project
    $ tmuxification create

You will need to reload your shell config file. The easiest way is to replace 
the current process with a new instance of your shell, e.g `exec zsh`.

### Start the project (from any directory)

    $ start_my_project

Note: The above will also autocomplete.

### List all your projects

    $ tmuxification list

### Delete a project

    $ cd ~/code/my_project
    $ tmuxification destroy

### Templates

You can create your own templates, just drop them in `~/.tmuxinator` with a
filename such as `basic.tmux.erb` and specify your template as such:

    $ tmuxification create --template-name=basic

You can also edit the `default.{zsh,fish}.tmux.erb` templates which are used when 
no `template-name` is specified. 

The default template is chosen based on the default shell.

### Project name

By default the tmux project is named after the root directory of the project, you
can specify a different project name as such:

    $ cd ~/code/my_project
    $ tmuxification create --project-name=foobar
    $ start_foobar

## Warning

Every project created will append a line per project to your `.zshrc` or
`config.fish` file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
