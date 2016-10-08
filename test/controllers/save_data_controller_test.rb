require 'test_helper'

class SaveDataControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get save_data_index_url
    assert_response :success
  end

end
