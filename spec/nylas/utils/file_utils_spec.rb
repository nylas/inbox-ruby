# frozen_string_literal: true

describe Nylas::FileUtils do
  let(:mock_file) { instance_double("file") }

  describe "#attach_file_request_builder" do
    let(:file_path) { "/path/to/file.txt" }
    let(:file_size) { 100 }

    before do
      allow(File).to receive(:size).with(file_path).and_return(file_size)
      allow(File).to receive(:new).with(file_path, "rb").and_return(mock_file)
    end

    it "returns the correct request" do
      file_path = "/path/to/file.txt"

      attach_file_req = described_class.attach_file_request_builder(file_path)

      expect(attach_file_req).to eq(
        filename: "file.txt",
        content_type: "text/plain",
        size: 100,
        content: mock_file
      )
    end

    it "defaults the file type to octet-stream if it is not found" do
      file_path = "/path/to/file.txt"
      file_size = 100

      allow(MIME::Types).to receive(:type_for).with(file_path).and_return(nil)

      attach_file_req = described_class.attach_file_request_builder(file_path)

      expect(attach_file_req).to eq(
        filename: "file.txt",
        content_type: "application/octet-stream",
        size: file_size,
        content: mock_file
      )
    end
  end

  describe "#build_form_request" do
    let(:attachment) do
      {
        filename: "file.txt",
        content_type: "text/plain",
        size: 100,
        content: mock_file
      }
    end
    let(:request_body) do
      {
        to: [{ email: "test@gmail.com" }],
        subject: "test",
        body: "test"
      }
    end

    it "returns builds the correct form request" do
      request_body_with_attachment = request_body.merge(attachments: [attachment])
      expected_response_form = {
        "multipart" => true,
        "message" => request_body.to_json,
        "file0" => mock_file
      }

      form_request = described_class.build_form_request(request_body_with_attachment)

      expect(form_request).to eq([expected_response_form, [mock_file]])
    end

    it "returns the correct form request when there are no attachments" do
      form_request = described_class.build_form_request(request_body)

      expect(form_request).to eq([request_body, []])
    end
  end

  describe "#build_json_request" do
    let(:mock_file) { instance_double("file") }

    it "encodes the content of each attachment" do
      allow(mock_file).to receive(:read).and_return("file content")
      attachments = [{ content: mock_file }]

      result, opened_files = described_class.build_json_request(attachments)

      expect(result.first[:content]).to eq(Base64.encode64("file content"))
      expect(opened_files).to include(mock_file)
    end

    it "skips attachments with no content" do
      attachments = [{ content: nil }]

      result, opened_files = described_class.build_json_request(attachments)

      expect(result.first[:content]).to be_nil
      expect(opened_files).to be_empty
    end

    it "returns empty arrays when attachments are empty" do
      attachments = []

      result, opened_files = described_class.build_json_request(attachments)

      expect(result).to eq([])
      expect(opened_files).to eq([])
    end

    it "handles multiple attachments" do
      mock_file1 = instance_double("file1")
      mock_file2 = instance_double("file2")
      allow(mock_file1).to receive(:read).and_return("file content 1")
      allow(mock_file2).to receive(:read).and_return("file content 2")
      attachments = [{ content: mock_file1 }, { content: mock_file2 }]

      result, opened_files = described_class.build_json_request(attachments)

      expect(result[0][:content]).to eq(Base64.encode64("file content 1"))
      expect(result[1][:content]).to eq(Base64.encode64("file content 2"))
      expect(opened_files).to include(mock_file1, mock_file2)
    end
  end
end
