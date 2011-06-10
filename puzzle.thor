class Puzzle < Thor
  include Actions
  source_root File.dirname(__FILE__)

  attr_accessor :keyword
  attr_accessor :puzzle_url

  desc 'start KEYWORD "PUZZLE_URL"', 'generates a new solution skeleton'
  def start keyword, puzzle_url = 'http://www.facebook.com/careers/puzzles.php'
    self.keyword, self.puzzle_url = keyword, puzzle_url
    directory 'template', keyword
    chmod keyword, 0755
  end

  no_tasks do
    def year
      Date.today.year
    end
  end
end
