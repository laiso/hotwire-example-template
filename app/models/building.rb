class Building < ApplicationRecord
  enum :building_type, owned: 0, leased: 1

  with_options presence: true do
    validates :line_1
    validates :line_2
    validates :city
    validates :state, inclusion: { in: -> record { record.states.keys }, allow_blank: true },
                      presence: { if: -> record { record.states.present? } }
    validates :postal_code
  end

  with_options presence: { if: :leased? } do
    validates :management_phone_number
  end

  def states
    CS.states(country).with_indifferent_access
  end

  def state_name
    states[state]
  end

  def country_name
    CS.countries.with_indifferent_access[country]
  end
end
