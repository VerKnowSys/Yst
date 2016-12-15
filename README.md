# Yst

Integration test scenarios executor - PoC ;)


## What am I looking at? :o

Under the hood we're spawning a browser (PhantomJS 2.1+) in "WebDriver" mode.
This way we take full control over a headless browser, to perform site integration testing.

Currently the PoC code logins to Silk backend playground and performs some read only checks (existence of text patterns or site elements).


## Requirements

  0. macOS 10.11+ or Linux
  1. Elixir 1.3+
  2. Erlang OTP 19+
  3. tmux (phantomjs is spawned under tmux session by default)


## How to run

  0. By default Yst is using these environment variables to access remote demo site.

    ```bash
    YS_URL    # Default url of tested site
    YS_LOGIN  # Login used to get to the Silk panel
    YS_PASS   # Password used to get to the Silk panel
    ```

  1. Production version `bin/build prod` and then just `env YS_URL="myshiny.site.com" YS_LOGIN="ys" YS_PASS="*******" MIX_ENV=prod ./yst`

  or

  2. Run under iex REPL:

    ```bash
    bin/fetch_deps
    bin/console
    ```

    under console call `Yst.run` to run main module. By default under :dev mode
    code will be recompiled on the fly and hot swapped by BEAM VM.

    ![Example console output](http://s.verknowsys.com/d3abbc036b823cd78d1007b5cc007367.png)

  or

  3. Tests also perform content checks (details in: [yst_test.exs](https://github.com/centrahq/yst/blob/master/test/yst_test.exs)):

    ```bash
    bin/test
    ```
