class Puzzle < Thor
  include Actions
  source_root File.dirname(__FILE__)
  TemplateDir = 'skeleton'
  TestDir = 'staging'
  PuzzlesURL = 'http://www.facebook.com/careers/puzzles.php'

  attr_accessor :keyword
  attr_accessor :puzzle_url

  desc 'skeleton KEYWORD', 'generates a new solution skeleton'
  def skeleton keyword, puzzle_url = PuzzlesURL
    self.keyword, self.puzzle_url = keyword, puzzle_url
    directory TemplateDir, keyword
    chmod keyword, 0755
  end

  desc 'prep KEYWORD', 'package the solution for sending'
  def prep keyword
    tar_into keyword, 'LICENSE', 'lib', keyword
  end

  desc 'test KEYWORD', 'test the solution from its tarball'
  def test keyword, test_dir = TestDir, test_file = 'in.txt'
    invoke :prep, [keyword]
    invoke :clobber_test, [test_dir]
    untar_into test_dir, keyword
    invoke :testfile, [test_dir, test_file]
    inside test_dir do
      run("./#{keyword} #{test_file}", :capture => true).tap do |result|
        say_status :result, result
      end
    end
  end

  desc 'clobber_test', 'clobber test directory'
  def clobber_test test_dir = TestDir
    remove_dir test_dir
  end

  desc 'dir file', 'create a file for testing'
  def testfile test_dir, file_name
    inside(test_dir) { touch file_name }
  end

  no_tasks do
    def year
      Date.today.year
    end

    def tar_into name, *file_list
      command :tar, '-czC', name, '-f', tarball(name), *file_list
    end

    def untar_into test_dir, name
      empty_directory test_dir
      command :tar, '-xzC', test_dir, '-f', tarball(name)
    end

    def tarball name = keyword
      "#{name}.tgz"
    end

    def touch file_name
      command :touch, file_name
    end

    def command *args
      run args.map(&:to_s).join(' ')
    end
  end
end
