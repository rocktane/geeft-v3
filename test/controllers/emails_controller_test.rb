require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get send_test_email" do
    get emails_send_test_email_url
    assert_response :success
  end
end
