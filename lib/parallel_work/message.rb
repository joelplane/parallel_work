Dir[File.dirname(__FILE__) + '/message/*.rb'].each do |file|
  require file
end

module ParallelWork
  class Message

    def self.build name
      class_name = name[0,1].upcase + name[1,name.length].downcase
      const_get(class_name).new
    end

    def name
      raise "To be implemented in subclass"
    end

    def has_payload?
      raise "To be implemented in subclass"
    end

    def payload
      nil
    end

    def payload_length
      payload ? payload.length : 0
    end

  end
end
