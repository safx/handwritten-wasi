(component
  (import "wasi:io/error@0.2.0" (instance $wasi_io_error 
    (export "error" (type (sub resource)))
  ))
  (alias export $wasi_io_error "error" (type $error_type))

  (import "wasi:io/streams@0.2.0" (instance $wasi_io_stream
    (export $os "output-stream" (type (sub resource)))

    (export $err "error" (type (eq $error_type)))
    (type $errval (variant (case "last-operation-failed" (own $err)) (case "closed")))
    (export $error "stream-error" (type (eq $errval)))

    (export "[method]output-stream.write"
      (func
        (param "self" (borrow $os))
        (param "contents" (list u8))
        (result (result (error $error)))))
  ))
  (alias export $wasi_io_stream "output-stream" (type $output_stream_type))

  (import "wasi:cli/stdout@0.2.0" (instance $wasi_cli_stdout 
    (export $os "output-stream" (type (eq $output_stream_type)))
    (export "get-stdout" (func (result (own $os))))
  ))

  (core module $MemMod
    (memory (export "memory") 1)
    (data (i32.const 0) "Hello, world!\n")
  )
  (core instance $mem_mod (instantiate $MemMod))
  (alias core export $mem_mod "memory" (core memory $mem))

  (core func $get_stdout (canon lower (func $wasi_cli_stdout "get-stdout")))
  (core instance $core_cli_stdout
    (export "get-stdout" (func $get_stdout))
  )

  (core func $output_stream_write (canon lower (func $wasi_io_stream "[method]output-stream.write") (memory $mem)))
  (core instance $core_io_stream
    (export "[method]output-stream.write" (func $output_stream_write))
  )

  (core module $Mod
    (func $get_stdout (import "wasi:cli/stdout@0.2.0" "get-stdout") (result i32))
    (func $write (import "wasi:io/streams@0.2.0" "[method]output-stream.write") (param i32 i32 i32 i32))

    (func (export "mod-main") (result i32)
      (call $get_stdout)
      (i32.const 0)  ;; offset
      (i32.const 14) ;; length
      (i32.const 16) ;; return value
      (call $write)
      (i32.const 0))
  )

  (core instance $m (instantiate $Mod
    (with "wasi:cli/stdout@0.2.0" (instance $core_cli_stdout))
    (with "wasi:io/streams@0.2.0" (instance $core_io_stream))
  ))

  (func $main_lifted (result (result)) (canon lift (core func $m "mod-main")))

  (component $Comp
    (import "main" (func $g (result (result))))
    (export "run" (func $g))
  )

  (instance $c (instantiate $Comp
      (with "main" (func $main_lifted)))
  )

  (export "wasi:cli/run@0.2.0" (instance $c))
)