require 'test_helper'
include CurrentCart

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cart = carts(:one)
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

  test 'should minus 1 for quantity >1 via ajax' do
    # set_cart
    @line_item.quantity = 3
    @line_item.save

    assert_difference('@line_item.quantity' , -1) do
      put minus_line_item_path(@line_item), xhr:true
      @line_item.reload
    end

    # assert_response :success
    # assert_select_jquery :html, '#cart' do
    #   assert_select 'tr#current_item td', /My String/
    # end
    item = @line_item
    assert_equal item.quantity, 2

    # mycart = css_select("#cart")
    # puts "length of mycart=#{mycart.length}"
    # mycart.each do |c|
    #   p c
    #   tr = css_select(c, "tr")
    #   p tr
    #   logger.debug("[tr=]#{tr}")
    #   assert_select 'tr#current_item td', '2'
    #   assert_select 'tr#current_item td', ''
    #
    # end

  end

  test 'should destroy when minus one with quantity 1' do
    assert_difference('LineItem.count', -1) do
      put minus_line_item_path(@line_item)
    end
    assert_redirected_to line_items_url
  end

  test 'should empty cart when last line item is minused to 0' do
    # set_cart
    get store_index_url

    @line_item.quantity = 3
    @line_item.save
    put minus_line_item_path(@line_item)
    follow_redirect!

    @line_item.reload
    assert_equal @line_item.quantity, 2

    assert_select "#columns > #side > #cart"
    carts=css_select "#columns > #side > #cart"
    puts "\nquantity=2 : carts.length=#{carts.length}"
    p carts

    put minus_line_item_path(@line_item)
    put minus_line_item_path(@line_item)
    # @line_item.reload
    # assert_equal @line_item.quantity, 0

    follow_redirect!

    # assert_select "#columns #side #cart [style=?]", "display: none;", count:1
    # assert_select "div[id=cart][style=?]", ".display: none;", count:1
    # assert_select "div[id=cart][style*=?]", "display", count:1

    assert_select "#columns > #side > #cart"
    carts=css_select "#columns > #side > #cart"
    puts "\nquantity=0 : carts.length=#{carts.length}"
    p carts

  end
end
