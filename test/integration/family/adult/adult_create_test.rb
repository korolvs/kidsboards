require 'test_helper'

class Family::AdultCreateTest < ActionDispatch::IntegrationTest

  test 'adult create success' do
    # prepare
    token = login

    # action
    name = Faker::Name.name
    url = Faker::Internet.url
    post '/api/v1/family/adult', token: token, name: name, photo_url: url

    # check results
    assert_response :success
    json = JSON.parse(response.body)
    id = json['id']
    adult = Family::Adult.where(id: id).first
    assert_not_nil adult
    assert_equal name, adult.name
    assert_equal url, adult.photo_url
  end

  test 'adult create wrong params' do
    # prepare
    token = login

    # action 1
    post '/api/v1/family/adult', token: token

    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['name'], 'can\'t be blank'

    # action 2
    name = Faker::Lorem.characters(300)
    url = 'fqweeqw'
    post '/api/v1/family/adult', token: token, name: name, photo_url: url

    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['name'], 'is too long (maximum is 50 characters)'
    assert_includes json['photo_url'], 'is a bad uri'

    # action 3
    name = Faker::Lorem.characters(300)
    url = 'ftp://asdasd.ru'
    post '/api/v1/family/adult', token: token, name: name, photo_url: url

    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['name'], 'is too long (maximum is 50 characters)'
    assert_includes json['photo_url'], 'has wrong protocol (use http or https)'
  end

  test 'adult create fail wrong token' do
    # prepare
    token = Faker::Lorem.characters(10)

    # action
    name = Faker::Name.name
    url = Faker::Internet.url
    post '/api/v1/family/adult', token: token, name: name, photo_url: url

    # check results
    assert_response 401
  end

  test 'adult create fail without token' do
    # action
    name = Faker::Name.name
    url = Faker::Internet.url
    post '/api/v1/family/adult', name: name, photo_url: url

    # check results
    assert_response 401
  end
end