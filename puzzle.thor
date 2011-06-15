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

  desc 'test KEYWORD', 'test the solution from its tarball'
  def test keyword, test_dir = TestDir, test_file = 'in.txt'
    tar 'LICENSE', 'lib', keyword, :from => keyword, :into => keyword do |tarball|
      invoke :clobber_test, [test_dir]
      untar tarball, :into => test_dir do
        invoke :testfile, test_file
        run("./#{keyword} #{test_file}", :capture => true).tap do |result|
          say_status :result, result
        end
      end
    end
  end

  desc 'clobber_test', 'clobber test directory'
  def clobber_test test_dir = TestDir
    remove_dir test_dir
  end

  desc 'dir file', 'create a file for testing'
  def testfile file_name
    touch file_name
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

    def touch file_name
      command :touch, file_name
    end

    def command *args
      run args.map(&:to_s).join(' ')
    end
  end
end
