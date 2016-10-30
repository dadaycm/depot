require 'test_helper'

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_item = line_items(:one)
  end

  test "should get index" do
    get line_items_url
    assert_response :success
  end

  test "should get new" do
    get new_line_item_url
    assert_response :success
  end

  test "should create line_item" do
    assert_difference('LineItem.count') do
      post line_items_url, params: { product_id: products(:ruby).id }
    end
    follow_redirect!
    assert_select 'h2', 'Your Cart'
    assert_select 'td', "Programming Ruby 1.9"
  end

  test "should create line_item via ajax" do
    assert_difference('LineItem.count') do
      post line_items_url, params: { product_id: products(:ruby).id },
          xhr:true
    end
    assert_response :success
    assert_select_jquery :html, '#cart' do
      assert_select 'tr#current_item td', /Programming Ruby 1.9/
    end
  end

  test "should show line_item" do
    get line_item_url(@line_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_line_item_url(@line_item)
    assert_response :success
  end

  test "should update line_item" do
    patch line_item_url(@line_item),
        params: { line_item: { product_id: @line_item.product_id } }
    assert_redirected_to line_item_url(@line_item)
  end

  test "should destroy line_item" do
    assert_difference('LineItem.count', -1) do
      delete line_item_url(@line_item)
    end

    assert_redirected_to line_items_url
  end

  test 'should minus 1 for quantity >1' do
    @line_item.quantity = 3
    @line_item.save

    # p "[before minus:] #{@line_item.inspect}"
    assert_difference('@line_item.quantity' , -1) do
      put minus_line_item_path(@line_item)
      @line_item.reload
    end

    assert_redirected_to line_items_url

    item = @line_item
    # p "[after minus:] #{item.inspect}" unless item.nil?
    assert_equal item.quantity, 2
  end

  test 'should destroy when minus one with quantity 1' do
    assert_difference('LineItem.count', -1) do
      put minus_line_item_path(@line_item)
    end
    assert_redirected_to line_items_url
  end

end
