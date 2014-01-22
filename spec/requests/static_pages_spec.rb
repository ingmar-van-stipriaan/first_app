require 'spec_helper'

describe "StaticPages" do
  
  subject { page }

  describe "Home page" do
    before { visit root_path }
    it { should have_selector('h1', :text => 'First App') }
    it { should_not have_selector('title', :text => full_title(" ") ) }
  
    describe "for signedin users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, :user => user, :content => "Lorem ipsum")
        FactoryGirl.create(:micropost, :user => user, :content => "Droks ipsum")
        sign_in user
        visit root_path
      end

      it "should render the users feed" do
        user.feed.each do |item|
          page.should have_selector("div", :id => item.id )
        end
      end
    end

  end

  describe "Help page" do
    before { visit help_path }
    it { should have_selector('h1', :text => 'Help') }
    it { should have_selector('title', :text => full_title("Help")) }
  end

  describe "About page" do
    before { visit about_path }
    it { should have_selector('h1', :text => 'About us') }
    it { should have_selector('title', :text => full_title("About us")) }
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', :text => full_title("About us")
    click_link "Help"
    page.should have_selector 'title', :text => full_title("Help")
    click_link "Home"
    click_link "Sign up"
    page.should have_selector 'title', :text => full_title("Sign up")
  end
end
