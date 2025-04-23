require 'date'
require 'holiday_japan'

class BusinessDayCalculator
  # 指定した日が営業日（平日かつ祝日でない日）かどうかを判定
  def business_day?(date)
    # 土曜日(6)または日曜日(0)ではない、かつ祝日でもない
    !weekend?(date) && !holiday?(date)
  end
  
  # 指定した年月の最終営業日を取得
  def last_business_day_of_month(year, month)
    # 月末日を取得
    last_day = Date.new(year, month, -1)
    
    # 月末から前日へさかのぼり、最初に見つかった営業日を返す
    last_day.downto(Date.new(year, month, 1)) do |date|
      return date if business_day?(date)
    end
    
    # 全日が営業日でない場合（通常はありえない）
    nil
  end
  
  # 土日判定
  def weekend?(date)
    date.saturday? || date.sunday?
  end
  
  # 祝日判定
  def holiday?(date)
    # holiday_japan gemを使用して祝日かどうかチェック
    !HolidayJapan.name(date).nil?
  end
  
  # 今月の最終営業日かどうか判定
  def last_business_day_of_current_month?(date)
    return false unless business_day?(date)
    
    # 翌日以降、当月内に営業日がないか確認
    next_day = date + 1
    while next_day.month == date.month
      return false if business_day?(next_day)
      next_day += 1
    end
    
    true
  end
end