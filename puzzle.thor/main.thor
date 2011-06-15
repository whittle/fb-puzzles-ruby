require 'rubygems'
require 'bundler'

class Puzzle < Thor
  include Actions
  source_root File.dirname(__FILE__)

  TemplateDir = 'skeleton'
  TestDir = 'staging'
  PuzzlesURL = 'http://www.facebook.com/careers/puzzles.php'
  InFixture = 'spec/fixtures/in.txt'
  OutFixture = 'spec/fixtures/out.txt'

  attr_accessor :keyword
  attr_accessor :puzzle_url

  desc 'skeleton KEYWORD', 'generates a new solution skeleton'
  def skeleton keyword, puzzle_url = PuzzlesURL
    self.keyword, self.puzzle_url = keyword, puzzle_url
    directory TemplateDir, keyword
    chmod keyword, 0755
  end

  desc 'prep KEYWORD', 'prep the solution for submission'
  def prep keyword, test_dir = TestDir
    tar :lib, :spec, :LICENSE, keyword, :from => keyword, :into => keyword do |tarball|
      invoke :clobber_test, [test_dir]
      untar tarball, :into => test_dir do
        invoke :test, keyword
      end
    end
  end

  desc 'test KEYWORD', 'test the solution against an output fixture'
  def test keyword, in_file = InFixture, out_file = OutFixture
    command("./#{keyword}", in_file, :capture => true).tap do |actual|
      if actual == File.read(out_file)
        say_status :test, 'passed'
      else
        say_status :test, 'failed', :red
        shell.send :show_diff, out_file, actual
      end
    end
  end

  desc 'clobber_test', 'clobber test directory'
  def clobber_test test_dir = TestDir
    remove_dir test_dir
  end

  no_tasks do
    def year
      Date.today.year
    end

    def tar *file_list, &block
      options = file_list.pop
      "#{options[:into]}.tgz".tap do |tarball|
        command :tar, '-czC', options[:from], '-f', tarball, *file_list
        block[tarball]
        remove_file tarball
      end
    end

    def untar tarball, options, &block
      options[:into].tap do |dir|
        empty_directory dir
        command :tar, '-xzC', dir, '-f', tarball
        inside dir, &block
      end
    end

    def command *args
      opts = args.pop  if args.last.is_a? Hash
      args = [args.map(&:to_s).join(' ')]
      args.push opts  if opts
      run *args
    end
  end
end
