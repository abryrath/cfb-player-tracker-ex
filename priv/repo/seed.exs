alias PTracker.Crawler.Player
alias PTracker.Crawler.Manager


player_links = Manager.get_player_links()

IO.puts "#{Enum.count(player_links)} player links"

PTracker.Crawler.start_link([])
Player.start(player_links)
