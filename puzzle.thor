class Puzzle < Thor
  include Actions
  source_root File.dirname(__FILE__)

  attr_accessor :keyword
  attr_accessor :puzzle_url

  desc 'skeleton KEYWORD "PUZZLE_URL"', 'generates a new solution skeleton'
  def skeleton keyword, puzzle_url = 'http://www.facebook.com/careers/puzzles.php'
    self.keyword, self.puzzle_url = keyword, puzzle_url
    directory 'skeleton', keyword
    chmod keyword, 0755
  end

  desc 'zip KEYWORD', 'package the solution for sending'
  def zip keyword
    self.keyword ||= keyword
    run tar_cmd(file_list)
  end

  desc 'test KEYWORD', 'test the solution from its tarball'
  method_options :force => :boolean
  def test keyword, test_dir = 'test', test_file = 'blank.txt'
    self.keyword ||= keyword
    thor :'puzzle:zip', keyword
    empty_directory test_dir
    run untar_cmd(test_dir)
    inside test_dir do
      thor :'puzzle:testfile', test_file
      run "./#{keyword} #{test_file}"
    end
  end

  desc 'testfile', 'create a file for testing'
  def testfile name
    run "touch #{name}"
  end

  no_tasks do
    def year
      Date.today.year
    end

    def tar_cmd file_list, name = keyword
      (['tar', '-czC', name, '-f', tarball(name)] + file_list).join(' ')
    end

    def untar_cmd test_dir, name = keyword
      ['tar', '-xzC', test_dir, '-f', tarball(name)].join(' ')
    end

    def tarball name = keyword
      "#{name}.tgz"
    end

    def file_list name = keyword
      ['LICENSE', 'lib', keyword]
    end
  end
end
