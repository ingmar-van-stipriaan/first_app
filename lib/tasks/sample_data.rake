namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!( name: "ingmar", 
                  email: "ingmar@montblanc.nl",
                  password: "123456", 
                  password_confirmation: "123456" )
    admin.toggle!(:admin)
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@example.org"
      password = "123456"
      User.create!(name: name, email: email, password: password, password_confirmation: password )
    end
  end

end