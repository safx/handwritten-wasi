(component
  (core module $Mod
    (func (export "mod-main") (result i32)
      (i32.const 0))
  )
  (core instance $m (instantiate $Mod))

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
