require 'test_helper'
include CurrentCart

class CartStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'Add 2 products with different quantity to cart, then minus' do
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

    puts "\n===add quantity with existing product"
    post line_items_path, params:{ product_id: ruby_book.id },  xhr:true
    assert_response :success

    set_cart
    assert_equal 1, @cart.line_items.size
    assert_equal 2, @cart.line_items[0].quantity
    p @cart.line_items

    post line_items_path, params:{ product_id: ruby_book.id },  xhr:true
    assert_response :success
    set_cart
    assert_equal 1, @cart.line_items.size
    assert_equal 3, @cart.line_items[0].quantity

    assert_select_jquery :html, '#cart' do
      assert_select 'tr#current_item td', /Programming Ruby 1.9/
      assert_select 'tr#current_item td', '3×'
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
    end

    assert_equal 2, @cart.line_items.size
    assert_equal python_book, @cart.line_items[1].product

    puts "\n################################################################ minus"

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
    end


    puts "\n===minus one from ruby2,expect: quantity changed to 1"
    assert_no_difference('LineItem.count') do
      put minus_line_item_path(@cart.line_items[0]), xhr:true
    end
    assert_response :success

    set_cart
    assert_select_jquery :html, '#cart' do
      assert_select 'tr td', /Programming Ruby 1.9/
      assert_select 'tr td', '1×'
    end
    carts=css_select "#columns #side #cart"
    puts "\ncarts.length=#{carts.length}"
    p carts

    puts "\n===minus one from ruby1, expect:cart is empty"
    assert_difference('LineItem.count', -1) do
      put minus_line_item_path(@cart.line_items[0]), xhr:true
    end
    assert_response :success

    set_cart
    assert @cart.line_items.empty?

    carts=css_select "#columns #side #cart"
    puts "\ncarts.length=#{carts.length}"
    p carts

  end

end
