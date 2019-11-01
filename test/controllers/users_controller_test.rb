require "test_helper"

describe UsersController do
  describe "index" do    
    it "responds with success when there is at least one user saved" do
      user = users(:ada)
      
      get users_path
      
      expect(User.count > 0).must_equal true
      must_respond_with :success      
    end
  end  
  
  describe "login" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count  
      user = users(:grace)
      
      perform_login(user)
      
      expect(flash[:success]).must_equal "Logged in as returning user #{user.name}"
      session[:user_id].must_equal user.id
      must_redirect_to root_path
      User.count.must_equal start_count
    end
    
    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com", name: "Tester")
      
      perform_login(user)
      
      expect(flash[:success]).must_equal "Logged in as new user #{user.name}"
      session[:user_id].must_equal User.last.id
      must_redirect_to root_path
      User.count.must_equal start_count + 1
    end
    
    it "redirects to the login route if given invalid user data" do
      start_count = User.count  
      bad_user = User.create(provider: "github", uid: 99999)
      
      perform_login(bad_user)
      
      expect(flash[:error]).must_include "Could not create new user account: "
      must_redirect_to root_path
      assert_nil(session[:user_id])
      User.count.must_equal start_count
    end
  end
  
  describe "show" do
  end
  
  describe "logout" do
    it "can log out a valid user and redirects to root" do
      start_count = User.count  
      user = users(:ada)
      
      perform_login(user)
      delete logout_path
      
      assert_nil(session[:user_id])
      expect(flash[:success]).must_equal "Successfully logged out!"
      must_redirect_to root_path
      User.count.must_equal start_count      
    end
    
    it "redirects to root if you try to log out, but nobody is logged in" do
      delete logout_path
      
      assert_nil(session[:user_id])
      must_redirect_to root_path      
    end
  end
end
