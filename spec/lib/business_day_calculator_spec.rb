require 'spec_helper'
require_relative '../../lib/business_day_calculator'

RSpec.describe BusinessDayCalculator do
  let(:calculator) { described_class.new }

  describe '#business_day?' do
    context '平日で祝日でない場合' do
      before do
        allow(calculator).to receive(:weekend?).and_return(false)
        allow(calculator).to receive(:holiday?).and_return(false)
      end

      it '営業日と判定する' do
        expect(calculator.business_day?(Date.new(2025, 4, 23))).to be true
      end
    end

    context '土日の場合' do
      before do
        allow(calculator).to receive(:weekend?).and_return(true)
        allow(calculator).to receive(:holiday?).and_return(false)
      end

      it '営業日ではないと判定する' do
        expect(calculator.business_day?(Date.new(2025, 4, 26))).to be false
      end
    end

    context '祝日の場合' do
      before do
        allow(calculator).to receive(:weekend?).and_return(false)
        allow(calculator).to receive(:holiday?).and_return(true)
      end

      it '営業日ではないと判定する' do
        expect(calculator.business_day?(Date.new(2025, 5, 5))).to be false
      end
    end
  end

  describe '#weekend?' do
    it '土曜日はtrueを返す' do
      date = Date.new(2025, 4, 26) # 土曜日
      expect(calculator.weekend?(date)).to be true
    end

    it '日曜日はtrueを返す' do
      date = Date.new(2025, 4, 27) # 日曜日
      expect(calculator.weekend?(date)).to be true
    end

    it '平日はfalseを返す' do
      date = Date.new(2025, 4, 23) # 水曜日
      expect(calculator.weekend?(date)).to be false
    end
  end

  describe '#holiday?' do
    before do
      # 元日のような通常の祝日
      allow(HolidayJapan).to receive(:name).with(Date.new(2025, 1, 1)).and_return('元日')
      # 振替休日のケース
      allow(HolidayJapan).to receive(:name).with(Date.new(2025, 5, 6)).and_return('振替休日')
      # 平日（祝日ではない日）
      allow(HolidayJapan).to receive(:name).with(Date.new(2025, 4, 23)).and_return(nil)
    end

    it '祝日はtrueを返す' do
      date = Date.new(2025, 1, 1) # 元日
      expect(calculator.holiday?(date)).to be true
    end

    it '振替休日もtrueを返す' do
      date = Date.new(2025, 5, 6) # 憲法記念日（5月3日）が日曜日の場合の振替休日
      expect(calculator.holiday?(date)).to be true
    end

    it '平日はfalseを返す' do
      date = Date.new(2025, 4, 23) # 平日
      expect(calculator.holiday?(date)).to be false
    end
  end

  describe '#last_business_day_of_month' do
    context '月末が営業日の場合' do
      before do
        # 2025年4月30日（水曜日）は営業日と仮定
        allow(calculator).to receive(:business_day?).with(Date.new(2025, 4, 30)).and_return(true)
      end

      it '月末日を返す' do
        expect(calculator.last_business_day_of_month(2025, 4)).to eq Date.new(2025, 4, 30)
      end
    end

    context '月末が営業日でない場合' do
      before do
        # 2025年4月30日は非営業日、4月29日は営業日と仮定
        allow(calculator).to receive(:business_day?).with(Date.new(2025, 4, 30)).and_return(false)
        allow(calculator).to receive(:business_day?).with(Date.new(2025, 4, 29)).and_return(true)
      end

      it '月末より前の最後の営業日を返す' do
        expect(calculator.last_business_day_of_month(2025, 4)).to eq Date.new(2025, 4, 29)
      end
    end
  end

  describe '#last_business_day_of_current_month?' do
    context '当日が最終営業日の場合' do
      before do
        date = Date.new(2025, 4, 29)
        # 4月29日は営業日
        allow(calculator).to receive(:last_business_day_of_month).with(2025, 4).and_return(Date.new(2025, 4, 29))
      end

      it 'trueを返す' do
        expect(calculator.last_business_day_of_current_month?(Date.new(2025, 4, 29))).to be true
      end
    end

    context '当日が最終営業日でない場合' do
      before do
        date = Date.new(2025, 4, 28)
        # 4月28日は営業日
        allow(calculator).to receive(:last_business_day_of_month).with(2025, 4).and_return(Date.new(2025, 4, 29))
      end

      it 'falseを返す' do
        expect(calculator.last_business_day_of_current_month?(Date.new(2025, 4, 28))).to be false
      end
    end
  end
end
