require "fileutils"
require "mechanize"
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
    url = choose(matching(term), "Choose a plugin to install")
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

  def choose(plugins, prompt)
    display plugins
    print "#{prompt}: "

    if (index = STDIN.gets.to_i) > 0
      return unless plugin = sort(plugins)[index-1]
      install_plugin plugin.first
    end
  end

  def display(plugins)
    sort(plugins).each_with_index do |(url, plugin), index|
      puts "%d) %-28s  %s" % [index+1, plugin[:name][0,28], plugin[:description][0,50]]
    end
  end

  def header
    puts "%-28s  %s" % %w(Name Description)
    puts "%-28s  %s" % ["="*28, "="*50]
  end

  def install_plugin(url)
    puts "Installing: #{url}"
    system %{ cd ~/.vim/bundle && git clone #{url}.git }
  end

  def matching(term)
    plugins.select do |url, plugin|
      [plugin[:name], plugin[:description]].join(" ") =~ /#{term}/i
    end
  end

  def mkdir(dir)
    FileUtils.mkdir_p(File.expand_path("~/#{dir}"))
  end

  def plugins
    page = Mechanize.new.get('http://vim-scripts.org/vim/scripts.html')
    page.search('//tr').inject({}) do |hash, row|
      link = row.search('td/a').first
      hash.update(link.attributes['href'] => {
        :name => link.text,
        :description => row.search('td')[3].text
      })
    end
  end

  def sort(plugins)
    plugins.sort_by { |p| p.last[:name] }
  end

  def template(file)
    source = File.expand_path("../../../data/template/#{file}", __FILE__)
    target = File.expand_path("~/#{file}", __FILE__)
    FileUtils.cp(source, target)
  end

end
