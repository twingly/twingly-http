# frozen_string_literal: true

module Twingly
  module StringUtilities
    module_function

    def logfmt(hsh)
      hsh.map { |key, value| "#{key}=#{value}" }.join(" ")
    end

    def strip_start_character(string, char:)
      return unless string

      if string[0] == char
        string[1..]
      else
        string
      end
    end

    def split_key_pair(key_pair)
      key_pair.to_s.split(":")
    end
  end
end
