require_relative '../config/environment'

class Interface
  #gets & sets // read & write
  attr_accessor :prompt, :user

  def initialize()
    @prompt = TTY::Prompt.new
    @user = {}
  end

  def login
    system "clear"# clear log // cleaner look
    @prompt.select("LOGIN OR CREATE A NEW ACCOUNT") do |menu|
      menu.choice "LOGIN", -> {old_user()}
      menu.choice "CREATE ACCOUNT", -> {new_user()}
      menu.choice "EXIT", -> {exit_program()}
    end
  end

  def new_user
    @prompt.say("I needz more info")
    @user = @prompt.collect do
      key(:name).ask('ENTER YOUR NAME?')
      key(:email).ask('ENTER YOUR EMAIL?')
    end

    ## this was fun... saving the new creation of user allowed me to create a new
    ## user, then purchase new items without having to go back and log new user in
    @user= User.create(@user)
    main_menu()
  end

  def old_user
    user_email = @prompt.ask("What is your email?")
    if User.find_by(email: user_email) == nil
      @prompt.say("NOT IN SYSTEM! CREATE A NEW ACCOUNT!")
      new_user()
    else
      @user = User.find_by(email: user_email)
      @prompt.say("WELCOME BACK #{@user[:name]}".upcase)
    end
    main_menu()
  end

  def main_menu
    system "clear"
    @prompt.select("WHAT WOULD YOU LIKE TO DO #{@user[:name]}") do |menu|
      menu.choice "SEE YOUR CLOSET", -> {closet()}
      menu.choice "BUY CLOTHING", -> {buy_clothes()}
      menu.choice "SETTINGS", -> {settings()}
      menu.choice "EXIT", -> {login()}
    end
  end

  #creation of back button for use throughout menu
  def back
      main_menu()
  end

  # buy clothes helper method
  def clothing_stock
    Clothing.all.map do |clothing|
        clothing.name
    end
  end

  def buy_clothes
   system "clear"
   clothing = [clothing_stock]
   clothing << "MAIN MENU"
   #allows there to be a menu button at the very bottom of list
   #to go "back" without buying anything
   buy = @prompt.select("HERES WHAT WE HAVE IN STOCK", clothing) 
    if buy == "MAIN MENU"
        main_menu()
    end
   item = Clothing.find_by(name: buy)
   Users_Clothes.create(user_id: @user.id, clothing_id: item.id)
   main_menu()
  end

  #enters closet
  def closet
    system "clear"
     @prompt.select("HEY #{@user[:name]}, WHAT WOULD YOU LIKE TO DO?") do |menu|
        menu.choice "SEE YOUR ITEMS", -> {closet2}
        menu.choice "DONATE", ->{donate}
        menu.choice "BACK", ->{back}
    end
  end

  #closet helper method
  def closet_helper
    system "clear"
    user_clothing_array = Users_Clothes.select do |user_clothes|
        user_clothes.user_id == @user.id
    end # returns an array of all user_clothing items that belong to the user

    clothing_items = user_clothing_array.map do |user_clothes|
        #binding.pry
        Clothing.find_by(id: user_clothes.clothing_id).name
    end # returns an array of all the clothing item id's in user_clothing_array
    clothing_items
  end
  
  # nested closet2 grants access to items in closet
  def closet2
    clothing = [closet_helper]
    clothing << "MAIN MENU"
    ggg = @prompt.select("HERES WHAT YOU OWN", clothing)
    ##adds menu button to bottom of list to go back
    if ggg == "MAIN MENU"
      main_menu()
  end
  end

  def donate
    donation =  @prompt.select("HERES WHAT YOU OWN", [closet_helper])
    decision = @prompt.yes?("MY GUY, YOU SURE YOU WANNA DONATE #{donation}?")
    if decision
      #binding.pry
        # v is an "object" lord let me never forget it
        v = Clothing.find_by(name: donation)
        gonzo = Users_Clothes.find_by(clothing_id: v.id)
        gonzo.destroy
        @prompt.say("86'd #{donation}")
        main_menu()
    else
        main_menu() 
    end
  end

  #updating ftw
  def settings
    @prompt.select("SETTINGS") do |menu|
        menu.choice "CHANGE YOUR NAME", -> {change_name()}
        menu.choice "CHANGE YOUR EMAIL", -> {change_email()}
        menu.choice "BACK", -> {back()}
    end
  end

  #updating ftw
  def change_name
    @user = @prompt.collect do
        key(:name).ask('WHAT WOULD YOU LIKE TO CHANGE YOUR NAME TO?')
        @prompt.say("NAME SUCCESSFULLY CHANGED")
        sleep(1.7)
      end
      main_menu()
  end

  #updating ftw
  def change_email
    @user = @prompt.collect do
        key(:email).ask('WHAT WOULD YOU LIKE TO CHANGE YOUR EMAIL TO?')
        @prompt.say("EMAIL SUCCESSFULLY CHANGED")
        sleep(1.7)
      end
      main_menu()
  end

  #are we done yet?!
  def exit_program
    @prompt.say("Goodbye!")
    exit!
  end

end