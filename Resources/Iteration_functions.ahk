#Requires AutoHotkey v2.0

range(a, b:=unset, c:=unset) {
   IsSet(b) ? '' : (b := a, a := 0)
   IsSet(c) ? '' : (a < b ? c := 1 : c := -1)

   pos := a < b && c > 0
   neg := a > b && c < 0
   if !(pos || neg)
      throw Error("Invalid range.")

   return (&n) => (
      n := a, a += c,
      (pos && n < b) OR (neg && n > b) 
   )
}

