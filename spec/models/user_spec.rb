require 'spec_helper'

describe User do
  before { @user = User.new(name: "example user", email: "example@example.com",
                            password: "foobar", password_confirmation: "foobar") }

  subject{ @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }

  it { should be_valid }
  it { should_not be_admin }

  describe "accessible attributes" do
    it "should not allow admin" do
      expect{ User.new(:admin => "1") }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it{ should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be valid" do
      addresses = %w[user@foo,com user_at_foo.org 
        example.user@foo. foo@bar_baz.com foor@ba+fa.com]
      addresses.each do |invalid_addresses|
        @user.email = invalid_addresses
        @user.should_not be_valid
      end
    end 
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org 
        first.last@foo.jp ]
      addresses.each do |valid_addresses|
        @user.email = valid_addresses
        @user.should be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesnt match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when password is too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should_not be_valid }
  end

  describe "return value of authenticate" do
    before { @user.save }
    let(:found_user) { User.find_by_email( @user.email ) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { 
        found_user.authenticate("invalid") 
      }
      it { should_not == user_for_invalid_password }
      specify{ user_for_invalid_password.should be_false }
    end

  end

  describe "remember_token" do
    before { @user.save }
    its(:remember_token){ should_not be_blank }
  end

  describe "association micropost" do
    
    before { @user.save }

    let!(:older_micropost) do
      FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago )
    end

    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, :user => @user, :created_at => 1.hour.ago )
    end

    it "should have microposts in the right order" do
      @user.microposts.should == [newer_micropost, older_micropost]
    end

    it "should destroy microposts associated" do
      microposts = @user.microposts
      @user.destroy
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, :user => FactoryGirl.create(:user) )
      end
      its(:feed) { should include(older_micropost) }
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
    end

  end

end
