class Report < ActiveRecord::Base
  require 'spreadsheet'
  belongs_to :report_schedule
  attr_accessible :body, :title, :start_date, :end_date

  def to_csv
    csv_string = String.new
    csv_string << CSV.generate do |csv|
      csv << ['Report between ' + self.start_date.strftime('%B %d, %Y') + 
        ' and ' + self.end_date.strftime('%B %d, %Y')  ]
      csv << ['License Server', 'Hours', 'Feature', 'License Count', 'Total_Utilization %' ]
    end
    body = YAML::load(self.body)
    body.each do |key,element|
      #for each liceserver
      element.each do |ek,ee|
        #for each office hours and 24-hours utilization
        ee.each do |stats|
          csv_string << CSV.generate do |csv|
            csv << ( Array.new << 
              Licserver.find(key.to_s).attributes.values_at("port", "server").join('@') << 
              ek.to_s << 
              stats[0] << 
              stats[1] <<
              (stats[2].to_f/stats[3]).round(4)*100
            )
          end
        end
      end
    end

    return csv_string
  end

  #dump this fucker to excel
  def to_xls
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    body = YAML::load(self.body)
    body.each do |key,element|
      #for each liceserver
      element.each do |ek,ee|
        #for each office hours and 24-hours utilization
        row_pos = 0
        ee.each do |stats|
            sheet.row(row_pos).push ek.to_s
            sheet.row(row_pos).push stats[0]
            sheet.row(row_pos).push stats[1]
            sheet.row(row_pos).push (stats[2].to_f/stats[3]).round(4)*100
            row_pos += row_pos.next
        end
      end
    end
    
    return book
  end
end
