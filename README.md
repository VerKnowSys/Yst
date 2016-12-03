# Yst

Integration test scenarios executor ;)


## How to run

  0. By default Yst is using this environment variables to access remote demo site.

    ```bash
    YS_URL    # Default url of tested site
    YS_LOGIN  # Login used to get to the Silk panel
    YS_PASS   # Password used to get to the Silk panel
    ```

  1. Production version `bin/build prod` and then just `MIX_ENV=prod ./yst`

  or

  2. Run under iex REPL:

    ```bash
    bin/fetch_deps
    bin/console
    ```

    under console call `Yst.run` to run main module. By default under :dev mode
    code will be recompiled on the fly and hot swapped by BEAM VM.

    ![Example console output](http://s.verknowsys.com/231f7067c0ed3f169b4b1d0992350ada.png)

  or

  3. Tests also perform content checks (details in: [yst_test.exs](https://github.com/centrahq/yst/blob/master/test/yst_test.exs)):

    ```bash
    bin/test
    ```
