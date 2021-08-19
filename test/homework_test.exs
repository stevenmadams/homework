defmodule HomeworkTest do
  # Import helpers
  use Hound.Helpers
  use ExUnit.Case

  # Start hound session and destroy when tests are run
  hound_session()


  test "add and remove elements" do
    navigate_to "https://the-internet.herokuapp.com/add_remove_elements/"
      click({:xpath, "//button[text()='Add Element']"})
    assert(element?(:xpath, "//button[text()='Delete']"), "Delete button did not appear")
      click({:xpath, "//button[text()='Delete']"})
      delete_shown = element?(:xpath, "//button[text()='Delete']")
    assert(delete_shown == false, "Delete button was not removed from view")
  end

  test "hovers over" do
    navigate_to "https://the-internet.herokuapp.com/hovers"
    HomeworkTest.hover_all_users(3)
  end

  test "login test" do
    users = [
      invalidUsername: %{username: "baduser", password: "invalidPassword"},
      invalidPassword: %{username: "tomsmith", password: "invalidPassword"},
      validUser: %{username: "tomsmith", password: "SuperSecretPassword!"}
    ]
    navigate_to "https://the-internet.herokuapp.com/login"

    #invalid username test
      input_into_field({:id, "username"}, users[:invalidUsername].username)
      input_into_field({:id, "password"}, users[:invalidUsername].password)
      click({:xpath, "//button/i[contains(text(),' Login')]"})
    assert(element?(:xpath, "//div[contains(text(), 'Your username is invalid!')]"), "Invalid username alert did not appear")

    #invalid password test
      input_into_field({:id, "username"}, users[:invalidPassword].username)
      input_into_field({:id, "password"}, users[:invalidPassword].password)
      click({:xpath, "//button/i[contains(text(),' Login')]"})
    assert(element?(:xpath, "//div[contains(text(), 'Your password is invalid!')]"), "Invalid password alert did not appear")

    #valid user test
      input_into_field({:id, "username"}, users[:validUser].username)
      input_into_field({:id, "password"}, users[:validUser].password)
      click({:xpath, "//button/i[contains(text(),' Login')]"})
    assert(current_url() == "https://the-internet.herokuapp.com/secure", "User was not authenticated")
    assert(element?(:xpath, "//div[@id='flash'][contains(text(), 'You logged into a secure area!')]"), "Logged in banner did not appear")
      click({:xpath, "//a/i[contains(text(),'Logout')]"})
    assert(current_url() == "https://the-internet.herokuapp.com/login", "User was not logged out properly")
  end

  test "api post" do
    HTTPoison.start
    postUrl = "https://reqres.in/api/users"
    postData = '{"name": "morpheus","job": "leader"}'
    case HTTPoison.post(postUrl, postData) do
      {:ok, %HTTPoison.Response{status_code: 201}} ->
      IO.puts("API is working properly")
    end
  end


  # had fun learning how to do a loop for the hovers
  def hover_all_users(n) when n > 0 do
    figure_path = "//div[@class='figure'][#{n}]"
    text_path = "#{figure_path}/div[@class='figcaption']/h5"
    move_to({:xpath, figure_path}, 1, 1)
    userText = visible_text({:xpath, text_path})
    assert(userText=="name: user#{n}", "Hover text for user #{n} did not appear")
    hover_all_users(n - 1)
  end
  # was struggling with how to properly end the loop, loops in elixir are strange!
  def hover_all_users(0) do
  end

end
