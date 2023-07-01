require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def thank_letter (id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone (phone)
  a = phone.gsub(/[^0-9]/,'')
  if a.length == 10
    true
  elsif a.length == 11 && a[0] == 1
    a[1,10]
  else puts"Invalid number"
  end 
end

  


def display_legislators(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
template = ERB.new template_letter

contents.each do |row|

  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  clean_phone(row[:homephone])
 
  legislator = display_legislators(zipcode)

  form_letter = template.result(binding) 
 
  id = row[0]
  
  thank_letter(id,form_letter)

  hours = []
end