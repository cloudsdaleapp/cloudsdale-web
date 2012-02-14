class MoveMetadataToSrcMetaForDrop < Mongoid::Migration
  
  def self.up
    total_drop_count = Drop.count
    
    Drop.all.each_with_index do |drop,index|
      drop.rename(:metadata,:src_meta)
      if ((index%100)==1)
        puts "#{index+1}/#{total_drop_count}"
      end
    end
    
  end

  def self.down
    total_drop_count = Drop.count
    
    Drop.all.each_with_index do |drop,index|
      drop.rename(:src_meta,:metadata)
      if ((index%100)==1)
        puts "#{index+1}/#{total_drop_count}"
      end
    end
  end
  
end