class FindByZip

  # Benchmark shows 0.03s for single search
  def self.find(zip)
    zip = zip.to_s
    IO.foreach(File.join(Rails.root, 'db', 'cities.csv')) do |line|
      unless line[0..4] == zip
        next
      else
        # 38921,MS,Charleston,33.972621,-90.111559\r\n
        read_line = line.strip.split(',')
        return {zip: zip, state: read_line[1], city: read_line[2], lat: read_line[3], lon: read_line[4]}
      end
    end
  end

end