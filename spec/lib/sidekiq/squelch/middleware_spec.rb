require 'spec_helper'

module Sidekiq
  module Squelch
    describe Middleware do
      let(:peroid) { 600 }
      let(:threshold) { 6 }
      let(:notifier) { BasicNotifier.new }
      subject { Middleware.new notifier }

      before(:each) { Sidekiq.redis { |redis| redis.flushall } }
      before(:each) { Sidekiq.options = Sidekiq.options.merge squelch: [ [ 'BasicError', threshold, peroid] ] }

      after(:each) { Sidekiq.options.delete :squelch }

      it 'raises any errors encountered' do
        expect { 
          subject.call(nil, nil, nil) { raise BasicError.new }
        }.to raise_error
      end

      it 'increments the error count' do
        expect(basic_error_count).to eq 0
        expect { subject.call(nil, nil, nil) { raise BasicError.new } }.to raise_error
        expect(basic_error_count).to eq 1
      end

      it 'it prunes the error count based on the peroid' do
        Timecop.travel Time.now do
          threshold.times {
            expect { 
              subject.call(nil, nil, nil) { raise BasicError.new }
            }.to raise_error
          }
        end

        expect(notifier.count).to eq 0        

        Timecop.travel Time.now + peroid * 2 do
          threshold.times {
            expect { 
              subject.call(nil, nil, nil) { raise BasicError.new }
            }.to raise_error
          }
        end

        expect(notifier.count).to eq 0
      end

      it 'notifies after hitting the threshold' do
        (threshold + 5).times {
          expect { 
            subject.call(nil, nil, nil) { raise BasicError.new }
          }.to raise_error
        }

        expect(notifier.count).to eq 5
      end
    end
  end
end

private

def basic_error_count
  Sidekiq.redis { |redis| redis.zcount 'squelch:basic_error', '-inf', '+inf' }
end

class BasicError < StandardError; end
class DifferentError < StandardError; end

class BasicNotifier
  attr_reader :exception, :options, :count

  def initialize
    reset
  end

  def reset
    @count = 0
  end

  def notify(ex, **opts)
    @count += 1
    @exception = ex
    @options = opts
  end
end
