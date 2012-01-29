require "fileutils"
require "json"
require "rest_client"
require "thor"
require "vimmy"

class Vimmy::CLI < Thor

  desc "init", "Initialize a local vim configuration"

  def init
    backup   "~/.vimrc"
    backup   "~/.vim"
    mkdir    ".vim/autoload"
    mkdir    ".vim/bundle"
    template ".vimrc"
    template ".vim/autoload/pathogen.vim"
  end

  desc "search TERM", "Search for a vim plugin"

  def search(term)
    display matching(term)
  end

  desc "install TERM", "Install a vim plugin"

  def install(term)
    url = install_choice(matching(term), "Choose a plugin to install")
  end

  desc "update", "Update all vim plugins"

  def update
    Dir[File.expand_path("~/.vim/bundle/*")].each do |plugin|
      puts "Updating: #{plugin}"
      system "cd #{plugin} && git pull"
    end
  end

private ######################################################################

  def backup(file)
    expanded = File.expand_path(file)
    if File.exists?(expanded)
      print "#{file} already exists, move to #{file}.old? [y/N]: "
      if STDIN.gets.strip.downcase == "y"
        FileUtils.mv(expanded, "#{expanded}.old")
      else
        exit 1
      end
    end
  end

  def install_choice(plugins, prompt)
    display plugins
    print "#{prompt}: "

    if (index = STDIN.gets.to_i) > 0
      return unless plugin = sort(plugins)[index-1]
      install_plugin plugin["url"]
    end
  end

  def display(plugins)
    sort(plugins).each_with_index do |plugin, index|
      puts "%d) %-28s  %s" % [index+1, plugin["name"][0,28], plugin["description"][0,50]]
    end
  end

  def header
    puts "%-28s  %s" % %w(Name Description)
    puts "%-28s  %s" % ["="*28, "="*50]
  end

  def install_plugin(url)
    puts "Installing: #{url}"
    if File.exist?(File.expand_path("~/.git"))
      name = url.to_s.split("/").last
      system %{ cd ~ && git submodule add -f #{url}.git .vim/bundle/#{name} &&
                git commit -m "added #{name} vim plugin" }
    else
      system %{ cd ~/.vim/bundle && git clone #{url}.git }
    end
  end

  def matching(term)
    plugins.select do |plugin|
      [plugin["name"], plugin["description"]].join(" ") =~ /#{term}/i
    end
  end

  def mkdir(dir)
    FileUtils.mkdir_p(File.expand_path("~/#{dir}"))
  end

  def plugins
    JSON.parse(vimscripts["scripts_recent.json"].get).map do |plugin|
      { 
        "name" => plugin["n"], 
        "description" => plugin["s"],
        "url" => "https://github.com/vim-scripts/#{plugin["n"]}"
      }
    end
  end

  def sort(plugins)
    plugins.sort_by { |p| p["name"] }
  end

  def template(file)
    source = File.expand_path("../../../data/template/#{file}", __FILE__)
    target = File.expand_path("~/#{file}", __FILE__)
    FileUtils.cp(source, target)
  end

  def vimscripts
    @vimscripts ||= RestClient::Resource.new("http://vim-scripts.org/api")
  end

end
