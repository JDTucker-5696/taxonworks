require 'rails_helper'
# rubocop:disable Style/AsciiComments, Style/EmptyLinesAroundBlockBody

# TODO: Extract all this to a gem
describe 'Dates', group: [:collecting_events, :dates] do

  context 'date discovery and parsing' do

    context 'bad values' do

      specify 'truley bogus data' do
        this_case = Utilities::Dates.hunt_dates('192:5:18.1N')

        expect(this_case).to eq(
                                 {:dd_dd_month_yyyy => {},
                                  :dd_mm_dd_mm_yyyy => {},
                                  :dd_month_dd_month_yyyy => {},
                                  :dd_month_yyy => {},
                                  :dd_month_yyyy_2 => {},
                                  :mm_dd_dd_yyyy => {},
                                  :mm_dd_mm_dd_yyyy => {},
                                  :mm_dd_yy => {},
                                  :mm_dd_yyyy => {},
                                  :mm_dd_yyyy_2 => {},
                                  :month_dd_dd_yyyy => {},
                                  :month_dd_month_dd_yyyy => {},
                                  :month_dd_yyy => {},
                                  :month_dd_yyyy_2 => {},
                                  :yyyy_mm_dd => {},
                                  :yyyy_month_dd => {}
                               }
                             )
      end
    end
    #done except failing on 'This is a test september 20 ,1944 - November 19 , 1945' (extra spaces)
    context 'single use case for dates hunt_dates' do
      use_case = {'Some text here,  5 V 2003, some more text after the date  ' =>
                      {:dd_dd_month_yyyy => {},
                       :dd_mm_dd_mm_yyyy => {},
                       :dd_month_dd_month_yyyy => {},
                       :dd_month_yyy => {:method => :dd_month_yyy, :piece => {0 => "5 V 2003"}, :start_date_year => "2003", :start_date_month => "5", :start_date_day => "5", :end_date_year => "", :end_date_month => "", :end_date_day => "", :start_date => "2003 5 5", :end_date => ""},
                       :dd_month_yyyy_2 => {},
                       :mm_dd_dd_yyyy => {},
                       :mm_dd_mm_dd_yyyy => {},
                       :mm_dd_yy => {},
                       :mm_dd_yyyy => {},
                       :mm_dd_yyyy_2 => {},
                       :month_dd_dd_yyyy => {},
                       :month_dd_month_dd_yyyy => {},
                       :month_dd_yyy => {},
                       :month_dd_yyyy_2 => {},
                       :yyyy_mm_dd => {},
                       :yyyy_month_dd => {}
                      }
      }
      @entry   = 0

      use_case.each {|label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Dates.hunt_dates(label)
          expect(this_case).to eq(result)
        end
      }
    end

    context 'two digit year use case for dates hunt_dates' do
      use_case = {"Some text here,  4 JUL '03, some more text after the date  " =>
                      {:dd_dd_month_yyyy => {},
                       :dd_mm_dd_mm_yyyy => {},
                       :dd_month_dd_month_yyyy => {},
                       :dd_month_yyy => {:method => :dd_month_yyy, :piece => {0 => "4 JUL '03"}, :start_date_year => "2003", :start_date_month => "7", :start_date_day => "4", :end_date_year => "", :end_date_month => "", :end_date_day => "", :start_date => "2003 7 4", :end_date => ""},
                       :dd_month_yyyy_2 => {},
                       :mm_dd_dd_yyyy => {},
                       :mm_dd_mm_dd_yyyy => {},
                       :mm_dd_yy => {},
                       :mm_dd_yyyy => {},
                       :mm_dd_yyyy_2 => {},
                       :month_dd_dd_yyyy => {},
                       :month_dd_month_dd_yyyy => {},
                       :month_dd_yyy => {},
                       :month_dd_yyyy_2 => {},
                       :yyyy_mm_dd => {},
                       :yyyy_month_dd => {}
                      }
      }
      @entry = 0

      use_case.each {|label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Dates.hunt_dates(label)
          expect(this_case).to eq(result)
        end
      }
    end


    context 'use one method at a time hunt_dates' do
      methods = Utilities::Dates::REGEXP_DATES.keys
      methods.each_with_index {|method, dex|
        this_hlp = Utilities::Dates::REGEXP_DATES[method][:hlp]
        matches = this_hlp.split('   ')
        matches.each {|this_match|


          specify "method  #{method} should correctly match each  #{this_match} example listed in the hlp attribute " do
          result = nil
          this_case = Utilities::Dates.hunt_dates(this_match, [method])
          expect(this_case[method][:piece][0]).to eq(this_match.strip)
        end
      }
      }
    end

    context 'multiple use cases for dates hunt_dates' do
      use_cases = {
          "Here is some extra text: 4 jan, '17  More stuff at the end" =>
            {:dd_dd_month_yyyy => {},
             :dd_mm_dd_mm_yyyy => {},
             :dd_month_dd_month_yyyy => {},
             :dd_month_yyy => {:method => :dd_month_yyy, :piece => {0 => "4 jan, '17"}, :start_date_year => "2017", :start_date_month => "1", :start_date_day => "4", :end_date_year => "", :end_date_month => "", :end_date_day => "", :start_date => "2017 1 4", :end_date => ""},
             :dd_month_yyyy_2 => {},
             :mm_dd_dd_yyyy => {},
             :mm_dd_mm_dd_yyyy => {},
             :mm_dd_yy => {},
             :mm_dd_yyyy => {},
             :mm_dd_yyyy_2 => {},
             :month_dd_dd_yyyy => {},
             :month_dd_month_dd_yyyy => {},
             :month_dd_yyy => {},
             :month_dd_yyyy_2 => {},
             :yyyy_mm_dd => {},
             :yyyy_month_dd => {}
          },
          'Here is some extra text:,;   22-23 V 2003; More stuff at the end' =>
            {:dd_dd_month_yyyy => {:method => :dd_dd_month_yyyy, :piece => {0 => "22-23 V 2003"}, :start_date_year => "2003", :start_date_month => "5", :start_date_day => "22", :end_date_year => "2003", :end_date_month => "5", :end_date_day => "23", :start_date => "2003 5 22", :end_date => "2003 5 23"},
             :dd_mm_dd_mm_yyyy => {},
             :dd_month_dd_month_yyyy => {},
             :dd_month_yyy => {:method => :dd_month_yyy, :piece => {0 => "23 V 2003"}, :start_date_year => "2003", :start_date_month => "5", :start_date_day => "23", :end_date_year => "", :end_date_month => "", :end_date_day => "", :start_date => "2003 5 23", :end_date => ""},
             :dd_month_yyyy_2 => {},
             :mm_dd_dd_yyyy => {},
             :mm_dd_mm_dd_yyyy => {},
             :mm_dd_yy => {},
             :mm_dd_yyyy => {},
             :mm_dd_yyyy_2 => {},
             :month_dd_dd_yyyy => {},
             :month_dd_month_dd_yyyy => {},
             :month_dd_yyy => {},
             :month_dd_yyyy_2 => {},
             :yyyy_mm_dd => {},
             :yyyy_month_dd => {}
          }
      }
      @entry    = 0

      use_cases.each {|label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Dates.hunt_dates(label)
          expect(this_case).to eq(result)
        end
      }

    end
  end
end
