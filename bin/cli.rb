require_relative '../config/environment'

class Interface
  #gets & sets // read & write
  attr_accessor :prompt, :user

  def initialize()
    @prompt = TTY::Prompt.new
    @user = {}
  end

  #login allows choices to create acct or use old acct
  def login
    system "clear"# clear log // cleaner look
    @prompt.select("LOGIN OR CREATE A NEW ACCOUNT") do |menu|
      menu.choice "LOGIN", -> {old_user()}
      menu.choice "CREATE ACCOUNT", -> {new_user()}
      menu.choice "EXIT", -> {exit_program()}
    end
  end

  #creation of new acct
  def new_user
    system "clear"
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

  #existing users can login
  def old_user
    system"clear"
    user_email = @prompt.ask("What is your email?")
    #checkr to see if actual user exists
    if User.find_by(email: user_email) == nil
      @prompt.say("NOT IN SYSTEM! CREATE A NEW ACCOUNT!")
      new_user()
    else
      #look up existing user
      @user = User.find_by(email: user_email)
      #greet user upon login
      @prompt.say("WELCOME BACK #{@user[:name]}!".upcase)
      sleep(2)
    end
    #once complete navigates to main menu
    main_menu()
  end

  #creation of main menu layout
  def main_menu
    system "clear"
    @prompt.select("WHAT WOULD YOU LIKE TO DO #{@user[:name]}?") do |menu|
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

  # buy clothes helper method [map]
  def clothing_stock
    Clothing.all.map do |clothing|
        clothing.name
    end
  end

  def buy_clothes
   system "clear"
   clothing = [clothing_stock]
   clothing << "BACK"
   #stores shouldnt force you to buy things so this ^^
   #allows there to be a menu button at the very bottom of list
   #to go "back" without buying anything
   buy = @prompt.select("HERE'S WHAT WE HAVE IN STOCK #{@user[:name]}.", clothing) 
    if buy == "BACK"
        main_menu()
    end
   item = Clothing.find_by(name: buy)
   UsersClothe.create(user_id: @user.id, clothing_id: item.id)
   main_menu()
  end

  #enters closet / create closet layout
  def closet
    system "clear"
     @prompt.select("HEY #{@user[:name]}, YOU'RE INSIDE YR CLOSET!") do |menu|
        menu.choice "VIEW CLOTHING", -> {closet2}
        menu.choice "DONATE CLOTHING", ->{donate}
        menu.choice "BACK", ->{back}
    end
  end

  #closet helper method :(
  def closet_helper
    system "clear"
     clothing_items = @user.clothings.map do |clothing|
        clothing.name
     end 
    clothing_items
  end

  # nested closet2 grants access to items in closet
  #where we can view the items we actually own
  def closet2
    system "clear"
    clothing = [closet_helper]
    clothing << "BACK"
    ggg = @prompt.select("HERE'S WHAT YOU OWN #{@user[:name]}!", clothing)
    ##adds menu button to bottom of list to go back
    if ggg == "BACK"
      main_menu()
  end
  end


  #delete
  def donate
    system "clear"
    donation =  @prompt.select("HERES WHAT YOU OWN", [closet_helper])
    decision = @prompt.yes?("MY GUY, YOU SURE YOU WANNA DONATE #{donation}?")
    if decision
      #binding.pry
        # v is an "object"
        v = Clothing.find_by(name: donation)
        #gonzo is also an obj 
        gonzo = @user.users_clothes.find_by(clothing_id: v.id)
        gonzo.destroy
        system"clear"
        @prompt.say("86'd #{donation}")
        sleep(2)
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
        new_name = @prompt.ask('WHAT WOULD YOU LIKE TO CHANGE YOUR NAME TO?')
        @prompt.say("NAME SUCCESSFULLY CHANGED")
        sleep(1.7)
      #this code was missing last time
      #actually updates the current users name and persists
      @user.update(name: new_name)
      main_menu()
  end

  #updating ftw
  def change_email
        new_email = @prompt.ask('WHAT WOULD YOU LIKE TO CHANGE YOUR EMAIL TO?')
        @prompt.say("EMAIL SUCCESSFULLY CHANGED")
        sleep(1)
      @user.update(email: new_email)
      main_menu()
  end

  #are we done yet?!
  def exit_program
    @prompt.say("Goodbye!")
    exit!
  end

end