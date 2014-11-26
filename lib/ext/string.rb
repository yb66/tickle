class String
  # returns true if the sending string is a text or numeric ordinal (e.g. first or 1st)
  def is_ordinal?
    scanner = %w{first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth twenty thirty thirtieth}
    regex = /\b(\d*)(st|nd|rd|th)\b/
    !(self =~ regex).nil? || scanner.include?(self.downcase)
  end

  def ordinal_as_number
    return self unless self.is_ordinal?
    scanner = {/first/ => '1st',
      /second/ => '2nd',
      /third/ => '3rd',
      /fourth/ => '4th',
      /fifth/ => '5th',
      /sixth/ => '6th',
      /seventh/ => '7th',
      /eighth/ => '8th',
      /ninth/ => '9th',
      /tenth/ => '10th',
      /eleventh/ => '11th',
      /twelfth/ => '12th',
      /thirteenth/ => '13th',
      /fourteenth/ => '14th',
      /fifteenth/ => '15th',
      /sixteenth/ => '16th',
      /seventeenth/ => '17th',
      /eighteenth/ => '18th',
      /nineteenth/ => '19th',
      /twentieth/ => '20th',
      /thirtieth/ => '30th',
    }
    result = self
    scanner.keys.each {|scanner_item| result = scanner[scanner_item] if scanner_item =~ self}
    return result.gsub(/\b(\d*)(st|nd|rd|th)\b/, '\1')
  end
end