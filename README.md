# Yst

Integration test scenarios executor ;)


## How to run


  1. Production version `bin/build prod` and then just `MIX_ENV=prod ./yst`

  or

  2. Run under iex REPL:

    ```bash
    bin/fetch_deps
    bin/console
    ```

    under console call `Yst.run` to run main module. By default under :dev mode
    code will be recompiled on the fly and hot swapped by BEAM VM.

  or

  3. Run with tests:

    ```bash
    bin/test
    ```
