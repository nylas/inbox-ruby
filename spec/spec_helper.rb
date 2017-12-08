require 'simplecov'
SimpleCov.start


require 'nylas-streaming'
require 'pry'
require 'webmock/rspec'

class FakeAPI
  def execute(method:, path:, payload: nil)
    requests.push({ method: method, path: path, payload: payload })
  end

  def requests
    @requests ||= []
  end
end

# Illustrates all the types and such a model can be built out of. Used for testing the generic Model
# functionality without conflating it with actual Models
class FullModel
  include Nylas::Model
  self.resources_path = "/collection"
  # It is possible to exclude certain values on create or update even if they're set. Mostly useful for ids or
  # values that are generated server side.
  attribute :id, :string, exclude_when: [:creating, :updating]

  attribute :string, :string
  attribute :nylas_date, :nylas_date
  attribute :email_address, :email_address
  attribute :im_address, :im_address
  attribute :phone_number, :phone_number
  attribute :web_page, :web_page

  has_n_of_attribute :web_pages, :web_page
end

class ReadOnlyModel
  include Nylas::Model
  self.resources_path = "/read_only_collection"
  self.read_only = true

  attribute :id, :string, exclude_when: [:creating, :updating]

  attribute :string, :string
  attribute :nylas_date, :nylas_date
  attribute :email_address, :email_address
  attribute :im_address, :im_address
  attribute :phone_number, :phone_number
  attribute :web_page, :web_page

  has_n_of_attribute :web_pages, :web_page
end

class NonSearchableModel < FullModel
  include Nylas::Model
  self.searchable = false
  self.resources_path = "/non_searchable_collection"

  attribute :id, :string, exclude_when: [:creating, :updating]

  attribute :string, :string
  attribute :nylas_date, :nylas_date
  attribute :email_address, :email_address
  attribute :im_address, :im_address
  attribute :phone_number, :phone_number
  attribute :web_page, :web_page

  has_n_of_attribute :web_pages, :web_page
end
