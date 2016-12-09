# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config


config :hound, driver: "phantomjs"
config :yst, scenarios_dir: "lib/scenes"

# config :yst, callmap: [
#     login: [
#       rel: "/login",
#       expected: [
#         {
#           ~r/SIGN IN/, [
#             parent_of: "somemore",
#             child_of: "container",
#             in_frame: "frame_1",
#             class: "some",
#             id: "uniqu3"
#           ]
#         },
#         ~r/Username/,
#         ~r/Password/
#       ],
#     ],

#     logout: [
#       rel: "/sign_out",
#       expected: [~r/SIGN IN/, ~r/Username/, ~r/Password/],
#     ],

#     sales: [
#       rel: "/retail/sales?q=status:3",
#       expected: [~r/Total/, ~r/Order/, ~r/Customer/, ~r/Total/],
#     ],

#     customers: [
#       rel: "/retail/customer?q=status:1",
#       expected: [~r/Orders/, ~r/Customer/, ~r/Total/, ~r/Created/],
#     ],
# ]

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :yst, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:yst, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
