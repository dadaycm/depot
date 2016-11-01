require 'test_helper'
include CurrentCart

class CartStoriesTest < ActionDispatch::IntegrationTest

  setup do
    @line_item = line_items(:one)
  end

  test 'should minus 1 for quantity >1' do
    puts "\n===should minus 1 for quantity >1"
    @line_item.quantity = 3
    @line_item.save

    puts "[before minus:] #{LineItem.all.inspect}"
    assert_difference('@line_item.quantity' , -1) do
      assert_no_difference('LineItem.count') do
        put minus_line_item_path(@line_item)
        @line_item.reload
      end
    end

    puts "[after minus:] #{LineItem.all.inspect}"

    assert_equal 2, @line_item.quantity
  end

  test 'should destroy when minus one with quantity 1' do
    puts "\n===should destroy when minus one with quantity 1"
    assert_difference('LineItem.count', -1) do
      put minus_line_item_path(@line_item)
    end
    puts "[after minus:] #{LineItem.all.inspect}"
    assert_redirected_to line_items_url
  end

  test 'traditional way: should empty cart when last line item is minused to 0' do
    puts "\n===[should empty cart when last line item is minused to 0"
    # set_cart
    get store_index_url

    puts "\n===put quantity to 3"

    @line_item.quantity = 3
    @line_item.save

    puts "\n===minus 1 from 3"
    put minus_line_item_path(@line_item)
    follow_redirect!


    @line_item.reload
    assert_equal @line_item.quantity, 2

    assert_select "#columns > #side > #cart"
    # assert_select "#columns > #side > #cart .fellow_item"
    # tds=css_select "#columns > #side > #cart"
    # tds.each do |t|
    #   lines = css_select(t, ".fellow_item")
    #   lines.each do |line|
    #     p lines
    #   end
    # end
    # puts "\nquantity=2 : tds.length=#{tds.length}"
    # p tds

    puts "\n===Two times minus 2 to 1, to 0"

    put minus_line_item_path(@line_item)
    put minus_line_item_path(@line_item)
    # @line_item.reload
    # assert_equal @line_item.quantity, 0

    follow_redirect!

    # assert_select "#columns #side #cart [style=?]", "display: none;", count:1
    # assert_select "div[id=cart][style=?]", ".display: none;", count:1
    # assert_select "div[id=cart][style*=?]", "display", count:1

    assert_select "#columns > #side > #cart", count:1
    carts=css_select "#columns > #side > #cart"
    puts "\nquantity=0 : carts.length=#{carts.length}"
    p carts

    puts "\n===should empty cart when last line item is minused to 0]"

  end


  test 'Ajax way -- Add 2 products with different quantity to cart, then minus' do
    puts "\n################################################################ CartStoriesTest: add"
    ruby_book = products(:ruby)
    python_book = products(:python)

    get "/"
    assert_response :success
    assert_select 'h1', "Your Pragmatic Catalog"

    puts "\n===add first product(ruby) with quantity 1"
    post '/line_items', params: { product_id: ruby_book.id }, xhr: true
    assert_response :success

    set_cart

    assert_equal 1, @cart.line_items.size
    assert_equal 1, @cart.line_items[0].quantity
    assert_equal ruby_book, @cart.line_items[0].product
    p @cart.line_items

    puts "\n===add quantity (from 1 to 2) with existing product(ruby)"
    post line_items_path, params:{ product_id: ruby_book.id },  xhr:true
    assert_response :success

    set_cart
    assert_equal 1, @cart.line_items.size
    assert_equal 2, @cart.line_items[0].quantity
    p @cart.line_items

    puts "\n===add quantity (from 2 to 3) with existing product(ruby)"
    post line_items_path, params:{ product_id: ruby_book.id },  xhr:true
    assert_response :success
    set_cart
    assert_equal 1, @cart.line_items.size
    assert_equal 3, @cart.line_items[0].quantity

    assert_select_jquery :html, '#cart' do
      assert_select 'tr#current_item td', /Programming Ruby 1.9/
      assert_select 'tr#current_item td', '3×'
      assert_select 'tr', count:2
    end

    puts "\n===add the second product(python) with quantity 1"
    assert_difference('LineItem.count') do
      post line_items_path, params: { product_id: products(:python).id },  xhr:true
    end
    assert_response :success

    set_cart
    p @cart.line_items

    assert_select_jquery :html, '#cart' do
      assert_select 'tr#current_item td', /Python Cookbook/
      assert_select 'tr#current_item td', '1×'
      assert_select 'tr td', /Programming Ruby 1.9/
      assert_select 'tr td', '3×'
      assert_select 'tr', count:3
    end

    assert_equal 2, @cart.line_items.size
    assert_equal python_book, @cart.line_items[1].product

    puts "\n################################################################ minus"
    get store_index_url

    puts "\n===minus one from ruby3, expect: quantity changed to 2"
    assert_no_difference('LineItem.count') do
      put minus_line_item_path(@cart.line_items[0]), xhr:true
    end
    assert_response :success

    set_cart
    p @cart.line_items

    assert_select_jquery :html, '#cart' do
      assert_select 'tr td', /Python Cookbook/
      assert_select 'tr td', '1×'
      assert_select 'tr#current_item td', /Programming Ruby 1.9/
      assert_select 'tr#current_item td', '2×'
      assert_select 'tr', count:3
    end

    puts "\n===minus one from python1, expect: line item python removed"
    assert_difference('LineItem.count', -1) do
      put minus_line_item_path(@cart.line_items[1]), xhr:true
    end
    assert_response :success

    set_cart
    p @cart.line_items

    assert_select_jquery :html, '#cart' do
      assert_select 'tr td', /Programming Ruby 1.9/
      assert_select 'tr td', '2×'
      assert_select 'tr#current_item td',false, 'no highlighted item'
      assert_select 'tr', count:2
    end


    puts "\n===minus one from ruby2,expect: quantity changed to 1"
    assert_no_difference('LineItem.count') do
      put minus_line_item_path(@cart.line_items[0]), xhr:true
    end
    assert_response :success

    # follow_redirect!  ## no works under ajax way

    set_cart
    assert_select_jquery :html, '#cart' do
      assert_select 'tr td', /Programming Ruby 1.9/
      assert_select 'tr td', '1×'
      assert_select 'tr', count:2
    end

    puts "\n===minus one from ruby1, expect:cart is empty"
    assert_difference('LineItem.count', -1) do
      put minus_line_item_path(@cart.line_items[0]), xhr:true
    end
    assert_response :success

    set_cart
    assert @cart.line_items.empty?
    assert_select_jquery :html, '#cart' do
      ###? how to express: style: display:none?/inline?
      assert_select 'tr', count:1  # only total_line
    end

    puts "\n################################################################ CartStoriesTest: over"

  end

end
