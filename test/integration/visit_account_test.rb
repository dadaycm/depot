require 'test_helper'

class VisitAccountTest < ActionDispatch::IntegrationTest
  setup do
    @line_item = line_items(:one)
  end

  test 'Visit account should be shown when it is visited more than 3 times' do
    get store_index_url
    assert_select '#visit_account', 0
    get store_index_url
    get store_index_url
    assert_select '#visit_account', 'Category (store index page) has been visted 3 times'

    assert_difference('LineItem.count') do
      post line_items_url, params: { product_id: products(:ruby).id }
    end

    follow_redirect!
    assert_select '#visit_account', 0

  end

  test 'Vist count should be hidden when new item has been added to cart' do
    assert_difference('LineItem.count') do
      post line_items_url, params: { product_id: products(:ruby).id }
    end

    follow_redirect!
    assert_select '#visit_account', 0

  end

end
