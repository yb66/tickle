module Tickle

  require 'texttube/filterable'
  module Filters
  
    extend TextTube::Filterable
  # Normalize natural string removing prefix language
    filter_with :remove_prefix do |text|
      text.gsub(/every(\s)?/, '')
          .gsub(/each(\s)?/, '')
          .gsub(/repeat(s|ing)?(\s)?/, '')
          .gsub(/on the(\s)?/, '')
          .gsub(/([^\w\d\s])+/, '')
          .downcase.strip
      text
    end


    # Converts natural language US Holidays into a date expression to be
    # parsed.
    filter_with :normalize_us_holidays do |text|
      normalized_text = text.to_s.downcase
      normalized_text.gsub(/\bnew\syear'?s?(\s)?(day)?\b/){|md| $1 }
        .gsub(/\bnew\syear'?s?(\s)?(eve)?\b/){|md| $1 }
        .gsub(/\bm(artin\s)?l(uther\s)?k(ing)?(\sday)?\b/){|md| $1 }
        .gsub(/\binauguration(\sday)?\b/){|md| $1 }
        .gsub(/\bpresident'?s?(\sday)?\b/){|md| $1 }
        .gsub(/\bmemorial\sday\b/){|md| $1 }
        .gsub(/\bindepend(e|a)nce\sday\b/){|md| $1 }
        .gsub(/\blabor\sday\b/){|md| $1 }
        .gsub(/\bcolumbus\sday\b/){|md| $1 }
        .gsub(/\bveterans?\sday\b/){|md| $1 }
        .gsub(/\bthanksgiving(\sday)?\b/){|md| $1 }
        .gsub(/\bchristmas\seve\b/){|md| $1 }
        .gsub(/\bchristmas(\sday)?\b/){|md| $1 }
        .gsub(/\bsuper\sbowl(\ssunday)?\b/){|md| $1 }
        .gsub(/\bgroundhog(\sday)?\b/){|md| $1 }
        .gsub(/\bvalentine'?s?(\sday)?\b/){|md| $1 }
        .gsub(/\bs(ain)?t\spatrick'?s?(\sday)?\b/){|md| $1 }
        .gsub(/\bapril\sfool'?s?(\sday)?\b/){|md| $1 }
        .gsub(/\bearth\sday\b/){|md| $1 }
        .gsub(/\barbor\sday\b/){|md| $1 }
        .gsub(/\bcinco\sde\smayo\b/){|md| $1 }
        .gsub(/\bmother'?s?\sday\b/){|md| $1 }
        .gsub(/\bflag\sday\b/){|md| $1 }
        .gsub(/\bfather'?s?\sday\b/){|md| $1 }
        .gsub(/\bhalloween\b/){|md| $1 }
        .gsub(/\belection\sday\b/){|md| $1 }
        .gsub(/\bkwanzaa\b/){|md| $1 }
      normalized_text
    end

#     filter_with :strip do |text|
#       text.strip
#     end
  
  end
end