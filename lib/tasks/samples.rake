namespace :samples do

  namespace :generate do

    desc 'Generates statistic samples for current day'
    task :today => :environment do
      first_date = Date.today
      last_date  = Date.today
      Sample.generate_statistics_for_date_range first_date, last_date
    end

    desc 'Generates statistic samples for previous day'
    task :yesterday => :environment do
      first_date = 1.day.ago
      last_date  = 1.day.ago
      Sample.generate_statistics_for_date_range first_date, last_date
    end

  end

end

