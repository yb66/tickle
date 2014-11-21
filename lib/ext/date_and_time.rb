class Date
  # returns the days in the sending month
  def days_in_month
    d,m,y = mday,month,year
    d += 1 while Date.valid_civil?(y,m,d)
    d - 1
  end


  # no idea what this is for
  def bump(attr, amount=nil)
    amount ||= 1
    case attr
    when :day then
      Date.civil(self.year, self.month, self.day + amount)
    when :wday then
      amount = Date::ABBR_DAYNAMES.index(amount) if amount.is_a?(String)
      raise Exception, "specified day of week invalid.  Use #{Date::ABBR_DAYNAMES}" unless amount
      diff = (amount > self.wday) ? (amount - self.wday) : (7 - (self.wday - amount))
      Date.civil(self.year, self.month, self.day + diff)
    when :week then
      Date.civil(self.year, self.month, self.day + (7*amount))
    when :month then
      Date.civil(self.year, self.month+amount, self.day)
    when :year then
      Date.civil(self.year + amount, self.month, self.day)
    else
      raise Exception, "type \"#{attr}\" not supported."
    end
  end
end

class Time

  # same again, no idea what this is for
  def bump(attr, amount=nil)
    amount ||= 1
    case attr
    when :sec then
      Time.local(self.year, self.month, self.day, self.hour, self.min, self.sec + amount)
    when :min then
      Time.local(self.year, self.month, self.day, self.hour, self.min + amount, self.sec)
    when :hour then
      Time.local(self.year, self.month, self.day, self.hour + amount, self.min, self.sec)
    when :day then
      Time.local(self.year, self.month, self.day + amount, self.hour, self.min, self.sec)
    when :wday then
      amount = Time::RFC2822_DAY_NAME.index(amount) if amount.is_a?(String)
      raise Exception, "specified day of week invalid.  Use #{Time::RFC2822_DAY_NAME}" unless amount
      diff = (amount > self.wday) ? (amount - self.wday) : (7 - (self.wday - amount))
      Time.local(self.year, self.month, self.day + diff, self.hour, self.min, self.sec)
    when :week then
      Time.local(self.year, self.month, self.day + (amount * 7), self.hour, self.min, self.sec)
    when :month then
      Time.local(self.year, self.month + amount, self.day, self.hour, self.min, self.sec)
    when :year then
      Time.local(self.year + amount, self.month, self.day, self.hour, self.min, self.sec)
    else
      raise Exception, "type \"#{attr}\" not supported."
    end
  end
end