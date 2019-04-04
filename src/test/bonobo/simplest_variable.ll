define void @main () {
  entry:
    %x = alloca i64, align 4
    store i64 0, i64* %x, align 4
    ret void
}

