# frozen_string_literal: true

require "spec_helper"

describe Nylas::Model::Attributes do
  describe "#serialize_for_api" do
    it "rejects keys which are read_only" do
      test_json = {
        id: 1234,
        string: "a-test-string",
        read_only_attribute: "a read-only-attribute",
        multiple_read_only_attributes: [
          "read-only-value-1",
          "read-only-value-2"
        ]
      }.to_json
      api = double("API")
      instance = FullModel.from_json(test_json, api: api)

      result = instance.attributes.serialize_for_api

      expect(result).to eq(
        {
          id: "1234",
          string: "a-test-string"
        }.to_json
      )
    end
  end
end
