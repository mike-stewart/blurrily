require 'spec_helper'
require 'blurrily/command_processor'
require 'blurrily/map_group'

describe Blurrily::CommandProcessor do

  subject { described_class.new(Blurrily::MapGroup.new) }

  describe '#process_command' do
    # Accepts input strings:
    # CLEAR-><db>
    # FIND -><db>-><needle>->[limit]
    # PUT-><db>-><needle>-><ref>->[weight]

    it 'PUT and FIND finds something' do
      expect(subject.process_command("PUT\tlocations_en\tgreat london\t12")).to eq('OK')
      expect(subject.process_command("PUT\tlocations_en\tgreater masovian\t13")).to eq('OK')
      expect(subject.process_command("FIND\tlocations_en\tgreat")).to eq("OK\t12\t6\t12\t13\t5\t16")
    end

    it 'FIND returns "OK" if nothing found' do
      expect(subject.process_command("FIND\tlocations_en\tgreat london")).to eq("OK")
    end


    it 'returns ERROR for bad input data' do
      expect(subject.process_command('Some stuff')).to match(/^ERROR\tUnknown command/)
    end

    it 'returns ERROR for bad db name' do
      expect(subject.process_command("FIND\tbad db name\tWhatever string")).to match(/^ERROR\tInvalid database name/)
    end

    it 'returns ERROR for not numeric limit' do
      expect(subject.process_command("FIND\tdb\tWhatever string\tlimit")).to match(/^ERROR\tLimit must be a number/)
    end

    it 'returns ERROR for not numeric ref' do
      expect(subject.process_command("PUT\tdb\tWhatever string\t12\tweight")).to match(/^ERROR\tInvalid weight/)
    end

    it 'returns ERROR for not numeric weight' do
      expect(subject.process_command("PUT\tdb\tWhatever string\tref")).to match(/^ERROR\tInvalid reference/)
    end

    it 'returns ERROR for too many aruments' do
      expect(subject.process_command("PUT\tdb\tWhatever string\tref\tweight\targument too much")).to match(/^ERROR\twrong number /)
    end

    it 'does not return ERROR for good PUT string' do
      expect(subject.process_command("PUT\tdb\tWhatever string\t12\t1")).to eq('OK')
    end

    it 'does not return ERROR for limit' do
      expect(subject.process_command("FIND\tdb\tWhatever string\t2")).to eq("OK")
    end

    # it 'CLEAR tries to clear given DB' do
    #   subject.send(:map_group).should_receive(:clear).with('locations_en')
    #   subject.process_command("CLEAR\tlocations_en")
    # end
  end
end
