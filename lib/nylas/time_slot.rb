# frozen_string_literal: true

module Nylas
  # Query free/busy information for a calendar during a certain time period
  # @see https://docs.nylas.com/reference#calendars-free-busy
  class TimeSlot
    include Model::Attributable
    attribute :object, :string
    attribute :status, :string
    attribute :start_time, :integer
    attribute :end_time, :integer
  end
end
