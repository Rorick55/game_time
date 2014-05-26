require 'sinatra'
require 'csv'
require 'pry'
require 'shotgun'


def games_breakdown
  games_array = []
  CSV.foreach('football_teams.csv', headers: true) do |row|
    game_hash = {
      home_team: row["home_team"],
      away_team: row["away_team"],
      home_score: row["home_score"],
      away_score: row["away_score"]
    }
    games_array << game_hash
  end
  games_array
end

def wins_losses(games)
  games_array = games
  wins_losses = {}
  games_array.each do |game|
    home = game[:home_team]
    away = game[:away_team]
    if game[:home_score].to_i > game[:away_score].to_i
      if !wins_losses.include? home
        wins_losses[home] = {wins: 1, losses: 0}
      else
         wins_losses[home][:wins] += 1
      end
      if !wins_losses.include? away
        wins_losses[away] = {wins: 0, losses: 1}
      else
         wins_losses[away][:losses] += 1
      end
    elsif game[:home_score].to_i < game[:away_score].to_i
       if !wins_losses.include? away
        wins_losses[away] = {wins: 1, losses: 0}
      else
         wins_losses[away][:wins] += 1
      end
      if !wins_losses.include? home
        wins_losses[home] = {wins: 0, losses: 1}
      else
         wins_losses[home][:losses] += 1
      end
    end
  end
  wins_losses
end

def sorted_leaderboard(hash)
  sorted_wins = hash.sort_by {|team,value| value[:losses]}
  sorted_losses = sorted_wins.sort_by {|team,value| value[:wins]}
  sorted_losses.reverse
end

get '/' do
  @wins_losses = sorted_leaderboard(wins_losses(games_breakdown))
    erb :index
end

get '/leaderboard' do
  @wins_losses = sorted_leaderboard(wins_losses(games_breakdown))
    erb :leaderboard
end

get '/teams/:team' do
  @wins_losses = sorted_leaderboard(wins_losses(games_breakdown))
  @games_breakdown = games_breakdown
    erb :teams
end
