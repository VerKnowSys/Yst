# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config


# Yst defaults:
config :yst, scene_timeout: 360000
config :yst, result_timeout: 30000


# Hound defaults:
config :hound, driver: "phantomjs"


# Logger defaults:
config :logger, level: :debug, truncate: 2048
config :logger, :console, format: "$time|$levelpad$message\n"
