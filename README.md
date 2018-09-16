# Yst

Integration test scenarios executor - PoC ;)


## What am I looking at? :o

Under the hood we're spawning a browser (PhantomJS 2.1+) in "WebDriver" mode.
This way we take full control over a headless browser, to perform site integration testing.

Currently the PoC code logins to Silk backend playground and performs some read only checks (existence of text patterns or site elements).


## Requirements

  0. macOS 10.11+ or Linux
  1. Elixir 1.7+
  2. Erlang OTP 19+
  3. tmux (phantomjs is spawned under tmux session by default)


## How to run

  0. Yst reads environment variables from .env file located in this repository.

```bash
YS_URL    # Default url of tested site
YS_LOGIN  # Login used to get to the Silk panel
YS_PASS   # Password used to get to the Silk panel
```

  1. Edit your .env file and put missing value of `YS_PASS` there.

  2. Run production escript (:prod env):

```bash
bin/run
```

  3. Run under iex REPL (:dev env:

```bash
bin/console
```

    Then just:

```elixir
Yst.run
```

    to start main supervisor and launch checks.


    Example results (YS_PASS is NOT set):

![output1](http://s.verknowsys.com/5784efcc180134f5b1399027b5dd356e.png)


    Example results (YS_PASS is set):

![output2](http://s.verknowsys.com/ce0552cde39f3f9baad91ed788c7413e.png)


  4. Currently tests do internal testing. To test scenarios, go back to `Yst.run` part. (For details about internal tests look here: [yst_test.exs](https://github.com/centrahq/yst/blob/master/test/yst_test.exs)):

```bash
bin/test
```

## License

BSD/MIT
