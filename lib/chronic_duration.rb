require 'numerizer' unless defined?(Numerizer)

module ChronicDuration

  extend self

  class DurationParseError < StandardError
  end

  @@raise_exceptions = false
  @@hours_per_day = 24
  @@days_per_week = 7

  def self.raise_exceptions
    !!@@raise_exceptions
  end

  def self.raise_exceptions=(value)
    @@raise_exceptions = !!value
  end

  def self.hours_per_day
    @@hours_per_day
  end

  def self.hours_per_day=(value)
    @@hours_per_day = value
  end

  def self.days_per_week
    @@days_per_week
  end

  def self.days_per_week=(value)
    @@days_per_week = value
  end

  # Given a string representation of elapsed time,
  # return an integer (or float, if fractions of a
  # second are input)
  def parse(string, opts = {})
    result = calculate_from_words(cleanup(string), opts)
    (!opts[:keep_zero] and result == 0) ? nil : result
  end

private

  def humanize_time_unit(number, unit, pluralize, keep_zero)
    return nil if number == 0 && !keep_zero
    res = "#{number}#{unit}"
    # A poor man's pluralizer
    res << 's' if !(number == 1) && pluralize
    res
  end

  def calculate_from_words(string, opts)
    val = 0
    words = string.split(' ')
    words.each_with_index do |v, k|
      if v =~ float_matcher
        val += (convert_to_number(v) * duration_units_seconds_multiplier(words[k + 1] || (opts[:default_unit] || 'seconds')))
      end
    end
    val
  end

  def cleanup(string)
    res = string.downcase
    res = filter_by_type(Numerizer.numerize(res))
    res = res.gsub(float_matcher) {|n| " #{n} "}.squeeze(' ').strip
    res = filter_through_white_list(res)
  end

  def convert_to_number(string)
    string.to_f % 1 > 0 ? string.to_f : string.to_i
  end

  def duration_units_list
    %w(seconds minutes hours days weeks months years)
  end
  def duration_units_seconds_multiplier(unit)
    return 0 unless duration_units_list.include?(unit)
    case unit
    when 'years';   31557600
    when 'months';  3600 * ChronicDuration.hours_per_day * 30
    when 'weeks';   3600 * ChronicDuration.hours_per_day * ChronicDuration.days_per_week
    when 'days';    3600 * ChronicDuration.hours_per_day
    when 'hours';   3600
    when 'minutes'; 60
    when 'seconds'; 1
    end
  end

  # Parse 3:41:59 and return 3 hours 41 minutes 59 seconds
  def filter_by_type(string)
    chrono_units_list = duration_units_list.reject {|v| v == "weeks"}
    if string.gsub(' ', '') =~ /#{float_matcher}(:#{float_matcher})+/
      res = []
      string.gsub(' ', '').split(':').reverse.each_with_index do |v,k|
        return unless chrono_units_list[k]
        res << "#{v} #{chrono_units_list[k]}"
      end
      res = res.reverse.join(' ')
    else
      res = string
    end
    res
  end

  def float_matcher
    /[0-9]*\.?[0-9]+/
  end

  # Get rid of unknown words and map found
  # words to defined time units
  def filter_through_white_list(string)
    res = []
    string.split(' ').each do |word|
      if word =~ float_matcher
        res << word.strip
        next
      end
      stripped_word = word.strip.gsub(/^,/, '').gsub(/,$/, '')
      if mappings.has_key?(stripped_word)
        res << mappings[stripped_word]
      elsif !join_words.include?(stripped_word) and ChronicDuration.raise_exceptions
        raise DurationParseError, "An invalid word #{word.inspect} was used in the string to be parsed."
      end
    end
    # add '1' at front if string starts with something recognizable but not with a number, like 'day' or 'minute 30sec'
    res.unshift(1) if res.length > 0 && mappings[res[0]]
    res.join(' ')
  end

  def mappings
    {
      'secondes' => 'seconds',
      'seconde'  => 'seconds',
      'secs'    => 'seconds',
      'sec'     => 'seconds',
      's'       => 'seconds',
      'minutes' => 'minutes',
      'minute'  => 'minutes',
      'mins'    => 'minutes',
      'min'     => 'minutes',
      'm'       => 'minutes',
      'heures'   => 'hours',
      'heure'    => 'hours',
      'h'       => 'hours',
      'jours'    => 'days',
      'jour'     => 'days',
      'j'       => 'days',
      'semaines'   => 'weeks',
      'semaine'    => 'weeks',
      'mois'  => 'months',
      'années'   => 'years',
      'année'    => 'years',
      'ans'     => 'years',
      'an'      => 'years'
    }
  end

  def join_words
    ['et', 'avec', 'plus', 'puis']
  end
end
