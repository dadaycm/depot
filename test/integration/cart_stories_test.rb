require 'test_helper'
include CurrentCart

class CartStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'Add 2 products with different quantity to cart ' do
    ruby_book = products(:ruby)
    python_book = products(:python)

    get "/"
    assert_response :success
    assert_select 'h1', "Your Pragmatic Catalog"

    puts "add first product(ruby) with quantity 1"
    post '/line_items', params: { product_id: ruby_book.id }, xhr: true
    assert_response :success

    set_cart

    assert_equal 1, @cart.line_items.size
    assert_equal 1, @cart.line_items[0].quantity
    assert_equal ruby_book, @cart.line_items[0].product
    p @cart.line_items

    puts "add quantity with existing product"
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

    puts "add the second product(python) with quantity 1"
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

  end

end
