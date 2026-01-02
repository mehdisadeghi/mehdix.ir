# frozen_string_literal: true

# Persian text and Jalali calendar utilities for Jekyll.

# Persian text utilities
module Parsi
  NUMERALS = {
    "0" => "۰", "1" => "۱", "2" => "۲", "3" => "۳", "4" => "۴",
    "5" => "۵", "6" => "۶", "7" => "۷", "8" => "۸", "9" => "۹"
  }.freeze

  def self.numerals(str)
    NUMERALS.reduce(str.to_s) { |s, (latin, persian)| s.gsub(latin, persian) }
  end

  module Filter
    def persian(input)
      Parsi.numerals(input.to_s)
    end
  end
end

Liquid::Template.register_filter(Parsi::Filter)

# Jalali (Persian/Solar Hijri) calendar conversion.
#
# Algorithm: Converts Gregorian dates to Jalali using the 33-year cycle.
# The cycle has 8 leap years (1,5,9,13,17,22,26,30) giving 365.2424 days/year.
#
# References:
#   - jdf.scr.ir — Original algorithm by Roozbeh Pournader & Mohammad Toossi
#   - FarsiWeb Project — Persian computing standards
#   - Reingold & Dershowitz, "Calendrical Calculations" (Academic reference)
#   - https://en.wikipedia.org/wiki/Solar_Hijri_calendar
#
# Epoch offset (355666): Days between Gregorian epoch (Jan 1, 1 CE) and
# Jalali epoch (Farvardin 1, year 1 = March 22, 622 CE).
module Jalali
  WEEKDAYS = %w[شنبه یکشنبه دوشنبه سه‌شنبه چهارشنبه پنجشنبه جمعه].freeze
  MONTHS = %w[فروردین اردیبهشت خرداد تیر مرداد شهریور مهر آبان آذر دی بهمن اسفند].freeze
  MONTH_DAYS = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29].freeze
  WEEKDAYS_SHORT = %w[ش ی د س چ پ ج].freeze

  class Date
    attr_reader :year, :month, :day, :weekday, :time

    def initialize(date)
      @time = date.is_a?(Time) ? date : Time.parse(date.to_s)
      @year, @month, @day = Jalali.gregorian_to_jalali(@time.year, @time.month, @time.day)
      @weekday = (@time.wday + 1) % 7 # Saturday = 0
    end

    def month_name
      MONTHS[@month - 1]
    end

    def weekday_name
      WEEKDAYS[@weekday]
    end

    def leap?
      Jalali.leap?(@year)
    end

    def day_of_year
      MONTH_DAYS.take(@month - 1).sum + @day
    end

    def to_s
      "#{@year}/#{@month}/#{@day}"
    end

    # Format date using strftime-style format string.
    # Follows C stdlib strftime conventions.
    #
    #   %A - full weekday name (شنبه)
    #   %a - abbreviated weekday (ش)
    #   %B - full month name (فروردین)
    #   %b - abbreviated month name (same as %B in Persian)
    #   %d - day of month, zero-padded (01-31)
    #   %e - day of month, space-padded ( 1-31)
    #   %j - day of year, zero-padded (001-366)
    #   %m - month, zero-padded (01-12)
    #   %Y - 4-digit year (1404)
    #   %y - 2-digit year (04)
    #   %H - hour 24h, zero-padded (00-23)
    #   %M - minute, zero-padded (00-59)
    #   %S - second, zero-padded (00-59)
    #   %n - newline
    #   %t - tab
    #   %% - literal %
    #
    def strftime(format, persian_digits: false)
      result = format.gsub(/%[AaBbdejmYyHMSnt%]/) do |spec|
        case spec
        when "%A" then WEEKDAYS[@weekday]
        when "%a" then WEEKDAYS_SHORT[@weekday]
        when "%B", "%b" then MONTHS[@month - 1]
        when "%d" then @day.to_s.rjust(2, "0")
        when "%e" then @day.to_s.rjust(2, " ")
        when "%j" then day_of_year.to_s.rjust(3, "0")
        when "%m" then @month.to_s.rjust(2, "0")
        when "%Y" then @year.to_s
        when "%y" then (@year % 100).to_s.rjust(2, "0")
        when "%H" then @time.strftime("%H")
        when "%M" then @time.strftime("%M")
        when "%S" then @time.strftime("%S")
        when "%n" then "\n"
        when "%t" then "\t"
        when "%%" then "%"
        end
      end
      persian_digits ? Parsi.numerals(result) : result
    end
  end

  # Convert Gregorian (gy, gm, gd) to Jalali [jy, jm, jd].
  #
  # Algorithm calculates days since Jalali epoch, then decomposes into year/month/day.
  # The 33-year cycle handles leap years: years 1,5,9,13,17,22,26,30 of each cycle are leap.
  #
  def self.gregorian_to_jalali(gy, gm, gd)
    # Cumulative days before each Gregorian month
    g_cumulative = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

    # Days from Gregorian epoch, adjusted for Jalali epoch offset (355666)
    gy2 = (gm > 2) ? gy + 1 : gy
    days = 355_666 +
      (365 * gy) +
      ((gy2 + 3) / 4) -
      ((gy2 + 99) / 100) +
      ((gy2 + 399) / 400) +
      gd +
      g_cumulative[gm - 1]

    # Extract Jalali year from 33-year cycles
    # 12053 days = 33 years, 1461 days = 4 years
    jy = -1595 + (33 * (days / 12_053))
    days %= 12_053

    jy += 4 * (days / 1461)
    days %= 1461

    if days > 365
      jy += (days - 1) / 365
      days = (days - 1) % 365
    end

    # Extract month and day
    # First 6 months: 31 days each (186 total)
    # Last 6 months: 30,30,30,30,30,29 days
    if days < 186
      jm = 1 + (days / 31)
      jd = 1 + (days % 31)
    else
      jm = 7 + ((days - 186) / 30)
      jd = 1 + ((days - 186) % 30)
    end

    [jy, jm, jd]
  end

  # Jalali leap year check using 33-year cycle
  def self.leap?(jy)
    [1, 5, 9, 13, 17, 22, 26, 30].include?(jy % 33)
  end

  module Filter
    FORMAT_CLASSES = {
      "%A" => "weekday", "%a" => "weekday",
      "%B" => "month", "%b" => "month",
      "%d" => "day", "%e" => "day",
      "%Y" => "year", "%y" => "year",
      "%m" => "month-num",
      "%j" => "day-of-year",
      "%H" => "hour", "%M" => "minute", "%S" => "second"
    }.freeze

    def jdate(date, format = "%d %b %Y")
      return "" if date.nil? || date.to_s.empty?

      Jalali::Date.new(date).strftime(format, persian_digits: true)
    rescue
      date.to_s
    end

    def jdate_html(date, format = "%d %b %Y")
      return "" if date.nil? || date.to_s.empty?

      j = Jalali::Date.new(date)

      html = format.gsub(/%[AaBbdeYymjHMS]/) do |spec|
        value = j.strftime(spec, persian_digits: true)
        %(<span class="#{FORMAT_CLASSES[spec]}">#{value}</span>)
      end

      gregorian = j.time.strftime("%-d %B %Y")
      %(<time datetime="#{j.time.iso8601}" title="\u200E#{gregorian}">#{html}</time>)
    rescue
      date.to_s
    end
  end
end

Liquid::Template.register_filter(Jalali::Filter)
