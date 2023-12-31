(module
        (export "fib" (func $fib))
        (func $fib (; 0 ;) (param $0 i32) (result i32)
                (local $1 i32)
                (local $2 i32)
                (local $3 i32)
                (local $4 i32)
                (set_local $4
                        (i32.const 1)
                )
                (block $label$0
                        (br_if $label$0
                                (i32.lt_s
                                        (get_local $0)
                                        (i32.const 1)
                                )
                        )
                        (set_local $3
                                (i32.const 0)
                        )
                        (loop $label$1
                                (set_local $1
                                        (i32.add
                                                (get_local $3)
                                                (get_local $4)
                                        )
                                )
                                (set_local $2
                                        (get_local $4)
                                )
                                (set_local $3
                                        (get_local $4)
                                )
                                (set_local $4
                                        get_local $1)
                                )
                                (br_if $label$1
                                        (tee_local $0
                                                (i32.add
                                                        (get_local $0)
                                                        (i32.const -1)
                                                )
                                        )
                                )
                        )
                        (return
                                (get_local $2)
                        )
                )
                (i32.const 0)
        )
)