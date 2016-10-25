require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    @update = {
      title:        'lushan',
      description:  'lushan pubu waterfall',
      image_url:    'lushan.jpg',
      price:        19.95
    }
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test 'should include actions from index' do
    get products_url

    assert_select 'a', 'New Product'
    assert_select '.list_actions', minimum:3

    actions = css_select(".list_actions")
    actions.each do |action|
      assert_select 'a', 'Show'
      assert_select 'a', 'Destroy'
      assert_select 'a', 'Edit'
    end

  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference('Product.count') do
      post products_url, params: {product: @update}
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: {product: @update}
    assert_redirected_to product_url(@product)
  end

  test 'Can not delete product in cart' do
    assert_difference( 'Product.count', 0 ) do
      delete product_url(products(:two))
    end
    assert_redirected_to products_url
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
