require 'spec_helper'

RSpec.describe LightIO::IOloop do
  it "auto started" do
    t = Thread.new {LightIO::IOloop.current.closed?}
    expect(t.value).to be_falsey
  end

  it "per threaded", skip_monkey_patch: true do
    t = Thread.new {LightIO::IOloop.current}
    expect(t.value).not_to eq LightIO::IOloop.current
  end

  describe "#close", skip_monkey_patch: true do
    it "#closed?" do
      result = []
      t = Thread.new {
        result << LightIO::IOloop.current.closed?
        LightIO::IOloop.current.close
        result << LightIO::IOloop.current.closed?
      }
      t.join
      expect(result).to eql [false, true]
    end

    it "raise error" do
      t = Thread.new {
        LightIO::IOloop.current.stop
        r, w = LightIO::IO.pipe
        r.wait_readable
      }
      expect {t.value}.to raise_error(IOError, 'selector is closed')
    end
  end
end