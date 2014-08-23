# ken mcfadden tealeaf course1 lesson 3
# Sinatra blackjack

require 'sinatra'
require 'pry'

set :sessions, true

helpers do

  def card_image(card)
    count = 0
    suit = case card[0]
             when 'hearts' then 'hearts'
             when 'diamonds' then 'diamonds'
             when 'clubs' then 'clubs'
             when 'spades' then 'spades'
           end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
                when 'J' then 'jack'
                when 'Q' then 'queen'
                when 'K' then 'king'
                when 'A' then 'ace'
              end
    end

    # return our HTML image element.
      "<img src='/images/cards/#{suit}_#{value}.jpg' class= 'card_image'>"

  end

  def get_hand_total(hand)

   card_values = hand.map{|index| index[1]}

  total = 0

   card_values.each do |x|
     if x == "A"
      total += 11
     else
      total += x.to_i == 0 ? 10 : x.to_i
     end
   end

    card_values.select{|face| face == "A"}.count.times do
      break if total <= 21
      total -= 10
    end

     total

  end

  def check_player_status(total_hand)
    # receives hand-total session value
    if total_hand > 21
      @player_status = "BUSTED"
    elsif total_hand == 21
      @player_status = "BLACKJACK"
    elsif
      session[:player_stands] == true
      @player_status = "stand"
    else
      @player_status = "in-play"
    end
      @player_status
  end

  def check_house_status(total_hand)
    # receives hand-total session value
    if total_hand > 21
      @house_status = "BUSTED"
    elsif total_hand == 21
      @house_status = "BLACKJACK"
    else
      @house_status = "in-play"
    end
    @house_status
  end


  def house_AI(house,player)

      @house_next_play = "hit"

    if house < 17 && house <= player

      @house_next_play = "hit"

    elsif house > player

      @house_next_play = "stand"

    end
    @house_next_play
  end


  def check_game_status
    # return game status flag and set game over session var
    # x = inplay
    # 0 = push
    # 1 = Player Blackjack
    # 2 = Dealer Blackjack
    # 3 = Player Bust
    # 4 = House Bust
    # 5 = player stands, but house wins on total

    @game_status = []
    @game_status[0]  = "x"
    @game_status[1]  = "Fred Sanford called me a dummy."

    if  session[:house_hand_total] == 21 && session[:player_hand_total] == 21
        @game_status[0] = "0" #push
        @game_status[1] = "Games ends in a push. Both house and player have Blackjack!"
    elsif
        session[:house_hand_total] >= 22 and session[:player_hand_total] >= 22
        @game_status[0] =  "0"  #push
        @game_status[1] = "Games ends in a push. Both house and player have Busted!"
    elsif
        session[:player_hand_total] == 21
        @game_status[0] =  "1"
        @game_status[1] = "Player wins! Blackjack!"
    elsif
        session[:house_hand_total] == 21
         @game_status[0] =  "2"
         @game_status[1] = "House wins! Blackjack!"
    elsif
        session[:player_hand_total] >= 22
        @game_status[0] = "3"
        @game_status[1] = "House wins on player Bust!"
    elsif
    session[:house_hand_total] >= 22
        @game_status[0] =  "4"
        @game_status[1] = "Player wins on house Bust!"
    elsif
    session[:player_stands] == true && session[:house_hand_total] > session[:player_hand_total]
         @game_status[0] =  "5"
         @game_status[1] = "House wins with greater total hand!"
     end

    @game_status

  end

end  # helper do

# entry point into the game is root.
get '/' do
  session[:username] = ""
    if session[:username] == ""
      redirect '/new_player'
    else
      redirect '/start_game'
    end
end

get '/new_player'  do
  erb :form_new_player
end

post '/new_player_validate' do

  if params[:username] =~ /\w/
       session[:username] = params[:username]
       redirect '/start_game'
  else
       @error = "Please enter your player name to start the game."
       erb :form_new_player
  end
end

get '/start_game' do

  SUITS = %w{hearts diamonds spades clubs}
  FACES = %w{2 3 4 5 6 7 8 9 10 J Q K A}
  session[:deck]= SUITS.product(FACES).shuffle!

  session[:player_hand] = []
  session[:house_hand]  = []

  session[:player_hand] << session[:deck].pop
  session[:house_hand]  << session[:deck].pop

  session[:player_hand] << session[:deck].pop
  session[:house_hand]  << session[:deck].pop

  session[:player_bank]    = 500
  session[:player_balance] = 0

  session[:player_stands] = false
  session[:house_stands]  = false

  session[:house_hand_total]  = 0
  session[:player_hand_total] = 0

  session[:player_hand_total] = get_hand_total(session[:player_hand])
  session[:house_hand_total]  = get_hand_total(session[:house_hand])

  session[:whose_turn] = "player"

  session[:game_over]  = false

  session[:first_time_here] = true

  redirect '/game_show'
end

get '/game_show'  do

  @house_status = check_house_status(session[:house_hand_total])
  @player_status = check_player_status(session[:player_hand_total])

  if session[:first_time_here]
    #if per chance house won on first draw.
       @game_status = check_game_status
    if @game_status[0] == "0" || @game_status[0] == "2"
        session[:game_over]  = true
        session[:whose_turn]  = "dealer"
        @hide_buttons = true
        @show_dealer_button = false
        @game_show_message = @game_status[1]
        @game_show_message = "As luck would have it, you lost right out of the starting gate!"
        session[:whose_turn] = "gameover"
    end
  end

    session[:first_time_here] = false


    if session[:whose_turn] == "player"

      if @player_status == "in-play"
        @hide_buttons = false
        @show_dealer_button = false
        @game_show_message = "GAME OPTIONS : HIT for another card / STAND to hold / QUIT to exit game."

      elsif @player_status == "stand"
        @hide_buttons = true
        @show_dealer_button = true
        session[:whose_turn]  = "dealer"
        @game_show_message = "You have chosen to Stand. It is now the Dealer's play.  Click button."

      elsif @player_status == "BLACKJACK"
        @hide_buttons = true
        @show_dealer_button = true
        session[:whose_turn]  = "dealer"
        @game_show_message = "You currently are holding a Blackjack hand. It is now the Dealer's play. Click button."

      elsif @player_status == "BUSTED"
        @hide_buttons = true
        @show_dealer_button = true
        session[:whose_turn]  = "dealer"
        @game_show_message = "You have Busted at this point.  It is now the Dealer's play.  Click the Dealer button."
      end

    elsif  session[:whose_turn] == "dealer"

      while session[:game_over] == false

        @house_next_play = house_AI(session[:house_hand_total],session[:player_hand_total])

        if @house_next_play == "hit"

          session[:house_hand]  << session[:deck].pop
          @show_dealer_button = false
          @hide_buttons = true

        elsif  @house_next_play == "stand"
          session[:house_stands] = true
          session[:game_over] = true
          @show_dealer_button = false
          @hide_buttons = true
       end

        session[:house_hand_total]  = get_hand_total(session[:house_hand])

        @house_status = check_house_status(session[:house_hand_total])

        @game_status = check_game_status
          if @game_status[0] != "x"
             session[:game_over] = true
             @show_dealer_button = false
             @hide_buttons = true
             @game_show_message = @game_status[1]
          end

      end   #while


    end  #turn

    erb :game_show

end  #get do


post '/form_player_hit' do
  session[:player_hand] << session[:deck].pop
  session[:player_hand_total] = get_hand_total(session[:player_hand])
  redirect '/game_show'
end

post '/form_player_stand' do
  session[:player_stands] = true
  redirect '/game_show'
end

post '/form_dealer_button' do
  session[:whose_turn] = "dealer"
  redirect '/game_show'
end

post '/form_player_quit' do
  session.clear
  redirect '/'
end

not_found do
  "Somehow you fell thru to me..there are no matching routes."
end
